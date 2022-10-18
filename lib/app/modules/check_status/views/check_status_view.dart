import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/check_status_controller.dart';

class CheckStatusView extends GetView<CheckStatusController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CheckStatusView'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: controller.jamdatang,
              decoration: InputDecoration(
                labelText: "Jam datang",
              )
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: controller.jampulang,
              decoration: InputDecoration(
                labelText: "Jam pulang",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.isLoading.isFalse){
                  await controller.safeDevice();
                }
              }, child: Text(
                "CEK",
              ))
          ],
        )
      ),
    );
  }
}
