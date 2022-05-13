import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_profile_controller.dart';

class UpdateProfileView extends GetView<UpdateProfileController> {
  final Map<String, dynamic> user = Get.arguments;
  @override
  Widget build(BuildContext context) {
    controller.nipC.text = user['nip'];
    controller.nameC.text = user['name'];
    controller.emailC.text = user['email'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Perbaharui Profil'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            readOnly: true,
            autocorrect: false,
            controller: controller.nipC,
            decoration: InputDecoration(
              labelText: "NIP",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height : 10,
          ),
          TextField(
            autocorrect: false,
            controller: controller.nameC,
            decoration: InputDecoration(
              labelText: "Nama",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height : 10,
          ),
          TextField(
            readOnly: true,
            autocorrect: false,
            controller: controller.emailC,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height : 15,
          ),
          Text(
                "Foto Profil",
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),  
              ),
          SizedBox(
            height : 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<UpdateProfileController>(
                builder: (c) {
                  if (c.image != null) {
                    return ClipOval(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Image.file(File(c.image!.path), 
                        fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    if (user['profile'] != null){
                      return ClipOval(
                      child: Container(
                        height: 100,
                        width: 100,
                          child: Image.network(
                            user['profile'],
                            fit: BoxFit.cover,
                          ), 
                        ),
                      );
                    } else {
                      return Text("No Image");
                    }
                  }
                },
              ),
              TextButton(onPressed: (){
                controller.pickImage();
              }, 
                  child: Text(
                    "choose",
                      style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Obx(
            ()=> ElevatedButton(onPressed: () async {
            if(controller.isLoading.isFalse){
              await controller.updateProfile(user["uid"]);
            }
          }, 
            child: 
            Text(controller.isLoading.isFalse ? "PERBAHARUI" : "LOADING...")),
          ) 
        ],
      )
    );
  }
}
