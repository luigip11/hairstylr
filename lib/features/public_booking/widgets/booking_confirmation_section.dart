import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../core/models/booking_support.dart';
import '../controllers/public_booking_controller.dart';
import 'booking_choice_pill.dart';
import 'booking_section_shell.dart';
import 'booking_summary_row.dart';

class BookingConfirmationSection extends GetView<PublicBookingController> {
  const BookingConfirmationSection({super.key});

  static final _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: const BorderSide(color: AppColors.borderBlue, width: 1.2),
  );

  @override
  Widget build(BuildContext context) {
    return BookingSectionShell(
      title: 'Conferma prenotazione',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            decoration: BoxDecoration(
              color: AppColors.softBlueTint,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderBlue),
            ),
            child: Column(
              children: [
                Obx(
                  () => BookingSummaryRow(
                    label: 'Giorno',
                    value: formatDate(controller.selectedDate.value),
                  ),
                ),
                Obx(
                  () => BookingSummaryRow(
                    label: 'Servizio',
                    value: controller.selectedServiceDisplayName,
                  ),
                ),
                Obx(
                  () => BookingSummaryRow(
                    label: 'Orario',
                    value: controller.selectedSlot.value == null
                        ? 'Seleziona un orario'
                        : formatTimeRange(
                            controller.selectedSlot.value!.start,
                            controller.selectedSlot.value!.end,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller.nameController,
            decoration: InputDecoration(
              labelText: 'Nome cliente',
              filled: true,
              fillColor: AppColors.fieldSurface,
              enabledBorder: _fieldBorder,
              focusedBorder: _fieldBorder.copyWith(
                borderSide: const BorderSide(
                  color: bookingAccentBlue,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: controller.updateCustomerName,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller.notesController,
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Note facoltative (colore, domicilio, richieste)',
              filled: true,
              fillColor: AppColors.fieldSurface,
              enabledBorder: _fieldBorder,
              focusedBorder: _fieldBorder.copyWith(
                borderSide: const BorderSide(
                  color: bookingAccentBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
          Obx(() {
            final message = controller.feedbackMessage.value;
            if (message == null || message.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                message,
                style: TextStyle(
                  color: message.startsWith('Richiesta')
                      ? AppTheme.accentBlueDark
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          Obx(
            () => FilledButton(
              onPressed: controller.canSubmit
                  ? controller.bookAppointment
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: bookingAccentBlue,
                disabledBackgroundColor: AppColors.disabledBlue,
                minimumSize: const Size.fromHeight(56),
              ),
              child: Text(
                controller.isSubmitting.value
                    ? 'Invio in corso...'
                    : 'Conferma appuntamento',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
