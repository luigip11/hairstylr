import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../core/models/booking_support.dart';
import '../../../core/widgets/custom_empty_state.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_panel_shell.dart';

class AdminWeekTimelineCard extends GetView<AdminAreaController> {
  const AdminWeekTimelineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final appointments = controller.currentWeekAppointments;

      return AdminPanelShell(
        title: 'Timeline settimana',
        subtitle: 'Appuntamenti presenti nella settimana corrente.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: appointments.isEmpty ? 174 : 310,
              child: appointments.isEmpty
                  ? const CustomEmptyState(
                      message: 'Nessun appuntamento questa settimana.',
                      height: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(right: 4),
                      itemCount: appointments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _WeekTimelineItem(data: appointments[index]);
                      },
                    ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: controller.openAppointmentsCalendar,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Vai agli appuntamenti'),
            ),
          ],
        ),
      );
    });
  }
}

class _WeekTimelineItem extends StatelessWidget {
  const _WeekTimelineItem({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final scheduledFor = _appointmentDate(data['scheduledFor']);
    final customerName = (data['customerName'] as String?) ?? 'Cliente';
    final serviceName =
        (data['serviceDisplayName'] as String?) ??
        (data['serviceName'] as String?) ??
        'Servizio';
    final status = (data['status'] as String?) ?? 'requested';
    final slotLabel = (data['slotLabel'] as String?)?.trim();
    final timeLabel = slotLabel?.isNotEmpty == true
        ? slotLabel!
        : scheduledFor == null
        ? '--:--'
        : formatTime(scheduledFor);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 54,
          child: Column(
            children: [
              Text(
                scheduledFor == null ? '--' : weekdayShort(scheduledFor),
                style: const TextStyle(
                  color: AppColors.textCalendarMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.softBlueTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    scheduledFor == null ? '--' : '${scheduledFor.day}',
                    style: const TextStyle(
                      color: AppColors.bookingDeepBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softPanel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderBlueSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        timeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.bookingDeepBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TimelineStatusDot(status: status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textGreyBlue),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DateTime? _appointmentDate(Object? value) {
    return switch (value) {
      Timestamp timestamp => timestamp.toDate(),
      DateTime date => date,
      _ => null,
    };
  }
}

class _TimelineStatusDot extends StatelessWidget {
  const _TimelineStatusDot({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'confirmed' => AppColors.successGreen,
      'completed' => AppTheme.accentBlueDark,
      _ => AppColors.warningOrange,
    };
    final label = switch (status) {
      'confirmed' => 'Confermato',
      'completed' => 'Completato',
      _ => 'Richiesto',
    };

    return Tooltip(
      message: label,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
