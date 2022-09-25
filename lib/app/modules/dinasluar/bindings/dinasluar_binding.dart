import 'package:get/get.dart';

import '../controllers/dinasluar_controller.dart';

class DinasluarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DinasluarController>(
      () => DinasluarController(),
    );
  }
}
