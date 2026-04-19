import 'package:get/get.dart';

import '../controllers/admin_area_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AdminAreaController.new);
  }
}
