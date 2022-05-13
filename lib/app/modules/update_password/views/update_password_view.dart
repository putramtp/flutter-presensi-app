import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_password_controller.dart';

class UpdatePasswordView extends GetView<UpdatePasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ganti Password'),
        centerTitle: true,
      ),
      body: ListView(
        padding : EdgeInsets.all(20),
        children: [
          TextField(
            controller: controller.currC,
            autocorrect: false,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password Lama",
              border: OutlineInputBorder()
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: controller.newP,
            autocorrect: false,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password Baru",
              border: OutlineInputBorder()
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: controller.confirmP,
            autocorrect: false,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Konfirmasi Password Baru",
              border: OutlineInputBorder()
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Obx(
            ()=> ElevatedButton(
              onPressed: (){
              if(controller.isLoading.isFalse){
                controller.updatePass();
              }
            }, 
              child: Text((controller.isLoading.isFalse) ? "GANTI PASSWORD" : "LOADING..."))
          )
        ],
      )
    );
  }
}
