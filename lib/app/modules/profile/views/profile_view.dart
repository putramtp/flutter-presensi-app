import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: controller.streamUser(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          if (snap.hasData){
            Map<String, dynamic> user = snap.data!.data()!;
            String defaultImage = "https://ui-avatars.com/api/?name=${user['name']}";
          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        user["profile"] != null ? user["profile"] != "" ? user["profile"] 
                        : defaultImage 
                        : defaultImage,
                      fit: BoxFit.cover,)),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text("${user['name'].toString().toUpperCase()}", 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),),
                  SizedBox(
                height: 5,
              ),
              Text("${user['email']}", 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              Text("status : ${user["role"]}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                ),),
                SizedBox(
                  height: 10,
                ),
              if (user["role"] == "admin")
              ListTile(
                onTap: ()=> Get.toNamed(Routes.ADD_PEGAWAI),
                leading: Icon(Icons.person_add),
                title: Text("Tambah Pegawai",
                  style: TextStyle(
                    fontSize: 14,
                  ),),
              ),
              ListTile(
                onTap: ()=> Get.toNamed(Routes.UPDATE_PROFILE, 
                arguments: user
                ),
                leading: Icon(Icons.person),
                title: Text("Perbaharui Profil",
                  style: TextStyle(
                    fontSize: 14,
                  ),),
              ),
              ListTile(
                onTap: ()=> Get.toNamed(Routes.UPDATE_PASSWORD),
                leading: Icon(Icons.vpn_key),
                title: Text("Ganti Password",
                  style: TextStyle(
                    fontSize: 14,
                  ),),
              ),
              ListTile(
                onTap: ()=> controller.logout(),
                leading: Icon(Icons.logout),
                title: Text("Logout",
                  style: TextStyle(
                    fontSize: 14,
                  ),),
              ),
            ],
          );
          } else {
            return Center(
              child: Text("Data tidak dapat ditemukan"),
            );
          }
          
        },
      )
    );
  }
}
