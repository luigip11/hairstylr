import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../app/app_theme.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_appointments_panel.dart';
import 'admin_dashboard_setup_section.dart';
import 'admin_kpi_panel.dart';
import 'admin_panel_shell.dart';
import 'admin_popup_selector.dart';
import 'admin_utilization_chart_card.dart';

class AdminDashboardView extends GetView<AdminAreaController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appCream,
      body: SafeArea(
        child: Row(
          children: [
            const _AdminSidebar(),
            Expanded(
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _AdminSectionBody(
                    key: ValueKey(controller.selectedSection.value),
                    section: controller.selectedSection.value,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSidebar extends GetView<AdminAreaController> {
  const _AdminSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.bookingDeepBlue.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => Get.offNamed(AppRoutes.home),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Area admin',
                  style: TextStyle(
                    fontFamily: 'StoryScript',
                    fontSize: 30,
                    color: AppColors.bookingDeepBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Obx(
            () => Column(
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  selected:
                      controller.selectedSection.value ==
                      AdminDashboardSection.dashboard,
                  onTap: () => controller.selectSection(
                    AdminDashboardSection.dashboard,
                  ),
                ),
                _SidebarItem(
                  icon: Icons.person_rounded,
                  label: 'Utente',
                  selected:
                      controller.selectedSection.value ==
                      AdminDashboardSection.user,
                  onTap: () =>
                      controller.selectSection(AdminDashboardSection.user),
                ),
                _SidebarItem(
                  icon: Icons.event_note_rounded,
                  label: 'Appuntamenti',
                  selected:
                      controller.selectedSection.value ==
                      AdminDashboardSection.appointments,
                  onTap: () => controller.selectSection(
                    AdminDashboardSection.appointments,
                  ),
                ),
                _SidebarItem(
                  icon: Icons.groups_rounded,
                  label: 'Clienti',
                  selected:
                      controller.selectedSection.value ==
                      AdminDashboardSection.customers,
                  onTap: () => controller.selectSection(
                    AdminDashboardSection.customers,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: controller.signOut,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.dangerRed,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.softBlueTint : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.borderBlue : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? AppTheme.accentBlueDark
                    : AppColors.textSlate,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppTheme.accentBlueDark
                      : AppColors.textSlate,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSectionBody extends StatelessWidget {
  const _AdminSectionBody({super.key, required this.section});

  final AdminDashboardSection section;

  @override
  Widget build(BuildContext context) {
    final child = switch (section) {
      AdminDashboardSection.dashboard => const _DashboardSection(),
      AdminDashboardSection.user => const _UserSection(),
      AdminDashboardSection.appointments => const _AppointmentsSection(),
      AdminDashboardSection.customers => const _CustomersSection(),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(4, 20, 20, 28),
      child: child,
    );
  }
}

class _DashboardSection extends GetView<AdminAreaController> {
  const _DashboardSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        const SizedBox(width: 600, child: AdminUtilizationChartCard()),
        Obx(
          () => SizedBox(
            width: 360,
            height: 174,
            child: AdminKpiPanel(
              label: 'Appuntamenti in agenda',
              value: '${controller.appointments.length}',
              detail: 'Prenotazioni totali nel workspace',
            ),
          ),
        ),
      ],
    );
  }
}

class _UserSection extends GetView<AdminAreaController> {
  const _UserSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        Obx(
          () => SizedBox(
            width: 400,
            height: 160,
            child: AdminKpiPanel(
              label: 'Workspace attivo',
              value: controller.currentWorkspaceName,
              detail: controller.currentUser.value?.email ?? 'admin',
            ),
          ),
        ),
        const SizedBox(width: 420, child: AdminDashboardSetupSection()),
      ],
    );
  }
}

class _AppointmentsSection extends GetView<AdminAreaController> {
  const _AppointmentsSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final range = controller.selectedAppointmentsRange.value;
      return AdminAppointmentsPanel(
        appointments: controller.filteredAppointments,
        emptyMessage:
            'Nessun appuntamento trovato per il filtro ${range.label.toLowerCase()}.',
        headerAction: AdminPopupSelector<AdminUtilizationRange>(
          width: 182,
          value: range,
          items: controller.utilizationRanges
              .map(
                (item) => AdminPopupSelectorItem<AdminUtilizationRange>(
                  value: item,
                  label: item.label,
                ),
              )
              .toList(growable: false),
          onChanged: controller.selectAppointmentsRange,
        ),
      );
    });
  }
}

class _CustomersSection extends StatelessWidget {
  const _CustomersSection();

  @override
  Widget build(BuildContext context) {
    return AdminPanelShell(
      title: 'Clienti',
      subtitle: 'Rubrica clienti e storico appuntamenti.',
      child: SizedBox(
        height: 360,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 46,
                color: AppColors.textChartMuted,
              ),
              const SizedBox(height: 14),
              const Text(
                'Non ci sono clienti censiti.',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bookingDeepBlue,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const Text('Aggiungi cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
