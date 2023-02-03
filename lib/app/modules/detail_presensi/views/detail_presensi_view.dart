import 'package:cloud_firestore/cloud_firestore.dart';
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
        leading: IconButton(
          onPressed: () => Get.toNamed(Routes.HOME),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 14,
          ),
          color: Color(0xff333333),
        ),
        title: Text(
          'Detail Presensi',
          style: GoogleFonts.poppins(
              color: Color(0xff333333),
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xffFFC107),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "${DateFormat.yMMMMEEEEd().format(DateTime.parse(data['date']))}",
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
                    Text(
                      "Jam",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 33,
                    ),
                    Text(
                      ":   ${DateFormat("HH:mm:ss").format(DateTime.parse(data['datang']!['date']))} WIB",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Posisi",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 26,
                    ),
                    Text(
                      ":   ${data['datang']!['lat']} , ${data['datang']!['long']}",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Status",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 22,
                    ),
                    Text(
                      ":   ",
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "${data['datang']!['status']}",
                      style: GoogleFonts.poppins(
                          color: Color.fromARGB(255, 5, 151, 64),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Alamat",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      ":",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(
                        "${data['datang']!['alamat']}",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Distance",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(width: 8),
                    Text(
                      ":   ${data['datang']!['distance'].toString().split(".").first} meter",
                      style: GoogleFonts.poppins(fontSize: 12),
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
                    Text(
                      "Jam",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 33,
                    ),
                    Container(
                        child: data['pulang'] != null
                            ? Text(
                                ":   ${DateFormat("HH:mm:ss").format(DateTime.parse(data['pulang']!['date']))} WIB",
                                style: GoogleFonts.poppins(fontSize: 12),
                              )
                            : Text(
                                ":   ${DateFormat("HH:mm:ss").format(DateTime.parse(data['datang']!['date']))} WIB",
                                style: GoogleFonts.poppins(fontSize: 12),
                              )),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Posisi",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 26,
                    ),
                    Container(
                        child: data["pulang"] != null
                            ? Text(
                                ":   ${data['pulang']!['lat']} , ${data['pulang']!['long']}",
                                style: GoogleFonts.poppins(fontSize: 12),
                              )
                            : Text(
                                ":   ${data['datang']!['lat']} , ${data['datang']!['long']}",
                                style: GoogleFonts.poppins(fontSize: 12),
                              )),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Status",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 22,
                    ),
                    Text(
                      ":   ",
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    Container(
                        child: data["pulang"] != null
                            ? Text(
                                "${data['pulang']!['status']}",
                                style: GoogleFonts.poppins(
                                    color: Color.fromARGB(255, 5, 151, 64),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              )
                            : Text(
                                "${data['datang']!['status']}",
                                style: GoogleFonts.poppins(
                                    color: Color.fromARGB(255, 5, 151, 64),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              )),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Alamat",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      ":",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Container(
                          child: data['pulang'] != null
                              ? Text(
                                  "${data['pulang']!['alamat']}",
                                  style: GoogleFonts.poppins(fontSize: 12),
                                )
                              : Text(
                                  "${data['datang']!['alamat']}",
                                  style: GoogleFonts.poppins(fontSize: 12),
                                )),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Distance",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    SizedBox(width: 8),
                    Container(
                        child: data['pulang'] != null
                            ? Text(
                                ":   ${data['pulang']!['distance'].toString().split(".").first} meter",
                                style: GoogleFonts.poppins(fontSize: 12),
                              )
                            : Text(
                                ":   ${data['datang']!['distance'].toString().split(".").first} meter",
                                style: GoogleFonts.poppins(fontSize: 12),
                              )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.grey[400],
                ),
                SizedBox(
                  height: 0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Status Sync   : ",
                      style: GoogleFonts.poppins(
                          fontSize: 9, fontStyle: FontStyle.italic),
                    ),
                    SizedBox(width: 4),
                    Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: data["sync"] == "N"
                            ? Column(
                                children: [
                                  Icon(
                                    Icons.close_rounded,
                                    color: Color.fromARGB(255, 214, 32, 32),
                                  ),
                                ],
                              )
                            : Icon(
                                Icons.check_rounded,
                                color: Color.fromARGB(255, 19, 204, 13),
                              ))
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
      ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: data['sync'] == "N"
              ? FloatingActionButton(
                  onPressed: () async {
                    await controller.postSync();
                  },
                  child: Icon(Icons.sync_outlined, size: 28),
                  backgroundColor: Color.fromARGB(255, 5, 151, 64),
                )
              : FloatingActionButton(
                  onPressed: () async {
                    await controller.postSync();
                  },
                  child: Icon(Icons.sync_outlined, size: 28),
                  backgroundColor: Color.fromARGB(255, 5, 151, 64),
                )
          // Visibility(
          //   visible: false,
          //   child: FloatingActionButton(
          //         onPressed: (){
          //           print("Cek Visible");
          //         },
          //           child: Icon(
          //               Icons.sync_outlined, size: 28,
          //                 color: Color.fromARGB(255, 241, 241, 241),
          //             ),
          //           backgroundColor: Color.fromARGB(255, 218, 218, 218),
          //       ),
          // ),
          ),
    );
  }
}
