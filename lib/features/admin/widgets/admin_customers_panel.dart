import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../core/services/phone_launcher.dart';
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
        expandChild: true,
        child: customers.isEmpty && controller.customerSearchQuery.value.isEmpty
            ? _CustomersEmptyState(
                message: 'Non ci sono clienti censiti.',
                onAdd: () => _showCreateDialog(context),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compactAction = constraints.maxWidth < 520;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Obx(
                              () => SizedBox(
                                height: 48,
                                child: TextField(
                                  controller:
                                      controller.customerSearchController,
                                  onChanged: controller.updateCustomerSearch,
                                  onTapOutside: (_) => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                  decoration: _searchInputDecoration(
                                    hasText: controller
                                        .customerSearchQuery
                                        .value
                                        .isNotEmpty,
                                    onClear: controller.clearCustomerSearch,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          SizedBox(
                            width: compactAction ? 48 : null,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: () => _showCreateDialog(context),
                              icon: const Icon(Icons.add_rounded),
                              label: compactAction
                                  ? const SizedBox.shrink()
                                  : const Text('Aggiungi cliente'),
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: compactAction ? 0 : 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: customers.isEmpty
                        ? const _CustomersEmptyState(
                            message: 'Nessun cliente trovato.',
                          )
                        : _CustomerTablesList(
                            groupedCustomers: _groupedCustomers(customers),
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

class _CustomerTablesList extends StatefulWidget {
  const _CustomerTablesList({required this.groupedCustomers});

  final Map<String, List<Map<String, dynamic>>> groupedCustomers;

  @override
  State<_CustomerTablesList> createState() => _CustomerTablesListState();
}

class _CustomerTablesListState extends State<_CustomerTablesList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      radius: const Radius.circular(999),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            ...widget.groupedCustomers.entries.map(
              (entry) => _CustomerTableGroup(
                letter: entry.key,
                customers: entry.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomersEmptyState extends StatelessWidget {
  const _CustomersEmptyState({required this.message, this.onAdd});

  final String message;
  final VoidCallback? onAdd;

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
            Text(
              message,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textChartMuted,
              ),
            ),
            if (onAdd != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Aggiungi cliente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomerTableGroup extends StatelessWidget {
  const _CustomerTableGroup({required this.letter, required this.customers});

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
                child: constraints.maxWidth < 620
                    ? _CustomerCardsList(customers: customers)
                    : DecoratedBox(
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
                                DataColumn(
                                  label: Text(
                                    'Nome',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Cognome',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Numero di telefono',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Note',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Scheda cliente',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              rows: customers
                                  .map(
                                    (customer) => DataRow(
                                      cells: [
                                        DataCell(
                                          Text(_value(customer, 'firstName')),
                                        ),
                                        DataCell(
                                          Text(_value(customer, 'lastName')),
                                        ),
                                        DataCell(
                                          _PhoneAction(
                                            phoneNumber: _value(
                                              customer,
                                              'phoneNumber',
                                            ),
                                          ),
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
                                          FilledButton.icon(
                                            onPressed: () =>
                                                _showCustomerDetail(
                                                  context,
                                                  customer,
                                                ),
                                            icon: const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 18,
                                            ),
                                            label: const Text('Scheda'),
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.accentBlue,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              minimumSize: const Size(0, 38),
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

  static void _showCustomerDetail(
    BuildContext context,
    Map<String, dynamic> customer,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AdminCustomerDetailDialog(customer: customer),
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

class _CustomerCardsList extends StatelessWidget {
  const _CustomerCardsList({required this.customers});

  final List<Map<String, dynamic>> customers;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderBlueSoft),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var index = 0; index < customers.length; index++) ...[
            _CustomerCompactCard(customer: customers[index]),
            if (index != customers.length - 1)
              const Divider(height: 1, color: AppColors.borderBlueSoft),
          ],
        ],
      ),
    );
  }
}

class _CustomerCompactCard extends StatelessWidget {
  const _CustomerCompactCard({required this.customer});

  final Map<String, dynamic> customer;

  @override
  Widget build(BuildContext context) {
    final firstName = _value('firstName');
    final lastName = _value('lastName');

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$firstName $lastName',
                  style: const TextStyle(
                    color: AppColors.textSlate,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AdminCustomerDetailDialog(customer: customer),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Scheda'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 38),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasCallablePhoneNumber(_value('phoneNumber')))
            Align(
              alignment: Alignment.centerLeft,
              child: _PhoneAction(
                phoneNumber: _value('phoneNumber'),
                showHint: true,
              ),
            )
          else
            const Text(
              'Numero da inserire',
              style: TextStyle(
                color: AppColors.textGreyBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (_value('notes') != '-') ...[
            const SizedBox(height: 4),
            Text(
              _value('notes'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textChartMuted),
            ),
          ],
        ],
      ),
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
      title: Text(
        _isEditing ? 'Modifica cliente' : 'Aggiungi cliente',
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
              _EditableDetailCard(
                icon: Icons.person_rounded,
                label: 'Nome',
                child: TextField(
                  minLines: 1,
                  controller: _firstNameController,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  textCapitalization: TextCapitalization.words,
                  decoration: _dialogInputDecoration('Nome'),
                ),
              ),
              const SizedBox(height: 12),
              _EditableDetailCard(
                icon: Icons.badge_rounded,
                label: 'Cognome',
                child: TextField(
                  minLines: 1,
                  controller: _lastNameController,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  textCapitalization: TextCapitalization.words,
                  decoration: _dialogInputDecoration('Cognome'),
                ),
              ),
              const SizedBox(height: 12),
              _EditableDetailCard(
                icon: Icons.phone_rounded,
                label: 'Numero di telefono',
                child: TextField(
                  minLines: 1,
                  controller: _phoneController,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _dialogInputDecoration('Numero di telefono'),
                ),
              ),
              const SizedBox(height: 12),
              _EditableDetailCard(
                icon: Icons.notes_rounded,
                label: 'Note',
                child: TextField(
                  controller: _notesController,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  minLines: 3,
                  maxLines: 5,
                  decoration: _dialogInputDecoration('Note opzionali'),
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
            onPressed: !_canSave || controller.isCreatingCustomer.value
                ? null
                : () async {
                    final navigator = Navigator.of(context);
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
                      navigator.pop();
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
      title: const Text(
        'Scheda cliente',
        style: TextStyle(
          color: AppColors.bookingDeepBlue,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
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
              onTap: hasCallablePhoneNumber(_value('phoneNumber'))
                  ? () => launchPhoneCall(_value('phoneNumber'))
                  : null,
              helperText: hasCallablePhoneNumber(_value('phoneNumber'))
                  ? 'Tocca per chiamare'
                  : 'Numero da inserire',
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
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: () => _confirmDelete(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Elimina'),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final controller = Get.find<AdminAreaController>();
    final customerId = customer['id'] as String? ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminare cliente?'),
        content: const Text(
          'Questa azione rimuove il cliente dal database. Vuoi continuare?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final success = await controller.deleteCustomer(customerId);
    if (context.mounted && success) {
      Navigator.of(context).pop();
    }
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
    this.helperText,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? helperText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
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
                if (helperText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    helperText!,
                    style: const TextStyle(
                      color: AppColors.accentBlueDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: content,
    );
  }
}

class _PhoneAction extends StatelessWidget {
  const _PhoneAction({required this.phoneNumber, this.showHint = false});

  final String phoneNumber;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    if (!hasCallablePhoneNumber(phoneNumber)) {
      return const Text('-');
    }

    return TextButton.icon(
      onPressed: () => launchPhoneCall(phoneNumber),
      icon: const Icon(Icons.phone_rounded, size: 18),
      label: Text(showHint ? '$phoneNumber - chiama' : phoneNumber),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentBlueDark,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(0, 36),
      ),
    );
  }
}

class _EditableDetailCard extends StatelessWidget {
  const _EditableDetailCard({
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

InputDecoration _searchInputDecoration({
  required bool hasText,
  required VoidCallback onClear,
}) {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
    borderSide: BorderSide(color: AppColors.borderNeutral),
  );

  return InputDecoration(
    prefixIcon: const Icon(Icons.search_rounded),
    prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
    suffixIcon: hasText
        ? IconButton(
            tooltip: 'Cancella ricerca',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded),
          )
        : null,
    suffixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
    hintText: 'Cerca per nome o cognome o entrambi',
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    filled: true,
    fillColor: Colors.white,
    border: border,
    enabledBorder: border,
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      borderSide: BorderSide(color: AppColors.borderNeutral, width: 1.4),
    ),
  );
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
