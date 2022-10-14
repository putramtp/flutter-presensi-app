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
 
  String jh = '15:45';

  Future <void> checkStatus() async {
    // int timestamp = j1.millisecondsSinceEpoch;
    // print(timestamp);

    final arr = jh.split(':');
    
    print(arr[0]);
    print(arr[1]);

    String jam2 = arr[0];
    String menit2 = arr[1];

    DateTime j0 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 45, 1);
    DateTime j1 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 45, 0);
    DateTime j2 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(jam2), int.parse(menit2), 0);
    
    print(j2);
    
    int timestamp = j1.millisecondsSinceEpoch;
    int timestamp2 = j0.millisecondsSinceEpoch;

    double hasil = (timestamp2 - timestamp)/600000;
    int hasilfix = hasil.ceil();

    print(hasilfix);
    
  }

}
