import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../core/models/booking_support.dart';
import '../../../core/services/phone_launcher.dart';
import '../../../core/widgets/custom_empty_state.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_panel_shell.dart';
import 'admin_popup_selector.dart';

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
            ? CustomEmptyState(
                message: 'Non ci sono clienti censiti.',
                actionLabel: 'Aggiungi cliente',
                onAction: () => _showCreateDialog(context),
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
                              icon: compactAction
                                  ? null
                                  : const Icon(Icons.add_rounded),
                              label: compactAction
                                  ? Text('+', style: TextStyle(fontSize: 20))
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
                        ? const CustomEmptyState(
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
                    : _CustomerDesktopTable(
                        customers: customers,
                        minWidth: constraints.maxWidth,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CustomerDesktopTable extends StatefulWidget {
  const _CustomerDesktopTable({
    required this.customers,
    required this.minWidth,
  });

  final List<Map<String, dynamic>> customers;
  final double minWidth;

  @override
  State<_CustomerDesktopTable> createState() => _CustomerDesktopTableState();
}

class _CustomerDesktopTableState extends State<_CustomerDesktopTable> {
  late final ScrollController _scrollController;
  bool _showRightShadow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_syncShadow);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncShadow());
  }

  @override
  void didUpdateWidget(covariant _CustomerDesktopTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncShadow());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncShadow)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderBlueSoft),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: widget.minWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppColors.softBlueTint,
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Nome',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Cognome',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Cellulare',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Scheda cliente',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Storico cliente',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Note',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                rows: widget.customers
                    .map(
                      (customer) => DataRow(
                        cells: [
                          DataCell(Text(_value(customer, 'firstName'))),
                          DataCell(Text(_value(customer, 'lastName'))),
                          DataCell(
                            _PhoneAction(
                              phoneNumber: _value(customer, 'phoneNumber'),
                            ),
                          ),
                          DataCell(
                            FilledButton.icon(
                              onPressed: () =>
                                  _showCustomerDetail(context, customer),
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: const Text('Scheda'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accentBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                minimumSize: const Size(0, 38),
                              ),
                            ),
                          ),
                          DataCell(
                            FilledButton.icon(
                              onPressed: () =>
                                  _showCustomerHistory(context, customer),
                              icon: const Icon(Icons.history_rounded, size: 18),
                              label: const Text('Storico'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.bookingDeepBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                minimumSize: const Size(0, 38),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 180,
                              child: Text(
                                _value(customer, 'notes'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
          if (_showRightShadow)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _syncShadow() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    final nextValue =
        _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels >
        1;
    if (nextValue != _showRightShadow) {
      setState(() {
        _showRightShadow = nextValue;
      });
    }
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

  static void _showCustomerHistory(
    BuildContext context,
    Map<String, dynamic> customer,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AdminCustomerHistoryDialog(customer: customer),
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
          Text(
            '$firstName $lastName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSlate,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AdminCustomerDetailDialog(customer: customer),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Scheda'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      AdminCustomerHistoryDialog(customer: customer),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bookingDeepBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Storico'),
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
        child: SingleChildScrollView(
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
      ),
      actions: [
        _CustomerDetailActions(
          customer: customer,
          onDelete: () => _confirmDelete(context),
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

class AdminCustomerHistoryDialog extends StatefulWidget {
  const AdminCustomerHistoryDialog({super.key, required this.customer});

  final Map<String, dynamic> customer;

  @override
  State<AdminCustomerHistoryDialog> createState() =>
      _AdminCustomerHistoryDialogState();
}

class _AdminCustomerHistoryDialogState
    extends State<AdminCustomerHistoryDialog> {
  late final TextEditingController _priceController;
  late final TextEditingController _colorCodeController;
  late final TextEditingController _companyController;
  late final TextEditingController _volumesController;
  late final TextEditingController _historyNotesController;
  late String _serviceId;
  late String _serviceName;

  AdminAreaController get controller => Get.find<AdminAreaController>();

  Map<String, dynamic>? get _lastAppointment {
    return controller.latestCompletedCustomerAppointmentForCustomer(
      widget.customer,
    );
  }

  Map<String, dynamic> get _history {
    final raw = widget.customer['history'];
    return raw is Map<String, dynamic> ? raw : <String, dynamic>{};
  }

  bool get _requiresColor => _serviceId == 'colore' || _serviceId == 'altro';

  @override
  void initState() {
    super.initState();
    final lastAppointment = _lastAppointment;
    final history = _history;
    _serviceId =
        (history['serviceId'] as String?) ??
        (lastAppointment?['serviceId'] as String?) ??
        _firstServiceId();
    _serviceName =
        (history['serviceName'] as String?) ??
        (lastAppointment?['serviceName'] as String?) ??
        _serviceLabel(_serviceId);
    _priceController = TextEditingController(
      text:
          (history['price'] as String?) ??
          _formattedPrice(controller.servicePriceFor(_serviceId)),
    );
    _colorCodeController = TextEditingController(
      text: (history['colorCode'] as String?) ?? '',
    );
    _companyController = TextEditingController(
      text: (history['company'] as String?) ?? '',
    );
    _volumesController = TextEditingController(
      text: (history['volumes'] as String?) ?? '',
    );
    _historyNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _colorCodeController.dispose();
    _companyController.dispose();
    _volumesController.dispose();
    _historyNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastAppointment = _lastAppointment;
    final lastWorkDate = lastAppointment == null
        ? null
        : controller.appointmentDate(lastAppointment);

    return AlertDialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      title: const Text(
        'Storico cliente',
        style: TextStyle(
          color: AppColors.bookingDeepBlue,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: 430,
        child: lastAppointment == null || lastWorkDate == null
            ? const CustomEmptyState(
                message: 'Nessun lavoro effettuato per questo cliente.',
                height: 260,
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DetailCard(
                      icon: Icons.event_available_rounded,
                      label: 'Data ultimo lavoro fatto',
                      value: formatDate(lastWorkDate),
                    ),
                    _EditableDetailCard(
                      icon: Icons.content_cut_rounded,
                      label: 'Tipo lavoro',
                      child: AdminPopupSelector<String>(
                        value: _serviceId,
                        items: _serviceOptions(lastAppointment)
                            .map(
                              (service) => AdminPopupSelectorItem<String>(
                                value: service.id,
                                label: service.name,
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _selectService,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EditableDetailCard(
                      icon: Icons.euro_rounded,
                      label: 'Prezzo',
                      child: TextField(
                        controller: _priceController,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _dialogInputDecoration('Prezzo'),
                      ),
                    ),
                    if (_requiresColor) ...[
                      const SizedBox(height: 12),
                      _EditableDetailCard(
                        icon: Icons.palette_rounded,
                        label: 'Colore utilizzato',
                        child: TextField(
                          controller: _colorCodeController,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          textCapitalization: TextCapitalization.characters,
                          decoration: _dialogInputDecoration('Codice colore'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _EditableDetailCard(
                        icon: Icons.business_rounded,
                        label: 'Azienda',
                        child: TextField(
                          controller: _companyController,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          textCapitalization: TextCapitalization.words,
                          decoration: _dialogInputDecoration('Azienda'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _EditableDetailCard(
                        icon: Icons.tune_rounded,
                        label: 'Volumi',
                        child: TextField(
                          controller: _volumesController,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: _dialogInputDecoration('Volumi'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _EditableDetailCard(
                      icon: Icons.notes_rounded,
                      label: 'Note',
                      child: TextField(
                        controller: _historyNotesController,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        minLines: 3,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
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
          child: const Text('Chiudi'),
        ),
        if (lastAppointment != null && lastWorkDate != null)
          Obx(
            () => FilledButton(
              onPressed: controller.isCreatingCustomer.value
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      final success = await controller.updateCustomerHistory(
                        customerId: widget.customer['id'] as String? ?? '',
                        serviceId: _serviceId,
                        serviceName: _serviceName,
                        price: _priceController.text,
                        colorCode: _colorCodeController.text,
                        company: _companyController.text,
                        volumes: _volumesController.text,
                        lastWorkDate: lastWorkDate,
                        appointmentId: lastAppointment['id'] as String?,
                        notes: _historyNotesController.text,
                      );
                      if (mounted && success) {
                        navigator.pop();
                      }
                    },
              child: Text(
                controller.isCreatingCustomer.value
                    ? 'Salvataggio...'
                    : 'Salva',
              ),
            ),
          ),
      ],
    );
  }

  void _selectService(String serviceId) {
    setState(() {
      _serviceId = serviceId;
      _serviceName = _serviceLabel(serviceId);
      final price = controller.servicePriceFor(serviceId);
      if (price != null) {
        _priceController.text = _formattedPrice(price);
      }
    });
  }

  List<_HistoryServiceOption> _serviceOptions(
    Map<String, dynamic> lastAppointment,
  ) {
    final entries = <String, _HistoryServiceOption>{};
    for (final service in controller.services) {
      entries[service.id] = _HistoryServiceOption(
        id: service.id,
        name: service.name,
      );
    }

    final appointmentServiceId = lastAppointment['serviceId'] as String?;
    final appointmentServiceName = lastAppointment['serviceName'] as String?;
    if (appointmentServiceId != null && appointmentServiceId.isNotEmpty) {
      entries.putIfAbsent(
        appointmentServiceId,
        () => _HistoryServiceOption(
          id: appointmentServiceId,
          name: appointmentServiceName?.isNotEmpty == true
              ? appointmentServiceName!
              : appointmentServiceId,
        ),
      );
    }

    entries.putIfAbsent(
      'altro',
      () => const _HistoryServiceOption(id: 'altro', name: 'Altro'),
    );

    return entries.values.toList(growable: false);
  }

  String _firstServiceId() {
    return controller.services.isEmpty ? 'altro' : controller.services.first.id;
  }

  String _serviceLabel(String serviceId) {
    for (final service in controller.services) {
      if (service.id == serviceId) {
        return service.name;
      }
    }
    if (serviceId == 'altro') {
      return 'Altro';
    }
    return serviceId;
  }

  String _formattedPrice(num? price) {
    if (price == null) {
      return '';
    }
    if (price % 1 == 0) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }
}

class _HistoryServiceOption {
  const _HistoryServiceOption({required this.id, required this.name});

  final String id;
  final String name;
}

class _CustomerDetailActions extends StatelessWidget {
  const _CustomerDetailActions({
    required this.customer,
    required this.onDelete,
  });

  final Map<String, dynamic> customer;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            Get.dialog<void>(AdminCustomerCreateDialog(customer: customer));
          },
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Modifica'),
        ),
        FilledButton.icon(
          onPressed: onDelete,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.dangerRed,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Elimina'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Chiudi'),
        ),
      ],
    );
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
