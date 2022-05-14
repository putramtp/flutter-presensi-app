import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_presensi_controller.dart';

class DetailPresensiView extends GetView<DetailPresensiController> {
  final Map<String, dynamic> data = Get.arguments;
  @override
  Widget build(BuildContext context) {
    print(data);
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
                child: Text("${DateFormat.yMMMMEEEEd().format(DateTime.parse(data['date']))}",
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
              Text(
                "Jam : ${DateFormat.jms().format(DateTime.parse(data['datang']!['date']))}"
                ),
              Text("Posisi : ${data['datang']!['lat']} , ${data['datang']!['long']}"),
              Text("Status : ${data['datang']!['status']}"),
              Text("Alamat : ${data['datang']!['alamat']}"),
              Text("Distance : ${data['datang']!['distance'].toString().split(".").first} meter"),
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
              Text(
                data['pulang']?['date'] == null ? "Jam : -" : "Jam : ${DateFormat.jms().format(DateTime.parse(data['pulang']!['date']))}"
                ),
              Text(
                data['pulang']?['lat'] == null && data['pulang']?['long'] == null ? "Posisi : -" : "Posisi : ${data['pulang']!['lat']} , ${data['pulang']!['long']}"
                ),
              Text(
                data['pulang']?['status'] == null ? "Status : -" : "Status : ${data['pulang']!['status']}"
                ),
              Text(
                data['pulang']?['alamat'] == null ? "Alamat : -" : "Alamat : ${data['pulang']!['alamat']}"),
              Text(
                data['pulang']?['distance'] == null ? "Distance : -" : "Distance : ${data['pulang']!['distance'].toString().split(".").first} meter"),
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
