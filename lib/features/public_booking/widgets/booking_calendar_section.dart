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
          Text('Servizi', style: Theme.of(context).textTheme.titleLarge),
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

            final slots = controller.slots;
            final customSlots = controller.customSlots;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Orari disponibili',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (controller.hasCustomSlots) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: controller.isEditingCustomSlots.value
                            ? 'Fine modifica'
                            : 'Modifica orari creati',
                        onPressed: controller.toggleCustomSlotsEditing,
                        icon: Icon(
                          controller.isEditingCustomSlots.value
                              ? Icons.check_circle
                              : Icons.edit,
                          color: controller.isEditingCustomSlots.value
                              ? Colors.green
                              : Colors.grey,
                          size: 26,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (slots.isEmpty && customSlots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Nessuno slot disponibile per il giorno selezionato.',
                    ),
                  ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...slots.map(
                      (slot) => BookingChoicePill(
                        label: formatTimeRange(slot.start, slot.end),
                        selected: _isSelectedSlot(slot),
                        onTap: () => controller.selectSlot(slot),
                      ),
                    ),
                    ...customSlots.indexed.map((entry) {
                      final index = entry.$1;
                      final slot = entry.$2;
                      return _CustomSlotPill(
                        label: formatTimeRange(slot.start, slot.end),
                        selected: _isSelectedSlot(slot),
                        showDelete: controller.isEditingCustomSlots.value,
                        onTap: () => _showCustomTimeDialog(
                          context,
                          isEditing: true,
                          customSlotIndex: index,
                        ),
                        onDelete: () => controller.deleteCustomSlotAt(index),
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
    if (!controller.canCreateCustomSlot) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hai raggiunto il limite di orari creati. Cancellane o modifica uno per continuare.',
          ),
        ),
      );
      return;
    }

    _showCustomTimeDialog(context);
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
                        style: Theme.of(context).textTheme.titleLarge,
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

                              controller.selectCustomTimeRange(
                                startTime: TimeOfDay.fromDateTime(
                                  startDateTime,
                                ),
                                endTime: TimeOfDay.fromDateTime(endDateTime),
                                index: customSlotIndex,
                              );
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

  int _roundToPickerMinute(int minute) => minute - (minute % 5);
}

class _CustomSlotPill extends StatelessWidget {
  const _CustomSlotPill({
    required this.label,
    required this.selected,
    required this.showDelete,
    required this.onTap,
    required this.onDelete,
  });

  final String label;
  final bool selected;
  final bool showDelete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 0, right: 0),
          child: BookingChoicePill(
            label: label,
            selected: selected,
            onTap: onTap,
          ),
        ),
        if (showDelete)
          Positioned(
            top: -5,
            right: -5,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onDelete,
                child: Ink(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: bookingDeepBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.close, size: 13, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
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
