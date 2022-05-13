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
            controller: controller.newPassC,
            obscureText: true,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: "Password Baru",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: (){
              controller.newPasword();
            }, 
            child: Text("UBAH PASSWORD")),
        ],
      )
    );
  }
}
