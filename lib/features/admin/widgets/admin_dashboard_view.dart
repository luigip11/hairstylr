import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_appointments_panel.dart';
import 'admin_dashboard_setup_section.dart';
import 'admin_dashboard_stats_section.dart';

class AdminDashboardView extends GetView<AdminAreaController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F1EA),
        title: const Text(
          'Area admin',
          style: TextStyle(fontFamily: 'StoryScript', fontSize: 32),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextButton.icon(
                onPressed: () => Get.offNamed(AppRoutes.home),
                label: const Text('Vista cliente'),
                icon: const Icon(Icons.remove_red_eye),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextButton.icon(
                onPressed: controller.signOut,
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminDashboardStatsSection(),
            SizedBox(height: 20),
            AdminDashboardSetupSection(),
            SizedBox(height: 20),
            AdminAppointmentsPanel(),
          ],
        ),
      ),
    );
  }
}
