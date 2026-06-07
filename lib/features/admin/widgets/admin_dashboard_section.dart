import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_area_controller.dart';
import 'admin_utilization_chart_card.dart';
import 'admin_week_timeline_card.dart';

class AdminDashboardSectionPanel extends GetView<AdminAreaController> {
  const AdminDashboardSectionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 980;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AdminUtilizationChartCard(),
              const SizedBox(height: 20),
              const AdminWeekTimelineCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 2, child: AdminUtilizationChartCard()),
            const SizedBox(width: 20),
            const Expanded(child: AdminWeekTimelineCard()),
          ],
        );
      },
    );
  }
}
