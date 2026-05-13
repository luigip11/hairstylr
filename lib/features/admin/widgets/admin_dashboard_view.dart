import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../app/app_theme.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_appointments_panel.dart';
import 'admin_customers_panel.dart';
import 'admin_dashboard_section.dart';
import 'admin_information_panel.dart';
import 'admin_user_panel.dart';

class AdminDashboardView extends GetView<AdminAreaController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appCream,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
            final forceCollapsed = constraints.maxWidth < 700;
            return Obx(() {
              final isCollapsed =
                  forceCollapsed || controller.isSidebarCollapsed.value;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AdminSidebar(isCollapsed: isCollapsed),
                  Expanded(
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.only(bottom: keyboardInset),
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
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.bookingDeepBlue,
              ),
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
                  icon: const Icon(
                    Icons.keyboard_double_arrow_left_rounded,
                    color: AppColors.bookingDeepBlue,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 26),
          Expanded(
            child: Obx(
              () => SingleChildScrollView(
                child: Column(
                  children: [
                    _SidebarItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      collapsed: isCollapsed,
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
                      onTap: () => controller.selectSection(
                        AdminDashboardSection.customers,
                      ),
                    ),
                    _SidebarItem(
                      icon: Icons.info_rounded,
                      label: 'Informazioni',
                      collapsed: isCollapsed,
                      selected:
                          controller.selectedSection.value ==
                          AdminDashboardSection.information,
                      onTap: () => controller.selectSection(
                        AdminDashboardSection.information,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Get.offNamed(AppRoutes.home),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSlate,
              alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: isCollapsed
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: const Text(
                      'Torna indietro',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
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
      AdminDashboardSection.dashboard => const AdminDashboardSectionPanel(),
      AdminDashboardSection.user => const AdminUserPanel(),
      AdminDashboardSection.appointments => const AdminAppointmentsPanel(),
      AdminDashboardSection.customers => const AdminCustomersPanel(),
      AdminDashboardSection.information => const AdminInformationPanel(),
    };

    if (section == AdminDashboardSection.customers) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 20, 28),
          child: SizedBox.expand(child: child),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(4, 20, 20, 28),
      child: child,
    );
  }
}
