import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:http/http.dart' as http;

class UpdateProfileController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var isDataLoading = false.obs;

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser() async* {
    String uid = await auth.currentUser!.uid;

    yield* firestore.collection("user").doc(uid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamTodayProfile() async* {
    final User user = auth.currentUser!;
    final uid = user.uid;
    final nipSession = await firestore.collection("user").doc(uid).get();
    var myResponse = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/mobile"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : nipSession['nip'], //199109102019031003
                  }
                );

                Map<String, dynamic> data = json.decode(myResponse.body) as Map<String, dynamic>;


                var postHome = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/pegawai"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : nipSession['nip'],
                  }
                );
                Map<String, dynamic> dataPegawai = json.decode(postHome.body) as Map<String, dynamic>;
  }

  void logout() async {
    await auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  backDeviceButton() {
    Get.back();
  }
}