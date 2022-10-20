import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presensi/app/routes/app_pages.dart';

import '../controllers/workfromhome_controller.dart';

class WorkfromhomeView extends GetView<WorkfromhomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> Get.offAllNamed(Routes.HOME),
        icon: const Icon(Icons.arrow_back_ios_new,
          size: 14,
          ),
        color: Color(0xff333333),
        ),
        title: Text(
          'Cuti',
          style: GoogleFonts.poppins(
            color: Color(0xff333333),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          ),
        centerTitle: true,
        backgroundColor: Color(0xffFFC107),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Text(
            'Menu Pengajuan Cuti sedang dalam proses integrasi dengan\nSistem Informasi Kepegawaian (SIMPEG)',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Color(0xff333333),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
