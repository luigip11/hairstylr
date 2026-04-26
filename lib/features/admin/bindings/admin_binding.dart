import 'package:get/get.dart';

import '../controllers/admin_area_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminAreaController>()) {
      Get.lazyPut(AdminAreaController.new);
    }
  }
}
