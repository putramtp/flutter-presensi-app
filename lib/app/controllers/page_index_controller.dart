import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:safe_device/safe_device.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;
  RxBool isLoading = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(
        "https://play.google.com/store/apps/details?id=com.msaiflanwr.presensi");

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Tidak bisa membuka url";
    }
  }

  void changePage(int i) async {
    final User user = auth.currentUser!;
    final uid = user.uid;

    // API DateTime GMT +07:00
    var myResponse = await http.get(
      Uri.parse(
          "https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta"),
    );

    Map<String, dynamic> data = json.decode(myResponse.body);

    // print(data);
    // print(myResponse.body);

    var dateTimeAPI = data['dateTime'];

    DateTime dateTimeGMT = DateTime.parse(dateTimeAPI);

    print(dateTimeGMT);

    // API DateTime GMT +07:00 - End

    String hariIni = DateFormat("EEE").format(dateTimeGMT);
    print(hariIni);
    String tanggalHariIni = DateFormat("d").format(dateTimeGMT);
    print(tanggalHariIni);

    //
    final nipSession = await firestore.collection("user").doc(uid).get();

    pageIndex.value = i;
    switch (i) {
      case 2:
        print("ABSENSI");
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse["error"] != true) {
          Position position = dataResponse["position"];

          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          // print(placemarks[0]);
          String alamat =
              "${placemarks[0].street} , ${placemarks[0].subLocality} , ${placemarks[0].locality} , ${placemarks[0].subAdministrativeArea}";
          await updatePosition(position, alamat);

          // ABSEN HARI SENIN atau TANGGAL 17 di SETDA
          if (hariIni == 'Mon' || tanggalHariIni == '17') {
            print("Absen di Setda Aktif");
            //cek distance between 2 koordinat / 2 posisi
            double distance2 = Geolocator.distanceBetween(
                // rev distance
                -7.361053, //SETDA
                108.1127393, //SETDA
                // -7.308180376093359, // SB
                // 108.20877916637005, // SB
                position.latitude,
                position.longitude);
            print("ini lokasi setda");

            double distance = Geolocator.distanceBetween(
                // -7.361053,
                // 108.1127393,
                double.parse(nipSession['lat']),
                double.parse(nipSession['long']),
                position.latitude,
                position.longitude);

            //block fakeGPS atau mocklocation yang aktif lewat Developer Options pada hari Senin/Tanggal 17
            bool isDevelopmentModeEnable =
                await SafeDevice.isDevelopmentModeEnable;
            print(isDevelopmentModeEnable);

            if (isDevelopmentModeEnable == false) {
              //false (asli apk), true (debug)
              await presensi(position, alamat, distance, distance2);
            } else {
              await presensiDetect();
            }
            // ABSEN HARI SENIN atau TANGGAL 17 di SETDA - End

            // ABSEN DENGAN LAT LONG MASING-MASING
          } else {
            print("Absen lokasi masing-masing aktif");
            //cek distance between 2 koordinat / 2 posisi
            double distance = Geolocator.distanceBetween(
                // -7.361053,
                // 108.1127393,
                double.parse(nipSession['lat']),
                double.parse(nipSession['long']),
                position.latitude,
                position.longitude);

            double distance2 = Geolocator.distanceBetween(
                //double check untuk kebutuhan function // rev distance
                // -7.361053,
                // 108.1127393,
                double.parse(nipSession['lat']),
                double.parse(nipSession['long']),
                position.latitude,
                position.longitude);

            //block fakeGPS atau mocklocation yang aktif lewat Developer Options pada hari Normal
            bool isDevelopmentModeEnable =
                await SafeDevice.isDevelopmentModeEnable;
            print(isDevelopmentModeEnable);

            if (isDevelopmentModeEnable == false) {
              //false (asli apk), true (debug)
              await presensi(position, alamat, distance, distance2);
            } else {
              await presensiDetect();
            }
          }
          //absen

          // Get.snackbar("Berhasil", "Anda berhasil mengisi daftar hadir");

          Get.snackbar("${dataResponse['message']}", alamat);
        } else {
          Get.snackbar("Terjadi Kesalahan", dataResponse["message"]);
        }
        break;
      case 1:
        pageIndex.value = i;
        Get.offAllNamed(Routes.WORKFROMHOME);
        break;
      case 3:
        pageIndex.value = i;
        Get.offAllNamed(Routes.DINASLUAR);
        break;
      case 4:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presensiDetect() async {
    Get.snackbar(
      "Fake GPS Terdeteksi!",
      "Mohon matikan aplikasi Fake GPS Anda sebelum melakukan presensi.",
      duration: const Duration(seconds: 6),
    );
    await Get.defaultDialog(
        titlePadding: EdgeInsets.only(top: 22),
        backgroundColor: Color.fromARGB(255, 255, 229, 229),
        title: "Developer Options\nHP Anda Aktif!",
        titleStyle: GoogleFonts.poppins(
            color: Color.fromARGB(255, 168, 7, 7),
            fontSize: 18,
            fontWeight: FontWeight.w800),
        contentPadding:
            EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 12),
        middleText:
            "Silahkan matikan Developer Options/Opsi Pengembang pada Pengaturan device Anda, lalu keluar dari aplikasi ini dan coba masuk kembali.",
        middleTextStyle: GoogleFonts.poppins(
            color: Color.fromARGB(255, 168, 7, 7),
            fontSize: 11,
            fontWeight: FontWeight.w400),
        actions: [
          ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 168, 7, 7),
              ),
              onPressed: () => Get.back(),
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                    color: Color(0xffFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              )),
        ]);
  }

  Future<void> presensi(Position position, String alamat, double distance,
      double distance2) async {
    final User user = auth.currentUser!;
    final uid = user.uid;
    // API DateTime GMT +07:00
    var myResponse = await http.get(
      Uri.parse(
          "https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta"),
    );

    Map<String, dynamic> data = json.decode(myResponse.body);

    // print(data);
    // print(myResponse.body);

    var dateTimeAPI = data['dateTime'];

    DateTime dateTimeGMT = DateTime.parse(dateTimeAPI);

    print(dateTimeGMT);

    // API DateTime GMT +07:00 - End

    // LOGIC LIBUR (BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/)

    String hariIni = DateFormat("EEE").format(dateTimeGMT);
    print(hariIni);

    String liburId = DateFormat("yMd").format(dateTimeGMT).replaceAll("/", "-");

    String uid5 = "T4OsQQOmPoJRjL9lb3j4";
    String uid6 = "HWRtoazzwa1qcgTpSDmc";
    String uidUpdate = "0zeDozFCHGFxXSwkZNZq";
    // 10-30-2022 BHT

    final liburSession = await firestore.collection("libur").doc(liburId).get();
    final nipSession = await firestore.collection("user").doc(uid).get();
    final nipRule5 = await firestore.collection("rule").doc(uid5).get();
    final nipRule6 = await firestore.collection("rule").doc(uid6).get();
    final versionUpdate =
        await firestore.collection("version").doc(uidUpdate).get();

    //interpolasi 5 dan 6 hari kerja
    String j2 = nipSession['j2'];
    String j3 = nipSession['j3'];

    // CEK VERSION UPDATE
    String versionName = versionUpdate['version_name'];

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String thisVersion = packageInfo.version;

    print("dibawah ini adalah versi aplikasi saat ini");
    print(thisVersion);

    print("dibawah ini adalah versi aplikasi dalam firebase");
    print(versionName);

    if (versionName != thisVersion) {
      print("versi tidak sesuai, update aplikasi anda");
      Get.snackbar("Update Versi Terbaru",
          "Versi terbaru sudah tersedia, silahkan update.");

      Get.dialog(AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(0, 42, 0, 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10,
            ),
            Image.asset(
              'assets/sadasbor-update-version.png',
              width: 187,
            ),
            SizedBox(
              height: 22,
            ),
            Text(
              'VERSI BARU TERSEDIA!',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff009b4c)),
            ),
            SizedBox(
              height: 6,
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: 'Versi Sadasbor Mobile terbaru sudah tersedia. ',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Color(0xff333333)),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Update',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w800)),
                        TextSpan(text: ' terlebih dahulu untuk melanjutkan.')
                      ])),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      try {
                        Get.back();
                        _launchURL(
                            "https://play.google.com/store/apps/details?id=com.msaiflanwr.presensi");
                      } catch (e) {
                        Get.back();
                        await Get.snackbar("Error", e.toString(),
                            duration: Duration(seconds: 5));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(122, 42),
                        backgroundColor: Color(0xff009b4c),
                        foregroundColor: Color(0xffF7FAFC),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    child: Text(
                      'UPDATE',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    )),
              ],
            ),
          )
        ],
      ));
    } else {
      print("versi sesuai, tidak perlu update");
      // Get.snackbar("Versi sesuai", "Lanjut");
      // END - CEK VERSION UPDATE

      // KONDISI 5 HARI KERJA (5HARIKERJA/5HARIKERJA/5HARIKERJA/5HARIKERJA/5HARIKERJA/)
      // TAMBAHAN BULAN PUASA JAM 14:15:00
      if (j2 == '15:45:00' || j2 == '14:15:00') {
        print("5 Hari Kerja Aktif"); // 5 HARI KERJA

        //interpolasi baru pakai RULE
        String j1n = nipRule5['j1'];
        String j2n = nipRule5['j2'];
        String j3n = nipRule5['j3'];

        print(j1n);
        print(j2n);
        print(j3n);
        print(liburId);
        print(liburSession.exists);

        if (hariIni == 'Sat' ||
            hariIni == 'Sun' ||
            liburSession.exists == true) {
          print("Libur Aktif");
          Get.defaultDialog(
              titlePadding: EdgeInsets.only(top: 22),
              title: "Hari Ini Hari Libur",
              titleStyle: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: EdgeInsets.all(16),
              middleText: liburSession.exists == false
                  ? "Menu Presensi Akan Aktif Kembali Pada Hari Kerja."
                  : "Bertepatan dengan Libur ${liburSession['nama_libur']}, menu presensi akan aktif kembali pada hari kerja selanjutnya.",
              middleTextStyle: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w400),
              actions: [
                ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xffFFC107),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      "OK",
                      style: GoogleFonts.poppins(
                          color: Color(0xff333333),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )),
              ]);
          // LOGIC LIBUR (BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/)
        } else {
          String uid = await auth.currentUser!.uid;

          CollectionReference<Map<String, dynamic>> colPresence =
              firestore.collection("user").doc(uid).collection("presence");
          QuerySnapshot<Map<String, dynamic>> snapPresence =
              await colPresence.get();
          print(snapPresence.docs.length);
          print("Check Length");

          DateTime now = dateTimeGMT;
          String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

          final nipSession = await firestore.collection("user").doc(uid).get();

          DocumentSnapshot<Map<String, dynamic>> todayDoc =
              await colPresence.doc(todayDocID).get();
          Map<String, dynamic>? dataPresenceToday = todayDoc.data();

          String status = "Di Luar Area";

          if (distance <= 500 || distance2 <= 500) {
            // rev distance
            status = "Di Dalam Area";
            double jarak = distance <= 500 ? distance : distance2;

            print("Jarak Terdekat adalah : ");
            print(jarak);

            if (snapPresence.docs.length == 0) {
              //null - belum pernah absen & set absen datang
              SizedBox(
                height: 5,
              );
              await Get.defaultDialog(
                  title: "Validasi Presensi",
                  titleStyle: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  titlePadding: EdgeInsets.only(top: 24, bottom: 2),
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  middleText:
                      "Apakah Anda yakin ingin mengisi Presensi Datang sekarang?",
                  middleTextStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w400),
                  actions: [
                    OutlinedButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Batalkan",
                          style: GoogleFonts.poppins(
                            color: Color(0xff333333),
                            fontSize: 12,
                          ),
                        )),
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xffFFC107),
                      ),
                      onPressed: () async {
                        await colPresence.doc(todayDocID).set({
                          "date": dateTimeGMT.toIso8601String(),
                          "sync": "N",
                          "datang": {
                            "date": dateTimeGMT.toIso8601String(),
                            "lat": position.latitude,
                            "long": position.longitude,
                            "alamat": alamat,
                            "status": status,
                            "distance": jarak,
                            // rev distance
                          },
                          "pulang": {
                            "date": dateTimeGMT.toIso8601String(),
                            "lat": position.latitude,
                            "long": position.longitude,
                            "alamat": alamat,
                            "status": status,
                            "distance": jarak,
                            // rev distance
                          },
                        });
                        Get.back();
                        Get.snackbar("Berhasil!",
                            "Anda berhasil mengisi Presensi Datang.");

                        DocumentSnapshot<Map<String, dynamic>>
                            todayDocPresence =
                            await colPresence.doc(todayDocID).get();

                        String jamDatangFb = todayDocPresence['datang']['date'];
                        String jamPulangFb = todayDocPresence['pulang']['date'];
                        var jamDatangFirebase = DateTime.parse(jamDatangFb);
                        var jamPulangFirebase = DateTime.parse(jamPulangFb);

                        // String datangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                        // String pulangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                        // // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

                        // var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
                        // var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

                        // print(parsedDatangPresence);
                        // print(parsedPulangPresence);

                        // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase //
                        String j2 = nipSession['j2']; //Pukul 15.45
                        String j3 = nipSession['j3']; //Pukul 16.15
                        // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase - end //

                        // String sekarang = DateFormat("EEE").format(DateTime(2022, 10, 15));
                        String hariSekarang = DateFormat("EEE").format(now);
                        print(hariSekarang);

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
                        DateTime jamDatangC = jamDatangFirebase;
                        DateTime jamPulangC = jamPulangFirebase;
                        // Inputen Presensi - End//

                        String jamd = DateFormat.Hms().format(jamDatangC);
                        String jamp = DateFormat.Hms().format(jamPulangC);

                        print(jamd);
                        print(jamp);

                        DateTime jam = DateTime(
                            dateTimeGMT.year,
                            dateTimeGMT.month,
                            dateTimeGMT.day,
                            8,
                            15,
                            1); // test

                        // DateTime PJ1 = DateTime(
                        //     dateTimeGMT.year,
                        //     dateTimeGMT.month,
                        //     dateTimeGMT.day,
                        //     7,
                        //     45,
                        //     0);

                        //PATOKAN JAM MASUK DARI RULE
                        print("PATOKAN JAM MASUK");

                        DateTime PJ1Tahun = DateTime(dateTimeGMT.year,
                            dateTimeGMT.month, dateTimeGMT.day);
                        print(PJ1Tahun);

                        String j1n0 = j1n + ".000";

                        String PJ1Merge = PJ1Tahun.toIso8601String()
                                .replaceAll("00:00:00.000", "") +
                            j1n0;
                        // print(PJ1Merge);

                        DateTime PJ1 = DateTime.parse(PJ1Merge);
                        print(PJ1);

                        //PATOKAN JAM MASUK DARI RULE

                        DateTime jam1 = DateTime(
                            dateTimeGMT.year,
                            dateTimeGMT.month,
                            dateTimeGMT.day,
                            15,
                            46,
                            0); // test
                        DateTime PJ2 = DateTime(
                            dateTimeGMT.year,
                            dateTimeGMT.month,
                            dateTimeGMT.day,
                            int.parse(jam2),
                            int.parse(menit2),
                            0); // Patokan jam pulang //

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

                        // print(ddat);
                        // print(jamd);
                        // print(datang);
                        // print(hasil);
                        // // print(dpul);

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

                        // LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI - End //

                        //// POST DATA DATANG KE API ABSENSI ////
                        if (sd != null && sp != null) {
                          Get.snackbar(
                              "Mohon Tunggu", "Data sedang diproses...");
                          // var myResponse = await http.post(
                          //     Uri.parse(
                          //         "https://apisadasbor.tasikmalayakab.go.id/api/absensi"),
                          //     headers: {
                          //       HttpHeaders.authorizationHeader:
                          //           'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                          //     },
                          //     body: {
                          //       "nip": nipSession['nip'],
                          //       "tanggal": DateFormat("yyyy-MM-dd").format(now),
                          //       "sd": sd,
                          //       "sp": sp,
                          //       "id_th": "1",
                          //       "jamd":
                          //           DateFormat.Hms().format(jamDatangFirebase),
                          //       "jamp":
                          //           DateFormat.Hms().format(jamPulangFirebase),
                          //     });
                          var myResponse = await http.post(
                              Uri.parse(
                                  "https://kinerja.tasikmalayakab.go.id/api/presensi"),
                              headers: {
                                HttpHeaders.authorizationHeader:
                                    'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
                              },
                              body: {
                                "nip": nipSession['nip'],
                                "tanggal": DateFormat("yyyy-MM-dd").format(now),
                                "sd": sd,
                                "sp": sp,
                                "id_th": "1",
                                "jamd":
                                    DateFormat.Hms().format(jamDatangFirebase),
                                "jamp":
                                    DateFormat.Hms().format(jamPulangFirebase),
                              });

                          Map<String, dynamic> data = json
                              .decode(myResponse.body) as Map<String, dynamic>;
                          print(myResponse.body);

                          Get.back();
                          Get.back();
                          Get.snackbar(
                              "Sukses!", "Data Datang Berhasil Masuk ke API.");
                          print("Data Datang Berhasil Masuk ke API");
                          isLoading.value = false;

                          if (data['status'] == "success") {
                            await colPresence.doc(todayDocID).update({
                              "sync": "Y",
                            });
                          } else {
                            await colPresence.doc(todayDocID).update({
                              "sync": "N",
                            });
                            Get.snackbar("Terjadi Gangguan Server",
                                "Data Datang Sukses, Tetapi Belum Sinkron Dengan API Server. Silahkan Coba Lain Waktu.");
                          }
                        } else {
                          Get.snackbar("Gagal",
                              "Data Datang Gagal Masuk ke API. Silahkan coba kembali.");
                          print("Data Datang Gagal Terupdate, Coba Kembali");
                          Get.offAllNamed(Routes.HOME);
                          isLoading.value = false;
                        }
                        //// POST DATA DATANG KE API ABSENSI - end ////
                      },
                      child: Text(
                        "Presensi",
                        style: GoogleFonts.poppins(
                            color: Color(0xff333333),
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ]);
            } else {
              //sudah pernah absen, cek hari ini udah absen datang atau pulang udah belum?
              //ABSEN PULANG
              DocumentSnapshot<Map<String, dynamic>> todayDoc =
                  await colPresence.doc(todayDocID).get();

              // print(todayDoc.exists);

              if (todayDoc.exists == true) {
                // tinggal absen pulang atau sudah 2-2nya
                // Map<String, dynamic>? dataPresenceToday =  todayDoc.data();
                // // if (dataPresenceToday?["pulang"] != null){
                // //   // sudah absen datang dan pulang
                // //   Get.snackbar("Informasi Penting", "Anda telah presensi Datang dan Pulang hari ini. Tidak dapat mengubah data kembali.");
                // // } else {
                /////////////////////////////////// absen pulang ////////////////////////////////////////
                await Get.defaultDialog(
                    title: "Validasi Presensi",
                    titleStyle: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    titlePadding: EdgeInsets.only(top: 24, bottom: 2),
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    middleText:
                        "Apakah Anda yakin ingin mengisi Presensi Pulang sekarang?",
                    middleTextStyle: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w400),
                    actions: [
                      OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text("Batalkan",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 12,
                              ))),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Color(0xffFFC107)),
                          onPressed: () async {
                            await colPresence.doc(todayDocID).update({
                              "pulang": {
                                "date": dateTimeGMT.toIso8601String(),
                                "lat": position.latitude,
                                "long": position.longitude,
                                "alamat": alamat,
                                "status": status,
                                "distance": jarak,
                              },
                            });
                            Get.back();
                            Get.snackbar("Berhasil!",
                                "Anda berhasil mengisi Presensi Pulang.");

                            DocumentSnapshot<Map<String, dynamic>>
                                todayDocPresence =
                                await colPresence.doc(todayDocID).get();

                            String jamDatangFb =
                                todayDocPresence['datang']['date'];
                            String jamPulangFb =
                                todayDocPresence['pulang']['date'];
                            var jamDatangFirebase = DateTime.parse(jamDatangFb);
                            var jamPulangFirebase = DateTime.parse(jamPulangFb);

                            // String datangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                            // String pulangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                            // // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

                            // var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
                            // var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

                            // print(parsedDatangPresence);
                            // print(parsedPulangPresence);

                            // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase //
                            String j2 = nipSession['j2'];
                            String j3 = nipSession['j3'];
                            // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase - end //

                            // String sekarang = DateFormat("EEE").format(DateTime(2022, 10, 15));
                            String hariSekarang = DateFormat("EEE").format(now);
                            print(hariSekarang);

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
                            DateTime jamDatangC = jamDatangFirebase;
                            DateTime jamPulangC = jamPulangFirebase;
                            // Inputen Presensi - End//

                            String jamd = DateFormat.Hms().format(jamDatangC);
                            String jamp = DateFormat.Hms().format(jamPulangC);

                            print(jamd);
                            print(jamp);

                            DateTime jam = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                8,
                                15,
                                1); // test

                            // DateTime PJ1 = DateTime(dateTimeGMT.year,
                            //     dateTimeGMT.month, dateTimeGMT.day, 7, 45, 0);

                            //PATOKAN JAM MASUK DARI RULE
                            print("PATOKAN JAM MASUK");

                            DateTime PJ1Tahun = DateTime(dateTimeGMT.year,
                                dateTimeGMT.month, dateTimeGMT.day);
                            print(PJ1Tahun);

                            String j1n0 = j1n + ".000";

                            String PJ1Merge = PJ1Tahun.toIso8601String()
                                    .replaceAll("00:00:00.000", "") +
                                j1n0;
                            // print(PJ1Merge);

                            DateTime PJ1 = DateTime.parse(PJ1Merge);
                            print(PJ1);

                            //PATOKAN JAM MASUK DARI RULE

                            DateTime jam1 = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                15,
                                46,
                                0); // test
                            DateTime PJ2 = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                int.parse(jam2),
                                int.parse(menit2),
                                0); // Patokan jam pulang //

                            // strtotime - Convert DateTime to millisecond //
                            int jamDatangStr =
                                jamDatangC.millisecondsSinceEpoch;
                            int jamPulangStr =
                                jamPulangC.millisecondsSinceEpoch;
                            int datang = PJ1.millisecondsSinceEpoch;
                            int pulang = PJ2.millisecondsSinceEpoch;
                            // strtotime - Convert DateTime to millisecond - end //

                            // Logic Status Jam //
                            double hasil = (jamDatangStr - datang) / 60000;
                            int ddat = hasil.ceil();

                            double hasil2 = (pulang - jamPulangStr) / 60000;
                            int dpul = hasil2.ceil();

                            // print(ddat);
                            // print(jamd);
                            // print(datang);
                            // print(hasil);
                            // // print(dpul);

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
                                  "Mohon Tunggu", "Data sedang diproses...");
                              // var myResponse = await http.post(
                              //     Uri.parse(
                              //         "https://apisadasbor.tasikmalayakab.go.id/api/absensi"),
                              //     headers: {
                              //       HttpHeaders.authorizationHeader:
                              //           'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                              //     },
                              //     body: {
                              //       "nip": nipSession['nip'],
                              //       "tanggal":
                              //           DateFormat("yyyy-MM-dd").format(now),
                              //       "sd": sd,
                              //       "sp": sp,
                              //       "id_th": "1",
                              //       "jamd": DateFormat.Hms()
                              //           .format(jamDatangFirebase),
                              //       "jamp": DateFormat.Hms()
                              //           .format(jamPulangFirebase),
                              //     });

                              var myResponse = await http.post(
                                  Uri.parse(
                                      "https://kinerja.tasikmalayakab.go.id/api/presensi"),
                                  headers: {
                                    HttpHeaders.authorizationHeader:
                                        'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
                                  },
                                  body: {
                                    "nip": nipSession['nip'],
                                    "tanggal":
                                        DateFormat("yyyy-MM-dd").format(now),
                                    "sd": sd,
                                    "sp": sp,
                                    "id_th": "1",
                                    "jamd": DateFormat.Hms()
                                        .format(jamDatangFirebase),
                                    "jamp": DateFormat.Hms()
                                        .format(jamPulangFirebase),
                                  });

                              if (myResponse.statusCode == 200) {
                                Map<String, dynamic> data =
                                    json.decode(myResponse.body)
                                        as Map<String, dynamic>;
                                print(myResponse.body);

                                Get.back();
                                Get.back();
                                Get.snackbar("Sukses!",
                                    "Data Pulang Berhasil Masuk ke API.");
                                print("Data Pulang Berhasil Masuk ke API");
                                isLoading.value = false;

                                if (data['status'] == "success") {
                                  await colPresence.doc(todayDocID).update({
                                    "sync": "Y",
                                  });
                                } else {
                                  await colPresence.doc(todayDocID).update({
                                    "sync": "N",
                                  });
                                  Get.snackbar(
                                    "Terjadi Gangguan Server",
                                    "Data Pulang Sukses, Tetapi Belum Sinkron Dengan API Server (N). Silahkan Coba Lain Waktu.",
                                    duration: const Duration(seconds: 8),
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  "Terjadi Gangguan Server",
                                  "Data Presensi Anda Sukses, Tetapi Belum Sinkron Dengan API Server (404). Silahkan Coba Lain Waktu.",
                                  duration: const Duration(seconds: 8),
                                );
                              }
                            } else {
                              Get.snackbar("Gagal",
                                  "Data Pulang Gagal Masuk ke API. Silahkan coba kembali.");
                              print(
                                  "Data Pulang Gagal Terupdate, Coba Kembali");
                              Get.offAllNamed(Routes.HOME);
                              isLoading.value = false;
                            }
                            //// POST DATA PULANG KE API ABSENSI - end ////
                          },
                          child: Text(
                            "Presensi",
                            style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          )),
                    ]);
              } else {
                // absen datang
                await Get.defaultDialog(
                    title: "Validasi Presensi",
                    titleStyle: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    titlePadding: EdgeInsets.only(top: 24, bottom: 2),
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    middleText:
                        "Apakah Anda yakin ingin mengisi Presensi Datang sekarang?",
                    middleTextStyle: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w400),
                    actions: [
                      OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            "Batalkan",
                            style: GoogleFonts.poppins(
                              color: Color(0xff333333),
                              fontSize: 12,
                            ),
                          )),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xffFFC107),
                          ),
                          onPressed: () async {
                            await colPresence.doc(todayDocID).set({
                              "date": dateTimeGMT.toIso8601String(),
                              "sync": "N",
                              "datang": {
                                "date": dateTimeGMT.toIso8601String(),
                                "lat": position.latitude,
                                "long": position.longitude,
                                "alamat": alamat,
                                "status": status,
                                "distance": jarak,
                              },
                              "pulang": {
                                "date": dateTimeGMT.toIso8601String(),
                                "lat": position.latitude,
                                "long": position.longitude,
                                "alamat": alamat,
                                "status": status,
                                "distance": jarak,
                              },
                            });
                            Get.back();
                            Get.snackbar("Berhasil!",
                                "Anda berhasil mengisi Presensi Datang.");

                            DocumentSnapshot<Map<String, dynamic>>
                                todayDocPresence =
                                await colPresence.doc(todayDocID).get();

                            String jamDatangFb =
                                todayDocPresence['datang']['date'];
                            String jamPulangFb =
                                todayDocPresence['pulang']['date'];
                            var jamDatangFirebase = DateTime.parse(jamDatangFb);
                            var jamPulangFirebase = DateTime.parse(jamPulangFb);

                            // String datangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                            // String pulangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                            // // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

                            // var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
                            // var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

                            // print(parsedDatangPresence);
                            // print(parsedPulangPresence);

                            // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase //
                            String j2 = nipSession['j2'];
                            String j3 = nipSession['j3'];
                            // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase - end //

                            // String sekarang = DateFormat("EEE").format(DateTime(2022, 10, 15));
                            String hariSekarang = DateFormat("EEE").format(now);
                            print(hariSekarang);

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
                            DateTime jamDatangC = jamDatangFirebase;
                            DateTime jamPulangC = jamPulangFirebase;
                            // Inputen Presensi - End//

                            String jamd = DateFormat.Hms().format(jamDatangC);
                            String jamp = DateFormat.Hms().format(jamPulangC);

                            print(jamd);
                            print(jamp);

                            DateTime jam = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                8,
                                15,
                                1); // test

                            // DateTime PJ1 = DateTime(
                            //     dateTimeGMT.year,
                            //     dateTimeGMT.month,
                            //     dateTimeGMT.day,
                            //     7,
                            //     45,
                            //     0); // Patokan jam masuk //

                            //PATOKAN JAM MASUK DARI RULE
                            print("PATOKAN JAM MASUK");

                            DateTime PJ1Tahun = DateTime(dateTimeGMT.year,
                                dateTimeGMT.month, dateTimeGMT.day);
                            print(PJ1Tahun);

                            String j1n0 = j1n + ".000";

                            String PJ1Merge = PJ1Tahun.toIso8601String()
                                    .replaceAll("00:00:00.000", "") +
                                j1n0;
                            // print(PJ1Merge);

                            DateTime PJ1 = DateTime.parse(PJ1Merge);
                            print(PJ1);

                            //PATOKAN JAM MASUK DARI RULE

                            DateTime jam1 = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                15,
                                46,
                                0); // test

                            DateTime PJ2 = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                int.parse(jam2),
                                int.parse(menit2),
                                0); // Patokan jam pulang //

                            // strtotime - Convert DateTime to millisecond //
                            int jamDatangStr =
                                jamDatangC.millisecondsSinceEpoch;
                            int jamPulangStr =
                                jamPulangC.millisecondsSinceEpoch;
                            int datang = PJ1.millisecondsSinceEpoch;
                            int pulang = PJ2.millisecondsSinceEpoch;
                            // strtotime - Convert DateTime to millisecond - end //

                            // Logic Status Jam //
                            double hasil = (jamDatangStr - datang) / 60000;
                            int ddat = hasil.ceil();

                            double hasil2 = (pulang - jamPulangStr) / 60000;
                            int dpul = hasil2.ceil();

                            // print(ddat);
                            // print(jamd);
                            // print(datang);
                            // print(hasil);
                            // // print(dpul);

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

                            // LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI - End //

                            //// POST DATA DATANG KE API ABSENSI ////

                            if (dataPresenceToday?['datang']['date'] == true) {
                              print("sukses");
                            }
                            if (todayDoc.exists == false) {
                              Get.snackbar(
                                  "Mohon Tunggu", "Data sedang diproses...");
                              // var myResponse = await http.post(
                              //     Uri.parse(
                              //         "https://apisadasbor.tasikmalayakab.go.id/api/absensi"),
                              //     headers: {
                              //       HttpHeaders.authorizationHeader:
                              //           'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                              //     },
                              //     body: {
                              //       "nip": nipSession['nip'],
                              //       "tanggal":
                              //           DateFormat("yyyy-MM-dd").format(now),
                              //       "sd": sd,
                              //       "sp": sp,
                              //       "id_th": "1",
                              //       "jamd": DateFormat.Hms()
                              //           .format(jamDatangFirebase),
                              //       "jamp": DateFormat.Hms()
                              //           .format(jamPulangFirebase),
                              //     });
                              var myResponse = await http.post(
                                  Uri.parse(
                                      "https://kinerja.tasikmalayakab.go.id/api/presensi"),
                                  headers: {
                                    HttpHeaders.authorizationHeader:
                                        'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
                                  },
                                  body: {
                                    "nip": nipSession['nip'],
                                    "tanggal":
                                        DateFormat("yyyy-MM-dd").format(now),
                                    "sd": sd,
                                    "sp": sp,
                                    "id_th": "1",
                                    "jamd": DateFormat.Hms()
                                        .format(jamDatangFirebase),
                                    "jamp": DateFormat.Hms()
                                        .format(jamPulangFirebase),
                                  });

                              if (myResponse.statusCode == 200) {
                                Map<String, dynamic> data =
                                    json.decode(myResponse.body)
                                        as Map<String, dynamic>;
                                print(myResponse.body);

                                Get.back();
                                Get.back();
                                Get.snackbar("Sukses!",
                                    "Data Datang Berhasil Masuk ke API.");
                                print("Data Datang Berhasil Masuk ke API");
                                isLoading.value = false;

                                if (data['status'] == "success") {
                                  await colPresence.doc(todayDocID).update({
                                    "sync": "Y",
                                  });
                                } else {
                                  Get.snackbar(
                                    "Terjadi Gangguan Server",
                                    "Data Datang Sukses, Tetapi Belum Sinkron Dengan API Server (N). Silahkan Coba Lain Waktu.",
                                    duration: const Duration(seconds: 8),
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  "Terjadi Gangguan Server",
                                  "Data Datang Sukses, Tetapi Belum Sinkron Dengan API Server (404). Silahkan Coba Lain Waktu.",
                                  duration: const Duration(seconds: 8),
                                );
                              }
                            } else {
                              Get.snackbar("Gagal",
                                  "Data Datang Gagal Masuk ke API. Silahkan coba kembali.");
                              print(
                                  "Data Datang Gagal Terupdate, Coba Kembali");
                              Get.offAllNamed(Routes.HOME);
                              isLoading.value = false;
                            }
                            //// POST DATA DATANG KE API ABSENSI - end ////
                          },
                          child: Text(
                            "Presensi",
                            style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          )),
                    ]);
              }
            }
          } else {
            Get.snackbar("Presensi Gagal",
                "Anda tidak dapat melakukan presensi karena sedang diluar area ${nipSession['nama_lokasi']}.",
                duration: const Duration(seconds: 8));
          }
        } // KONDISI 5 HARI KERJA - End
      }

      // KONDISI 6 HARI KERJA (6HARIKERJA/6HARIKERJA/6HARIKERJA/6HARIKERJA/6HARIKERJA/)
      // TAMBAHAN BULAN PUASA JAM 13:15:00
      else if (j2 == '14:30:00' || j2 == '13:15:00') {
        // 6 HARI KERJA
        print("6 Hari Kerja Aktif");

        //interpolasi baru pakai RULE
        String j1n = nipRule6['j1'];
        String j2n = nipRule6['j2'];
        String j3n = nipRule6['j3'];

        print(j1n);
        print(j2n);
        print(j3n);

        if (hariIni == 'Sun' || liburSession.exists == true) {
          Get.defaultDialog(
              titlePadding: EdgeInsets.only(top: 22),
              title: "Hari Ini Hari Libur",
              titleStyle: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: EdgeInsets.all(16),
              middleText: liburSession.exists == false
                  ? "Menu Presensi Akan Aktif Kembali Pada Hari Kerja."
                  : "Bertepatan dengan Libur ${liburSession['nama_libur']}, menu presensi akan aktif kembali pada hari kerja selanjutnya.",
              middleTextStyle: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w400),
              actions: [
                ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xffFFC107),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      "OK",
                      style: GoogleFonts.poppins(
                          color: Color(0xff333333),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )),
              ]);
          // LOGIC LIBUR (BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/BERHASIL/)
        } else {
          String uid = await auth.currentUser!.uid;

          CollectionReference<Map<String, dynamic>> colPresence =
              firestore.collection("user").doc(uid).collection("presence");
          QuerySnapshot<Map<String, dynamic>> snapPresence =
              await colPresence.get();
          print(snapPresence.docs.length);
          print("Check Length");

          DateTime now = dateTimeGMT;
          String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

          final nipSession = await firestore.collection("user").doc(uid).get();

          DocumentSnapshot<Map<String, dynamic>> todayDoc =
              await colPresence.doc(todayDocID).get();
          Map<String, dynamic>? dataPresenceToday = todayDoc.data();

          String status = "Di Luar Area";
          double jarak = 0.0;

          if (distance <= 500 || distance2 <= 500) {
            // rev distance
            status = "Di Dalam Area";
            double jarak = distance <= 500 ? distance : distance2;

            print("Jarak Terdekat adalah : ");
            print(jarak);

            if (snapPresence.docs.length == 0) {
              //null - belum pernah absen & set absen datang
              SizedBox(
                height: 5,
              );
              await Get.defaultDialog(
                  title: "Validasi Presensi",
                  titleStyle: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  titlePadding: EdgeInsets.only(top: 24, bottom: 2),
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  middleText:
                      "Apakah Anda yakin ingin mengisi Presensi Datang sekarang?",
                  middleTextStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w400),
                  actions: [
                    OutlinedButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Batalkan",
                          style: GoogleFonts.poppins(
                            color: Color(0xff333333),
                            fontSize: 12,
                          ),
                        )),
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xffFFC107),
                      ),
                      onPressed: () async {
                        await colPresence.doc(todayDocID).set({
                          "date": dateTimeGMT.toIso8601String(),
                          "sync": "N",
                          "datang": {
                            "date": dateTimeGMT.toIso8601String(),
                            "lat": position.latitude,
                            "long": position.longitude,
                            "alamat": alamat,
                            "status": status,
                            "distance": jarak,
                          },
                          "pulang": {
                            "date": dateTimeGMT.toIso8601String(),
                            "lat": position.latitude,
                            "long": position.longitude,
                            "alamat": alamat,
                            "status": status,
                            "distance": jarak,
                          },
                        });
                        Get.back();
                        Get.snackbar("Berhasil!",
                            "Anda berhasil mengisi Presensi Datang.");

                        DocumentSnapshot<Map<String, dynamic>>
                            todayDocPresence =
                            await colPresence.doc(todayDocID).get();

                        String jamDatangFb = todayDocPresence['datang']['date'];
                        String jamPulangFb = todayDocPresence['pulang']['date'];
                        var jamDatangFirebase = DateTime.parse(jamDatangFb);
                        var jamPulangFirebase = DateTime.parse(jamPulangFb);

                        // String datangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                        // String pulangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                        // // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

                        // var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
                        // var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

                        // print(parsedDatangPresence);
                        // print(parsedPulangPresence);

                        // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase //
                        String j2 = nipSession['j2']; //Pukul 15.45
                        String j3 = nipSession['j3']; //Pukul 16.15
                        // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase - end //

                        // String sekarang = DateFormat("EEE").format(DateTime(2022, 10, 15));
                        String hariSekarang = DateFormat("EEE").format(now);
                        print(hariSekarang);

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
                        DateTime jamDatangC = jamDatangFirebase;
                        DateTime jamPulangC = jamPulangFirebase;
                        // Inputen Presensi - End//

                        String jamd = DateFormat.Hms().format(jamDatangC);
                        String jamp = DateFormat.Hms().format(jamPulangC);

                        print(jamd);
                        print(jamp);

                        DateTime jam = DateTime(
                            dateTimeGMT.year,
                            dateTimeGMT.month,
                            dateTimeGMT.day,
                            8,
                            15,
                            1); // test

                        // DateTime PJ1 = DateTime(
                        //     dateTimeGMT.year,
                        //     dateTimeGMT.month,
                        //     dateTimeGMT.day,
                        //     7,
                        //     45,
                        //     0); // Patokan jam masuk //

                        //PATOKAN JAM MASUK DARI RULE
                        print("PATOKAN JAM MASUK");

                        DateTime PJ1Tahun = DateTime(dateTimeGMT.year,
                            dateTimeGMT.month, dateTimeGMT.day);
                        print(PJ1Tahun);

                        String j1n0 = j1n + ".000";

                        String PJ1Merge = PJ1Tahun.toIso8601String()
                                .replaceAll("00:00:00.000", "") +
                            j1n0;
                        // print(PJ1Merge);

                        DateTime PJ1 = DateTime.parse(PJ1Merge);
                        print(PJ1);

                        //PATOKAN JAM MASUK DARI RULE

                        DateTime jam1 = DateTime(
                            dateTimeGMT.year,
                            dateTimeGMT.month,
                            dateTimeGMT.day,
                            15,
                            46,
                            0); // test

                        DateTime PJ2 = DateTime(
                            dateTimeGMT.year,
                            dateTimeGMT.month,
                            dateTimeGMT.day,
                            int.parse(jam2),
                            int.parse(menit2),
                            0); // Patokan jam pulang //

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

                        // print(ddat);
                        // print(jamd);
                        // print(datang);
                        // print(hasil);
                        // // print(dpul);

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

                        // LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI - End //

                        //// POST DATA DATANG KE API ABSENSI ////
                        if (sd != null && sp != null) {
                          Get.snackbar(
                              "Mohon Tunggu", "Data sedang diproses...");
                          // var myResponse = await http.post(
                          //     Uri.parse(
                          //         "https://apisadasbor.tasikmalayakab.go.id/api/absensi"),
                          //     headers: {
                          //       HttpHeaders.authorizationHeader:
                          //           'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                          //     },
                          //     body: {
                          //       "nip": nipSession['nip'],
                          //       "tanggal": DateFormat("yyyy-MM-dd").format(now),
                          //       "sd": sd,
                          //       "sp": sp,
                          //       "id_th": "1",
                          //       "jamd":
                          //           DateFormat.Hms().format(jamDatangFirebase),
                          //       "jamp":
                          //           DateFormat.Hms().format(jamPulangFirebase),
                          //     });

                          var myResponse = await http.post(
                              Uri.parse(
                                  "https://kinerja.tasikmalayakab.go.id/api/presensi"),
                              headers: {
                                HttpHeaders.authorizationHeader:
                                    'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
                              },
                              body: {
                                "nip": nipSession['nip'],
                                "tanggal": DateFormat("yyyy-MM-dd").format(now),
                                "sd": sd,
                                "sp": sp,
                                "id_th": "1",
                                "jamd":
                                    DateFormat.Hms().format(jamDatangFirebase),
                                "jamp":
                                    DateFormat.Hms().format(jamPulangFirebase),
                              });

                          Map<String, dynamic> data = json
                              .decode(myResponse.body) as Map<String, dynamic>;
                          print(myResponse.body);

                          Get.back();
                          Get.back();
                          Get.snackbar(
                              "Sukses!", "Data Datang Berhasil Masuk ke API.");
                          print("Data Datang Berhasil Masuk ke API");
                          isLoading.value = false;

                          if (data['status'] == "success") {
                            await colPresence.doc(todayDocID).update({
                              "sync": "Y",
                            });
                          } else {
                            Get.snackbar("Terjadi Gangguan Server",
                                "Data Datang Sukses, Tetapi Belum Sinkron Dengan API Server. Silahkan Coba Lain Waktu.");
                          }
                        } else {
                          Get.snackbar("Gagal",
                              "Data Datang Gagal Masuk ke API. Silahkan coba kembali.");
                          print("Data Datang Gagal Terupdate, Coba Kembali");
                          Get.offAllNamed(Routes.HOME);
                          isLoading.value = false;
                        }
                        //// POST DATA DATANG KE API ABSENSI - end ////
                      },
                      child: Text(
                        "Presensi",
                        style: GoogleFonts.poppins(
                            color: Color(0xff333333),
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ]);
            } else {
              //sudah pernah absen, cek hari ini udah absen datang atau pulang udah belum?
              //ABSEN PULANG
              DocumentSnapshot<Map<String, dynamic>> todayDoc =
                  await colPresence.doc(todayDocID).get();

              // print(todayDoc.exists);

              if (todayDoc.exists == true) {
                // tinggal absen pulang atau sudah 2-2nya
                // Map<String, dynamic>? dataPresenceToday =  todayDoc.data();
                // // if (dataPresenceToday?["pulang"] != null){
                // //   // sudah absen datang dan pulang
                // //   Get.snackbar("Informasi Penting", "Anda telah presensi Datang dan Pulang hari ini. Tidak dapat mengubah data kembali.");
                // // } else {
                /////////////////////////////////// absen pulang ////////////////////////////////////////
                await Get.defaultDialog(
                    title: "Validasi Presensi",
                    titleStyle: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    titlePadding: EdgeInsets.only(top: 24, bottom: 2),
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    middleText:
                        "Apakah Anda yakin ingin mengisi Presensi Pulang sekarang?",
                    middleTextStyle: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w400),
                    actions: [
                      OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text("Batalkan",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 12,
                              ))),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Color(0xffFFC107)),
                          onPressed: () async {
                            await colPresence.doc(todayDocID).update({
                              "pulang": {
                                "date": dateTimeGMT.toIso8601String(),
                                "lat": position.latitude,
                                "long": position.longitude,
                                "alamat": alamat,
                                "status": status,
                                "distance": jarak,
                              },
                            });
                            Get.back();
                            Get.snackbar("Berhasil!",
                                "Anda berhasil mengisi Presensi Pulang.");

                            DocumentSnapshot<Map<String, dynamic>>
                                todayDocPresence =
                                await colPresence.doc(todayDocID).get();

                            String jamDatangFb =
                                todayDocPresence['datang']['date'];
                            String jamPulangFb =
                                todayDocPresence['pulang']['date'];
                            var jamDatangFirebase = DateTime.parse(jamDatangFb);
                            var jamPulangFirebase = DateTime.parse(jamPulangFb);

                            // String datangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                            // String pulangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                            // // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

                            // var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
                            // var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

                            // print(parsedDatangPresence);
                            // print(parsedPulangPresence);

                            // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase //
                            String j2 = nipSession['j2'];
                            String j3 = nipSession['j3'];
                            // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase - end //

                            // String sekarang = DateFormat("EEE").format(DateTime(2022, 10, 15));
                            String hariSekarang = DateFormat("EEE").format(now);
                            print(hariSekarang);

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
                            DateTime jamDatangC = jamDatangFirebase;
                            DateTime jamPulangC = jamPulangFirebase;
                            // Inputen Presensi - End//

                            String jamd = DateFormat.Hms().format(jamDatangC);
                            String jamp = DateFormat.Hms().format(jamPulangC);

                            print(jamd);
                            print(jamp);

                            DateTime jam = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                8,
                                15,
                                1); // test

                            // DateTime PJ1 = DateTime(
                            //     dateTimeGMT.year,
                            //     dateTimeGMT.month,
                            //     dateTimeGMT.day,
                            //     7,
                            //     45,
                            //     0); // Patokan jam masuk //

                            //PATOKAN JAM MASUK DARI RULE
                            print("PATOKAN JAM MASUK");

                            DateTime PJ1Tahun = DateTime(dateTimeGMT.year,
                                dateTimeGMT.month, dateTimeGMT.day);
                            print(PJ1Tahun);

                            String j1n0 = j1n + ".000";

                            String PJ1Merge = PJ1Tahun.toIso8601String()
                                    .replaceAll("00:00:00.000", "") +
                                j1n0;
                            // print(PJ1Merge);

                            DateTime PJ1 = DateTime.parse(PJ1Merge);
                            print(PJ1);

                            //PATOKAN JAM MASUK DARI RULE

                            DateTime jam1 = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                15,
                                46,
                                0); // test

                            DateTime PJ2 = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                int.parse(jam2),
                                int.parse(menit2),
                                0); // Patokan jam pulang //

                            // strtotime - Convert DateTime to millisecond //
                            int jamDatangStr =
                                jamDatangC.millisecondsSinceEpoch;
                            int jamPulangStr =
                                jamPulangC.millisecondsSinceEpoch;
                            int datang = PJ1.millisecondsSinceEpoch;
                            int pulang = PJ2.millisecondsSinceEpoch;
                            // strtotime - Convert DateTime to millisecond - end //

                            // Logic Status Jam //
                            double hasil = (jamDatangStr - datang) / 60000;
                            int ddat = hasil.ceil();

                            double hasil2 = (pulang - jamPulangStr) / 60000;
                            int dpul = hasil2.ceil();

                            // print(ddat);
                            // print(jamd);
                            // print(datang);
                            // print(hasil);
                            // // print(dpul);

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
                                  "Mohon Tunggu", "Data sedang diproses...");
                              // var myResponse = await http.post(
                              //     Uri.parse(
                              //         "https://apisadasbor.tasikmalayakab.go.id/api/absensi"),
                              //     headers: {
                              //       HttpHeaders.authorizationHeader:
                              //           'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                              //     },
                              //     body: {
                              //       "nip": nipSession['nip'],
                              //       "tanggal":
                              //           DateFormat("yyyy-MM-dd").format(now),
                              //       "sd": sd,
                              //       "sp": sp,
                              //       "id_th": "1",
                              //       "jamd": DateFormat.Hms()
                              //           .format(jamDatangFirebase),
                              //       "jamp": DateFormat.Hms()
                              //           .format(jamPulangFirebase),
                              //     });

                              var myResponse = await http.post(
                                  Uri.parse(
                                      "https://kinerja.tasikmalayakab.go.id/api/presensi"),
                                  headers: {
                                    HttpHeaders.authorizationHeader:
                                        'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
                                  },
                                  body: {
                                    "nip": nipSession['nip'],
                                    "tanggal":
                                        DateFormat("yyyy-MM-dd").format(now),
                                    "sd": sd,
                                    "sp": sp,
                                    "id_th": "1",
                                    "jamd": DateFormat.Hms()
                                        .format(jamDatangFirebase),
                                    "jamp": DateFormat.Hms()
                                        .format(jamPulangFirebase),
                                  });

                              if (myResponse.statusCode == 200) {
                                Map<String, dynamic> data =
                                    json.decode(myResponse.body)
                                        as Map<String, dynamic>;
                                print(myResponse.body);

                                Get.back();
                                Get.back();
                                Get.snackbar("Sukses!",
                                    "Data Pulang Berhasil Masuk ke API.");
                                print("Data Pulang Berhasil Masuk ke API");
                                isLoading.value = false;

                                if (data['status'] == "success") {
                                  await colPresence.doc(todayDocID).update({
                                    "sync": "Y",
                                  });
                                } else {
                                  Get.snackbar(
                                    "Terjadi Gangguan Server",
                                    "Data Pulang Sukses, Tetapi Belum Sinkron Dengan API Server (N). Silahkan Coba Lain Waktu.",
                                    duration: const Duration(seconds: 8),
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  "Terjadi Gangguan Server",
                                  "Data Presensi Anda Sukses, Tetapi Belum Sinkron Dengan API Server (404). Silahkan Coba Lain Waktu.",
                                  duration: const Duration(seconds: 8),
                                );
                              }
                            } else {
                              Get.snackbar("Gagal",
                                  "Data Pulang Gagal Masuk ke API. Silahkan coba kembali.");
                              print(
                                  "Data Pulang Gagal Terupdate, Coba Kembali");
                              Get.offAllNamed(Routes.HOME);
                              isLoading.value = false;
                            }
                            //// POST DATA PULANG KE API ABSENSI - end ////
                          },
                          child: Text(
                            "Presensi",
                            style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          )),
                    ]);
              } else {
                // absen datang
                await Get.defaultDialog(
                    title: "Validasi Presensi",
                    titleStyle: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    titlePadding: EdgeInsets.only(top: 24, bottom: 2),
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    middleText:
                        "Apakah Anda yakin ingin mengisi Presensi Datang sekarang?",
                    middleTextStyle: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w400),
                    actions: [
                      OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            "Batalkan",
                            style: GoogleFonts.poppins(
                              color: Color(0xff333333),
                              fontSize: 12,
                            ),
                          )),
                      ElevatedButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xffFFC107),
                          ),
                          onPressed: () async {
                            await colPresence.doc(todayDocID).set({
                              "date": dateTimeGMT.toIso8601String(),
                              "sync": "N",
                              "datang": {
                                "date": dateTimeGMT.toIso8601String(),
                                "lat": position.latitude,
                                "long": position.longitude,
                                "alamat": alamat,
                                "status": status,
                                "distance": jarak,
                              },
                              "pulang": {
                                "date": dateTimeGMT.toIso8601String(),
                                "lat": position.latitude,
                                "long": position.longitude,
                                "alamat": alamat,
                                "status": status,
                                "distance": jarak,
                              },
                            });
                            Get.back();
                            Get.snackbar("Berhasil!",
                                "Anda berhasil mengisi Presensi Datang.");

                            DocumentSnapshot<Map<String, dynamic>>
                                todayDocPresence =
                                await colPresence.doc(todayDocID).get();

                            String jamDatangFb =
                                todayDocPresence['datang']['date'];
                            String jamPulangFb =
                                todayDocPresence['pulang']['date'];
                            var jamDatangFirebase = DateTime.parse(jamDatangFb);
                            var jamPulangFirebase = DateTime.parse(jamPulangFb);

                            // String datangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                            // String pulangPresence = now.toIso8601String(); //Interpolasi dari Firestore
                            // // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

                            // var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
                            // var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

                            // print(parsedDatangPresence);
                            // print(parsedPulangPresence);

                            // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase //
                            String j2 = nipSession['j2'];
                            String j3 = nipSession['j3'];
                            // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase - end //

                            // String sekarang = DateFormat("EEE").format(DateTime(2022, 10, 15));
                            String hariSekarang = DateFormat("EEE").format(now);
                            print(hariSekarang);

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
                            DateTime jamDatangC = jamDatangFirebase;
                            DateTime jamPulangC = jamPulangFirebase;
                            // Inputen Presensi - End//

                            String jamd = DateFormat.Hms().format(jamDatangC);
                            String jamp = DateFormat.Hms().format(jamPulangC);

                            print(jamd);
                            print(jamp);

                            DateTime jam = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                8,
                                15,
                                1); // test

                            // DateTime PJ1 = DateTime(
                            //     dateTimeGMT.year,
                            //     dateTimeGMT.month,
                            //     dateTimeGMT.day,
                            //     7,
                            //     45,
                            //     0);

                            //PATOKAN JAM MASUK DARI RULE
                            print("PATOKAN JAM MASUK");

                            DateTime PJ1Tahun = DateTime(dateTimeGMT.year,
                                dateTimeGMT.month, dateTimeGMT.day);
                            print(PJ1Tahun);

                            String j1n0 = j1n + ".000";

                            String PJ1Merge = PJ1Tahun.toIso8601String()
                                    .replaceAll("00:00:00.000", "") +
                                j1n0;
                            // print(PJ1Merge);

                            DateTime PJ1 = DateTime.parse(PJ1Merge);
                            print(PJ1);

                            //PATOKAN JAM MASUK DARI RULE

                            DateTime jam1 = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                15,
                                46,
                                0); // test
                            DateTime PJ2 = DateTime(
                                dateTimeGMT.year,
                                dateTimeGMT.month,
                                dateTimeGMT.day,
                                int.parse(jam2),
                                int.parse(menit2),
                                0); // Patokan jam pulang //

                            // strtotime - Convert DateTime to millisecond //
                            int jamDatangStr =
                                jamDatangC.millisecondsSinceEpoch;
                            int jamPulangStr =
                                jamPulangC.millisecondsSinceEpoch;
                            int datang = PJ1.millisecondsSinceEpoch;
                            int pulang = PJ2.millisecondsSinceEpoch;
                            // strtotime - Convert DateTime to millisecond - end //

                            // Logic Status Jam //
                            double hasil = (jamDatangStr - datang) / 60000;
                            int ddat = hasil.ceil();

                            double hasil2 = (pulang - jamPulangStr) / 60000;
                            int dpul = hasil2.ceil();

                            // print(ddat);
                            // print(jamd);
                            // print(datang);
                            // print(hasil);
                            // // print(dpul);

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

                            // LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI - End //

                            //// POST DATA DATANG KE API ABSENSI ////
                            if (dataPresenceToday?['datang']['date'] == true) {
                              print("sukses");
                            }
                            if (todayDoc.exists == false) {
                              Get.snackbar(
                                  "Mohon Tunggu", "Data sedang diproses...");
                              // var myResponse = await http.post(
                              //     Uri.parse(
                              //         "https://apisadasbor.tasikmalayakab.go.id/api/absensi"),
                              //     headers: {
                              //       HttpHeaders.authorizationHeader:
                              //           'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                              //     },
                              //     body: {
                              //       "nip": nipSession['nip'],
                              //       "tanggal":
                              //           DateFormat("yyyy-MM-dd").format(now),
                              //       "sd": sd,
                              //       "sp": sp,
                              //       "id_th": "1",
                              //       "jamd": DateFormat.Hms()
                              //           .format(jamDatangFirebase),
                              //       "jamp": DateFormat.Hms()
                              //           .format(jamPulangFirebase),
                              //     });

                              var myResponse = await http.post(
                                  Uri.parse(
                                      "https://kinerja.tasikmalayakab.go.id/api/presensi"),
                                  headers: {
                                    HttpHeaders.authorizationHeader:
                                        'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
                                  },
                                  body: {
                                    "nip": nipSession['nip'],
                                    "tanggal":
                                        DateFormat("yyyy-MM-dd").format(now),
                                    "sd": sd,
                                    "sp": sp,
                                    "id_th": "1",
                                    "jamd": DateFormat.Hms()
                                        .format(jamDatangFirebase),
                                    "jamp": DateFormat.Hms()
                                        .format(jamPulangFirebase),
                                  });

                              if (myResponse.statusCode == 200) {
                                Map<String, dynamic> data =
                                    json.decode(myResponse.body)
                                        as Map<String, dynamic>;
                                print(myResponse.body);

                                Get.back();
                                Get.back();
                                Get.snackbar("Sukses!",
                                    "Data Datang Berhasil Masuk ke API.");
                                print("Data Datang Berhasil Masuk ke API");
                                isLoading.value = false;

                                if (data['status'] == "success") {
                                  await colPresence.doc(todayDocID).update({
                                    "sync": "Y",
                                  });
                                } else {
                                  Get.snackbar(
                                    "Terjadi Gangguan Server",
                                    "Data Datang Sukses, Tetapi Belum Sinkron Dengan API Server (N). Silahkan Coba Lain Waktu.",
                                    duration: const Duration(seconds: 8),
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  "Terjadi Gangguan Server",
                                  "Data Datang Sukses, Tetapi Belum Sinkron Dengan API Server (404). Silahkan Coba Lain Waktu.",
                                  duration: const Duration(seconds: 8),
                                );
                              }
                            } else {
                              Get.snackbar("Gagal",
                                  "Data Datang Gagal Masuk ke API. Silahkan coba kembali.");
                              print(
                                  "Data Datang Gagal Terupdate, Coba Kembali");
                              Get.offAllNamed(Routes.HOME);
                              isLoading.value = false;
                            }
                            //// POST DATA DATANG KE API ABSENSI - end ////
                          },
                          child: Text(
                            "Presensi",
                            style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          )),
                    ]);
              }
            }
          } else {
            Get.snackbar("Presensi Gagal",
                "Anda tidak dapat melakukan presensi karena sedang diluar area ${nipSession['nama_lokasi']}.",
                duration: const Duration(seconds: 8));
          }
        }
      }
    } // KONDISI 6 HARI KERJA - End
  }

  Future<void> updatePosition(Position position, String alamat) async {
    String uid = await auth.currentUser!.uid;

    firestore.collection("user").doc(uid).update({
      "position": {
        "lat": position.latitude,
        "long": position.longitude,
      },
      "alamat": alamat,
    });
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      //return Future.error('Location services are disabled.');
      return {
        "message": "Tidak dapat mengambil GPS dari device ini",
        "error": true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return {
          "message": "Izin menggunakan GPS ditolak.",
          "error": true,
        };
        //return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message":
            "Pengaturan HP Anda tidak memperbolehkan untuk mengakses GPS. Ubah pada pengaturan HP Anda.",
        "error": true,
      };
      //return Future.error(
      //'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    return {
      "position": position,
      "message": "Berhasil Mendapatkan Posisi Device Anda.",
      "error": false,
    };
  }
}
