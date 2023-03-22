import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/new_password_controller.dart';

class NewPasswordView extends GetView<NewPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Password Baru'),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextField(
              controller: controller.currentPassC,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: "Password Lama",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: controller.newPassC,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: controller.confirmPassC,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                  labelText: "Konfirmasi Password Baru",
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 20,
            ),
            Obx(
              () => ElevatedButton(
                  onPressed: () {
                    if (controller.isLoading.isFalse) {
                      controller.newPasword();
                    }
                  },
                  child: Text((controller.isLoading.isFalse)
                      ? "GANTI PASSWORD"
                      : "LOADING...")),
            ),
          ],
        ));
  }
}
