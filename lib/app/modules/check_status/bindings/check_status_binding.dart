import 'package:get/get.dart';

import '../controllers/check_status_controller.dart';

class CheckStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckStatusController>(
      () => CheckStatusController(),
    );
  }
}
