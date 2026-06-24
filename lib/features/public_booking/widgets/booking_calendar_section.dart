import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
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
          Text(
            'Servizi',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.services
                  .expand((service) {
                    if (service.id == 'altro') {
                      return [
                        BookingChoicePill(
                          label: service.name,
                          selected:
                              service.id == controller.selectedServiceId.value,
                          onTap: () => controller.selectService(service.id),
                        ),
                        if (controller.isOtherServiceSelected)
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: SizedBox(
                              width: 220,
                              height: 48,
                              child: TextField(
                                controller: controller.customServiceController,
                                onChanged: controller.updateCustomServiceLabel,
                                decoration: InputDecoration(
                                  labelText: 'Specifica il servizio',
                                  labelStyle: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                      color: bookingDeepBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ];
                    }

                    return [
                      BookingChoicePill(
                        label: service.name,
                        selected:
                            service.id == controller.selectedServiceId.value,
                        onTap: () => controller.selectService(service.id),
                      ),
                    ];
                  })
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (!controller.hasSelectedService) {
              return const SizedBox.shrink();
            }

            final customSlots = controller.customSlots;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Orario',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...customSlots.map((slot) {
                      return BookingChoicePill(
                        label: formatTimeRange(slot.start, slot.end),
                        selected: _isSelectedSlot(slot),
                        onTap: () => controller.selectSlot(slot),
                      );
                    }),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _handleCreateCustomTime(context),
                        style: ButtonStyle(
                          side: WidgetStateProperty.all(
                            const BorderSide(
                              color: bookingDeepBlue,
                              width: 1.5,
                            ),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),

                        child: const Text(
                          'Imposta un orario',
                          style: TextStyle(color: bookingDeepBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _handleCreateCustomTime(BuildContext context) {
    _showCustomTimeDialog(
      context,
      isEditing: controller.hasCustomSlots,
      customSlotIndex: controller.hasCustomSlots ? 0 : null,
    );
  }

  bool _isSelectedSlot(TimeSlot slot) {
    final selected = controller.selectedSlot.value;
    return selected?.start == slot.start && selected?.end == slot.end;
  }

  Future<void> _showCustomTimeDialog(
    BuildContext context, {
    bool isEditing = false,
    int? customSlotIndex,
  }) async {
    final customSlot =
        customSlotIndex != null &&
            customSlotIndex < controller.customSlots.length
        ? controller.customSlots[customSlotIndex]
        : null;
    final currentSlot = customSlot ?? controller.selectedSlot.value;
    final now = TimeOfDay.now();
    var startDateTime = DateTime(
      controller.selectedDate.value.year,
      controller.selectedDate.value.month,
      controller.selectedDate.value.day,
      currentSlot?.start.hour ?? now.hour,
      currentSlot?.start.minute ?? _roundToPickerMinute(now.minute),
    );
    var endDateTime =
        currentSlot?.end ?? startDateTime.add(const Duration(minutes: 30));
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.borderBluePale),
                    boxShadow: [
                      BoxShadow(
                        color: bookingDeepBlue.withValues(alpha: 0.16),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Modifica orario' : 'Imposta un orario',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: AppColors.bookingDeepBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isEditing
                            ? "Modifica l'orario personalizzato per questo giorno."
                            : 'Scegli un orario personalizzato per questo giorno.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _CustomTimePickerPanel(
                              label: 'Inizio',
                              value: startDateTime,
                              onChanged: (value) {
                                setDialogState(() {
                                  startDateTime = value;
                                  if (!endDateTime.isAfter(startDateTime)) {
                                    endDateTime = startDateTime.add(
                                      const Duration(minutes: 30),
                                    );
                                  }
                                  errorText = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CustomTimePickerPanel(
                              key: ValueKey(endDateTime),
                              label: 'Fine',
                              value: endDateTime,
                              onChanged: (value) {
                                setDialogState(() {
                                  endDateTime = value;
                                  errorText = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Annulla'),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: bookingAccentBlue,
                            ),
                            onPressed: () {
                              if (!endDateTime.isAfter(startDateTime)) {
                                setDialogState(() {
                                  errorText =
                                      "L'orario di fine deve essere dopo l'inizio.";
                                });
                                return;
                              }

                              final selected = controller.selectCustomTimeRange(
                                startTime: TimeOfDay.fromDateTime(
                                  startDateTime,
                                ),
                                endTime: TimeOfDay.fromDateTime(endDateTime),
                                index: customSlotIndex,
                              );
                              if (!selected) {
                                Navigator.of(dialogContext).pop();
                                _showOccupiedSlotDialog(context);
                                return;
                              }

                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Conferma'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showOccupiedSlotDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: const Text(
            'Intervallo orario già occupato. Seleziona altri orari.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  int _roundToPickerMinute(int minute) => minute - (minute % 5);
}

class _CustomTimePickerPanel extends StatelessWidget {
  const _CustomTimePickerPanel({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: bookingDeepBlue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          height: 170,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.white, AppColors.softBlueTint],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderBlueLight),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                brightness: Brightness.light,
                primaryColor: bookingAccentBlue,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    color: bookingDeepBlue,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: value,
                minuteInterval: 5,
                use24hFormat: true,
                onDateTimeChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
