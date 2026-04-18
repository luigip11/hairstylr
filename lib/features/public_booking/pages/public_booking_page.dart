import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../controllers/public_booking_controller.dart';
import '../widgets/booking_calendar_section.dart';
import '../widgets/booking_confirmation_section.dart';
import '../widgets/booking_info_panel.dart';
import '../widgets/booking_poster_header.dart';

class PublicBookingPage extends GetView<PublicBookingController> {
  const PublicBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final mainWidth = isWide
                ? (constraints.maxWidth - 60) * 0.6
                : constraints.maxWidth;
            final sideWidth = isWide
                ? (constraints.maxWidth - 60) * 0.4
                : constraints.maxWidth;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookingPosterHeader(
                    onAdminTap: () => Get.toNamed(AppRoutes.admin),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final hasServices = controller.services.isNotEmpty;
                    final hasAvailability = controller.availability.value != null;

                    if (!hasServices || !hasAvailability) {
                      return const BookingInfoPanel(
                        title: 'Setup iniziale richiesto',
                        body:
                            'Servizi o disponibilita non ancora pronti. Entra nell area admin per inizializzare la piattaforma.',
                      );
                    }

                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        SizedBox(
                          width: mainWidth,
                          child: const BookingCalendarSection(),
                        ),
                        SizedBox(
                          width: sideWidth,
                          child: const BookingConfirmationSection(),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
