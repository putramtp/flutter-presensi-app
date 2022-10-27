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
      var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      var lastPosition = await Geolocator.getLastKnownPosition();
      print(lastPosition);
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();  
      
      locationMessage = "$position";
      print(latitude);
      print(longitude);
    }
  
  var selectedDate = DateTime.now().obs;

  defaultDate() async {
  }

  chooseDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!, 
      initialDate: selectedDate.value, 
      firstDate: DateTime.now(), 
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(). copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xffFFC107)
            ),
          ), child: child!,
        );
      }
      );

      if (pickedDate != null && pickedDate != selectedDate.value){
        selectedDate.value = pickedDate;
        dateInput.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate.value).toString();
      }
      print(pickedDate);
  }


  Future <void> addSakit() async {
    final User user = auth.currentUser!;
    final uid = user.uid;

    final nipSession = await firestore.collection("user").doc(uid).get();

    if (keterangan.text.isNotEmpty) {
      Get.snackbar("Mohon Tunggu", "Data sedang diproses...");
            var myResponse = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/sakit"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : nipSession['nip'],
                    "tgl" : DateFormat("yyyy-MM-dd HH:mm:ss").format(selectedDate.value),
                    "ket" : keterangan.text,
                    "status" : "menunggu",
                  }
                );

                Map<String, dynamic> data = json.decode(myResponse.body) as Map<String, dynamic>;
                print(myResponse.body);

                Get.back();
                Get.back();
                Get.snackbar("Berhasil", "Pengajuan Sakit Anda sudah diproses!",
                  duration: const Duration(seconds: 6),
                );
                Get.offAllNamed(Routes.WORKFROMHOME);
                isLoading.value = false;
    } else {
      Get.snackbar("Terjadi Kesalahan", "Gagal memproses data. Silahkan coba kembali.");
      Get.offAllNamed(Routes.WORKFROMHOME);
      isLoading.value = false;
    }

  }
}
