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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final forceCollapsed = constraints.maxWidth < 700;
            return Obx(() {
              final isCollapsed =
                  forceCollapsed || controller.isSidebarCollapsed.value;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AdminSidebar(isCollapsed: isCollapsed),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _AdminSectionBody(
                        key: ValueKey(controller.selectedSection.value),
                        section: controller.selectedSection.value,
                      ),
                    ),
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }
}

class _AdminSidebar extends GetView<AdminAreaController> {
  const _AdminSidebar({required this.isCollapsed});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 86 : 270,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.fromLTRB(16, 18, 16, isCollapsed ? 12 : 16),
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
          if (isCollapsed)
            IconButton(
              tooltip: 'Apri menu',
              onPressed: controller.toggleSidebarCollapsed,
              icon: const Icon(Icons.menu_rounded),
            )
          else
            Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Area admin',
                      style: TextStyle(
                        fontFamily: 'StoryScript',
                        fontSize: 30,
                        color: AppColors.bookingDeepBlue,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Comprimi menu',
                  onPressed: controller.toggleSidebarCollapsed,
                  icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
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
                  collapsed: isCollapsed,
                  selected:
                      controller.selectedSection.value ==
                      AdminDashboardSection.dashboard,
                  onTap: () =>
                      controller.selectSection(AdminDashboardSection.dashboard),
                ),
                _SidebarItem(
                  icon: Icons.person_rounded,
                  label: 'Utente',
                  collapsed: isCollapsed,
                  selected:
                      controller.selectedSection.value ==
                      AdminDashboardSection.user,
                  onTap: () =>
                      controller.selectSection(AdminDashboardSection.user),
                ),
                _SidebarItem(
                  icon: Icons.event_note_rounded,
                  label: 'Appuntamenti',
                  collapsed: isCollapsed,
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
                  collapsed: isCollapsed,
                  selected:
                      controller.selectedSection.value ==
                      AdminDashboardSection.customers,
                  onTap: () =>
                      controller.selectSection(AdminDashboardSection.customers),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => Get.offNamed(AppRoutes.home),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSlate,
              alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
            label: isCollapsed
                ? const SizedBox.shrink()
                : const Text('Torna indietro', style: TextStyle(fontSize: 16)),
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
    required this.collapsed,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool collapsed;
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
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.softBlueTint : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.bookingDeepBlue : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected
                    ? AppTheme.accentBlueDark
                    : AppColors.textGreyBlue,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppTheme.accentBlueDark
                        : AppColors.textGreyBlue,
                    fontSize: selected ? 16 : 15,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
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

class _UserSection extends GetView<AdminAreaController> {
  const _UserSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 980;
        final workspaceCard = Obx(
          () => AdminKpiPanel(
            label: 'Workspace attivo',
            value: controller.currentWorkspaceName,
            detail: controller.currentUser.value?.email ?? 'admin',
          ),
        );
        const setupCard = AdminDashboardSetupSection();
        final logoutCard = _LogoutCard(onLogout: controller.signOut);

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              workspaceCard,
              const SizedBox(height: 20),
              setupCard,
              const SizedBox(height: 20),
              logoutCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SizedBox(height: 170, child: workspaceCard)),
            const SizedBox(width: 20),
            Expanded(child: setupCard),
            const SizedBox(width: 20),
            Expanded(child: SizedBox(height: 170, child: logoutCard)),
          ],
        );
      },
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onLogout,
      child: Ink(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.dangerRed,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
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
