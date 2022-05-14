import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
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
        title: Text('Beranda'),
        centerTitle: true,
        actions: [
          IconButton(
                onPressed: ()=> Get.toNamed(Routes.PROFILE), 
              icon: Icon(Icons.person)
              )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Row(
            children: [
              ClipOval(
                child: Container(
                  height: 75,
                  width: 75,
                  color: Colors.grey[200],
                  child: Center(
                    child: Text("X"),
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
                    "Welcome,",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "Alamat Sekarang Ada Dimana",
                    style: TextStyle(
                      fontSize: 12,
                    ),)
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
               color: Colors.grey[200],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Developer",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                Text(
                  "3278042109980009",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text("Muhammad Saiful Anwar")
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
              color: Colors.grey[200],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Datang"),
                    Text("-")
                  ],
                ),
                Container(
                  width: 2,
                  height: 25,
                  color: Colors.grey[400],
                ),
                Column(
                  children: [
                    Text("Pulang"),
                    Text("-")
                  ],
                )
              ],
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
              TextButton(
                onPressed: (){}, 
                child: Text(
                        "see more",
                        style: TextStyle(
                          fontSize: 12
                        ),
                        ),
                ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
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
                          "${DateFormat.yMMMEd().format(DateTime.now())}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Text("${DateFormat.jms().format(DateTime.now())}"),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Pulang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text("${DateFormat.jms().format(DateTime.now())}"),
                  ],
                ),
              );
            }
            ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.fingerprint, title: 'Add'),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        initialActiveIndex: pageC.pageIndex.value,//optional, default as 0
        onTap: (int i) => pageC.changePage(i),
      )
    );
  }
}
