import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class DinasluarController extends GetxController {
  var selectedDate = DateTime.now().obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  void increment() => count.value++;

  chooseDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!, 
      initialDate: selectedDate.value, 
      firstDate: DateTime(1990), 
      lastDate: DateTime(2030)
      );

      if (pickedDate != null && pickedDate != selectedDate.value){
        selectedDate.value = pickedDate;
      }
      print(pickedDate);
  }
}
