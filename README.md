# presensi

Ini adalah Aplikasi Presensi yang saya buat menggunakan Flutter Dart.

Pada project ini, saya menggunakan konsep MVC (GetX Framework) untuk penulisan script baik logic (controller), design (view) dan biding (model) secara terpisah. Selain itu saya menggunakan package Geolocator dari pub.dev untuk menjalankan logic GPS presensinya. Secara singkat, user hanya bisa presensi dalam radius tertentu (yang dibatas menggunakan lat dan long). Diluar itu, user tidak bisa presensi.

Project ini saya buat untuk presensi ASN di suatu Pemerintah Daerah, latar belakang dibuatnya aplikasi ini sebenarnya adalah ketidak-efektifan presensi jika menggunakan web, sehingga ada keinginan untuk migrasi dari presensi web ke presensi mobile, yang dimana aplikasi web yang dipakai sebelumnya menggunakan Native PHP dengan database SQL yang disimpan di server lokal. Meskipun aplikasi web tersebut di web-view menjadi app android, tetapi dirasa kurang efektif karena corenya masih web. Maka, dibuatlah aplikasi mobile dengan flutter agar bisa di compile di android dan iOS sekaligus.

Idenya, data 15.000 ASN yang ada di lokal server (sudah dibuat API dari aplikasi web awal) itu akan di masukkan ke Firebase Database menggunakan method POST (dengan bodynya adalah NIP), respon dari POST tersebut akan berformat JSON dengan banyak field didalamnya. Dan selanjutnya, field-field hasil respon JSON tsb dimasukkan kedalam Firebase Database. Caranya, ketika user pertama kali download dan login di mobile app ini, logicnya, login page yg saya buat ini dibuat "bekerja" otomatis untuk sinkronisasi sekaligus login, dengan cara, jika NIP yg diinput == NIP yang ada di API, sistem langsung meminta data JSON ke API, dan data API JSON tsb dimasukkan kedalam Firebase Database dan mendapatkan uid baru serta email password untuk auth.

Karena login di Firebase mengharuskan authentikasi dengan email, maka logicnya saya buat seperti berikut :
    1. Cek NIP dari controller == NIP API,
    2. Jika true, jalankan signInWithEmailAndPassword(), nah disini kuncinya, digunakanlah error handling
    3. Error handling yg dipakai adalah "user-not-found"
    4. Jika user baru pertama kali download, otomatis akan "user-not-found" meskipun langkah no. 1 true, 
        karena nip dari user tsb belum ada di Firebase. 
    5. Lalu, dalam error handling tersebut dijalankan createUserWithEmailAndPassword() dengan idenya 
        email : nipC.text + "@email.go.id"
        password : passC.text ditambah MD5 hash
        Sehingga, firebase akan membaca inputan tersebut sebagai email, bukan string biasa.
        Nah pada tahap function ini pula, dijalankan Url POST untuk mengambil data dari API dan ditampung ke variabel yang selanjutnya variabel tsb akan dipanggil untuk dimasukkan ke firebase
    6. Dengan ide tsb, otomatis email baru dibuat dan flutter mendapat variabel yang isinya respon JSON lalu bekerja utk memasukkan data JSON tsb ke Firebase Database sehingga user tersebut sudah otomatis register tanpa perlu register manual.
    7. Setelah user terdaftar, maka halaman di routing menuju ke HOME
    8. Tahap sinkronisasi selesai, dan user login juga.
    9. Tambahan : jika user sudah pernah login, maka kedepannya jika user login lagi, tahap no. 3 akan false dan langsung otomatis login tanpa register ulang.

Untuk ide selanjutnya, adalah logika untuk presensi. Pada Page Index, dituliskan secara statis lat, long dan radius dari kantor setempatnya berapa. Jika user ada di radius 300m lingkaran, maka bisa presensi, jika diluar, maka tidak bisa presensi.

Lalu, data dari presensi tersebut akan berupa tanggal dan waktu yang dibungkus dalam document "hari", dan disimpan didalam collection yang sama dengan data user yang baru saja di daftarkan. Dan selanjutnya, data presensi di collection tersebut di PUSH ke server lokal untuk disatukan dengan data presensi yang sudah ada sebelumnya.

## Fluter Apps

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
