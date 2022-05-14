import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    pageIndex.value = i;
    switch (i) {
      case 1 :
        print("ABSENSI");
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse["error"] != true){
          Position position = dataResponse["position"];

          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          // print(placemarks[0]);
          String alamat = "${placemarks[0].street} , ${placemarks[0].subLocality} , ${placemarks[0].locality} , ${placemarks[0].subAdministrativeArea}";
          await updatePosition(position, alamat);


          //absen
          await presensi(position, alamat);

          Get.snackbar("Berhasil", "Anda berhasil mengisi daftar hadir");

          Get.snackbar("${dataResponse['message']}" , alamat);
        } else {
          Get.snackbar("Terjadi Kesalahan", dataResponse["message"]);
        }
        break;
      case 2 : 
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future <void> presensi(Position position, String alamat) async {
    String uid = await auth.currentUser!.uid;

    CollectionReference<Map<String, dynamic>> colPresence =  firestore.collection("pegawai").doc(uid).collection("presence");

    QuerySnapshot<Map<String, dynamic>> snapPresence =  await colPresence.get();

    //print(snapPresence.docs.length);
    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");
    print(todayDocID);

    if (snapPresence.docs.length == 0){
      //belum pernah absen & set absen datang

     await colPresence.doc(todayDocID).set({
        "date" : now.toIso8601String(),
        "datang" : {
          "date" : now.toIso8601String(),
          "lat" : position.latitude,
          "long" : position.longitude,
          "alamat" : alamat,
          "status" : "Didalam Area",
        }
      });

    } else {
      //sudah pernah absen, cek hari ini udah absen datang atau keluar udah belum?
    }
  }

  Future <void> updatePosition(Position position, String alamat) async {
    String uid = await auth.currentUser!.uid;

    firestore.collection("pegawai").doc(uid).update({
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
  Position position =  await Geolocator.getCurrentPosition();
  return {
    "position" : position,
    "message" : "Berhasil mendapatkan posisi device Anda",
    "error" : false,
    };
}
}
