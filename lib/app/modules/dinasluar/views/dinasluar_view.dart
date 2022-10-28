import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presensi/app/routes/app_pages.dart';
import '../controllers/dinasluar_controller.dart';

class DinasluarView extends GetView<DinasluarController> {
  // TextEditingController suratTugas = TextEditingController();
  // TextEditingController dateInput = TextEditingController();
  // TextEditingController maksudTujuan = TextEditingController();
  // TextEditingController lokasiTujuan = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => controller.backDeviceButton(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: ()=> Get.toNamed(Routes.HOME), 
          icon: Icon(Icons.arrow_back_ios_new,
            size: 14,
            ),
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
          child: ListView(
            padding: EdgeInsets.all(22),
            children: [
              SizedBox(
                height: 4,
              ),
              TextField(
                controller: controller.suratTugas,
                decoration: new InputDecoration(
                  hintText: "Masukkan No. Surat Tugas",
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
                  labelText: "No. Surat Tugas",
                  labelStyle: GoogleFonts.poppins(
                    color: Color(0xff828282),
                    fontSize: 12,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
              SizedBox(
                height: 14
              ),
              Obx(
                ()=> TextField(
                controller: controller.dateInput,
                decoration: new InputDecoration(
                  hintText: DateFormat("yyyy-MM-dd").format(controller.selectedDateNow.value),
                  hintStyle: TextStyle(
                    color: Colors.black
                  ),
                  suffixIcon: Icon(Icons.date_range_outlined,
                  color: FocusScope.of(context).isFirstFocus ? Color(0xff828282) : Color(0xffFFC107),
                  ),
                  labelText: "Tanggal Surat Tugas",
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
                      color: Color(0xffFFC107),
                      width: 1.5
                    ),
                  ),
                  labelStyle: GoogleFonts.poppins(
                    color: Color(0xff828282),
                    fontSize: 12,
                    fontWeight: FontWeight.w500
                  ),
                ),
                readOnly: true,
                // jika true, user tidak akan bisa edit textfield
                onTap: () {
                  controller.chooseDate();
                  controller.getCurrentLocation();
                }
              ),
              ),
              SizedBox(
                height: 14,
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                controller: controller.maksudTujuan,
                decoration: new InputDecoration(
                  alignLabelWithHint : true,
                  hintText: "Masukkan Maksud Tujuan",
                  hintStyle: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 172, 172, 172),
                    fontSize: 12,
                  ),
                  labelText: "Maksud Tujuan",
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
                height: 14,
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                controller: controller.lokasiTujuan,
                decoration: new InputDecoration(
                  alignLabelWithHint: true,
                  hintText: "Masukkan Lokasi Tujuan",
                  hintStyle: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 172, 172, 172),
                    fontSize: 12,
                  ),
                  labelText: "Lokasi Tujuan",
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
                  )
                ),
              ),
              // SizedBox(
              //   height: 18,
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 8),
              //   child: Text(
              //     "Tanggal dan Waktu",
              //     style: GoogleFonts.poppins(
              //       color: Color(0xff828282),
              //       fontSize: 10,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 8,
              // ),
              // TextField(
              //   enabled: false,
              //   enableInteractiveSelection: false,
              //   focusNode: FocusNode(),
              //   decoration: new InputDecoration(
              //     filled: true,
              //     fillColor: Color(0xffF2F2F2),
              //     suffixIcon: Icon(Icons.date_range_outlined,
              //     color: FocusScope.of(context).isFirstFocus ? Color(0xffBDBDBD) : Color(0xffFFC107),
              //     ),
              //     disabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //       borderSide: BorderSide(
              //         color: Color(0xffe0e0e0),
              //         width: 1.0
              //       ),
              //     ),
              //     labelText: DateFormat("yyyy-MM-dd").format(controller.selectedDate.value),
              //     labelStyle: TextStyle(
              //       color: Color(0xffBDBDBD),
              //     ),
              //   ),
              //   readOnly: true,
              //   // jika true, user tidak akan bisa edit textfield
              //   onTap: () {
              //     controller.chooseDate();
              //   }
              // ),
              // SizedBox(
              //   height: 14,
              // ),
              // Stack(
              //   children: [
              //     Container(
              //       width: 220,
              //       child: TextField(
              //   // enabled: false,
              //   enableInteractiveSelection: false,
              //   focusNode: FocusNode(),
              //   decoration: new InputDecoration(
              //       labelText: controller.latitude,
              //       labelStyle: TextStyle(
              //         color: Color(0xffBDBDBD),
              //       ),
              //       filled: true,
              //       fillColor: Color(0xffF2F2F2),
              //       enabledBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10),
              //         borderSide: BorderSide(
              //           color: Color(0xffe0e0e0),
              //           width: 1.0
              //         ),
              //       ),
              //   ),
              //   readOnly: true,
              //   // jika true, user tidak akan bisa edit textfield
              //   onTap: () {
              //       controller.getCurrentLocation();
              //   }
              // ),
              //     ),
              //   Positioned(
              //     right: 70,
              //     child: Container(
              //       width: 105,
              //         child: TextField(
              //     enabled: false,
              //     enableInteractiveSelection: false,
              //     focusNode: FocusNode(),
              //     decoration: new InputDecoration(
              //       prefixIcon: Icon(Icons.location_on_outlined,
              //       color: Color(0xff828282),
              //       ),
              //         labelText: "Lat",
              //         labelStyle: GoogleFonts.poppins(
              //           color: Color(0xff828282),
              //           fontSize: 12,
              //         ),
              //         filled: true,
              //         fillColor: Color(0xffF8F8F8),
              //         disabledBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(10),
              //           borderSide: BorderSide(
              //             color: Color(0xffe0e0e0),
              //             width: 1.0
              //           ),
              //         ),
              //     ),
              //     readOnly: true,
              //     // jika true, user tidak akan bisa edit textfield
              //     onTap: () {
              //         controller.getCurrentLocation();
              //     }
              // ),
              //       ),
              //   ),
              //   ],
              // ),
              // SizedBox(
              //   height: 14,
              // ),
              // Stack(
              //   children: [
              //     Container(
              //       width: 220,
              //       child: TextField(
              //   enabled: false,
              //   enableInteractiveSelection: false,
              //   focusNode: FocusNode(),
              //   decoration: new InputDecoration(
              //       labelText: controller.longitude,
              //       labelStyle: TextStyle(
              //         color: Color(0xffBDBDBD),
              //       ),
              //       filled: true,
              //       fillColor: Color(0xffF2F2F2),
              //       disabledBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10),
              //         borderSide: BorderSide(
              //           color: Color(0xffe0e0e0),
              //           width: 1.0
              //         ),
              //       ),
              //   ),
              //   readOnly: true,
              //   // jika true, user tidak akan bisa edit textfield
              //   onTap: () {
              //       controller.getCurrentLocation();
              //   }
              // ),
              //     ),
              //   Positioned(
              //     right: 70,
              //     child: Container(
              //       width: 105,
              //         child: TextField(
              //     enabled: false,
              //     enableInteractiveSelection: false,
              //     focusNode: FocusNode(),
              //     decoration: new InputDecoration(
              //       prefixIcon: Icon(Icons.location_on_outlined,
              //       color: Color(0xff828282),
              //       ),
              //         labelText: "Long",
              //         labelStyle: GoogleFonts.poppins(
              //           color: Color(0xff828282),
              //           fontSize: 12,
              //         ),
              //         filled: true,
              //         fillColor: Color(0xffF8F8F8),
              //         disabledBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(10),
              //           borderSide: BorderSide(
              //             color: Color(0xffe0e0e0),
              //             width: 1.0
              //           ),
              //         ),
              //     ),
              //     readOnly: true,
              //     // jika true, user tidak akan bisa edit textfield
              //     onTap: () {
              //         controller.getCurrentLocation();
              //     }
              // ),
              //       ),
              //   ),
              //   ],
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              // Text(
              //   "note : Jika posisi masih kosong, tekan form \"Lat\" atau \"Long\" berulang kali hingga muncul",
              //   style: GoogleFonts.poppins(
              //     color: Color.fromARGB(255, 182, 182, 182),
              //     fontSize: 6,
              //     fontWeight: FontWeight.w400
              //   ),
              // ),
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
                      await controller.addDinasLuar();
                    }
                  }, 
                  child: Text(
                    controller.isLoading.isFalse? "Submit" : "LOADING...",
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
                  onPressed: ()=> Get.offAllNamed(Routes.DINASLUAR),
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
                    "Reset",
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
          )
        ),
      ),
    );
  }
}
