import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:new_version/new_version.dart';

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

    yield* firestore.collection("user").doc(uid).collection("presence").orderBy("date", descending: true).limit(3).snapshots();
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

  // @override 
  // void onInit() async {
  //   super.onInit();
  //   final newVersion = 
  //       NewVersion(androidId: "com.msaiflanwr.presensi", iOSId: "com.msaiflanwr.presensi");
  //       newVersion.showAlertIfNecessary(context: Get.context!);

  //   final status = await newVersion.getVersionStatus();
  //   if (status != null) {
  //         newVersion.showUpdateDialog(
  //           context: Get.context!, 
  //           versionStatus: status,
  //           dialogTitle: "Pembaharuan Tersedia!",
  //           dialogText: "Silahkan perbaharui versi aplikasi untuk mendapatkan fitur terbaru dari SADASBOR.",
  //           allowDismissal: false,
  //           updateButtonText: "Perbaharui",
  //           dismissAction: () {},
  //           dismissButtonText: "Batal"

  //           );
  //   }
  // }
}
