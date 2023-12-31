import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

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

    //print(snapPresence.docs.length);
    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

    String status = "Di Luar Area";

    if(distance <= 200){
      status = "Di dalam Area";
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
        middleText: "Apakah Anda yakin ingin mengisi Presensi Datang sekarang?",
        actions: [
          OutlinedButton(
            onPressed: ()=> Get.back(), 
          child: Text("Batalkan")
          ),
          ElevatedButton(
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
