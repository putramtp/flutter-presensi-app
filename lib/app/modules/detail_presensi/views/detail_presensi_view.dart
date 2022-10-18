import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_presensi_controller.dart';

class DetailPresensiView extends GetView<DetailPresensiController> {
  final Map<String, dynamic> data = Get.arguments;
  @override
  Widget build(BuildContext context) {
    print(data);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Presensi',
          style: GoogleFonts.poppins(
            color: Color(0xff333333),
            fontSize: 16,
            fontWeight: FontWeight.w600
          ),
          ),
        backgroundColor: Color(0xffFFC107),
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
                style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                ),
              Row(
                children: [
                  Text("Jam",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                    SizedBox(
                      width: 37,
                    ),
                  Text(":     ${DateFormat.jms().format(DateTime.parse(data['datang']!['date']))}",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                ],
              ),
              Row(
                children: [
                  Text("Posisi",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                  Text(":     ${data['datang']!['lat']} , ${data['datang']!['long']}",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                ],
              ),
              Row(
                children: [
                  Text("Status",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                    SizedBox(
                      width: 26,
                    ),
                  Text(":     ${data['datang']!['status']}",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                ],
              ),
              Row(
                children: [
                  Text("Alamat",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  Expanded(
                    child: FittedBox(
                      child: Text(":     ${data['datang']!['alamat']}",
                            style: GoogleFonts.poppins(
                              fontSize: 12
                            ),
                        ),
                    ),
                  ),
                ],
              ),
              Text("Distance : ${data['datang']!['distance'].toString().split(".").first} meter",
                    style: GoogleFonts.poppins(
                      fontSize: 12
                    ),
                ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Pulang",
                style: GoogleFonts.poppins(
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
