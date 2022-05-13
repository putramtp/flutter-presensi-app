import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';

class NewPasswordController extends GetxController {
TextEditingController newPassC = TextEditingController();
FirebaseAuth auth = FirebaseAuth.instance;

  void newPasword() async {
    if (newPassC.text.isNotEmpty){
      if (newPassC.text != "kabtasikjuara"){
        try {
          String email = auth.currentUser!.email!;
        await auth.currentUser!.updatePassword(newPassC.text);

        await auth.signOut();

        auth.signInWithEmailAndPassword(
          email: email, 
          password: newPassC.text,
        );

        Get.offAllNamed(Routes.HOME);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password'){
          Get.snackbar("Terjadi Kesalahan", "Password Lemah, silahkan buat kembali");
        } 
        } catch (e){
          Get.snackbar("Terjadi Kesalahan", "Tidak dapat membuat password baru. Silahkan hubungi Admin");
        }
        
      } else {
        Get.snackbar("Terjadi Kesalahan", "Password baru harus berbeda! Segera ubah password Anda.");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Password baru wajib diisi");
    }
  }
}
