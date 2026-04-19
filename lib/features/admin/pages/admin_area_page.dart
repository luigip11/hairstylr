import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_area_controller.dart';
import '../widgets/admin_dashboard_view.dart';
import '../widgets/admin_login_panel.dart';
import '../widgets/admin_unauthorized_panel.dart';

class AdminAreaPage extends GetView<AdminAreaController> {
  const AdminAreaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.currentUser.value;

      if (user == null) {
        return const AdminLoginPanel();
      }

      if (!controller.isAuthorizedAdmin) {
        return AdminUnauthorizedPanel(
          controller: controller,
          email: user.email,
        );
      }

      return const AdminDashboardView();
    });
  }
}
