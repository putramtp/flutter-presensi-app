import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_presensi_controller.dart';

class DetailPresensiView extends GetView<DetailPresensiController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Presensi'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children : [ 
          Container(
            padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text("${DateFormat.yMMMMEEEEd().format(DateTime.now())}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Datang",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                ),
              Text("Jam : ${DateFormat.jms().format(DateTime.now())}"
                ),
              Text("Posisi : -6.96465 , 192.55647"),
              Text("Status : Didalam Area"),
              SizedBox(
                height: 10,
              ),
              Text(
                "Pulang",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                ),
              Text("Jam : ${DateFormat.jms().format(DateTime.now())}"
                ),
              Text("Posisi : -6.96465 , 192.55647"),
              Text("Status : Didalam Area"),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
              color: Colors.grey[200],
          ),
        ),
        ],
      )
    );
  }
}
