import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safe_device/safe_device.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddPegawai = false.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController nipC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var isPasswordHidden = true.obs;

  Future<void> safeDevice() async {
    // bool canMockLocation = await SafeDevice.canMockLocation;
    bool isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;
    // print(canMockLocation);
    print(isDevelopmentModeEnable);

    if (isDevelopmentModeEnable == false) {
      //false (asli apk), true (debug)
      login();
    } else {
      await Get.defaultDialog(
          backgroundColor: Color.fromARGB(255, 255, 229, 229),
          title: "Developer Options\nHP Anda Aktif!",
          titleStyle: GoogleFonts.poppins(
              color: Color.fromARGB(255, 168, 7, 7),
              fontSize: 18,
              fontWeight: FontWeight.w800),
          middleText:
              "Silahkan matikan Developer Options/Opsi Pengembang pada setting/pengaturan device Anda, lalu coba kembali.",
          middleTextStyle: GoogleFonts.poppins(
              color: Color.fromARGB(255, 168, 7, 7),
              fontSize: 11,
              fontWeight: FontWeight.w400),
          actions: [
            ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 168, 7, 7),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  "OK",
                  style: GoogleFonts.poppins(
                      color: Color(0xffFFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                )),
          ]);
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  var locationMessage = "";
  var latitude = "";
  var longitude = "";

  void getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator.getLastKnownPosition();
    print(lastPosition);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();

    locationMessage = "$position";
    print(latitude);
    print(longitude);
  }

  Future<void> login() async {
    log("This is Log Print");
    if (nipC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: nipC.text + "@tasikmalayakab.go.id",
            password: md5.convert(utf8.encode(passC.text)).toString());

        print(UserCredential);
        print(nipC.text + "@tasikmalayakab.go.id");
        print(md5.convert(utf8.encode(passC.text)).toString());

        if (userCredential.user != null) {
          Get.offAllNamed(Routes.HOME);
          // Get.snackbar("Login Berhasil", "Selamat menggunakan SADASBOR");
        } else {
          isLoading.value = false;
          Get.snackbar("Terjadi Kesalahan", "Tidak dapat login.");
        }
      } on FirebaseAuthException catch (e) {
        log(e.code);
        if (e.code == 'user-not-found') {
          Get.snackbar("Mohon Tunggu", "Sedang menyinkronkan akun Anda...");
          var myResponse = await http.post(
              Uri.parse("https://kinerja.tasikmalayakab.go.id/api/mobile"),
              headers: {
                HttpHeaders.authorizationHeader:
                    'Bearer 1|trk7epBLLpZSb95Hv8ZvUkFEqUIO0BR5b9MRJyyP',
              },
              body: {
                "nip": nipC.text, //199109102019031003
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
                "nip": nipC.text,
              });

          // Tasiksiap2022

          Map<String, dynamic> dataPegawai =
              json.decode(postHome.body) as Map<String, dynamic>;

          print(myResponse.body);
          print(postHome.body);
          print(md5
              .convert(utf8.encode(passC.text))
              .toString()); // MD5 HASH Pasword

          if (nipC.text.isNotEmpty && passC.text.isNotEmpty) {
            isLoading.value = true;
            try {
              // cek nip apakah terdaftar atau tidak
              if (nipC.text == data['mapData']['data']['nip'] &&
                  md5.convert(utf8.encode(passC.text)).toString() ==
                      data['mapData']['data']['password']) {
                // cek nip apakah terdaftar atau tidak, jika nip dan password sama dengan api, login
                Get.snackbar("NIP Ditemukan", "Sinkronisasi berjalan...");
                UserCredential userCredential =
                    await auth.createUserWithEmailAndPassword(
                        email: nipC.text + "@tasikmalayakab.go.id",
                        password:
                            md5.convert(utf8.encode(passC.text)).toString());

                if (userCredential.user != null) {
                  String uid = userCredential.user!.uid;

                  await firestore.collection("user").doc(uid).set({
                    "nip": nipC.text,
                    "nama_pegawai": dataPegawai['mapData']['data']
                        ['nama_pegawai'],
                    "gelar_depan": dataPegawai['mapData']['data']
                        ['gelar_depan'],
                    "gelar_nonakademis": dataPegawai['mapData']['data']
                        ['gelar_nonakademis'],
                    "gelar_belakang": dataPegawai['mapData']['data']
                        ['gelar_belakang'],
                    "tempat_lahir": dataPegawai['mapData']['data']
                        ['tempat_lahir'],
                    "tanggal_lahir": dataPegawai['mapData']['data']
                        ['tanggal_lahir'],
                    "gender": dataPegawai['mapData']['data']['gender'],
                    "nama_pangkat": dataPegawai['mapData']['data']
                        ['nama_pangkat'],
                    "nama_golongan": dataPegawai['mapData']['data']
                        ['nama_golongan'],
                    "tmt_pangkat": dataPegawai['mapData']['data']
                        ['tmt_pangkat'],
                    "jenis_jabatan": dataPegawai['mapData']['data']
                        ['jenis_jabatan'],
                    "nomenklatur_jabatan": dataPegawai['mapData']['data']
                        ['nomenklatur_jabatan'],
                    "tmt_jabatan": dataPegawai['mapData']['data']
                        ['tmt_jabatan'],
                    "nama_jenjang": dataPegawai['mapData']['data']
                        ['nama_jenjang'],
                    "tmt_cpns": dataPegawai['mapData']['data']['tmt_cpns'],
                    "tmt_pns": dataPegawai['mapData']['data']['tmt_pns'],
                    "nomenklatur_pada": dataPegawai['mapData']['data']
                        ['nomenklatur_pada'],
                    "nama_unor": dataPegawai['mapData']['data']['nama_unor'],
                    "nik": dataPegawai['mapData']['data']['nik'],
                    "status": dataPegawai['mapData']['data']['status'],
                    "file_dokumen": dataPegawai['mapData']['data']
                        ['file_dokumen'],
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

                  // await userCredential.user!.sendEmailVerification();

                  await auth.signOut();

                  //  await auth.signInWithEmailAndPassword(
                  //    email: email,
                  //    password: password)

                  Get.back();
                  Get.back();
                  Get.snackbar("Login & Sinkronisasi Berhasil!",
                      "Selamat menggunakan layanan SADASBOR Kab. Tasikmalaya");
                  login(); //jika berhasil sinkron, auto login dengan inputan nip dan password tersebut
                  isLoadingAddPegawai.value = false;
                } else {
                  Get.snackbar("Terjadi Kesalahan", "Gagal sinkronisasi data.");
                  Get.offAllNamed(Routes.LOGIN);
                  isLoading.value = false;
                }
              } else {
                Get.snackbar(
                  "Terjadi Kesalahan",
                  "Password yang Anda masukkan salah. Harap masukkan password yang benar.",
                  duration: const Duration(seconds: 8),
                );
                Get.offAllNamed(Routes.LOGIN);
              }
            } catch (e) {
              Get.snackbar(
                "Terjadi Kesalahan",
                "NIP yang Anda masukkan tidak terdaftar pada sistem. Silahkan coba kembali.",
                duration: const Duration(seconds: 5),
              );
              Get.offAllNamed(Routes.LOGIN);
            }
          }
        } else if (e.code == 'wrong-password') {
          Get.snackbar(
            "Terjadi Kesalahan",
            "Password yang Anda masukkan salah!",
            duration: const Duration(seconds: 5),
          );
          Get.offAllNamed(Routes.LOGIN);
        } else if (e.code == 'too-many-requests') {
          Get.snackbar(
            "Sistem Sedang Sibuk",
            "Harap coba kembali sekitar 20 detik kedepan.",
            duration: const Duration(seconds: 5),
          );
          Get.offAllNamed(Routes.LOGIN);
        } else if (e.code == 'network-request-failed') {
          Get.snackbar("Jaringan Internet Anda Bermasalah",
              "Silahkan cek kembali koneksi Anda dan pastikan internet Anda berjalan secara normal.",
              duration: const Duration(seconds: 5));
          Get.offAllNamed(Routes.LOGIN);
        }
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "NIP dan Password Anda wajib diisi!",
          duration: const Duration(seconds: 6));
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
