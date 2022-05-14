import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/add_pegawai_controller.dart';

class AddPegawaiView extends GetView<AddPegawaiController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Pegawai'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
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
            autocorrect: false,
            controller: controller.nameC,
            decoration: InputDecoration(
              labelText: "Jabatan",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height : 10,
          ),
          TextField(
            autocorrect: false,
            controller: controller.emailC,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height : 10,
          ),
          Obx(
            ()=> ElevatedButton(onPressed: () async {
            if(controller.isLoading.isFalse){
              await controller.addPegawai();
            }
          }, 
            child: 
            Text(controller.isLoading.isFalse ? "TAMBAH PEGAWAI" : "LOADING...")),
          ) 
        ],
      )
    );
  }
}
