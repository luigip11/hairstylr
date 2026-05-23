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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: LayoutBuilder(
                    builder: (context, contentConstraints) {
                      final isWide = contentConstraints.maxWidth >= 980;
                      final availableWidth = contentConstraints.maxWidth;
                      final mainWidth = isWide
                          ? ((availableWidth - 20) * 0.58).clamp(0.0, 670.0)
                          : availableWidth;
                      final sideWidth = isWide
                          ? ((availableWidth - 20) * 0.42).clamp(0.0, 470.0)
                          : availableWidth;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BookingPosterHeader(
                            onAdminTap: () {
                              controller.resetConfirmationSection();
                              Get.toNamed(AppRoutes.admin);
                            },
                          ),
                          const SizedBox(height: 20),
                          Obx(() {
                            final hasServices = controller.services.isNotEmpty;
                            final hasAvailability =
                                controller.availability.value != null;

                            if (!hasServices || !hasAvailability) {
                              return const BookingInfoPanel(
                                title: 'Setup iniziale richiesto',
                                body:
                                    'Servizi o disponibilita non ancora pronti. Entra nell area admin per inizializzare la piattaforma.',
                              );
                            }

                            return Wrap(
                              alignment: WrapAlignment.center,
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
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
