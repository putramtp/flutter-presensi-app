import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presensi/app/routes/app_pages.dart';

import '../controllers/update_password_controller.dart';

class UpdatePasswordView extends GetView<UpdatePasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> Get.toNamed(Routes.PROFILE),
        icon: const Icon(Icons.arrow_back_ios_new,
          size: 14,
          ),
        color: Color(0xff333333),
        ),
        title: Text(
          'Ganti Password',
          style: GoogleFonts.poppins(
            color: Color(0xff333333),
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
          ),
        backgroundColor: Color(0xffFFC107),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Text(
            'Menu Ganti Password sedang dalam proses pengembangan sistem.',
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
