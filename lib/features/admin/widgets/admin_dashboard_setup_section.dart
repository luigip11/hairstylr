import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_area_controller.dart';
import 'admin_panel_shell.dart';

class AdminDashboardSetupSection extends GetView<AdminAreaController> {
  const AdminDashboardSetupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminPanelShell(
      title: 'Setup veloce',
      subtitle:
          'Inizializza servizi, disponibilitÃ  settimanale e documento placeholder.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => FilledButton(
              onPressed: controller.isSeeding.value
                  ? null
                  : controller.seedCollections,
              child: Text(
                controller.isSeeding.value
                    ? 'Aggiornamento in corso...'
                    : 'Aggiorna setup iniziale',
              ),
            ),
          ),
          Obx(() {
            final info = controller.infoMessage.value;
            if (info == null || info.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(info),
            );
          }),
        ],
      ),
    );
  }
}
