import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presensi/app/routes/app_pages.dart';

import '../controllers/profile_controller.dart';
import '../../../controllers/page_index_controller.dart';

class ProfileView extends GetView<ProfileController> {
  final pageC = Get.find<PageIndexController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          if (snap.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          if (snap.hasData){
            Map<String, dynamic> user = snap.data!.data()!;
            String defaultImage = "https://ui-avatars.com/api/?name=${user['nama_pegawai']}";
          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        user["profile"] != null ? user["profile"] != "" ? user["profile"] 
                        : defaultImage 
                        : defaultImage,
                      fit: BoxFit.cover,)),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text("${user['nama_pegawai'].toString().toUpperCase()}, ${user['gelar_belakang']}", 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                  ),),
                  SizedBox(
                height: 5,
              ),
              Text("${user['nomenklatur_jabatan']}", 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              Text("${user["nomenklatur_pada"]}",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 8,
                ),),
                SizedBox(
                  height: 40,
                ),
              if (user["role"] == "admin")
              ListTile(
                onTap: ()=> Get.toNamed(Routes.ADD_PEGAWAI),
                leading: Icon(Icons.person_add),
                title: Text("Tambah Pegawai",
                  style: TextStyle(
                    fontSize: 14,
                  ),),
              ),
              Container(
                height: 48,
                child: ListTile(
                  onTap: ()=> Get.toNamed(Routes.UPDATE_PROFILE, 
                  arguments: user
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Color.fromARGB(255, 199, 199, 199)
                    ),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  leading: Icon(Icons.people_outline,
                  color: Color(0xffFFC107),
                  ),
                  title: Text(
                    "Perbaharui Profil",
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                    ),
                    ),
                ),
              ),
              ListTile(
                onTap: ()=> Get.toNamed(Routes.UPDATE_PASSWORD),
                leading: Icon(Icons.vpn_key),
                title: Text("Ganti Password",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                  ),),
              ),
              ListTile(
                onTap: ()=> controller.logout(),
                leading: Icon(Icons.logout),
                title: Text("Logout",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                  ),),
              ),
            ],
          );
          } else {
            return Center(
              child: Text("Data tidak dapat ditemukan"),
            );
          }
          
        },
      ),
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: Color(0xffFFC107),
          style: TabStyle.fixedCircle,
          items: [
            TabItem(icon: Icons.home_outlined, title: 'Home'),
            TabItem(icon: Icons.leave_bags_at_home_outlined, title: 'Cuti'),
            TabItem(icon: Icons.fingerprint, title: 'Add'),
            TabItem(icon: Icons.flight_class_outlined, title: 'Dns. Luar'),
            TabItem(icon: Icons.people_outline, title: 'Profil'),
          ],
          initialActiveIndex: pageC.pageIndex.value,//optional, default as 0
          onTap: (int i) => pageC.changePage(i),
      ),
    );
  }
}
