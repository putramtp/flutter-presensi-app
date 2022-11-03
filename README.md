**Presensi Mobile App with FAKE GPS Detector**

**App Name : SADASBOR**

Pada project ini, saya menggunakan Dart dan Flutter Framework dengan konsep MVC (GetX Framework) untuk penulisan script baik logic (controller), design (view) dan biding (model) secara terpisah. Selain itu saya menggunakan package _Geolocator_ dan _Geocoding_ dari pub.dev untuk menjalankan logic GPS presensinya dan package _Safe Device_ untuk mengatasi permasalahan penggunaan Fake GPS ketika presensi. Secara singkat, user hanya bisa presensi dalam radius tertentu (yang dibatas menggunakan lat dan long). Diluar itu, user tidak bisa presensi.

Project ini saya buat untuk presensi ASN di suatu Pemerintah Daerah, latar belakang dibuatnya aplikasi ini sebenarnya adalah ketidak-efektifan presensi jika menggunakan web, sehingga ada keinginan untuk migrasi dari presensi web ke presensi mobile, yang dimana aplikasi web yang dipakai sebelumnya menggunakan Native PHP dengan database SQL yang disimpan di server lokal. Meskipun aplikasi web tersebut di web-view menjadi app android, tetapi dirasa kurang efektif karena corenya masih web sehingga ketika dihadapkan dalam kondisi serentak (pengisian laporan kinerja bulanan atau kegiatan serentak lain) yang menyebabkan server lokal akan bekerja lebih berat karena seluruh data yang berjalan itu di proses pada server, bukan device masing-masing user. Oleh karena itu, dibuatlah aplikasi mobile dengan flutter ini agar bisa di compile di android dan iOS sekaligus sehingga proses data yang berjalan bisa dilakukan pada device masing-masing dan tidak memberatkan server. Server hanya menerima kembalian data berupa mapping JSON dari aplikasi ini dan memasukannya ke database utama tanpa harus melakukan serangkaian logic didalam server tersebut sekaligus. Adapun metode proses data yang digunakan adalah menggunakan REST API.

Idenya, data 15.000 ASN yang ada di lokal server di proses melalui serangkaian REST API. Data yang dimaksud khususnya data Auth akan di masukkan ke Firebase Database menggunakan method POST (dengan bodynya adalah NIP dan headnya adalah Bearer Token), respon dari POST tersebut akan berformat JSON dengan banyak field didalamnya. Dan selanjutnya, field-field hasil respon JSON tsb dimasukkan kedalam Firebase Database. Caranya, ketika user pertama kali download dan login di mobile app ini, logicnya, login page yg saya buat ini dibuat "bekerja" otomatis untuk sinkronisasi sekaligus login, dengan cara, jika NIP yg diinput == NIP yang ada di API, sistem langsung meminta data JSON ke API, dan data API JSON tsb dimasukkan kedalam Firebase Database dan mendapatkan uid baru serta email password untuk auth.

Karena login di Firebase mengharuskan authentikasi dengan email, maka logicnya saya buat seperti berikut :
1. Cek NIP dari controller == NIP API,
2. Jika true, jalankan `signInWithEmailAndPassword()`, nah disini kuncinya, digunakanlah error handling
3. Error handling yg dipakai adalah `"user-not-found"`
4. Jika user baru pertama kali download, otomatis akan `"user-not-found"` meskipun langkah no. 1 true, 
        karena nip dari user tsb belum ada di Firebase. 
5. Lalu, dalam error handling tersebut dijalankan `createUserWithEmailAndPassword()` dengan idenya 
`email : nipC.text + "@email.go.id"`
`password : passC.text` ditambah MD5 hash
Sehingga, firebase akan membaca inputan tersebut sebagai email, bukan string biasa.
Nah pada tahap function ini pula, dijalankan Url POST untuk mengambil data dari API dan ditampung ke variabel yang selanjutnya variabel tsb akan dipanggil untuk dimasukkan ke firebase
6. Dengan ide tsb, otomatis email baru dibuat dan flutter mendapat variabel yang isinya respon JSON lalu bekerja utk memasukkan data JSON tsb ke Firebase Database sehingga user tersebut sudah otomatis register tanpa perlu register manual.
7. Setelah user terdaftar, maka halaman di routing menuju ke HOME
8. Tahap sinkronisasi selesai, dan user login juga.
9. Tambahan : jika user sudah pernah login, maka kedepannya jika user login lagi, tahap no. 3 akan false dan langsung otomatis login tanpa register ulang.

Untuk ide selanjutnya, adalah logika untuk presensi. Pada Page Index, dituliskan secara statis lat, long dan radius dari kantor setempatnya berapa. Jika user ada di radius 300 m lingkaran, maka bisa presensi, jika diluar, maka tidak bisa presensi.

Lalu, data dari presensi tersebut akan berupa tanggal dan waktu yang dibungkus dalam document "hari", dan disimpan didalam collection yang sama dengan data user yang baru saja di daftarkan. Dan selanjutnya, data presensi di collection tersebut di PUSH ke server lokal untuk disatukan dengan data presensi yang sudah ada sebelumnya.

Selain fitur Presensi Datang dan Presensi Pulang, pada aplikasi ini saya buat pula fitur Dinas Luar dan Pengajuan Sakit. 

Untuk Dinas Luar, idenya adalah user dapat melakukan presensi Dinas Luar di suatu tempat sesuai dengan surat tugas yang diterima. Logicnya, jika user sudah berada ditempat tugas tujuan, aplikasi akan mendeteksi secara akurat Latitude dan Longitude dari device tersebut apakah sesuai dengan koordinat tempat yang ditugaskan atau tidak. Jika sesuai, maka dapat mengisi presensi Dinas Luar tersebut. 

Untuk Pengajuan Sakit, sama halnya seperti Dinas Luar. Aplikasi akan membaca latitude dan longitude pengguna ketika mengajukan izin sakit. Meskipun tidak masalah apabila user melakukan presensi dimanapun, tetapi pada fitur ini, koordinat tetap dipakai.



**Logic Block Fake GPS**

Package yang dipakai untuk block Fake GPS atau Mock Location lain adalah _Safe Device 1.1.1. Package_ (https://pub.dev/packages/safe_device), yang saya implementasikan pada halaman Login dan button Presensi, dengan sintaks : 

`bool canMockLocation = await SafeDevice.canMockLocation;` // untuk check Mock Location apakah aktif atau tidak

`bool isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;` // untuk check Developer Mode apakah aktif atau tidak

Idenya, hampir seluruh aplikasi Mock Location pasti mengharuskan user untuk menyalakan fitur Developer Mode pada devicenya sebagai syarat agar aplikasi dapat berjalan. Oleh karena itu, aplikasi ini dibuat agar bisa mendeteksi "lebih dalam" karena aplikasi ini akan bekerja 2 kali, yaitu cek apakah aplikasi Mock Location itu sedang berjalan atau tidak, dan juga cek apakah Developer Mode pada device user itu sedang aktif atau tidak. Jika salah satu aktif, maka kembalian nilai akan tetap "true" dan aplikasi akan mengeluarkan pop-up "Fake GPS Terdeteksi" dan menghimbau user untuk keluar dari aplikasi dan mematikan aplikasi mock location tersebut sebelum melakukan presensi. Jika mock location tetap aktif dan developer mode masih aktif, maka user tidak dapat presensi sama sekali.


**Minimum System Requirements**

SADASBOR for Android app is available for phones running Android OS versions 7.0. (Nougat) and above. 
Note: We no longer support older versions of SADASBOR for Android.


## Fluter Apps

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
