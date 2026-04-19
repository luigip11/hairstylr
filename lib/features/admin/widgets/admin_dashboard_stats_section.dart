import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_area_controller.dart';
import 'admin_kpi_panel.dart';

class AdminDashboardStatsSection extends GetView<AdminAreaController> {
  const AdminDashboardStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          SizedBox(
            width: 400,
            height: 144,
            child: AdminKpiPanel(
              label: 'Admin attivo',
              value: controller.currentUser.value?.email ?? 'admin',
            ),
          ),
          SizedBox(
            width: 320,
            height: 144,
            child: AdminKpiPanel(
              label: 'Appuntamenti in agenda',
              value: '${controller.appointments.length}',
              detail: 'Richieste e slot prenotati',
            ),
          ),
        ],
      ),
    );
  }
}
