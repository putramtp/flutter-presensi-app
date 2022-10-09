import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddPegawai = false.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController nipC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future <void> login() async {
    if(nipC.text.isNotEmpty && passC.text.isNotEmpty){
            isLoading.value = true;
            try {
              UserCredential userCredential = 
              await auth.signInWithEmailAndPassword(
                email: nipC.text + "@tasikmalayakab.go.id", 
                password: md5.convert(utf8.encode(passC.text)).toString()
                );

                print(UserCredential);
                print(nipC.text + "@tasikmalayakab.go.id");
                print(md5.convert(utf8.encode(passC.text)).toString());

                if(userCredential.user != null){
                  
                  Get.offAllNamed(Routes.HOME);
                  Get.snackbar("Login Berhasil", "Selamat menggunakan SADASBOR");
                } else {
                  isLoading.value = false;
                  Get.snackbar("Terjadi Kesalahan", "Tidak dapat login");
                }

            
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found'){
        Get.snackbar("Mohon Tunggu", "Sedang menyinkronkan akun Anda...");
            var myResponse = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/mobile"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : nipC.text, //199109102019031003
                  }
                );

                Map<String, dynamic> data = json.decode(myResponse.body) as Map<String, dynamic>;


                var postHome = await http.post(
                  Uri.parse("https://apisadasbor.tasikmalayakab.go.id/api/pegawai"),
                  headers: {
                    HttpHeaders.authorizationHeader : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJJZFVzZXIiOiI2IiwiVXNlcm5hbWUiOiJlcHVsIn0.kpMrrLuf-go9Qg0ZQnEw3jVPLuSSnEBXkCq-DvhxJzw',
                  },
                  body: {
                    "nip" : nipC.text,
                  }
                );

                // Tasiksiap2022

                Map<String, dynamic> dataPegawai = json.decode(postHome.body) as Map<String, dynamic>;

              print(myResponse.body);
              print(postHome.body);
              print(md5.convert(utf8.encode(passC.text)).toString()); // MD5 HASH Pasword

              if (nipC.text.isNotEmpty && passC.text.isNotEmpty) {
                isLoading.value = true;
                try {
                  
                  // cek nip apakah terdaftar atau tidak
                  if(nipC.text == data['data']['nip'] && md5.convert(utf8.encode(passC.text)).toString() == data['data']['password']){  // cek nip apakah terdaftar atau tidak, jika nip dan password sama dengan api, login
                  Get.snackbar("NIP Ditemukan", "Sinkronisasi berjalan...");
                  UserCredential userCredential = 
                    await auth.createUserWithEmailAndPassword(
                      email: nipC.text + "@tasikmalayakab.go.id", 
                      password: md5.convert(utf8.encode(passC.text)).toString()
                      );

                      if(userCredential.user != null) {
                        String uid = userCredential.user!.uid;

                        await firestore.collection("user").doc(uid).set({
                          "nip" : nipC.text,
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
                          "status" : dataPegawai['data']['pns'],
                          "id_jabatan" : data['data']['id_jabatan'],
                          "password" : data['data']['password'],
                          "level" : data['data']['level'],
                          "id_skpd" : data['data']['id_skpd'],
                          "lat" : data['data']['lat'],
                          "long" : data['data']['long'],
                          "uid" : uid,
                          "role" : "pegawai",
                          "createdAt" : DateTime.now().toIso8601String(),
                          
                        });

                        // await userCredential.user!.sendEmailVerification();

                        await auth.signOut();


                      //  await auth.signInWithEmailAndPassword(
                      //    email: email, 
                      //    password: password)

                        Get.back();
                        Get.back();
                        Get.snackbar("Sinkronisasi Berhasil", "Selamat menggunakan SADASBOR!");
                        login(); //jika berhasil sinkron, auto login dengan inputan nip dan password tersebut
                        isLoadingAddPegawai.value = false;
                    } else {
                Get.snackbar("Terjadi Kesalahan", "Gagal sinkronisasi data");
                Get.offAllNamed(Routes.LOGIN);
                isLoading.value = false;
                
              }
            
                        
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar("Terjadi Kesalahan", "E-mail sudah ada. Tidak dapat menambah pegawai dengan email ini");
      }
    } catch (e) {
    Get.snackbar("Terjadi Kesalahan", "NIP tidak terdaftar pada sistem");
    Get.offAllNamed(Routes.LOGIN);
    }
              }
      }
    }
    }
  }
}