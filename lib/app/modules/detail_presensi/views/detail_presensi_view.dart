import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/routes/app_pages.dart';

import '../controllers/detail_presensi_controller.dart';

class DetailPresensiView extends GetView<DetailPresensiController> {
  final Map<String, dynamic> data = Get.arguments;
  @override
  Widget build(BuildContext context) {
    print(data);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> Get.toNamed(Routes.HOME), 
        icon: Icon(Icons.arrow_back_ios_new,
          size: 14,
          ),
        color: Color(0xff333333),
        ),
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
                      width: 33,
                    ),
                  Text(":   ${DateFormat.jms().format(DateTime.parse(data['datang']!['date']))}",
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
                      width: 26,
                    ),
                  Text(":   ${data['datang']!['lat']} , ${data['datang']!['long']}",
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
                      width: 22,
                    ),
                  Text(":   ${data['datang']!['status']}",
                        style: GoogleFonts.poppins(
                          color: Color.fromARGB(255, 5, 151, 64),
                          fontSize: 12,
                          fontWeight: FontWeight.w400
                        ),
                    ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Alamat",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(":", 
                      style: GoogleFonts.poppins(
                      fontSize: 12
                      ),
                      ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text("${data['datang']!['alamat']}",
                            style: GoogleFonts.poppins(
                              fontSize: 12
                            ),
                        ),
                    
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Distance",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                    SizedBox(
                      width: 8
                    ),
                  Text(":   ${data['datang']!['distance'].toString().split(".").first} meter",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Text(
                "Pulang",
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
                      width: 33,
                    ),
                  Text(":   ${DateFormat.jms().format(DateTime.parse(data['pulang']!['date']))}",
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
                      width: 26,
                    ),
                  Text(":   ${data['pulang']!['lat']} , ${data['pulang']!['long']}",
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
                      width: 22,
                    ),
                  Text(":   ${data['pulang']!['status']}",
                        style: GoogleFonts.poppins(
                          color: Color.fromARGB(255, 5, 151, 64),
                          fontSize: 12,
                          fontWeight: FontWeight.w400
                        ),
                    ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Alamat",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(":", 
                      style: GoogleFonts.poppins(
                      fontSize: 12
                      ),
                      ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text("${data['pulang']!['alamat']}",
                            style: GoogleFonts.poppins(
                              fontSize: 12
                            ),
                        ),
                    
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Distance",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                    SizedBox(
                      width: 8
                    ),
                  Text(":   ${data['pulang']!['distance'].toString().split(".").first} meter",
                        style: GoogleFonts.poppins(
                          fontSize: 12
                        ),
                    ),
                ],
              ),
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
