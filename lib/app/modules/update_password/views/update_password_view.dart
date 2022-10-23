import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/update_password_controller.dart';

class UpdatePasswordView extends GetView<UpdatePasswordController> {
  final String imageError = 'assets/error404.svg';
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
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
        child: ListView(
          children: [
            SizedBox(
              height: 0,
            ),
            Text(
              "404",
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xff333333),
              ),
              ),
            Text(
              "Halaman Sedang Diperbaharui ...",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff333333)
              ),
              ),
            SizedBox(
              height: 30,
            ),
            SvgPicture.asset(imageError,
            width: 240,
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Halaman Ganti Password sedang dalam proses pengembangan sistem.',
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: Color(0xff333333),
                fontSize: 12,
                fontWeight: FontWeight.w400
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                    Row(
                      children: [
                        IconButton(onPressed: (){
                          Get.offAllNamed(Routes.PROFILE);
                        }, 
                          icon: Icon(Icons.keyboard_arrow_left_rounded,
                            size: 26,
                            color: Color(0xffFFC107),
                            ),
                          ),
                        TextButton(onPressed: (){
                          Get.offAndToNamed(Routes.PROFILE);
                        }, 
                          child: Text("Kembali",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xffFFC107)
                          ),
                          ),
                          )
                  ],
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}
