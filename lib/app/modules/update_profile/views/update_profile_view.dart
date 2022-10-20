import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';
import '../controllers/update_profile_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateProfileView extends GetView<UpdateProfileController> {
  final Map<String, dynamic> user = Get.arguments;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new,
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
        centerTitle: true,
        backgroundColor: Color(0xffFFC107),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Text(
            'Menu Perbaharui Profil sedang dalam proses pengembangan sistem',
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
