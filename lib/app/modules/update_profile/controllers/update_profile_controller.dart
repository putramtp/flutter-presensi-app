import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UpdateProfileController extends GetxController {

  RxBool isLoading = false.obs;
  TextEditingController nipC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final ImagePicker picker = ImagePicker();

  XFile? image;

  void pickImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null){
      print(image!.name);
      print(image!.name.split(".").last);
      print(image!.path);
    } else {
      print(image);
    }
      update();
  }

  Future<void> updateProfile(String uid) async {
    if (nameC.text.isNotEmpty && emailC.text.isNotEmpty && nipC.text.isNotEmpty){
      isLoading.value = true;
      try {
        if (image != null) {
          //proses upload image ke firebase storage
        }
        await firestore.collection("pegawai").doc(uid).update({
        "name" : nameC.text,
      });
        Get.snackbar("Berhasil", "Berhasil memperbarui profil");
      } catch (e) {
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat memperbarui profil");
      } finally {
      isLoading.value = false;
      }
    } 
  }
}
