import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../admin/controllers/admin_area_controller.dart';
import '../../admin/widgets/admin_login_panel.dart';
import '../../public_booking/controllers/public_booking_controller.dart';
import '../../public_booking/pages/public_booking_page.dart';

class AuthenticatedHomePage extends GetView<AdminAreaController> {
  const AuthenticatedHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.currentUser.value;

      if (user == null) {
        if (Get.isRegistered<PublicBookingController>()) {
          Get.delete<PublicBookingController>();
        }
        return const AdminLoginPanel();
      }

      if (!Get.isRegistered<PublicBookingController>()) {
        Get.put(PublicBookingController());
      }

      return const PublicBookingPage();
    });
  }
}
