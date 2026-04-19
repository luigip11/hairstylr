import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_theme.dart';
import '../../../core/models/booking_support.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_popup_selector.dart';

class AdminAppointmentEditDialog extends StatefulWidget {
  const AdminAppointmentEditDialog({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<AdminAppointmentEditDialog> createState() =>
      _AdminAppointmentEditDialogState();
}

class _AdminAppointmentEditDialogState
    extends State<AdminAppointmentEditDialog> {
  late final TextEditingController _customerNameController;
  late final TextEditingController _serviceNameController;
  late final TextEditingController _notesController;
  late String _status;

  AdminAreaController get controller => Get.find<AdminAreaController>();

  static const _statusOptions = <String>['requested', 'confirmed', 'completed'];

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: (widget.data['customerName'] as String?) ?? '',
    );
    _serviceNameController = TextEditingController(
      text: (widget.data['serviceName'] as String?) ?? '',
    );
    _notesController = TextEditingController(
      text: (widget.data['notes'] as String?) ?? '',
    );
    _status = (widget.data['status'] as String?) ?? 'requested';
    if (!_statusOptions.contains(_status)) {
      _status = 'requested';
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _serviceNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentId = widget.data['id'] as String? ?? '';
    final scheduledFor = (widget.data['scheduledFor'] as Timestamp?)?.toDate();

    return AlertDialog(
      title: const Text('Modifica appuntamento'),
      content: SizedBox(
        width: 350,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (scheduledFor != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Text(
                    'Slot: ${formatDate(scheduledFor)} alle ${formatTime(scheduledFor)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              TextField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Nome cliente'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _serviceNameController,
                decoration: const InputDecoration(labelText: 'Servizio'),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  'Stato',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF556072),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AdminPopupSelector<String>(
                value: _status,
                items: _statusEntries
                    .map(
                      (entry) => AdminPopupSelectorItem<String>(
                        value: entry.value,
                        label: entry.label,
                        icon: entry.icon,
                        iconColor: entry.color,
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        Obx(
          () => FilledButton(
            onPressed: controller.isAppointmentBusy(appointmentId)
                ? null
                : () async {
                    final success = await controller.updateAppointment(
                      appointmentId: appointmentId,
                      customerName: _customerNameController.text,
                      serviceName: _serviceNameController.text,
                      notes: _notesController.text,
                      status: _status,
                    );

                    if (mounted && success) {
                      Navigator.of(context).pop();
                    }
                  },
            child: Text(
              controller.isAppointmentBusy(appointmentId)
                  ? 'Salvataggio...'
                  : 'Salva',
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

const _statusEntries = <_StatusConfig>[
  _StatusConfig(
    value: 'requested',
    label: 'Richiesto',
    icon: Icons.schedule_rounded,
    color: Color(0xFFA86B12),
  ),
  _StatusConfig(
    value: 'confirmed',
    label: 'Confermato',
    icon: Icons.verified_rounded,
    color: Color(0xFF2A7C4B),
  ),
  _StatusConfig(
    value: 'completed',
    label: 'Completato',
    icon: Icons.task_alt_rounded,
    color: AppTheme.accentBlueDark,
  ),
];
