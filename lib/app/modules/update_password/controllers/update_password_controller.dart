import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UpdatePasswordController extends GetxController {

  RxBool isLoading = false.obs;
  TextEditingController currC = TextEditingController();
  TextEditingController newP = TextEditingController();
  TextEditingController confirmP = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void updatePass() async {
    if (currC.text.isNotEmpty && newP.text.isNotEmpty && confirmP.text.isNotEmpty){
      if (newP.text == confirmP.text){
        isLoading.value = true;
        try {
          String emailUser =  auth.currentUser!.email!;

            await auth.signInWithEmailAndPassword(email: emailUser, password: currC.text);

            await auth.currentUser!.updatePassword(newP.text);

          Get.back();
          Get.snackbar("Berhasil", "Password baru Anda sudah diperbaharui!");

        } on FirebaseAuthException catch (e) {
          if(e.code == "wrong-password"){
            Get.snackbar("Terjadi Kesalahan", "Password lama Anda salah!");
          } else {
            Get.snackbar("Terjadi Kesalahan", "${e.code.toLowerCase()}");
          }
        } catch (e) {
          Get.snackbar("Terjadi Kesalahan", "Tidak dapat mengganti password!");
        } finally {
          isLoading.value = false;
        }
        //
      } else {
        Get.snackbar("Terjadi Kesalahan", "Konfirmasi password tidak cocok. Silahkan coba kembali.");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Semua input harus diisi!");
    }
  }
}
