import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/models/booking_support.dart';

class AdminAppointmentRow extends StatelessWidget {
  const AdminAppointmentRow({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
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
                Text('$serviceName - $status'),
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
        ],
      ),
    );
  }
}
