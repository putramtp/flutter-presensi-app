import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presensi/app/modules/workfromhome/controllers/workfromhome_controller.dart';
import 'package:presensi/app/routes/app_pages.dart';

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
          'Sakit',
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
        child: ListView(
          padding: EdgeInsets.all(22),
          children: [
            TextField(
              controller: controller.dateInput,
              decoration: new InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: DateFormat("yyyy-MM-dd // HH:mm:ss WIB").format(controller.selectedDate.value),
                hintStyle: TextStyle(
                  color: Color(0XffBDBDBD)
                ),
                suffixIcon: Icon(Icons.date_range_outlined,
                color: FocusScope.of(context).isFirstFocus ? Color(0xffBDBDBD) : Color(0xffBDBDBD),
                ),
                labelText: "Tanggal Pengajuan Sakit",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Color(0xffe0e0e0),
                    width: 1.0
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xffe0e0e0),
                    width: 1.0
                  ),
                ),
                labelStyle: GoogleFonts.poppins(
                  color: Color(0xff828282),
                  fontSize: 12,
                  fontWeight: FontWeight.w500
                ),
                filled: true,
                fillColor: Color(0xffF2F2F2)
            //         fillColor: Color(0xffF8F8F8),
            //         disabledBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(10),
            //           borderSide: BorderSide(
            //             color: Color(0xffe0e0e0),
            //             width: 1.0
            //           ),
              ),
              readOnly: true,
              // jika true, user tidak akan bisa edit textfield
              onTap: () {}
            ),
            
            SizedBox(
              height: 14,
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              controller: controller.keterangan,
              decoration: new InputDecoration(
                alignLabelWithHint : true,
                hintText: "Masukkan Keterangan Sakit",
                hintStyle: GoogleFonts.poppins(
                  color: Color.fromARGB(255, 172, 172, 172),
                  fontSize: 12,
                ),
                labelText: "Keterangan",
                labelStyle: GoogleFonts.poppins(
                  color: Color(0xff828282),
                  fontSize: 12,
                  fontWeight: FontWeight.w500
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
                  borderSide: BorderSide(
                    color: Color(0xffFFC107),
                    width: 1.5
                  )
                ),
              ),
            ),
            SizedBox(
              height: 32,
            ),
            Container(
              height: 1.5,
              width: 276,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 238, 238, 238)
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              height: 46,
              width: 276,
              child: ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffFFC107),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    )
                  ),
                onPressed: () async {
                  if(controller.isLoading.isFalse){
                    await controller.addSakit();
                  }
                }, 
                child: Text(
                  controller.isLoading.isFalse? "Ajukan" : "LOADING...",
                  style: GoogleFonts.poppins(
                    color: Color(0xff333333),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                    fontSize: 14,
                  ),
                  ),
              ),
              ),
            SizedBox(
              height: 14,
            ),
            Container(
              height: 46,
              child: OutlinedButton(
                onPressed: ()=> Get.offAllNamed(Routes.HOME),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Color(0xffFFC107),
                    width: 2.0
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)
                  )
                ),
                child: Text(
                  "Batal",
                  style: GoogleFonts.poppins(
                  color: Color(0xffFFC107),
                  fontSize: 14,
                  fontWeight : FontWeight.w600,
                  letterSpacing: 0.7,
                )
                  )
              ),
            ),
          ],
        ),
      )
    );
  }
}
