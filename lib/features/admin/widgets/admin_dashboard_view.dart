import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_appointment_row.dart';
import 'admin_kpi_panel.dart';
import 'admin_panel_shell.dart';

class AdminDashboardView extends GetView<AdminAreaController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda admin'),
        actions: [
          TextButton(
            onPressed: () => Get.offNamed(AppRoutes.home),
            child: const Text('Vista cliente'),
          ),
          TextButton(
            onPressed: controller.signOut,
            child: const Text('Logout'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _AdminDashboardStats(),
            SizedBox(height: 20),
            _AdminDashboardSetup(),
            SizedBox(height: 20),
            _AdminAppointmentsPanel(),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardStats extends GetView<AdminAreaController> {
  const _AdminDashboardStats();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          SizedBox(
            width: 320,
            child: AdminKpiPanel(
              label: 'Appuntamenti in agenda',
              value: '${controller.appointments.length}',
              detail: 'Richieste e slot prenotati visibili solo admin',
            ),
          ),
          SizedBox(
            width: 320,
            child: AdminKpiPanel(
              label: 'Admin attivo',
              value: controller.currentUser.value?.email ?? 'admin',
              detail: 'Accesso riservato a voi due',
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardSetup extends GetView<AdminAreaController> {
  const _AdminDashboardSetup();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        SizedBox(
          width: 360,
          child: AdminPanelShell(
            title: 'Setup veloce',
            subtitle:
                'Inizializza servizi, disponibilita settimanale e documento placeholder.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => FilledButton(
                    onPressed:
                        controller.isSeeding.value ? null : controller.seedCollections,
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
          ),
        ),
        const SizedBox(
          width: 520,
          child: AdminPanelShell(
            title: 'Promemoria operativo',
            subtitle:
                'Per ora il flusso pubblico prenota direttamente uno slot e crea la richiesta in Firestore.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Aggiorna services e availability da Firestore.'),
                SizedBox(height: 8),
                Text(
                  '2. Le clienti vedono solo la pagina pubblica e prenotano senza account.',
                ),
                SizedBox(height: 8),
                Text('3. L area admin resta separata su /admin.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminAppointmentsPanel extends GetView<AdminAreaController> {
  const _AdminAppointmentsPanel();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AdminPanelShell(
        title: 'Appuntamenti',
        subtitle:
            'Vista agenda iniziale. Nel prossimo step possiamo aggiungere modifica, conferma e stato.',
        child: controller.appointments.isEmpty
            ? const Text(
                'Nessuna prenotazione ancora presente. Usa il seed o prova una prenotazione dalla vista cliente.',
              )
            : Column(
                children: controller.appointments
                    .map(
                      (appointment) => AdminAppointmentRow(data: appointment),
                    )
                    .toList(growable: false),
              ),
      ),
    );
  }
}
