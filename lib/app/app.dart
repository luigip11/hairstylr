import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/admin/bindings/admin_binding.dart';
import '../features/admin/pages/admin_area_page.dart';
import '../features/home/pages/authenticated_home_page.dart';
import '../features/public_booking/bindings/public_booking_binding.dart';
import 'app_binding.dart';
import 'app_routes.dart';
import 'app_theme.dart';

class HairstylrApp extends StatelessWidget {
  const HairstylrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hairstylr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: AppBinding(),
      initialRoute: _initialRoute(),
      getPages: [
        GetPage(
          name: AppRoutes.home,
          page: AuthenticatedHomePage.new,
          binding: PublicBookingBinding(),
        ),
        GetPage(
          name: AppRoutes.admin,
          page: AdminAreaPage.new,
          binding: AdminBinding(),
        ),
      ],
    );
  }

  static String _initialRoute() {
    final path = Uri.base.path;
    return path.startsWith(AppRoutes.admin) ? AppRoutes.admin : AppRoutes.home;
  }
}
