import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_dashboard_setup_section.dart';
import 'admin_kpi_panel.dart';

class AdminUserPanel extends GetView<AdminAreaController> {
  const AdminUserPanel({super.key});

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
