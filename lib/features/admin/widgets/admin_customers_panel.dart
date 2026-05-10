import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_panel_shell.dart';

class AdminCustomersPanel extends GetView<AdminAreaController> {
  const AdminCustomersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final customers = controller.filteredCustomers;

      return AdminPanelShell(
        title: 'Clienti',
        subtitle: 'Rubrica clienti e info relative ad essi.',
        child: customers.isEmpty && controller.customerSearchQuery.value.isEmpty
            ? _CustomersEmptyState(onAdd: () => _showCreateDialog(context))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.customerSearchController,
                          onChanged: controller.updateCustomerSearch,
                          decoration: _searchInputDecoration(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      FilledButton.icon(
                        onPressed: () => _showCreateDialog(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Aggiungi cliente'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (customers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('Nessun cliente trovato.')),
                    )
                  else
                    ..._groupedCustomers(customers).entries.map(
                      (entry) => _CustomerTableGroup(
                        letter: entry.key,
                        customers: entry.value,
                      ),
                    ),
                ],
              ),
      );
    });
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const AdminCustomerCreateDialog(),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupedCustomers(
    List<Map<String, dynamic>> customers,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final customer in customers) {
      final lastName = ((customer['lastName'] as String?) ?? '').trim();
      final letter = lastName.isEmpty ? '#' : lastName[0].toUpperCase();
      grouped.putIfAbsent(letter, () => <Map<String, dynamic>>[]).add(customer);
    }
    return grouped;
  }
}

class _CustomersEmptyState extends StatelessWidget {
  const _CustomersEmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 46,
              color: AppColors.textChartMuted,
            ),
            const SizedBox(height: 14),
            const Text(
              'Non ci sono clienti censiti.',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textChartMuted,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Aggiungi cliente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerTableGroup extends StatelessWidget {
  const _CustomerTableGroup({
    required this.letter,
    required this.customers,
  });

  final String letter;
  final List<Map<String, dynamic>> customers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              letter,
              style: const TextStyle(
                color: AppColors.bookingDeepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.borderBlueSoft),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.softBlueTint,
                        ),
                        columns: const [
                          DataColumn(label: Text('Nome')),
                          DataColumn(label: Text('Cognome')),
                          DataColumn(label: Text('Numero di telefono')),
                          DataColumn(label: Text('Note')),
                          DataColumn(label: Text('Scheda cliente')),
                        ],
                        rows: customers
                            .map(
                              (customer) => DataRow(
                                cells: [
                                  DataCell(Text(_value(customer, 'firstName'))),
                                  DataCell(Text(_value(customer, 'lastName'))),
                                  DataCell(
                                    Text(_value(customer, 'phoneNumber')),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 260,
                                      child: Text(
                                        _value(customer, 'notes'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      tooltip: 'Apri scheda cliente',
                                      onPressed: () => showDialog<void>(
                                        context: context,
                                        builder: (_) =>
                                            AdminCustomerDetailDialog(
                                              customer: customer,
                                            ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_forward_rounded,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _value(Map<String, dynamic> data, String key) {
    final value = data[key] as String?;
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value;
  }
}

class AdminCustomerCreateDialog extends StatefulWidget {
  const AdminCustomerCreateDialog({super.key, this.customer});

  final Map<String, dynamic>? customer;

  @override
  State<AdminCustomerCreateDialog> createState() =>
      _AdminCustomerCreateDialogState();
}

class _AdminCustomerCreateDialogState extends State<AdminCustomerCreateDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

  AdminAreaController get controller => Get.find<AdminAreaController>();

  bool get _isEditing => widget.customer != null;

  bool get _canSave =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: _value('firstName'))
      ..addListener(_refresh);
    _lastNameController = TextEditingController(text: _value('lastName'))
      ..addListener(_refresh);
    _phoneController = TextEditingController(text: _value('phoneNumber'))
      ..addListener(_refresh);
    _notesController = TextEditingController(text: _value('notes'));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      title: Text(_isEditing ? 'Modifica cliente' : 'Aggiungi cliente'),
      content: SizedBox(
        width: 350,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                decoration: _dialogInputDecoration('Nome'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                decoration: _dialogInputDecoration('Cognome'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _dialogInputDecoration('Numero di telefono'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: _dialogInputDecoration('Note opzionali'),
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
            onPressed: !_canSave || controller.isCreatingCustomer.value
                ? null
                : () async {
                    final success = _isEditing
                        ? await controller.updateCustomer(
                            customerId: widget.customer?['id'] as String? ?? '',
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            phoneNumber: _phoneController.text,
                            notes: _notesController.text,
                          )
                        : await controller.createCustomer(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            phoneNumber: _phoneController.text,
                            notes: _notesController.text,
                          );
                    if (mounted && success) {
                      Navigator.of(context).pop();
                    }
                  },
            child: Text(
              controller.isCreatingCustomer.value ? 'Salvataggio...' : 'Salva',
            ),
          ),
        ),
      ],
    );
  }

  String _value(String key) {
    return (widget.customer?[key] as String?) ?? '';
  }

  void _refresh() {
    setState(() {});
  }
}

class AdminCustomerDetailDialog extends StatelessWidget {
  const AdminCustomerDetailDialog({super.key, required this.customer});

  final Map<String, dynamic> customer;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      title: const Text('Scheda cliente'),
      content: SizedBox(
        width: 390,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailCard(
              icon: Icons.person_rounded,
              label: 'Nome',
              value: _value('firstName'),
            ),
            _DetailCard(
              icon: Icons.badge_rounded,
              label: 'Cognome',
              value: _value('lastName'),
            ),
            _DetailCard(
              icon: Icons.phone_rounded,
              label: 'Numero di telefono',
              value: _value('phoneNumber'),
            ),
            _DetailCard(
              icon: Icons.notes_rounded,
              label: 'Note',
              value: _value('notes'),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Get.dialog<void>(AdminCustomerCreateDialog(customer: customer));
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Modifica'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      ],
    );
  }

  String _value(String key) {
    final value = customer[key] as String?;
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value;
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textSlate,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _searchInputDecoration() {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
    borderSide: BorderSide(color: AppColors.borderNeutral),
  );

  return const InputDecoration(
    prefixIcon: Icon(Icons.search_rounded),
    hintText: 'cerca per nome o cognome o entrambi',
    filled: true,
    fillColor: Colors.white,
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      borderSide: BorderSide(color: AppColors.borderNeutral, width: 1.4),
    ),
  );
}

InputDecoration _dialogInputDecoration(String label) {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    borderSide: BorderSide(color: AppColors.borderNeutral),
  );

  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: border,
    enabledBorder: border,
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: AppColors.bookingDeepBlue, width: 1.4),
    ),
  );
}
