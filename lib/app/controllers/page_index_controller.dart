import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  void changePage(int i) async {
    pageIndex.value = i;
    switch (i) {
      case 1 :
        print("ABSEN"); 
        break;
      case 2 : 
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }
}
