import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/routes/app_pages.dart';
import '../../../controllers/page_index_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
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

          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Container(
                      height: 75,
                      width: 75,
                      color: Colors.grey[200],
                      child: Image.network(user["profile"] != null ? user["profile"] : defaultImage,
                              fit: BoxFit.cover,
                              ),
                      // child: Image.network(src),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat Datang di SADASBOR",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 200,
                        child: Text(
                          user['alamat'] != null ? "${user['alamat']}" : "Belum ada lokasi",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 12,
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
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                   color: Color(0xffFFC107),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user['nomenklatur_jabatan']}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    Text(
                      "${user['nip']}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${user['nama_pegawai']}, ${user['gelar_belakang']}",
                      )
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
                  color: Color.fromARGB(255, 255, 206, 59),
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
                            Text("Datang"),
                            Text(dataToday?["datang"] == null ? "-" : "${DateFormat.jms().format(DateTime.parse(dataToday!['datang']['date']))}"),
                          ],
                        ),
                        Container(
                          width: 2,
                          height: 25,
                          color: Color.fromARGB(255, 255, 225, 134),
                        ),
                        Column(
                          children: [
                            Text("Pulang"),
                            Text(dataToday?["pulang"] == null ? "-" : "${DateFormat.jms().format(DateTime.parse(dataToday!['pulang']['date']))}"),
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
                    "Presensi 5 hari terakhir",
                    style: TextStyle(
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
                        child: Text("Belum ada data"),
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
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                        "${DateFormat.yMMMEd().format(DateTime.parse(data['date']))}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(data['datang']?['date'] == null ? "-" : "${DateFormat.jms().format(DateTime.parse(data['datang']!['date']))}" ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Pulang",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(data['pulang']?['date'] == null ? "-" : "${DateFormat.jms().format(DateTime.parse(data['pulang']!['date']))}"),
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
      )
    );
  }
}
