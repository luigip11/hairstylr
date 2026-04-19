import 'package:get/get.dart';

import '../controllers/public_booking_controller.dart';

class PublicBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(PublicBookingController.new);
  }
}
