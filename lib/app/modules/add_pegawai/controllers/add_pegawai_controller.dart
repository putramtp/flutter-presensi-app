import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddPegawaiController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddPegawai = false.obs;
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> prosesAddPegawai() async {

    if (passAdminC.text.isNotEmpty) {
      isLoadingAddPegawai.value = true;
      try {
         String emailAdmin = auth.currentUser!.email!;
         
         UserCredential userCredentialAdmin = await auth.signInWithEmailAndPassword(
           email: emailAdmin, password: passAdminC.text);

         UserCredential pegawaiCredential = await auth.createUserWithEmailAndPassword(
           email: emailC.text, 
           password: "kabtasikjuara"
           ); 
           
           if (pegawaiCredential.user != null) {
           String uid = pegawaiCredential.user!.uid;

           await firestore.collection("pegawai").doc(uid).set({
             "nip": nipC.text,
             "name": nameC.text,
             "email": emailC.text,
             "uid": uid,
             "role" : "pegawai",
             "createdAt": DateTime.now().toIso8601String(),
           });

           await pegawaiCredential.user!.sendEmailVerification();

           await auth.signOut();

           UserCredential userCredentialAdmin = await auth.signInWithEmailAndPassword(
           email: emailAdmin, password: passAdminC.text);

          //  await auth.signInWithEmailAndPassword(
          //    email: email, 
          //    password: password)

           Get.back();
           Get.back();
           Get.snackbar("Berhasil", "Berhasil menambahkan pegawai");
           isLoadingAddPegawai.value = false;
           }

      } 
      on FirebaseAuthException catch (e) {
        isLoadingAddPegawai.value = false;
        if (e.code == 'weak-password') {
          Get.snackbar("Terjadi Kesalahan", "Password yang digunakan terlalu singkat dan mudah");
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Terjadi Kesalahan", "Pegawai sudah ada, Anda tidak dapat menambahkan dengan email ini lagi");
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Terjadi Kesalahan", "Password yang Anda masukkan salah. Silahkan coba kembali");
        } else {
          Get.snackbar("Terjadi Kesalahan", "${e.code}");
        }
      } catch (e) {
        isLoadingAddPegawai.value = false;
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat menambahkan pegawai");
      }
    } else {
      isLoadingAddPegawai.value = false;
      Get.snackbar("Terjadi Kesalahan", "Password harus diisi.");
    }
    
  }

  Future <void> addPegawai() async {
    if (nameC.text.isNotEmpty && nipC.text.isNotEmpty && emailC.text.isNotEmpty) {
      isLoading.value = true;
      Get.defaultDialog(
        title: "Validasi Admin",
        content: Column(
          children: [
            Text("Masukkan Password Validasi Admin"),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: passAdminC,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
          isLoading.value = false;
          Get.back();
          }, 
          child: Text("Kembali"),),
          Obx(
            ()=> ElevatedButton(
            onPressed: () async { 
              if(isLoadingAddPegawai.isFalse){
                 await prosesAddPegawai();
              }
            isLoading.value = false;
          }, child: Text(
            isLoadingAddPegawai.isFalse ? "Tambah Pegawai" : "Loading..."),
            ),
          ), 
        ],
      );
    } else {
      Get.snackbar("Terjadi Kesalahan", "NIP, Nama dan Email harus diisi");
    }
  }
}
