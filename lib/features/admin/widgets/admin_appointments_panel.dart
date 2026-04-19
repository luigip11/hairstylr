import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_area_controller.dart';
import 'admin_appointment_row.dart';
import 'admin_panel_shell.dart';

class AdminAppointmentsPanel extends StatefulWidget {
  const AdminAppointmentsPanel({super.key});

  @override
  State<AdminAppointmentsPanel> createState() => _AdminAppointmentsPanelState();
}

class _AdminAppointmentsPanelState extends State<AdminAppointmentsPanel> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminAreaController>();
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final panelHeight = isLandscape
        ? mediaQuery.size.height * 0.58
        : mediaQuery.size.height * 0.5;
    final clampedPanelHeight = panelHeight.clamp(280.0, 520.0).toDouble();

    return Obx(
      () => AdminPanelShell(
        title: 'Appuntamenti',
        subtitle:
            'Visualizza, modifica e cancella le richieste di prenotazione.',
        child: controller.appointments.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Nessuna prenotazione ancora presente. Usa il seed o prova una prenotazione dalla vista cliente.',
                ),
              )
            : SizedBox(
                height: clampedPanelHeight,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(right: 8, bottom: 24),
                    itemCount: controller.appointments.length,
                    itemBuilder: (context, index) {
                      return AdminAppointmentRow(
                        data: controller.appointments[index],
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
