import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../core/models/booking_support.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_appointment_edit_dialog.dart';

class AdminAppointmentRow extends GetView<AdminAreaController> {
  const AdminAppointmentRow({
    super.key,
    required this.data,
    this.compact = false,
  });

  final Map<String, dynamic> data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final appointmentId = data['id'] as String? ?? '';
    final scheduledFor = (data['scheduledFor'] as Timestamp?)?.toDate();
    final customerName = (data['customerName'] as String?) ?? 'Cliente';
    final serviceName =
        (data['serviceDisplayName'] as String?) ??
        (data['serviceName'] as String?) ??
        'Servizio';
    final notes = (data['notes'] as String?) ?? '';
    final status = (data['status'] as String?) ?? 'requested';

    if (compact) {
      return _buildCompact(
        context: context,
        appointmentId: appointmentId,
        scheduledFor: scheduledFor,
        customerName: customerName,
        serviceName: serviceName,
        notes: notes,
        status: status,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appCream,
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
                  style: const TextStyle(color: AppColors.textMutedGreen),
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
                    style: const TextStyle(
                      color: AppColors.textMutedGreenAlt,
                    ),
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
                        ? AppColors.successSurface
                        : AppColors.confirmedBlueSurface,
                    foregroundColor: isConfirmed
                        ? AppColors.successGreen
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
                    backgroundColor: AppColors.dangerSurface,
                    foregroundColor: AppColors.dangerRed,
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

  Widget _buildCompact({
    required BuildContext context,
    required String appointmentId,
    required DateTime? scheduledFor,
    required String customerName,
    required String serviceName,
    required String notes,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.softBlueTint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                scheduledFor == null ? '--:--' : formatTime(scheduledFor),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.bookingDeepBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    _StatusChip(status: status, compact: true),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMutedGreenAlt,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Obx(() {
            final isBusy = controller.isAppointmentBusy(appointmentId);
            final isConfirmed = status == 'confirmed' || status == 'completed';

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CompactActionButton(
                  tooltip: 'Modifica appuntamento',
                  icon: Icons.edit_outlined,
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
                ),
                const SizedBox(width: 6),
                _CompactActionButton(
                  tooltip: isConfirmed
                      ? 'Appuntamento gia confermato'
                      : 'Conferma appuntamento',
                  icon: isBusy
                      ? Icons.hourglass_top_rounded
                      : Icons.check_rounded,
                  backgroundColor: isConfirmed
                      ? AppColors.successSurface
                      : AppColors.confirmedBlueSurface,
                  foregroundColor: isConfirmed
                      ? AppColors.successGreen
                      : AppTheme.accentBlueDark,
                  onPressed: isBusy || isConfirmed
                      ? null
                      : () => controller.confirmAppointment(appointmentId),
                ),
                const SizedBox(width: 6),
                _CompactActionButton(
                  tooltip: 'Elimina appuntamento',
                  icon: Icons.delete_outline_rounded,
                  backgroundColor: AppColors.dangerSurface,
                  foregroundColor: AppColors.dangerRed,
                  onPressed: isBusy
                      ? null
                      : () => _confirmDelete(context, appointmentId),
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
  const _StatusChip({required this.status, this.compact = false});

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (status) {
      'confirmed' => AppColors.successSurface,
      'completed' => AppColors.completedSurface,
      _ => AppColors.warningSurface,
    };
    final foregroundColor = switch (status) {
      'confirmed' => AppColors.successGreen,
      'completed' => AppTheme.accentBlueDark,
      _ => AppColors.warningOrange,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: foregroundColor,
          fontSize: compact ? 11 : null,
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

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
    );
  }
}
