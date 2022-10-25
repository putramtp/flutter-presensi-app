import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetailPresensiController extends GetxController {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  Stream<DocumentSnapshot<Map<String, dynamic>>> streamTodayPresence() async* {
    String uid = auth.currentUser!.uid;

    String todayID = DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");

    yield* firestore.collection("user").doc(uid).collection("presence").doc(todayID).snapshots();
  }

  Future <void> postSync() async {
    String uid = await auth.currentUser!.uid;
    
    CollectionReference<Map<String, dynamic>> colPresence =  firestore.collection("user").doc(uid).collection("presence");
    QuerySnapshot<Map<String, dynamic>> snapPresence =  await colPresence.get();
    print(snapPresence.docs.length);
    print("Check Length");
  }
}
