import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:http/http.dart' as http;

class DetailPresensiController extends GetxController {
  RxInt pageIndex = 0.obs;
  RxBool isLoading = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamTodayPresence() async* {
    String uid = auth.currentUser!.uid;

    String todayID =
        DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");

    yield* firestore
        .collection("user")
        .doc(uid)
        .collection("presence")
        .doc(todayID)
        .snapshots();
  }

  Future<void> postSync() async {
    try {
      var response = await http.get(Uri.https("kinerja.tasikmalayakab.go.id"));
      print(response.statusCode);
      if (response.statusCode == 200) {
        Get.snackbar("Berhasil", "API Sadasbor Aktif.");
        print("Sync Berjalan...");

        final Map<String, dynamic> data = Get.arguments;
        String uid = await auth.currentUser!.uid;
        String uid5 = "T4OsQQOmPoJRjL9lb3j4";
        String uid6 = "HWRtoazzwa1qcgTpSDmc";

        // API DateTime GMT +07:00
        var myResponse = await http.get(
          Uri.parse(
              "https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta"),
        );

        Map<String, dynamic> data2 = json.decode(myResponse.body);

        // print(data);
        // print(myResponse.body);

        var dateTimeAPI = data2['dateTime'];

        DateTime dateTimeGMT = DateTime.parse(dateTimeAPI);

        print(dateTimeGMT);

        // API DateTime GMT +07:00 - End

        final nipSession = await firestore.collection("user").doc(uid).get();
        final nipRule5 = await firestore.collection("rule").doc(uid5).get();
        final nipRule6 = await firestore.collection("rule").doc(uid6).get();

        CollectionReference<Map<String, dynamic>> colPresence =
            firestore.collection("user").doc(uid).collection("presence");
        QuerySnapshot<Map<String, dynamic>> snapPresence =
            await colPresence.get();
        print(snapPresence.docs.length);
        print("Check Length");

        DateTime now = DateTime.parse(data['date']);
        String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");
        DocumentSnapshot<Map<String, dynamic>> todayDoc =
            await colPresence.doc(todayDocID).get();

        print(now);
        print("Tanggal diatas adalah hasil interpolasi dari firestore");

        colPresence.doc(todayDocID).set({
          "date": data['date'],
          "sync": "Y",
          "datang": {
            "date": data['datang']['date'],
            "lat": data['datang']!['lat'],
            "long": data['datang']!['long'],
            "alamat": data['datang']!['alamat'],
            "status": data['datang']!['status'],
            "distance": data['datang']!['distance'].toString().split(".").first,
          },
          "pulang": {
            "date": data['pulang']['date'],
            "lat": data['pulang']!['lat'],
            "long": data['pulang']!['long'],
            "alamat": data['pulang']!['alamat'],
            "status": data['pulang']!['status'],
            "distance": data['pulang']!['distance'].toString().split(".").first,
          },
        });
        Get.back();

        String datangPresence =
            data['datang']['date']; //Interpolasi dari Firestore
        String pulangPresence =
            data['pulang']['date']; //Interpolasi dari Firestore
        DateTime tanggalSyncFinalAPI = DateTime.parse(data['date']);
        // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

        var parsedDatangPresence = DateTime.parse(
            datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
        var parsedPulangPresence = DateTime.parse(
            pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

        // print(parsedDatangPresence);
        // print(parsedPulangPresence);

        // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase //
        String j2 = nipSession['j2'];
        String j3 = nipSession['j3'];
        // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase - end //

        // SYNC 5 HARI KERJA
        // TAMBAHAN BULAN PUASA JAM 14:15:00
        if (j2 == '15:45:00' || j2 == '14:15:00') {
          print("Sync 5 Hari Kerja Aktif");
          String hariSekarang = DateFormat("EEE").format(now);
          print(hariSekarang);

          //interpolasi baru pakai RULE
          String j1n = nipRule5['j1'];
          String j2n = nipRule5['j2'];
          String j3n = nipRule5['j3'];

          print(j1n);
          print(j2n);
          print(j3n);

          cekHari(String hari) {
            String b;
            if (hari == 'Fri') {
              return b = j3n;
            } else {
              return b = j2n;
            }
          }

          String jp = cekHari(hariSekarang);

          final arr = jp.split(':');

          // print(arr[0]);
          // print(arr[1]);

          String jam2 = arr[0];
          String menit2 = arr[1];

          // LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI //

          // Inputan Presensi //
          DateTime jamDatangC = parsedDatangPresence;
          DateTime jamPulangC = parsedPulangPresence;
          // Inputen Presensi - End//

          String jamd = DateFormat.Hms().format(jamDatangC);
          String jamp = DateFormat.Hms().format(jamPulangC);

          print(jamd);
          print(jamp);

          DateTime jam =
              DateTime(now.year, now.month, now.day, 8, 15, 1); // test
          // DateTime PJ1 = DateTime(
          //     now.year, now.month, now.day, 7, 45, 0); // Patokan jam masuk //

          //PATOKAN JAM MASUK DARI RULE
          print("PATOKAN JAM MASUK");

          DateTime PJ1Tahun =
              DateTime(dateTimeGMT.year, dateTimeGMT.month, dateTimeGMT.day);
          print(PJ1Tahun);

          String j1n0 = j1n + ".000";

          String PJ1Merge =
              PJ1Tahun.toIso8601String().replaceAll("00:00:00.000", "") + j1n0;
          // print(PJ1Merge);

          DateTime PJ1 = DateTime.parse(PJ1Merge);
          print(PJ1);

          //PATOKAN JAM MASUK DARI RULE

          DateTime jam1 =
              DateTime(now.year, now.month, now.day, 15, 46, 0); // test
          DateTime PJ2 = DateTime(now.year, now.month, now.day, int.parse(jam2),
              int.parse(menit2), 0); // Patokan jam pulang //

          // strtotime - Convert DateTime to millisecond //
          int jamDatangStr = jamDatangC.millisecondsSinceEpoch;
          int jamPulangStr = jamPulangC.millisecondsSinceEpoch;
          int datang = PJ1.millisecondsSinceEpoch;
          int pulang = PJ2.millisecondsSinceEpoch;
          // strtotime - Convert DateTime to millisecond - end //

          // Logic Status Jam //
          double hasil = (jamDatangStr - datang) / 60000;
          int ddat = hasil.ceil();

          double hasil2 = (pulang - jamPulangStr) / 60000;
          int dpul = hasil2.ceil();

          print(ddat);
          // print(jamd);
          // print(datang);
          // print(hasil);
          print(dpul);

          cekStatusDatang(int d) {
            String statusd;
            if (d <= 0) {
              return statusd = "Tepat Waktu";
            } else if (d >= 1 && d <= 30) {
              return statusd = "TL1";
            } else if (d >= 31 && d <= 60) {
              return statusd = "TL2";
            } else if (d >= 61 && d <= 90) {
              return statusd = "TL3";
            } else if (d >= 91) {
              return statusd = "TL4";
            }
          }

          cekStatusPulang(int p) {
            String statusp;
            if (p < 1) {
              return statusp = "Sesuai Waktu";
            } else if (p >= 1 && p <= 30) {
              return statusp = "PSW1";
            } else if (p >= 31 && p <= 60) {
              return statusp = "PSW2";
            } else if (p >= 61 && p <= 90) {
              return statusp = "PSW3";
            } else if (p >= 91) {
              return statusp = "PSW4";
            }
          }

          // Cetak Status Datang //
          String? sd = cekStatusDatang(ddat);
          print(sd);

          // Cetak Status Pulang //
          String? sp = cekStatusPulang(dpul);
          print(sp);

          //Kondisi TL1 menjadi Dispensasi
          if (sd == "TL1") {
            double a = (jamPulangStr - jamDatangStr) / 60000;
            double b = (pulang - datang) / 60000;

            if (a >= b) {
              sd = "Dispensasi";
              print(sd);
              print("dispen");
            }
          }

          // LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI - End //

          //// POST DATA PULANG KE API ABSENSI ////
          if (todayDoc.exists == true) {
            Get.snackbar(
              "Mohon Tunggu",
              "Sinkronisasi ulang sedang diproses...",
              duration: const Duration(seconds: 10),
            );

            var myResponse = await http.post(
                Uri.parse("https://kinerja.tasikmalayakab.go.id/api/presensi"),
                headers: {
                  HttpHeaders.authorizationHeader:
                      'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
                },
                body: {
                  "nip": nipSession['nip'],
                  "tanggal":
                      DateFormat("yyyy-MM-dd").format(tanggalSyncFinalAPI),
                  "sd": sd,
                  "sp": sp,
                  "id_th": "1",
                  "jamd": DateFormat.Hms().format(jamDatangC),
                  "jamp": DateFormat.Hms().format(jamPulangC),
                });

            Map<String, dynamic> data =
                json.decode(myResponse.body) as Map<String, dynamic>;
            print(myResponse.body);
            print("aaaa");

            Get.back();
            Get.back();
            isLoading.value = false;

            if (data['status'] == "success") {
              await colPresence.doc(todayDocID).update({
                "sync": "Y",
              });
              Get.snackbar(
                "Sukses!",
                "Sinkronisasi Ulang Presensi Anda Sudah Berhasil.",
                duration: const Duration(seconds: 5),
              );
              Get.offNamed(Routes.HOME);
              print("Data Pulang (5) Berhasil Masuk ke API, Sync Berhasil");
            } else {
              await colPresence.doc(todayDocID).update({
                "sync": "N",
              });
              Get.snackbar(
                "Terjadi Gangguan Server (N)",
                "Data Presensi Anda Gagal Sinkronisasi. Silahkan Coba Lain Waktu.",
                duration: const Duration(seconds: 8),
              );
            }
          } else {
            Get.snackbar(
              "Terjadi Gangguan Server",
              "Data Presensi Anda Gagal Sinkronisasi. Silahkan Coba Lain Waktu.",
              duration: const Duration(seconds: 8),
            );
            print("Data Pulang Gagal Terupdate, Coba Kembali");
            Get.offAllNamed(Routes.HOME);
            isLoading.value = false;
          }
        }
        // SYNC 5 HARI KERJA END

        // SYNC 6 HARI KERJA
        // TAMBAHAN BULAN PUASA JAM 13:15:00
        else if (j2 == '14:30:00' || j2 == '13:15:00') {
          print("Sync 6 Hari Kerja Aktif");
          String hariSekarang = DateFormat("EEE").format(now);
          print(hariSekarang);

          //interpolasi baru pakai RULE
          String j1n = nipRule6['j1'];
          String j2n = nipRule6['j2'];
          String j3n = nipRule6['j3'];

          print(j1n);
          print(j2n);
          print(j3n);

          cekHari(String hari) {
            String b;
            if (hari == 'Fri') {
              return b = j3n;
            } else {
              return b = j2n;
            }
          }

          String jp = cekHari(hariSekarang);

          final arr = jp.split(':');

          // print(arr[0]);
          // print(arr[1]);

          String jam2 = arr[0];
          String menit2 = arr[1];

          // LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI //

          // Inputan Presensi //
          DateTime jamDatangC = parsedDatangPresence;
          DateTime jamPulangC = parsedPulangPresence;
          // Inputen Presensi - End//

          String jamd = DateFormat.Hms().format(jamDatangC);
          String jamp = DateFormat.Hms().format(jamPulangC);

          print(jamd);
          print(jamp);

          DateTime jam =
              DateTime(now.year, now.month, now.day, 8, 15, 1); // test
          // DateTime PJ1 = DateTime(
          //     now.year, now.month, now.day, 7, 45, 0); // Patokan jam masuk //

          //PATOKAN JAM MASUK DARI RULE
          print("PATOKAN JAM MASUK");

          DateTime PJ1Tahun =
              DateTime(dateTimeGMT.year, dateTimeGMT.month, dateTimeGMT.day);
          print(PJ1Tahun);

          String j1n0 = j1n + ".000";

          String PJ1Merge =
              PJ1Tahun.toIso8601String().replaceAll("00:00:00.000", "") + j1n0;
          // print(PJ1Merge);

          DateTime PJ1 = DateTime.parse(PJ1Merge);
          print(PJ1);

          //PATOKAN JAM MASUK DARI RULE

          DateTime jam1 =
              DateTime(now.year, now.month, now.day, 15, 46, 0); // test
          DateTime PJ2 = DateTime(now.year, now.month, now.day, int.parse(jam2),
              int.parse(menit2), 0); // Patokan jam pulang //

          // strtotime - Convert DateTime to millisecond //
          int jamDatangStr = jamDatangC.millisecondsSinceEpoch;
          int jamPulangStr = jamPulangC.millisecondsSinceEpoch;
          int datang = PJ1.millisecondsSinceEpoch;
          int pulang = PJ2.millisecondsSinceEpoch;
          // strtotime - Convert DateTime to millisecond - end //

          // Logic Status Jam //
          double hasil = (jamDatangStr - datang) / 60000;
          int ddat = hasil.ceil();

          double hasil2 = (pulang - jamPulangStr) / 60000;
          int dpul = hasil2.ceil();

          print(ddat);
          // print(jamd);
          // print(datang);
          // print(hasil);
          print(dpul);

          cekStatusDatang(int d) {
            String statusd;
            if (d <= 0) {
              return statusd = "Tepat Waktu";
            } else if (d >= 1 && d <= 30) {
              return statusd = "TL1";
            } else if (d >= 31 && d <= 60) {
              return statusd = "TL2";
            } else if (d >= 61 && d <= 90) {
              return statusd = "TL3";
            } else if (d >= 91) {
              return statusd = "TL4";
            }
          }

          cekStatusPulang(int p) {
            String statusp;
            if (p < 1) {
              return statusp = "Sesuai Waktu";
            } else if (p >= 1 && p <= 30) {
              return statusp = "PSW1";
            } else if (p >= 31 && p <= 60) {
              return statusp = "PSW2";
            } else if (p >= 61 && p <= 90) {
              return statusp = "PSW3";
            } else if (p >= 91) {
              return statusp = "PSW4";
            }
          }

          // Cetak Status Datang //
          String? sd = cekStatusDatang(ddat);
          print(sd);

          // Cetak Status Pulang //
          String? sp = cekStatusPulang(dpul);
          print(sp);

          //Kondisi TL1 menjadi Dispensasi
          if (sd == "TL1") {
            double a = (jamPulangStr - jamDatangStr) / 60000;
            double b = (pulang - datang) / 60000;

            if (a >= b) {
              sd = "Dispensasi";
              print(sd);
              print("dispen");
            }
          }

          // LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI - End //

          //// POST DATA PULANG KE API ABSENSI ////
          if (todayDoc.exists == true) {
            Get.snackbar(
              "Mohon Tunggu",
              "Sinkronisasi ulang sedang diproses...",
              duration: const Duration(seconds: 10),
            );

            var myResponse = await http.post(
                Uri.parse("https://kinerja.tasikmalayakab.go.id/api/presensi"),
                headers: {
                  HttpHeaders.authorizationHeader:
                      'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
                },
                body: {
                  "nip": nipSession['nip'],
                  "tanggal":
                      DateFormat("yyyy-MM-dd").format(tanggalSyncFinalAPI),
                  "sd": sd,
                  "sp": sp,
                  "id_th": "1",
                  "jamd": DateFormat.Hms().format(jamDatangC),
                  "jamp": DateFormat.Hms().format(jamPulangC),
                });

            Map<String, dynamic> data =
                json.decode(myResponse.body) as Map<String, dynamic>;
            print(myResponse.body);
            print("aaaa");

            Get.back();
            Get.back();
            isLoading.value = false;

            if (data['status'] == "success") {
              await colPresence.doc(todayDocID).update({
                "sync": "Y",
              });
              Get.snackbar(
                "Sukses!",
                "Sinkronisasi Ulang Presensi Anda Sudah Berhasil.",
                duration: const Duration(seconds: 5),
              );
              Get.offNamed(Routes.HOME);
              print("Data Pulang (6) Berhasil Masuk ke API, Sync Berhasil");
            } else {
              await colPresence.doc(todayDocID).update({
                "sync": "N",
              });
              Get.snackbar(
                "Terjadi Gangguan Server (N)",
                "Data Presensi Anda Gagal Sinkronisasi. Silahkan Coba Lain Waktu.",
                duration: const Duration(seconds: 8),
              );
            }
          } else {
            Get.snackbar(
              "Terjadi Gangguan Server",
              "Data Presensi Anda Gagal Sinkronisasi. Silahkan Coba Lain Waktu.",
              duration: const Duration(seconds: 8),
            );
            print("Data Pulang Gagal Terupdate, Coba Kembali");
            Get.offAllNamed(Routes.HOME);
            isLoading.value = false;
          }
        }
        // SYNC 6 HARI KERJA END
      }
    } catch (e) {
      Get.snackbar("Terjadi Kesalahan",
          "Server Sadasbor Tidak Dapat Dijangkau. Harap Menunggu Hingga Server Normal Kembali.");
    }
  }
}
