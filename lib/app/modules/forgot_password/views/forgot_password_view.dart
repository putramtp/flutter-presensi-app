import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        centerTitle: true,
      ),
      body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextField(
              autocorrect: false,
              controller: controller.emailC,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Obx(
              ()=> ElevatedButton(
                onPressed: () {
                  if (controller.isLoading.isFalse) {
                    controller.sendEmail();
                  }
                }, child: Text(controller.isLoading.isFalse ? "KIRIM RESET PASSWORD" : "LOADING..."),
              ),
            ), 
          ]),
    );
  }
}
