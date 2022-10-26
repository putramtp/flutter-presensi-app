import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/check_status_controller.dart';
import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/standalone.dart' as tz;


class CheckStatusView extends GetView<CheckStatusController> {

  void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
}

  DateTime sekarang = DateTime.now();
  @override
  Widget build(BuildContext context) {
    String defaultImage = "https://simpeg.tasikmalayakab.go.id/assets/media/file/199109102019031003/pasfoto/thumb_xx_Foto_2.jpeg";
    return Scaffold(
      appBar: AppBar(
        title: Text('CheckStatusView'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: controller.jamdatang,
              decoration: InputDecoration(
                labelText: "Jam datang",
              )
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: controller.jampulang,
              decoration: InputDecoration(
                labelText: "Jam pulang",
              ),
            ),
            SizedBox(
              height: 20,
            ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      height: 75,
                      width: 75,
                      child: CachedNetworkImage(imageUrl: "https://i.picsum.photos/id/9/250/250.jpg?hmac=tqDH5wEWHDN76mBIWEPzg1in6egMl49qZeguSaH9_VI",
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ), //https://picsum.photos/250?image=9
            
          // Image.network('https://picsum.photos/250?image=9',
          //   errorBuilder: ((context, error, stackTrace) {
          //     return Container(
          //       color: Colors.amber,
          //       alignment: Alignment.center,
          //       child: const Text("Eits"),
          //     );
          //   }),
          // ),
            ElevatedButton(
              onPressed: () async {
                if (controller.isLoading.isFalse){
                  await controller.checkAPITime();
                 ;
                }
              }, child: Text(
                "CEK",
              ))
          ],
        )
      ),
    );
  }
}
