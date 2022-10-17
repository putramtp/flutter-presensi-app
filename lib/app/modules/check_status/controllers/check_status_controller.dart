import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckStatusController extends GetxController {

  RxBool isLoading = false.obs;
  RxBool isLoadingAddDinasLuar = false.obs;
  TextEditingController jamdatang = TextEditingController();
  TextEditingController jampulang = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  DateTime today = new DateTime.now();


  Future <void> checkStatus() async {
    final User user = auth.currentUser!;
    final uid = user.uid;

    CollectionReference<Map<String, dynamic>> colPresence =  firestore.collection("user").doc(uid).collection("presence");
    QuerySnapshot<Map<String, dynamic>> snapPresence =  await colPresence.get();
    print(snapPresence.docs.length);

    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

    final nipSession = await firestore.collection("user").doc(uid).get();

    DocumentSnapshot<Map<String, dynamic>> todayDoc = await colPresence.doc(todayDocID).get();
    Map<String, dynamic>? dataPresenceToday =  todayDoc.data();

    String datangPresence = dataPresenceToday?['datang']['date']; //Interpolasi dari Firestore
    String pulangPresence = dataPresenceToday?['pulang']['date']; //Interpolasi dari Firestore

    var parsedDatangPresence = DateTime.parse(datangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)
    var parsedPulangPresence = DateTime.parse(pulangPresence); //Convert hasil interpolasi jadi DateTime (supaya bisa di convert ke ms)

    print(parsedDatangPresence);
    print(parsedPulangPresence);

    // int timestamp = j1.millisecondsSinceEpoch;
    // print(timestamp);

    // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase //
    String j2 = nipSession['j2'];
    String j3 = nipSession['j3'];
    // Get data (Jenis Jam Pulang) masing - masing NIP dari Firebase - end //
  
    // String sekarang = DateFormat("EEE").format(DateTime(2022, 10, 15));
    String sekarang = DateFormat("EEE").format(DateTime.now());
    print(sekarang);

  cekHari(String hari) {
    String b;
    if (hari == 'Fri') {
      return b = j3;
    } else {
      return b = j2;
    }
  }
      String jp =  cekHari(sekarang);
      
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

    int jamd = jam.millisecondsSinceEpoch; // test //

    // Logic Status Jam //
    double hasil = (jamDatangStr - datang)/60000;
    int ddat = hasil.ceil();

    int jamp = jam1.millisecondsSinceEpoch;
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
        String? statusDatang = cekStatusDatang(ddat);
        print(statusDatang);


        // Cetak Status Pulang //
        String? statusPulang = cekStatusPulang(dpul);
        print(statusPulang);
      }

}
