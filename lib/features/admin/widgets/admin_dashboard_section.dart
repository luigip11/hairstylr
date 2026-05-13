import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_area_controller.dart';
import 'admin_kpi_panel.dart';
import 'admin_utilization_chart_card.dart';

class AdminDashboardSectionPanel extends GetView<AdminAreaController> {
  const AdminDashboardSectionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 980;
        final agendaCard = Obx(
          () => AdminKpiPanel(
            label: 'Appuntamenti in agenda',
            value: '${controller.appointments.length}',
            detail: 'Prenotazioni totali nel workspace',
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AdminUtilizationChartCard(),
              const SizedBox(height: 20),
              agendaCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 2, child: AdminUtilizationChartCard()),
            const SizedBox(width: 20),
            Expanded(child: SizedBox(height: 174, child: agendaCard)),
          ],
        );
      },
    );
  }
}
