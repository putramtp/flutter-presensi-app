import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presensi/app/routes/app_pages.dart';

import '../controllers/dinasluar_controller.dart';

class DinasluarView extends GetView<DinasluarController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> Get.toNamed(Routes.HOME), 
        icon: Icon(Icons.arrow_back_ios_new),
        color: Color(0xff333333),
        ),
        title: Text(
          'Dinas Luar',
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
        child: Text(
          'Dinas Luar View is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
