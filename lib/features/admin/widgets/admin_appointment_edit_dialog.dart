import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/booking_support.dart';
import '../controllers/admin_area_controller.dart';

class AdminAppointmentEditDialog extends StatefulWidget {
  const AdminAppointmentEditDialog({
    super.key,
    required this.data,
  });

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

  static const _statusOptions = <String>[
    'requested',
    'confirmed',
    'completed',
  ];

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
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (scheduledFor != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
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
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Stato'),
                items: _statusOptions
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(_labelForStatus(value)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _status = value;
                  });
                },
              ),
              const SizedBox(height: 12),
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

  String _labelForStatus(String value) => switch (value) {
    'requested' => 'Richiesto',
    'confirmed' => 'Confermato',
    'completed' => 'Completato',
    _ => value,
  };
}
