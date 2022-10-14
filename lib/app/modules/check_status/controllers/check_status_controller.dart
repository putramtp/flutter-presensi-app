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

    String todayID = DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");

    final nipSession = await firestore.collection("user").doc(uid).get();
    final presenceDate = firestore.collection("user").doc(uid).collection("presence").doc(todayID).snapshots();
    // CollectionReference<Map<String, dynamic>> colPresence = firestore.collection("user").doc(uid).collection("presence");

    // int timestamp = j1.millisecondsSinceEpoch;
    // print(timestamp);

    //get data dari firebase
    String j2 = nipSession['j2'];
    String j3 = nipSession['j3'];
  
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
    // String jamFB = presenceDate['datang']['date'];

    // print(jamFB);
    

    // DateTime jam = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 15, 1); //////
    DateTime jam = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 15, 1);
    DateTime jj1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 45, 0);

    DateTime jam1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 15, 46, 0); ///////
    DateTime jj2 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(jam2), int.parse(menit2), 0);
    
    
    int datang = jj1.millisecondsSinceEpoch;
    int pulang = jj2.millisecondsSinceEpoch;

    int jamd = jam.millisecondsSinceEpoch; 
    double hasil = (jamd - datang)/60000;
    int ddat = hasil.ceil();

    int jamp = jam1.millisecondsSinceEpoch;
    double hasil2 = (pulang - jamp)/60000;
    int dpul = hasil2.ceil();

    // print(ddat);
    // print(jamd);
    // print(datang);
    // print(hasil);
    // // print(dpul);

cekstatus(int a) {
  String status;
    if (a <= 0) {
      return status = "Tepat Waktu";
    } else if (a >= 1 && a <= 30){
      return status = "TL1";
    } else if (a >= 31 && a <= 60){
      return status = "TL2";
    } else if (a >= 61 && a <= 90){
      return status = "TL3";
    } else if (a >= 91){
      return status = "TL4";
    }
  }
    // print(cekstatus(ddat));

    String? sd = cekstatus(ddat);
    print(sd);
  }

}
