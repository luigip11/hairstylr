import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
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
      title: const Text(
        'Modifica appuntamento',
        style: TextStyle(
          color: AppColors.bookingDeepBlue,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: 390,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (scheduledFor != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppColors.textGreyBlue,
                      ),
                      children: [
                        const TextSpan(text: 'Slot: '),
                        TextSpan(
                          text:
                              '${formatDate(scheduledFor)} alle ${formatTime(scheduledFor)}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              _EditableAppointmentCard(
                icon: Icons.person_rounded,
                label: 'Nome cliente',
                child: TextField(
                  controller: _customerNameController,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  textCapitalization: TextCapitalization.words,
                  decoration: _dialogInputDecoration('Nome cliente'),
                ),
              ),
              const SizedBox(height: 12),
              _EditableAppointmentCard(
                icon: Icons.content_cut_rounded,
                label: 'Servizio',
                child: TextField(
                  controller: _serviceNameController,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _dialogInputDecoration('Servizio'),
                ),
              ),
              const SizedBox(height: 12),
              _EditableAppointmentCard(
                icon: Icons.task_alt_rounded,
                label: 'Stato',
                child: AdminPopupSelector<String>(
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
              ),
              const SizedBox(height: 12),
              _EditableAppointmentCard(
                icon: Icons.notes_rounded,
                label: 'Note',
                child: TextField(
                  controller: _notesController,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  minLines: 3,
                  maxLines: 5,
                  decoration: _dialogInputDecoration('Note'),
                ),
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
                    final navigator = Navigator.of(context);
                    final success = await controller.updateAppointment(
                      appointmentId: appointmentId,
                      customerName: _customerNameController.text,
                      serviceName: _serviceNameController.text,
                      notes: _notesController.text,
                      status: _status,
                    );

                    if (mounted && success) {
                      navigator.pop();
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

class _EditableAppointmentCard extends StatelessWidget {
  const _EditableAppointmentCard({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderBlueSoft),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.softBlueTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.bookingDeepBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGreyBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _dialogInputDecoration(String label) {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
    borderSide: BorderSide(color: AppColors.borderNeutral, width: 1.4),
  );

  return InputDecoration(
    hintText: label,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    filled: true,
    fillColor: Colors.white,
    border: border,
    enabledBorder: border,
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.bookingDeepBlue, width: 1.7),
    ),
  );
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
    color: AppColors.warningOrange,
  ),
  _StatusConfig(
    value: 'confirmed',
    label: 'Confermato',
    icon: Icons.verified_rounded,
    color: AppColors.successGreen,
  ),
  _StatusConfig(
    value: 'completed',
    label: 'Completato',
    icon: Icons.task_alt_rounded,
    color: AppTheme.accentBlueDark,
  ),
];
