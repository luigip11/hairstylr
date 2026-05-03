import 'package:get/get.dart';

import '../features/admin/controllers/admin_area_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminAreaController>()) {
      Get.put(AdminAreaController(), permanent: true);
    }
  }
}
