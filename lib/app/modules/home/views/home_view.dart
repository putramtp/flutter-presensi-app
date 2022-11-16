import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/routes/app_pages.dart';
import '../../../controllers/page_index_controller.dart';
import '../controllers/home_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends GetView<HomeController> {
  final String imageLogo = 'assets/kabtasik.svg';
  final String imageSiluet = 'assets/kabtasiksiluet-saiful2.svg';
  final String sadasborLogo = 'assets/sadasbor-icon-tr.png';
  final pageC = Get.find<PageIndexController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Beranda',
          style: GoogleFonts.poppins(
            color: Color(0xff333333),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          ),
        backgroundColor: Color(0xffFFC107),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SvgPicture.asset(
                      imageLogo,
                        height: 38,
                        ),
        ),
        leadingWidth: 46,
        actions: [
            Padding(
              padding: const EdgeInsets.only(top:13, bottom: 13, right: 18),
              child: Image.asset(sadasborLogo,
                height: 15,  
          ),
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: controller.streamUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData){

          Map<String, dynamic> user = snapshot.data!.data()!;
          String defaultImage = "https://ui-avatars.com/api/?name=${user['nama_pegawai']}";
          String imageSimpeg = "https://simpeg.tasikmalayakab.go.id/assets/media/file/${user['nip']}/pasfoto/thumb_${user['file_dokumen']}";
          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Container(
                                  width: 78.0,
                                  height: 78.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff7c94b6),
                                    image: DecorationImage(
                                      image: NetworkImage(defaultImage 
                                      ,
                                    ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all( Radius.circular(70.0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 3,
                                        blurRadius: 7,
                                        offset: Offset(0,6)
                                      )
                                    ],
                                    border: Border.all(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      width: 0,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SELAMAT DATANG DI SADASBOR",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Container(
                        width: 200,
                        child: Text(
                          user['alamat'] != null ? "${user['alamat']}" : "Belum ada lokasi",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Color.fromARGB(255, 116, 116, 116),
                            fontWeight: FontWeight.normal,
                          ),),
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                   color: Color(0xffFFC107),
                   boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0,6)
                    )
                  ]
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                    ),
                    Positioned(
                      top: 14,
                      left: 220,
                      child: SvgPicture.asset(imageSiluet,
                        height: 70,
                        color: Color.fromARGB(255, 231, 173, 0),
                      ),
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user['nomenklatur_jabatan']}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        Text(
                          "${user['nip']}",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${user['nama_pegawai']}, ${user['gelar_belakang']}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500
                          ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffFFC107),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0,6)
                    )
                  ]
                ),
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: controller.streamTodayPresence(),
                  builder: (context, snapToday) {
                    if (snapToday.connectionState == ConnectionState.waiting){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    Map<String, dynamic>? dataToday = snapToday.data?.data();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Datang",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700
                              ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                            Text(dataToday?["datang"] == null ? "-" : "${DateFormat("HH:mm:ss").format(DateTime.parse(dataToday!['datang']['date']))} WIB",
                            style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                        Container(
                          width: 2,
                          height: 25,
                          color: Color.fromARGB(255, 243, 185, 11),
                        ),
                        Column(
                          children: [
                            Text(
                              "Pulang",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700
                              ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                            Text(dataToday?["pulang"] == null ? "-" : "${DateFormat("HH:mm:ss").format(DateTime.parse(dataToday!['pulang']['date']))} WIB",
                            style: GoogleFonts.poppins(),
                            ),
                          ],
                        )
                      ],
                    );
                  }
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                color: Colors.grey[400],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Presensi 3 Hari Terakhir",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.streamLastPresence(),
                builder: (context, snapPresence) {
                  if (snapPresence.connectionState == ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapPresence.data?.docs.length == 0 || snapPresence.data?.docs.length == null){
                    return SizedBox(
                      height: 60,
                      child: Center(
                        child: Text(
                          "Belum ada data",
                          style: GoogleFonts.poppins(),
                          ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapPresence.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = snapPresence.data!.docs[index].data();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Material(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            onTap: ()=> Get.toNamed(
                              Routes.DETAIL_PRESENSI, 
                              arguments: data
                              ),
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Datang",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                        "${DateFormat.yMMMEd().format(DateTime.parse(data['date']))}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(data['datang']?['date'] == null ? "-" : "${DateFormat("HH:mm:ss").format(DateTime.parse(data['datang']!['date']))} WIB",
                                    style: GoogleFonts.poppins(),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Pulang",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 20),
                                        child: data["sync"] == "N" 
                                        ? Column(
                                          children: [
                                            Icon(Icons.close_rounded,
                                            color: Color.fromARGB(255, 214, 32, 32),
                                            ),
                                        
                                          ],
                                        )
                                        : Icon(Icons.check_rounded,
                                        color: Color.fromARGB(255, 19, 204, 13),
                                        )
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 0,
                                  ),
                                  Text(data['pulang']?['date'] == null ? "-" : "${DateFormat("HH:mm:ss").format(DateTime.parse(data['pulang']!['date']))} WIB",
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    );
                }
              ),
            ],
          );
        } else {
          return Center(
            child: Text("Tidak dapat memuat database."),
          );
        }
        },
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Color(0xffFFC107),
        activeColor: Color.fromARGB(255, 255, 255, 255),
        style: TabStyle.fixedCircle,
        elevation: 2,
        cornerRadius: 16,
        height: 56,
        items: [
          TabItem(icon: Icons.home_outlined, title: 'Home'),
          TabItem(icon: Icons.local_hospital_outlined, title: 'Sakit'),
          TabItem(icon: Icons.fingerprint, title: 'Add'),
          TabItem(icon: Icons.flight_class_outlined, title: 'Dns. Luar'),
          TabItem(icon: Icons.people_outline, title: 'Profil'),
        ],
        // initialActiveIndex: pageC.pageIndex.value,//optional, default as 0
        onTap: (int i) => pageC.changePage(i),
      )
    );
  }
}
