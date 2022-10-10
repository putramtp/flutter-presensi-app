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

class DinasluarController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddDinasLuar = false.obs;
  TextEditingController suratTugas = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  TextEditingController maksudTujuan = TextEditingController();
  TextEditingController lokasiTujuan = TextEditingController();

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

  chooseDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!, 
      initialDate: selectedDate.value, 
      firstDate: DateTime(1990), 
      lastDate: DateTime(2030)
      );

      if (pickedDate != null && pickedDate != selectedDate.value){
        selectedDate.value = pickedDate;
      }
      print(pickedDate);
  }


  Future <void> addDinasLuar() async {
    final User user = auth.currentUser!;
    final uid = user.uid;

    if (suratTugas.text.isNotEmpty && maksudTujuan.text.isNotEmpty && lokasiTujuan.text.isNotEmpty ) {
      Get.snackbar("Mohon Tunggu", "Data sedang diproses...");
            var myResponse = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/dl"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : uid.toString(),
                    "no_st" : suratTugas.text, //199109102019031003
                    "tgl_st" : DateFormat('yyyy-MM-dd KK:mm:ss').format(DateTime.now()),
                    "maksud" : maksudTujuan.text,
                    "tujuan" : lokasiTujuan.text,
                    "tgl" : DateFormat('yyyy-MM-dd KK:mm:ss').format(DateTime.now()),
                    "lat" : latitude,
                    "long" : longitude,
                    "status" : "menunggu",
                  }
                );

                Map<String, dynamic> data = json.decode(myResponse.body) as Map<String, dynamic>;
                print(myResponse.body);

                Get.back();
                Get.back();
                Get.snackbar("Berhasil", "Data Dinas Luar Anda sudah diproses!");
                Get.offAllNamed(Routes.DINASLUAR);
                isLoading.value = false;
    } else {
      Get.snackbar("Terjadi Kesalahan", "Gagal memproses data. Silahkan coba kembali");
      Get.offAllNamed(Routes.DINASLUAR);
      isLoading.value = false;
    }

  }

}
