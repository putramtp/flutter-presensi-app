import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  RxBool isLoading = false.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser() async* {
    String? uid = auth.currentUser!.uid;

    yield* firestore.collection("user").doc(uid).snapshots();
  }

   Stream<QuerySnapshot<Map<String, dynamic>>> streamLastPresence() async* {
    String uid = auth.currentUser!.uid;

    yield* firestore.collection("user").doc(uid).collection("presence").orderBy("date", descending: true).limitToLast(5).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamTodayPresence() async* {
    // API DateTime GMT +07:00
    var myResponse = await http.get(
                  Uri.parse("https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta"),
                );

                Map<String, dynamic> data = json.decode(myResponse.body);

                // print(data);
                // print(myResponse.body);

      var dateTimeAPI = data['dateTime'];

      DateTime dateTimeGMT = DateTime.parse(dateTimeAPI);

      print(dateTimeGMT);
    
    // API DateTime GMT +07:00 - End
    String uid = auth.currentUser!.uid;

    String todayID = DateFormat.yMd().format(dateTimeGMT).replaceAll("/", "-");

    yield* firestore.collection("user").doc(uid).collection("presence").doc(todayID).snapshots();
  }
}
