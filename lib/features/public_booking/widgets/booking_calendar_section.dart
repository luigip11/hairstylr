import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/booking_support.dart';
import '../controllers/public_booking_controller.dart';
import 'booking_choice_pill.dart';
import 'booking_month_grid.dart';
import 'booking_month_header.dart';
import 'booking_section_shell.dart';

class BookingCalendarSection extends GetView<PublicBookingController> {
  const BookingCalendarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BookingSectionShell(
      title: 'Scegli il giorno',
      subtitle: 'Visualizza gli slot disponibili',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => BookingMonthHeader(
              visibleMonth: controller.visibleMonth.value,
              onPrevious: () => controller.changeMonth(-1),
              onNext: () => controller.changeMonth(1),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => BookingMonthGrid(
              dates: controller.calendarCells,
              selectedDate: controller.selectedDate.value,
              onSelect: controller.selectDate,
            ),
          ),
          const SizedBox(height: 24),
          Text('Servizi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.services
                  .map(
                    (service) => BookingChoicePill(
                      label: service.name,
                      selected: service.id == controller.selectedServiceId.value,
                      onTap: () => controller.selectService(service.id),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Orari disponibili',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Obx(() {
            final slots = controller.slots;
            if (slots.isEmpty) {
              return const Text(
                'Nessuno slot disponibile per il giorno selezionato.',
              );
            }

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: slots
                  .map(
                    (slot) => BookingChoicePill(
                      label: formatTimeRange(slot.start, slot.end),
                      selected:
                          controller.selectedSlot.value?.start == slot.start,
                      onTap: () => controller.selectSlot(slot),
                    ),
                  )
                  .toList(growable: false),
            );
          }),
        ],
      ),
    );
  }
}
