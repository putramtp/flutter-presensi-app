import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/routes/app_pages.dart';
import '../controllers/profile_controller.dart';
import '../../../controllers/page_index_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileView extends GetView<ProfileController> {
  String bgGradationCurve = 'assets/rec-shadow-trim.png';
  final pageC = Get.find<PageIndexController>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => controller.backDeviceButton(),
      child: Scaffold(
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
            'Profil',
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
                              width: 124.0,
                              height: 124.0,
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
                    height: 12,
                  ),
                  Text(
                    "${user['gelar_depan']} ${user['gelar_nonakademis']} ${user['nama_pegawai'].toString().toUpperCase()}, ${user['gelar_belakang']}",
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
                    "${user['nomenklatur_jabatan']}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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
                    height: 35,
                  ),
                  SizedBox(
                    height: 13,
                  ),
                  if (user["role"] == "admin")
                    ListTile(
                      onTap: () => Get.toNamed(Routes.ADD_PEGAWAI),
                      leading: Icon(Icons.person_add),
                      title: Text(
                        "Tambah Pegawai",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28, right: 28),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xffFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 6))
                          ]),
                      child: ListTile(
                        onTap: () =>
                            Get.toNamed(Routes.UPDATE_PROFILE, arguments: user),
                        leading: Icon(
                          Icons.people_outline,
                          color: Color(0xff333333),
                        ),
                        title: Text(
                          "Perbaharui Profil",
                          textAlign: TextAlign.start,
                          style: GoogleFonts.poppins(
                              color: Color(0xff333333),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28, right: 28),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xffFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 6)),
                          ]),
                      child: ListTile(
                        onTap: () => Get.toNamed(Routes.NEW_PASSWORD),
                        leading: Icon(
                          Icons.lock_outline,
                          color: Color(0xff333333),
                        ),
                        title: Text(
                          "Ganti Password",
                          style: GoogleFonts.poppins(
                              color: Color(0xff333333),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 38, right: 38),
                    child: Container(
                      height: 1.5,
                      width: 200,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 241, 241, 241)),
                    ),
                  ),
                  // LOGOUT-LOGOUT-LOGOUT-LOGOUT-LOGOUT-LOGOUT-LOGOUT-LOGOUT-
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 28, right: 28),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //         color: Color(0xffFFF1F1),
                  //         borderRadius: BorderRadius.all(Radius.circular(10)),
                  //         boxShadow: [
                  //           BoxShadow(
                  //               color: Colors.grey.withOpacity(0.2),
                  //               spreadRadius: 5,
                  //               blurRadius: 7,
                  //               offset: Offset(0, 6))
                  //         ]),
                  //     child: ListTile(
                  //       onTap: () => controller.logout(),
                  //       leading: Icon(
                  //         Icons.logout,
                  //         color: Color(0xffEB5757),
                  //       ),
                  //       title: Text(
                  //         "Logout",
                  //         style: GoogleFonts.poppins(
                  //             color: Color(0xffEB5757),
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.w600),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // LOGOUT-LOGOUT-LOGOUT-LOGOUT-LOGOUT-LOGOUT-LOGOUT-LOGOUT-
                  SizedBox(
                    height: 40,
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
                  Image.asset(
                    "assets/Sadasbor-Logo.png",
                    height: 22,
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 38.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Versi Obt 6(1.5)',
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 192, 192, 192),
                            fontSize: 7,
                          ),
                        ),
                      ],
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
      ),
    );
  }
}
