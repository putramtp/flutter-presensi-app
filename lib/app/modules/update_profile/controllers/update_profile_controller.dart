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

  Future<void> updateProfileAPI() async {
    final User user = auth.currentUser!;
    final uid = user.uid;
    final nipSession = await firestore.collection("user").doc(uid).get();
    try {
      Get.snackbar("Mohon Tunggu", "Data sedang diperbaharui...");
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

                print(postHome.body);
                print(myResponse.body);

                await firestore.collection("user").doc(uid).set({
                          "nip" : nipSession['nip'],
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
                        Get.snackbar("Berhasil", "Profil Anda Sudah Berhasil Diperbaharui");
    } catch (e) {
      Get.snackbar("Terjadi Kesalahan", "Perbaharui Profil Gagal, Coba Beberapa Saat Lagi");
    }
  }

  void logout() async {
    await auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  backDeviceButton() {
    Get.back();
    Get.offAllNamed(Routes.PROFILE);
  }
}