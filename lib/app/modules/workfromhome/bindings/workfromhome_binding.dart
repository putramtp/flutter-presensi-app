import 'package:get/get.dart';

import '../controllers/workfromhome_controller.dart';

class WorkfromhomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkfromhomeController>(
      () => WorkfromhomeController(),
    );
  }
}
