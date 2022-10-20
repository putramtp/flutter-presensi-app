import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_device/safe_device.dart';
import 'package:trust_location/trust_location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

class CheckStatusController extends GetxController {

  RxBool isLoading = false.obs;
  RxBool isLoadingAddDinasLuar = false.obs;
  TextEditingController jamdatang = TextEditingController();
  TextEditingController jampulang = TextEditingController();
  TextEditingController nipC = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  DateTime today = new DateTime.now();

  Future <void> safeDevice() async {
    bool isRealDevice = await SafeDevice.isRealDevice;
    bool canMockLocation = await SafeDevice.canMockLocation;
    bool isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;

    bool a = !canMockLocation;
    print(a);
    // print(isRealDevice);
    // print(isDevelopmentModeEnable);

    // if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
    //     bool isMockLocation = await TrustLocation.isMockLocation;
    //     print(isMockLocation);
    // }
  }


//   Future <void> checkStatus() async {
//     final User user = auth.currentUser!;
//     final uid = user.uid;

//     CollectionReference<Map<String, dynamic>> colPresence =  firestore.collection("user").doc(uid).collection("presence");
//     QuerySnapshot<Map<String, dynamic>> snapPresence =  await colPresence.get();
//     print(snapPresence.docs.length);

//     DateTime now = DateTime.now();
//     String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

//     final nipSession = await firestore.collection("user").doc(uid).get();

//     DocumentSnapshot<Map<String, dynamic>> todayDoc = await colPresence.doc(todayDocID).get();
//     Map<String, dynamic>? dataPresenceToday =  todayDoc.data();

//     String datangPresence = dataPresenceToday?['datang']['date']; //Interpolasi dari Firestore
//     String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

//     var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
//     var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

//     print(parsedDatangPresence);
//     print(parsedPulangPresence);

//     // int timestamp = j1.millisecondsSinceEpoch;
//     // print(timestamp);

//     // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase //
//     String j2 = nipSession['j2'];
//     String j3 = nipSession['j3'];
//     // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase - end //
  
//     // String sekarang = DateFormat("EEE").format(DateTime(2022, 10, 15));
//     String hariSekarang = DateFormat("EEE").format(now);
//     print(hariSekarang);

//       cekHari(String hari) {
//         String b;
//         if (hari == 'Fri') {
//           return b = j3;
//         } else {
//           return b = j2;
//         }
//       }
//           String jp =  cekHari(hariSekarang);
          
//           final arr = jp.split(':');
    
//     // print(arr[0]);
//     // print(arr[1]);

//     String jam2 = arr[0];
//     String menit2 = arr[1];
    
//     // LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI -- LOGIC STATUS PRESENSI //

//     // Inputan Presensi //
//     DateTime jamDatangC = parsedDatangPresence;
//     DateTime jamPulangC = parsedPulangPresence;
//     // Inputen Presensi - End//
    
//     String jamd = DateFormat.Hms().format(jamDatangC);
//     String jamp = DateFormat.Hms().format(jamPulangC);

//     print(jamd);
//     print(jamp);

//     DateTime jam = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 15, 1); // test
//     DateTime PJ1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 45, 0); // Patokan jam masuk //

//     DateTime jam1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 15, 46, 0); // test
//     DateTime PJ2 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(jam2), int.parse(menit2), 0); // Patokan jam pulang //
    
//     // strtotime - Convert DateTime to millisecond //
//     int jamDatangStr = jamDatangC.millisecondsSinceEpoch;
//     int jamPulangStr = jamPulangC.millisecondsSinceEpoch;
//     int datang = PJ1.millisecondsSinceEpoch;
//     int pulang = PJ2.millisecondsSinceEpoch;
//     // strtotime - Convert DateTime to millisecond - end //


//     // Logic Status Jam //
//     double hasil = (jamDatangStr - datang)/60000;
//     int ddat = hasil.ceil();

//     double hasil2 = (pulang - jamPulangStr)/60000;
//     int dpul = hasil2.ceil();

//     // print(ddat);
//     // print(jamd);
//     // print(datang);
//     // print(hasil);
//     // // print(dpul);

//     cekStatusDatang(int d) {
//       String statusd;
//         if (d <= 0) {
//           return statusd = "Tepat Waktu";
//         } else if (d >= 1 && d <= 30){
//           return statusd = "TL1";
//         } else if (d >= 31 && d <= 60){
//           return statusd = "TL2";
//         } else if (d >= 61 && d <= 90){
//           return statusd = "TL3";
//         } else if (d >= 91){
//           return statusd = "TL4";
//         }
//       }

//       cekStatusPulang(int p) {
//         String statusp;
//         if (p < 1) {
//           return statusp = "Sesuai Waktu";
//         } else if (p >= 1 && p <= 30){
//           return statusp = "PSW1";
//         } else if (p >= 31 && p <= 60){
//           return statusp = "PSW2";
//         } else if (p >= 61 && p <= 90){
//           return statusp = "PSW3";
//         } else if (p >= 91){
//           return statusp = "PSW4";
//         }
//       }
//         // Cetak Status Datang //
//         String? sd = cekStatusDatang(ddat);
//         print(sd);


//         // Cetak Status Pulang //
//         String? sp = cekStatusPulang(dpul);
//         print(sp);
//       }

