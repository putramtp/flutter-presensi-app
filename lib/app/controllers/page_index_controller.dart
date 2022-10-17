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

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;
  RxBool isLoading = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    pageIndex.value = i;
    switch (i) {
      case 2 :
        print("ABSENSI");
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse["error"] != true){
          Position position = dataResponse["position"];

          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          // print(placemarks[0]);
          String alamat = "${placemarks[0].street} , ${placemarks[0].subLocality} , ${placemarks[0].locality} , ${placemarks[0].subAdministrativeArea}";
          await updatePosition(position, alamat);

          //cek distance between 2 koordinat / 2 posisi
          double distance =  Geolocator.distanceBetween(-7.361053, 108.1127393, position.latitude, position.longitude);

          //absen
          await presensi(position, alamat, distance);

          // Get.snackbar("Berhasil", "Anda berhasil mengisi daftar hadir");

          Get.snackbar("${dataResponse['message']}" , alamat);
        } else {
          Get.snackbar("Terjadi Kesalahan", dataResponse["message"]);
        }
        break;
      case 1 : 
        pageIndex.value = i;
        Get.offAllNamed(Routes.WORKFROMHOME);
        break;
      case 3 : 
        pageIndex.value = i;
        Get.offAllNamed(Routes.DINASLUAR);
        break;
      case 4 : 
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future <void> presensi(Position position, String alamat, double distance) async {
    String uid = await auth.currentUser!.uid;

    CollectionReference<Map<String, dynamic>> colPresence =  firestore.collection("user").doc(uid).collection("presence");
    QuerySnapshot<Map<String, dynamic>> snapPresence =  await colPresence.get();
    print(snapPresence.docs.length);
    print("Check Length");

    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

    final nipSession = await firestore.collection("user").doc(uid).get();

    DocumentSnapshot<Map<String, dynamic>> todayDoc = await colPresence.doc(todayDocID).get();
    Map<String, dynamic>? dataPresenceToday =  todayDoc.data();

    String status = "Di Luar Area";

    if(distance <= 200){
      status = "Di Dalam Area";
    } 


    if (snapPresence.docs.length == 0){
      //belum pernah absen & set absen datang
      SizedBox(
        height: 5,
      );
      await Get.defaultDialog(
        title: "Validasi Presensi",
          titleStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
        middleText: "Apakah Anda yakin ingin mengisi Presensi Datang sekarang?",
        middleTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400
        ),
        actions: [
          OutlinedButton(
            onPressed: ()=> Get.back(), 
          child: Text(
            "Batalkan",
            style: GoogleFonts.poppins(
              color: Color(0xff333333),
              fontSize: 12,
            ),
            )
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              backgroundColor: Color(0xffFFC107),
            ),
            onPressed: () async {
              await colPresence.doc(todayDocID).set({
              "date" : now.toIso8601String(),
              "datang" : {
              "date" : now.toIso8601String(),
              "lat" : position.latitude,
              "long" : position.longitude,
              "alamat" : alamat,
              "status" : status,
              "distance" : distance,
            }
          });
          Get.back();
          Get.snackbar("Berhasil", "Anda berhasil mengisi Presensi Datang");

      String datangPresence = now.toIso8601String(); //Interpolasi dari Firestore
      String pulangPresence = now.toIso8601String(); //Interpolasi dari Firestore
      // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

      var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
      var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

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
            return b = j3;
          } else {
            return b = j2;
          }
        }
            String jp =  cekHari(hariSekarang);
            
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

      DateTime jam = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 15, 1); // test
      DateTime PJ1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 45, 0); // Patokan jam masuk //

      DateTime jam1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 15, 46, 0); // test
      DateTime PJ2 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(jam2), int.parse(menit2), 0); // Patokan jam pulang //
      
      // strtotime - Convert DateTime to millisecond //
      int jamDatangStr = jamDatangC.millisecondsSinceEpoch;
      int jamPulangStr = jamPulangC.millisecondsSinceEpoch;
      int datang = PJ1.millisecondsSinceEpoch;
      int pulang = PJ2.millisecondsSinceEpoch;
      // strtotime - Convert DateTime to millisecond - end //

      // Logic Status Jam //
      double hasil = (jamDatangStr - datang)/60000;
      int ddat = hasil.ceil();

      double hasil2 = (pulang - jamPulangStr)/60000;
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
          } else if (d >= 1 && d <= 30){
            return statusd = "TL1";
          } else if (d >= 31 && d <= 60){
            return statusd = "TL2";
          } else if (d >= 61 && d <= 90){
            return statusd = "TL3";
          } else if (d >= 91){
            return statusd = "TL4";
          }
        }

        cekStatusPulang(int p) {
          String statusp;
          if (p < 1) {
            return statusp = "Sesuai Waktu";
          } else if (p >= 1 && p <= 30){
            return statusp = "PSW1";
          } else if (p >= 31 && p <= 60){
            return statusp = "PSW2";
          } else if (p >= 61 && p <= 90){
            return statusp = "PSW3";
          } else if (p >= 91){
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
              Get.snackbar("Mohon Tunggu", "Data sedang diproses...");
            var myResponse = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/absensi"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : nipSession['nip'],
                    "tanggal" : DateFormat("yyyy-MM-dd").format(now),
                    "sd" : sd,
                    "sp" : sp,
                    "id_th" : "1",
                    "jamd" : DateFormat.Hms().format(jamDatangC),
                    "jamp" : DateFormat.Hms().format(jamPulangC),
                  }
                );

                Map<String, dynamic> data = json.decode(myResponse.body) as Map<String, dynamic>;
                print(myResponse.body);

                Get.back();
                Get.back();
                Get.snackbar("Sukses","Data Datang Berhasil Masuk ke API");
                print("Data Datang Berhasil Masuk ke API");
                isLoading.value = false;

            } else {
              Get.snackbar("Gagal","Data Datang Gagal Masuk ke API");
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
              fontWeight: FontWeight.w500
            ),
            ),
          ),
        ]
      );

    } else {
      //sudah pernah absen, cek hari ini udah absen datang atau keluar udah belum?
      DocumentSnapshot<Map<String, dynamic>> todayDoc = await colPresence.doc(todayDocID).get();

      // print(todayDoc.exists);

      if(todayDoc.exists == true){
        // tinggal absen pulang atau sudah 2-2nya 
        Map<String, dynamic>? dataPresenceToday =  todayDoc.data();
        if (dataPresenceToday?["pulang"] != null){
          // sudah absen datang dan pulang
          Get.snackbar("Informasi Penting", "Anda telah presensi Datang dan Pulang hari ini. Tidak dapat mengubah data kembali.");
        } else {
          /////////////////////////////////// absen pulang ////////////////////////////////////////
          await Get.defaultDialog(
        title: "Validasi Presensi",
        titleStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
        middleText: "Apakah Anda yakin ingin mengisi Presensi Pulang sekarang?",
        middleTextStyle: GoogleFonts.poppins(
          fontSize : 13,
          fontWeight: FontWeight.w400
        ),
        actions: [
          OutlinedButton(
            onPressed: ()=> Get.back(), 
          child: Text(
            "Batalkan",
            style: GoogleFonts.poppins(
              color: Color(0xff333333),
              fontSize: 12,
            )
            )
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              backgroundColor: Color(0xffFFC107)
            ),
            onPressed: () async {
              await colPresence.doc(todayDocID).update({
              "pulang" : {
              "date" : now.toIso8601String(),
              "lat" : position.latitude,
              "long" : position.longitude,
              "alamat" : alamat,
              "status" : status,
              "distance" : distance,
        },
        });
          Get.back();
          Get.snackbar("Berhasil", "Anda berhasil mengisi Presensi Pulang");

          String datangPresence = now.toIso8601String(); //Interpolasi dari Firestore
      String pulangPresence = now.toIso8601String(); //Interpolasi dari Firestore
      // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

      var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
      var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

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
            return b = j3;
          } else {
            return b = j2;
          }
        }
            String jp =  cekHari(hariSekarang);
            
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

      DateTime jam = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 15, 1); // test
      DateTime PJ1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 45, 0); // Patokan jam masuk //

      DateTime jam1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 15, 46, 0); // test
      DateTime PJ2 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(jam2), int.parse(menit2), 0); // Patokan jam pulang //
      
      // strtotime - Convert DateTime to millisecond //
      int jamDatangStr = jamDatangC.millisecondsSinceEpoch;
      int jamPulangStr = jamPulangC.millisecondsSinceEpoch;
      int datang = PJ1.millisecondsSinceEpoch;
      int pulang = PJ2.millisecondsSinceEpoch;
      // strtotime - Convert DateTime to millisecond - end //

      // Logic Status Jam //
      double hasil = (jamDatangStr - datang)/60000;
      int ddat = hasil.ceil();

      double hasil2 = (pulang - jamPulangStr)/60000;
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
          } else if (d >= 1 && d <= 30){
            return statusd = "TL1";
          } else if (d >= 31 && d <= 60){
            return statusd = "TL2";
          } else if (d >= 61 && d <= 90){
            return statusd = "TL3";
          } else if (d >= 91){
            return statusd = "TL4";
          }
        }

        cekStatusPulang(int p) {
          String statusp;
          if (p < 1) {
            return statusp = "Sesuai Waktu";
          } else if (p >= 1 && p <= 30){
            return statusp = "PSW1";
          } else if (p >= 31 && p <= 60){
            return statusp = "PSW2";
          } else if (p >= 61 && p <= 90){
            return statusp = "PSW3";
          } else if (p >= 91){
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
          
          //// POST DATA PULANG KE API ABSENSI ////
            if (todayDoc.exists == true) {
              Get.snackbar("Mohon Tunggu", "Data sedang diproses...");
            var myResponse = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/absensi"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : nipSession['nip'],
                    "tanggal" : DateFormat("yyyy-MM-dd").format(now),
                    "sd" : sd,
                    "sp" : sp,
                    "id_th" : "1",
                    "jamd" : DateFormat.Hms().format(jamDatangC),
                    "jamp" : DateFormat.Hms().format(jamPulangC),
                  }
                );

                Map<String, dynamic> data = json.decode(myResponse.body) as Map<String, dynamic>;
                print(myResponse.body);

                Get.back();
                Get.back();
                Get.snackbar("Sukses","Data Pulang Berhasil Masuk ke API");
                print("Data Pulang Berhasil Masuk ke API");
                isLoading.value = false;

            } else {
              Get.snackbar("Gagal","Data Pulang Gagal Masuk ke API");
              print("Data Pulang Gagal Terupdate, Coba Kembali");
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
              fontWeight: FontWeight.w500
            ),
            )
          ),
        ]
      );
      } 
      } else {
        // absen datang
       await Get.defaultDialog(
        title: "Validasi Presensi",
          titleStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
        middleText: "Apakah Anda yakin ingin mengisi Presensi Datang sekarang?",
        middleTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400
        ),
        actions: [
          OutlinedButton(
            onPressed: ()=> Get.back(), 
          child: Text(
            "Batalkan",
            style: GoogleFonts.poppins(
              color: Color(0xff333333),
              fontSize: 12,
            ),
            )
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              backgroundColor: Color(0xffFFC107),
            ),
            onPressed: () async {
              await colPresence.doc(todayDocID).set({
              "date" : now.toIso8601String(),
              "datang" : {
              "date" : now.toIso8601String(),
              "lat" : position.latitude,
              "long" : position.longitude,
              "alamat" : alamat,
              "status" : status,
              "distance" : distance,
            }
          });
          Get.back();
          Get.snackbar("Berhasil", "Anda berhasil mengisi Presensi Datang");

      String datangPresence = now.toIso8601String(); //Interpolasi dari Firestore
      String pulangPresence = now.toIso8601String(); //Interpolasi dari Firestore
      // String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

      var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
      var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

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
            return b = j3;
          } else {
            return b = j2;
          }
        }
            String jp =  cekHari(hariSekarang);
            
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

      DateTime jam = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 15, 1); // test
      DateTime PJ1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 45, 0); // Patokan jam masuk //

      DateTime jam1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 15, 46, 0); // test
      DateTime PJ2 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(jam2), int.parse(menit2), 0); // Patokan jam pulang //
      
      // strtotime - Convert DateTime to millisecond //
      int jamDatangStr = jamDatangC.millisecondsSinceEpoch;
      int jamPulangStr = jamPulangC.millisecondsSinceEpoch;
      int datang = PJ1.millisecondsSinceEpoch;
      int pulang = PJ2.millisecondsSinceEpoch;
      // strtotime - Convert DateTime to millisecond - end //

      // Logic Status Jam //
      double hasil = (jamDatangStr - datang)/60000;
      int ddat = hasil.ceil();

      double hasil2 = (pulang - jamPulangStr)/60000;
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
          } else if (d >= 1 && d <= 30){
            return statusd = "TL1";
          } else if (d >= 31 && d <= 60){
            return statusd = "TL2";
          } else if (d >= 61 && d <= 90){
            return statusd = "TL3";
          } else if (d >= 91){
            return statusd = "TL4";
          }
        }

        cekStatusPulang(int p) {
          String statusp;
          if (p < 1) {
            return statusp = "Sesuai Waktu";
          } else if (p >= 1 && p <= 30){
            return statusp = "PSW1";
          } else if (p >= 31 && p <= 60){
            return statusp = "PSW2";
          } else if (p >= 61 && p <= 90){
            return statusp = "PSW3";
          } else if (p >= 91){
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
              Get.snackbar("Mohon Tunggu", "Data sedang diproses...");
            var myResponse = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/absensi"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : nipSession['nip'],
                    "tanggal" : DateFormat("yyyy-MM-dd").format(now),
                    "sd" : sd,
                    "sp" : sp,
                    "id_th" : "1",
                    "jamd" : DateFormat.Hms().format(jamDatangC),
                    "jamp" : DateFormat.Hms().format(jamPulangC),
                  }
                );

                Map<String, dynamic> data = json.decode(myResponse.body) as Map<String, dynamic>;
                print(myResponse.body);

                Get.back();
                Get.back();
                Get.snackbar("Sukses","Data Datang Berhasil Masuk ke API");
                print("Data Datang Berhasil Masuk ke API");
                isLoading.value = false;

            } else {
              Get.snackbar("Gagal","Data Datang Gagal Masuk ke API");
              print("Data Datang Gagal Terupdate, Coba Kembali");
              Get.offAllNamed(Routes.HOME);
              isLoading.value = false;
            }
            //// POST DATA DATANG KE API ABSENSI - end ////
            }, 
          child: Text("Presensi")
          ),
        ]
      );
      }
    }
  }

  Future <void> updatePosition(Position position, String alamat) async {
    String uid = await auth.currentUser!.uid;

    firestore.collection("user").doc(uid).update({
      "position" : {
        "lat" : position.latitude,
        "long" : position.longitude,
      },
        "alamat" : alamat,
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
      "message" : "Tidak dapat mengambil GPS dari device ini",
      "error" : true,
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
      "message" : "Izin menggunakan GPS ditolak.",
      "error" : true,
      };
      //return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return {
    "message" : "Pengaturan HP Anda tidak memperbolehkan untuk mengakses GPS. Ubah pada pengaturan HP Anda",
    "error" : true,
    };
    //return Future.error(
      //'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  Position position =  await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  return {
    "position" : position,
    "message" : "Berhasil mendapatkan posisi device Anda",
    "error" : false,
    };
}
}
