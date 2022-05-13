import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
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
            TextField(
              autocorrect: false,
              controller: controller.passC,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Obx(
              ()=> ElevatedButton(
              onPressed: () async {
                if (controller.isLoading.isFalse){
                  await controller.login();
                }
              }, 
              child: Text(controller.isLoading.isFalse ? "LOGIN" : "LOADING..."),
            ),
            ),
            TextButton(
              onPressed: 
                ()=> Get.toNamed(Routes.FORGOT_PASSWORD), 
              child: Text("Lupa Password?")),
          ],
        )
      ),
    );
  }
}
