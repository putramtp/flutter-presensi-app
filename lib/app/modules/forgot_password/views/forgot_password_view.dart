import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> Get.back(), 
        icon: Icon(Icons.arrow_back_ios_new,
          size: 14,
          ),
        color: Color(0xff333333),
        ),
        title: Text(
          'Lupa Password',
          style: GoogleFonts.poppins(
            color: Color(0xff333333),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          ),
        centerTitle: true,
        backgroundColor: Color(0xffFFC107),
      ),
      body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextField(
              controller: controller.emailC,
              decoration: new InputDecoration(
                hintText: "Masukkan Email Anda",
                hintStyle: GoogleFonts.poppins(
                  color: Color.fromARGB(255, 172, 172, 172),
                  fontSize: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Color(0xffe0e0e0),
                    width: 1.0
                  )
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xffFFC107),
                    width: 1.5,
                  ),
                ),
                labelText: "Email",
                labelStyle: GoogleFonts.poppins(
                  color: Color(0xff828282),
                  fontSize: 12,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 46,
              width: 276,
              child: Obx(
                ()=> ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xffFFC107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                      )
                    ),
                  onPressed: () async {
                    if(controller.isLoading.isFalse){
                      controller.sendEmail();
                    }
                  }, 
                  child: Text(
                    controller.isLoading.isFalse? "KIRIM RESET PASSWORD" : "LOADING...",
                    style: GoogleFonts.poppins(
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.7,
                      fontSize: 14,
                    ),
                    ),
                ),
              ),
            ), 
          ]),
    );
  }
}
