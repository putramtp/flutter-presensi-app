import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';
import '../controllers/login_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trust_location/trust_location.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginView extends GetView<LoginController> {

  // TextEditingController nipC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE9ECEF),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            SizedBox(
              height: 40,
            ),
            Image.asset(
              'assets/loader.gif',
              height: 135,
            ),
            SizedBox(
              height: 0,
            ),
            Text(
              'SADASBOR',
              style: GoogleFonts.poppins(
                color: Color(0xff333333),
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 5,
              ),
            textAlign: TextAlign.center
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'KABUPATEN TASIKMALAYA',
              style: GoogleFonts.poppins(
                color: Color(0xff333333),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 39,
            ),
            Container(
              height: 48,
              width: 276,
              child: TextFormField(
                // onTap: ()=> controller.getCurrentLocation(),
                textAlign: TextAlign.left,
                autocorrect: false,
                controller: controller.nipC,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: "NIP",
                  contentPadding: EdgeInsets.only(left: 20),
                  hintStyle: GoogleFonts.poppins(
                    color: Color(0xff575757),
                    fontSize: 12,
                    fontWeight: FontWeight.w500
                  ),
                  suffixIcon: Icon(Icons.person, size: 22,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 48,
              width: 276,
              child: Theme(
                    data: Theme.of(context).copyWith(
                      primaryColor: Color(0xffFFC107)
                    ),
                child: 
                Obx(()=>
                TextFormField(
                  // onTap: ()=> controller.getCurrentLocation(),
                  textAlign: TextAlign.left,
                  autocorrect: false,
                  controller: controller.passC,
                  obscureText: controller.isPasswordHidden.value,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Password",
                    contentPadding: EdgeInsets.only(left: 22),
                    hintStyle: GoogleFonts.poppins(
                      color: Color(0xff575757),
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                    ),
                    suffixIcon: InkWell(
                      child: Icon(controller.isPasswordHidden.value? Icons.visibility:
                      Icons.visibility_off, size: 22,),
                      onTap: (){
                        controller.isPasswordHidden.value =
                          !controller.isPasswordHidden.value;
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none
                    ),
                  ),
                ),
                ),
              ),
            ),
            SizedBox(
              height: 0,
            ),
            Container(
              alignment: Alignment(1, 0.5),
              child: TextButton(
                onPressed: 
                  ()=> Get.toNamed(Routes.FORGOT_PASSWORD), 
                child: Text(
                  "Lupa Password?",
                  style: GoogleFonts.poppins(
                    color: Color(0xff575757),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  )
                ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 34,
                  width: 146,
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      fillColor: Color(0xffe0e0e0),
                      filled: true,
                      hintText: "Lat   :          " + controller.latitude,
                      hintStyle: GoogleFonts.poppins(
                      color: Color.fromARGB(255, 184, 184, 184),
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none
                    )
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              Container(
              height: 34,
              width: 146,
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  fillColor: Color(0xffe0e0e0),
                  filled: true,
                  hintText: "Long   :          ${controller.longitude}",
                  hintStyle: GoogleFonts.poppins(
                  color: Color.fromARGB(255, 184, 184, 184),
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none
                    )
                ),
              ),
            ),
              ],
            ),
            SizedBox(
              height: 22,
            ),
            Container(
              height: 1.5,
              width: 276,
              decoration: BoxDecoration(
                color: const Color(0xffe0e0e0)
              ),
            ),
            SizedBox(
              height: 16.5,
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
                  if (controller.isLoading.isFalse){
                    await controller.safeDevice();
                  }
                }, 
                child: Text(
                  controller.isLoading.isFalse ? "LOGIN" : "LOADING..."
                  ,
                  style: GoogleFonts.poppins(
                    color: Color(0xff333333),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  ),
              ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pemerintah Daerah Kabupaten Tasikmalaya. © 2022',
                  style: GoogleFonts.poppins(
                    color: Color(0xff575757),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 4
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                      'Versi Obt 0.6.',
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(255, 192, 192, 192),
                        fontSize: 7,
                      ),
                    ),
              ],
            ),
          ],
        )
      ),
    );
  }
}
