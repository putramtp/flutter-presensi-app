import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/modules/update_profile/controllers/update_profile_controller.dart';
import 'package:presensi/app/routes/app_pages.dart';
import '../../../controllers/page_index_controller.dart';

class UpdateProfileView extends GetView<UpdateProfileController> {
  String bgGradationCurve = 'assets/rec-shadow-trim.png';
  final pageC = Get.find<PageIndexController>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => controller.backDeviceButton(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 14,
            ),
            color: Color(0xff333333),
          ),
          title: Text(
            'Perbaharui Profil',
            style: GoogleFonts.poppins(
              color: Color(0xff333333),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Color(0xffFFC107),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: controller.streamUser(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snap.hasData) {
              Map<String, dynamic> user = snap.data!.data()!;
              String createdAt = user['createdAt'];
              var dateLastUpdate = DateTime.parse(createdAt);
              String lastUpdate =
                  DateFormat("EEE, d MMMM yyyy").format(dateLastUpdate);
              String jamLastUpdate =
                  DateFormat("HH:mm:ss").format(dateLastUpdate);
              String tanggal_lahir = user['tanggal_lahir'];
              DateTime tanggal_lahirDT = DateTime.parse(tanggal_lahir);
              String TTL = DateFormat("dd MMMM yyyy").format(tanggal_lahirDT);
              String defaultImage =
                  "https://ui-avatars.com/api/?name=${user['nama_pegawai']}";
              String imageSample = "http://i.imgur.com/QSev0hg.jpg";
              return ListView(
                // padding: EdgeInsets.all(28),
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        bgGradationCurve,
                        fit: BoxFit.fill,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 36),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 130.0,
                              height: 130.0,
                              decoration: BoxDecoration(
                                color: const Color(0xff7c94b6),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    user['foto_profil'] != null
                                        ? user['foto_profil'] != ""
                                            ? user['foto_profil']
                                            : defaultImage
                                        : defaultImage,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(70.0)),
                                border: Border.all(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  width: 4.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${user['nama_pegawai'].toString().toUpperCase()}, ${user['gelar_belakang']}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: Color(0xff333333),
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "${user['nip']}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${user["nomenklatur_pada"]}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28, right: 28),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 12, bottom: 20),
                      child: Stack(alignment: Alignment.topCenter, children: [
                        Positioned(
                          child: Container(
                            height: 2.5,
                            width: 28,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(255, 218, 218, 218)),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 14,
                            ),
                            Text(
                              "Tempat Tanggal Lahir",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['tempat_lahir']}, $TTL",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Jenis Kelamin",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['gender']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Pangkat",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['nama_pangkat']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Jabatan",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['nomenklatur_jabatan']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Unit Organisasi",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['nama_unor']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Organisasi",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['nomenklatur_pada']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Golongan",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['nama_golongan']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Jenjang Pendidikan",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['nama_jenjang']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "TMT CPNS",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['tmt_cpns']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "TMT PNS",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['tmt_pns']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Lokasi Presensi",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 8,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "${user['nama_lokasi']}",
                              style: GoogleFonts.poppins(
                                color: Color(0xff333333),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 0, right: 0),
                              child: Container(
                                height: 1,
                                width: 700,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Color.fromARGB(255, 226, 226, 226)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Update Terakhir :   $lastUpdate  |  Pukul $jamLastUpdate WIB",
                              style: GoogleFonts.poppins(
                                color: Color(0xff828282),
                                fontSize: 7,
                              ),
                            ),
                          ],
                        ),
                      ]),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pemerintah Daerah Kabupaten Tasikmalaya. © 2023',
                          style: GoogleFonts.poppins(
                            color: Color(0xff575757),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 38.0),
                    child: Image.asset(
                      "assets/Sadasbor-Logo.png",
                      height: 22,
                    ),
                  ),
                  // SizedBox(
                  //     height: 20,
                  //   ),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Color(0xffFFF1F1),
                  //     borderRadius: BorderRadius.all(Radius.circular(10)),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.grey.withOpacity(0.2),
                  //         spreadRadius: 5,
                  //         blurRadius: 7,
                  //         offset: Offset(0,6)
                  //       )
                  //     ]
                  //   ),
                  //   child: ListTile(
                  //     onTap: ()=> controller.logout(),
                  //     leading: Icon(Icons.logout,
                  //         color: Color(0xffEB5757),
                  //     ),
                  //     title: Text("Logout",
                  //       style: GoogleFonts.poppins(
                  //         color: Color(0xffEB5757),
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w600
                  //       ),),
                  //   ),
                  // ),
                ],
              );
            } else {
              return Center(
                child: Text("Data tidak dapat ditemukan"),
              );
            }
          },
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Center(child: CircularProgressIndicator());
                  },
                );
                await controller.updateProfileAPI();

                Navigator.of(context).pop();
              },
              child: Icon(Icons.sync_outlined, size: 28),
              backgroundColor: Color.fromARGB(255, 5, 151, 64),
            )),
      ),
    );
  }
}
