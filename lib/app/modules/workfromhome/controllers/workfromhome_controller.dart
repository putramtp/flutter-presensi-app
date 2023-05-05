import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presensi/app/routes/app_pages.dart';

class WorkfromhomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingSakit = false.obs;
  TextEditingController keterangan = TextEditingController();
  TextEditingController dateInput = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var locationMessage = "";
  var latitude = "";
  var longitude = "";
  // variabel untuk menampung koordinat lokasi

  void getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator.getLastKnownPosition();
    print(lastPosition);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();

    locationMessage = "$position";
    print(latitude);
    print(longitude);
  }

  chooseDate() async {
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

    var selectedDateGMT = dateTimeGMT.obs;

    // API DateTime GMT +07:00 - End
    DateTime? pickedDate = await showDatePicker(
        context: Get.context!,
        initialDate: dateTimeGMT,
        firstDate: dateTimeGMT,
        lastDate: dateTimeGMT,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(primary: Color(0xffFFC107)),
            ),
            child: child!,
          );
        });

    if (pickedDate != null && pickedDate != dateTimeGMT) {
      dateTimeGMT = pickedDate;
      dateInput.text = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(selectedDateGMT.value)
          .toString();
    }
    print(pickedDate);
  }

  var selectedDate = DateTime.now().obs;

  Future<void> realTimeGMT() async {
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

    var selectedDateGMT = dateTimeGMT.obs;
    print(selectedDateGMT);
  }

  Future<void> addSakit() async {
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

    var selectedDateGMT = dateTimeGMT.obs;

    // API DateTime GMT +07:00 - End
    final User user = auth.currentUser!;
    final uid = user.uid;

    final nipSession = await firestore.collection("user").doc(uid).get();

    if (keterangan.text.isNotEmpty) {
      Get.snackbar("Mohon Tunggu", "Data sedang diproses...");
      var myResponse = await http.post(
          Uri.parse("https://kinerja.tasikmalayakab.go.id/api/sakit"),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP'
          },
          body: {
            "nip": nipSession['nip'],
            "tgl":
                DateFormat("yyyy-MM-dd HH:mm:ss").format(selectedDateGMT.value),
            "ket": keterangan.text,
            "status": "menunggu",
          });

      Map<String, dynamic> data =
          json.decode(myResponse.body) as Map<String, dynamic>;
      print(myResponse.body);

      Get.back();
      Get.back();

      var response = await http.post(Uri.https("kinerja.tasikmalayakab.go.id"));
      if (data['status'] == "success" || response.statusCode == 404) {
        Get.snackbar(
          "Berhasil",
          "Pengajuan Sakit Anda sudah diproses!",
          duration: const Duration(seconds: 6),
        );
        Get.offAllNamed(Routes.WORKFROMHOME);
        print("Pengajuan Sakit Berhasil Masuk");
        isLoading.value = false;
      } else if (response.statusCode == 504) {
        Get.snackbar("Terjadi Kesalahan",
            "API Server Sedang Gangguan, Mohon Tunggu Hingga Normal Kembali (504)");
        print("error 504");
      }
    } else {
      Get.snackbar(
          "Terjadi Kesalahan", "Gagal memproses data. Silahkan coba kembali.");
      Get.offAllNamed(Routes.WORKFROMHOME);
      isLoading.value = false;
    }
  }

  backDeviceButton() {
    Get.offAllNamed(Routes.HOME);
  }
}
