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
          Uri.parse("https://kinerja.tasikmalayakab.go.id/api/mobile"),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
          },
          body: {
            "nip": nipSession['nip'], //199109102019031003
          });

      Map<String, dynamic> data =
          json.decode(myResponse.body) as Map<String, dynamic>;

      var postHome = await http.post(
          Uri.parse("https://kinerja.tasikmalayakab.go.id/api/pegawai"),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
          },
          body: {
            "nip": nipSession['nip'],
          });
      Map<String, dynamic> dataPegawai =
          json.decode(postHome.body) as Map<String, dynamic>;

      print(postHome.body);
      print(myResponse.body);

      await firestore.collection("user").doc(uid).set({
        "nip": nipSession['nip'],
        "nama_pegawai": dataPegawai['mapData']['data']['nama_pegawai'],
        "gelar_depan": dataPegawai['mapData']['data']['gelar_depan'],
        "gelar_nonakademis": dataPegawai['mapData']['data']
            ['gelar_nonakademis'],
        "gelar_belakang": dataPegawai['mapData']['data']['gelar_belakang'],
        "tempat_lahir": dataPegawai['mapData']['data']['tempat_lahir'],
        "tanggal_lahir": dataPegawai['mapData']['data']['tanggal_lahir'],
        "gender": dataPegawai['mapData']['data']['gender'],
        "nama_pangkat": dataPegawai['mapData']['data']['nama_pangkat'],
        "nama_golongan": dataPegawai['mapData']['data']['nama_golongan'],
        "tmt_pangkat": dataPegawai['mapData']['data']['tmt_pangkat'],
        "jenis_jabatan": dataPegawai['mapData']['data']['jenis_jabatan'],
        "nomenklatur_jabatan": dataPegawai['mapData']['data']
            ['nomenklatur_jabatan'],
        "tmt_jabatan": dataPegawai['mapData']['data']['tmt_jabatan'],
        "nama_jenjang": dataPegawai['mapData']['data']['nama_jenjang'],
        "tmt_cpns": dataPegawai['mapData']['data']['tmt_cpns'],
        "tmt_pns": dataPegawai['mapData']['data']['tmt_pns'],
        "nomenklatur_pada": dataPegawai['mapData']['data']['nomenklatur_pada'],
        "nama_unor": dataPegawai['mapData']['data']['nama_unor'],
        "nik": dataPegawai['mapData']['data']['nik'],
        "status": dataPegawai['mapData']['data']['status'],
        "file_dokumen": dataPegawai['mapData']['data']['file_dokumen'],
        "id_jabatan": data['mapData']['data']['id_jabatan'],
        "password": data['mapData']['data']['password'],
        "level": data['mapData']['data']['level'],
        "id_skpd": data['mapData']['data']['id_skpd'],
        "lat": data['mapData']['data']['lat'],
        "long": data['mapData']['data']['long'],
        "uid": uid,
        "j2": data['mapData']['data']['j2'],
        "j3": data['mapData']['data']['j3'],
        "nama_lokasi": data['mapData']['data']['nama_lokasi'],
        "role": "pegawai",
        "createdAt": DateTime.now().toIso8601String(),
      });
      Get.snackbar("Berhasil", "Profil Anda Sudah Berhasil Diperbaharui.");
    } catch (e) {
      Get.snackbar("Terjadi Kesalahan",
          "Perbaharui Profil Gagal, Coba Beberapa Saat Lagi");
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
