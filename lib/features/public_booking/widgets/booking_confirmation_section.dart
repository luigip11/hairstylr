import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../core/models/booking_support.dart';
import '../controllers/public_booking_controller.dart';
import 'booking_choice_pill.dart';
import 'booking_section_shell.dart';
import 'booking_summary_row.dart';

final _bookingFieldBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(18),
  borderSide: const BorderSide(color: AppColors.borderBlue, width: 1.2),
);

class BookingConfirmationSection extends GetView<PublicBookingController> {
  const BookingConfirmationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BookingSectionShell(
      title: 'Conferma prenotazione',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            decoration: BoxDecoration(
              color: AppColors.softBlueTint,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderBlue),
            ),
            child: Column(
              children: [
                Obx(
                  () => BookingSummaryRow(
                    label: 'Giorno',
                    value: formatDate(controller.selectedDate.value),
                  ),
                ),
                Obx(
                  () => BookingSummaryRow(
                    label: 'Servizio',
                    value: controller.selectedServiceDisplayName,
                  ),
                ),
                Obx(
                  () => BookingSummaryRow(
                    label: 'Orario',
                    value: controller.selectedSlot.value == null
                        ? 'Seleziona un orario'
                        : formatTimeRange(
                            controller.selectedSlot.value!.start,
                            controller.selectedSlot.value!.end,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.nameController,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      labelText: 'Nome cliente',
                      suffixIcon: controller.customerName.value.isNotEmpty
                          ? IconButton(
                              tooltip: 'Cancella nome cliente',
                              onPressed: controller.clearCustomerName,
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.fieldSurface,
                      enabledBorder: _bookingFieldBorder,
                      focusedBorder: _bookingFieldBorder.copyWith(
                        borderSide: const BorderSide(
                          color: bookingAccentBlue,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: controller.updateCustomerName,
                  ),
                ),
                if (controller.hasCustomerDirectory) ...[
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const _CustomerLookupDialog(),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: bookingAccentBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Lista clienti'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller.notesController,
            minLines: 3,
            maxLines: 4,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              labelText: 'Note facoltative (colore, domicilio, richieste)',
              filled: true,
              fillColor: AppColors.fieldSurface,
              enabledBorder: _bookingFieldBorder,
              focusedBorder: _bookingFieldBorder.copyWith(
                borderSide: const BorderSide(
                  color: bookingAccentBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
          Obx(() {
            final message = controller.feedbackMessage.value;
            if (message == null || message.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                message,
                style: TextStyle(
                  color: message.startsWith('Richiesta')
                      ? AppTheme.accentBlueDark
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          Obx(
            () => FilledButton(
              onPressed: controller.canSubmit
                  ? controller.bookAppointment
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: bookingAccentBlue,
                disabledBackgroundColor: AppColors.disabledBlue,
                minimumSize: const Size.fromHeight(56),
              ),
              child: Text(
                controller.isSubmitting.value
                    ? 'Invio in corso...'
                    : 'Conferma appuntamento',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerLookupDialog extends GetView<PublicBookingController> {
  const _CustomerLookupDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 620),
        child: const _CustomerLookupContent(),
      ),
    );
  }
}

class _CustomerLookupContent extends StatefulWidget {
  const _CustomerLookupContent();

  @override
  State<_CustomerLookupContent> createState() => _CustomerLookupContentState();
}

class _CustomerLookupContentState extends State<_CustomerLookupContent> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';

  PublicBookingController get controller => Get.find<PublicBookingController>();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lista clienti',
                  style: TextStyle(
                    color: AppColors.bookingDeepBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              hintText: 'Cerca rapidamente',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: _bookingFieldBorder,
              focusedBorder: _bookingFieldBorder.copyWith(
                borderSide: const BorderSide(
                  color: bookingAccentBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Obx(() {
              final customers = _filteredCustomers(controller.customers);
              if (customers.isEmpty) {
                return const Center(child: Text('Nessun cliente trovato.'));
              }

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      ..._groupedCustomers(customers).entries.map(
                        (entry) => _CustomerLookupTable(
                          letter: entry.key,
                          customers: entry.value,
                          onSelect: _selectCustomer,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredCustomers(
    List<Map<String, dynamic>> customers,
  ) {
    final query = _query.trim().toLowerCase();
    final filtered = customers
        .where((customer) {
          if (query.isEmpty) {
            return true;
          }

          final firstName = ((customer['firstName'] as String?) ?? '')
              .toLowerCase();
          final lastName = ((customer['lastName'] as String?) ?? '')
              .toLowerCase();
          return firstName.contains(query) ||
              lastName.contains(query) ||
              '$firstName $lastName'.contains(query) ||
              '$lastName $firstName'.contains(query);
        })
        .toList(growable: false);

    return filtered..sort((left, right) {
      final lastNameCompare =
          (((left['lastName'] as String?) ?? '').toLowerCase()).compareTo(
            ((right['lastName'] as String?) ?? '').toLowerCase(),
          );
      if (lastNameCompare != 0) {
        return lastNameCompare;
      }

      return (((left['firstName'] as String?) ?? '').toLowerCase()).compareTo(
        ((right['firstName'] as String?) ?? '').toLowerCase(),
      );
    });
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

  void _selectCustomer(Map<String, dynamic> customer) {
    controller.selectCustomer(customer);
    Navigator.of(context).pop();
  }
}

class _CustomerLookupTable extends StatelessWidget {
  const _CustomerLookupTable({
    required this.letter,
    required this.customers,
    required this.onSelect,
  });

  final String letter;
  final List<Map<String, dynamic>> customers;
  final ValueChanged<Map<String, dynamic>> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              letter,
              style: const TextStyle(
                color: AppColors.bookingDeepBlue,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.borderBlueSoft),
                borderRadius: BorderRadius.circular(18),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                        'Seleziona cliente',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  rows: customers
                      .map(
                        (customer) => DataRow(
                          cells: [
                            DataCell(Text(_value(customer, 'firstName'))),
                            DataCell(Text(_value(customer, 'lastName'))),
                            DataCell(
                              Center(
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: IconButton.filled(
                                    onPressed: () => onSelect(customer),
                                    icon: const Icon(Icons.check_rounded),
                                    iconSize: 18,
                                  ),
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
        ],
      ),
    );
  }

  String _value(Map<String, dynamic> customer, String key) {
    final value = customer[key] as String?;
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value;
  }
}