      Future <void> checkInput() async {
              var myResponse = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/mobile"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : "198408032003122001", //199109102019031003
                  }
                );

                Map<String, dynamic> data = json.decode(myResponse.body) as Map<String, dynamic>;


                var postHome = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/pegawai"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : "198408032003122001",
                  }
                );

                // Tasiksiap2022

                Map<String, dynamic> dataPegawai = json.decode(postHome.body) as Map<String, dynamic>;

              print(myResponse.body);
              print(postHome.body);
              print(md5.convert(utf8.encode("istriasep")).toString()); // MD5 HASH Pasword
               
                  // cek nip apakah terdaftar atau tidak
                  if("198408032003122001" == data['data']['nip'] && md5.convert(utf8.encode("istriasep")).toString() == data['data']['password']){  // cek nip apakah terdaftar atau tidak, jika nip dan password sama dengan api, login
                  print("NIP Ditemukan Sinkronisasi berjalan...");
                  UserCredential userCredential = 
                    await auth.createUserWithEmailAndPassword(
                      email: "198408032003122001@tasikmalayakab.go.id", 
                      password: md5.convert(utf8.encode("istriasep")).toString()
                      );

                      if(userCredential.user != null) {
                        String uid = userCredential.user!.uid;

                        await firestore.collection("user").doc(uid).set({
                          "nip" : nipC.text,
                          "nama_pegawai" : dataPegawai['data']['nama_pegawai'],
                          "gelar_depan" : dataPegawai['data']['gelar_depan'],
                          "gelar_nonakademis" : dataPegawai['data']['gelar_nonakademis'],
                          "gelar_belakang" : dataPegawai['data']['gelar_belakang'],
                          "tempat_lahir" : dataPegawai['data']['tempat_lahir'],
                          "tanggal_lahir" : dataPegawai['data']['tanggal_lahir'],
                          "gender" : dataPegawai['data']['gender'],
                          "nama_pangkat" : dataPegawai['data']['nama_pangkat'],
                          "nama_golongan" : dataPegawai['data']['nama_golongan'],
                          "tmt_pangkat" : dataPegawai['data']['tmt_pangkat'],
                          "jenis_jabatan" : dataPegawai['data']['jenis_jabatan'],
                          "nomenklatur_jabatan" : dataPegawai['data']['nomenklatur_jabatan'],
                          "tmt_jabatan" : dataPegawai['data']['tmt_jabatan'],
                          "nama_jenjang" : dataPegawai['data']['nama_jenjang'],
                          "tmt_cpns" : dataPegawai['data']['tmt_cpns'],
                          "tmt_pns" : dataPegawai['data']['tmt_pns'],
                          "nomenklatur_pada" : dataPegawai['data']['nomenklatur_pada'],
                          "nama_unor" : dataPegawai['data']['nama_unor'],
                          "nik" : dataPegawai['data']['nik'],
                          "status" : dataPegawai['data']['status'],
                          "file_dokumen" : dataPegawai['data']['file_dokumen'],
                          "id_jabatan" : data['data']['id_jabatan'],
                          "password" : data['data']['password'],
                          "level" : data['data']['level'],
                          "id_skpd" : data['data']['id_skpd'],
                          "lat" : data['data']['lat'],
                          "long" : data['data']['long'],
                          "uid" : uid,
                          "j2" : data['data']['j2'],
                          "j3" : data['data']['j3'],
                          "nama_lokasi" : data['data']['nama_lokasi'],
                          "role" : "pegawai",
                          "createdAt" : DateTime.now().toIso8601String(),
                          
                        });

                        // await userCredential.user!.sendEmailVerification();

                        await auth.signOut();


                      //  await auth.signInWithEmailAndPassword(
                      //    email: email, 
                      //    password: password)

                        Get.back();
                        Get.back();
                        Get.snackbar("Login & Sinkronisasi Berhasil", "Selamat menggunakan layanan SADASBOR!");
                      }
                  }}}