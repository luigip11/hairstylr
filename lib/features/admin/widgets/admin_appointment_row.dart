import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_theme.dart';
import '../../../core/models/booking_support.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_appointment_edit_dialog.dart';

class AdminAppointmentRow extends GetView<AdminAreaController> {
  const AdminAppointmentRow({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final appointmentId = data['id'] as String? ?? '';
    final scheduledFor = (data['scheduledFor'] as Timestamp?)?.toDate();
    final customerName = (data['customerName'] as String?) ?? 'Cliente';
    final serviceName = (data['serviceName'] as String?) ?? 'Servizio';
    final notes = (data['notes'] as String?) ?? '';
    final status = (data['status'] as String?) ?? 'requested';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 74,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  scheduledFor == null ? '--' : '${scheduledFor.day}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                Text(
                  scheduledFor == null ? '--' : monthShort(scheduledFor),
                  style: const TextStyle(color: Color(0xFF5D6664)),
                ),
                const SizedBox(height: 6),
                Text(
                  scheduledFor == null ? '--:--' : formatTime(scheduledFor),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(serviceName),
                    _StatusChip(status: status),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    notes,
                    style: const TextStyle(color: Color(0xFF5E6966)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            final isBusy = controller.isAppointmentBusy(appointmentId);
            final isConfirmed = status == 'confirmed' || status == 'completed';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Modifica appuntamento',
                  onPressed: isBusy
                      ? null
                      : () {
                          showDialog<void>(
                            context: context,
                            builder: (_) => AdminAppointmentEditDialog(
                              data: data,
                            ),
                          );
                        },
                  icon: const Icon(Icons.edit_outlined),
                ),
                const SizedBox(height: 8),
                IconButton.filledTonal(
                  tooltip: isConfirmed
                      ? 'Appuntamento gia confermato'
                      : 'Conferma appuntamento',
                  onPressed: isBusy || isConfirmed
                      ? null
                      : () => controller.confirmAppointment(appointmentId),
                  style: IconButton.styleFrom(
                    backgroundColor: isConfirmed
                        ? const Color(0xFFE2F3E8)
                        : const Color(0xFFE8EEFF),
                    foregroundColor: isConfirmed
                        ? const Color(0xFF2A7C4B)
                        : AppTheme.accentBlueDark,
                  ),
                  icon: Icon(
                    isBusy ? Icons.hourglass_top_rounded : Icons.check_rounded,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton.filledTonal(
                  tooltip: 'Elimina appuntamento',
                  onPressed: isBusy
                      ? null
                      : () => _confirmDelete(context, appointmentId),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE7E7),
                    foregroundColor: const Color(0xFFB33535),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String appointmentId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminare appuntamento?'),
          content: const Text(
            'Questa azione cancella definitivamente la prenotazione selezionata.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await controller.deleteAppointment(appointmentId);
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (status) {
      'confirmed' => const Color(0xFFE2F3E8),
      'completed' => const Color(0xFFE7F0FF),
      _ => const Color(0xFFFFF1D9),
    };
    final foregroundColor = switch (status) {
      'confirmed' => const Color(0xFF2A7C4B),
      'completed' => AppTheme.accentBlueDark,
      _ => const Color(0xFFA86B12),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _statusLabel(String value) => switch (value) {
    'confirmed' => 'Confermato',
    'completed' => 'Completato',
    _ => 'Richiesto',
  };
}
