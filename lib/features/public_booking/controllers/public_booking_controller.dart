import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/booking_support.dart';

class PublicBookingController extends GetxController {
  final nameController = TextEditingController();
  final notesController = TextEditingController();
  final customServiceController = TextEditingController();

  final selectedDate = dateOnly(DateTime.now()).obs;
  final visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;
  final selectedServiceId = RxnString();
  final selectedSlot = Rxn<TimeSlot>();
  final customSlots = <TimeSlot>[].obs;
  final isEditingCustomSlots = false.obs;
  final isSubmitting = false.obs;
  final feedbackMessage = RxnString();
  final customerName = ''.obs;
  final customServiceLabel = ''.obs;
  final selectedCustomerId = RxnString();

  final services = <SalonService>[].obs;
  final customers = <Map<String, dynamic>>[].obs;
  final availability = Rxn<AvailabilitySchedule>();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _servicesSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _customersSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _availabilitySubscription;
  WorkspaceConfig? _workspace;

  SalonService? get selectedService {
    if (services.isEmpty) {
      return null;
    }

    final activeId = selectedServiceId.value;
    if (activeId == null) {
      return null;
    }

    for (final service in services) {
      if (service.id == activeId) {
        return service;
      }
    }

    return null;
  }

  List<TimeSlot> get slots {
    final currentAvailability = availability.value;
    if (currentAvailability == null) {
      return const <TimeSlot>[];
    }

    return buildSlotsForDate(
      selectedDate.value,
      currentAvailability.windowsForDate(selectedDate.value),
    );
  }

  List<DateTime?> get calendarCells {
    final firstDay = DateTime(
      visibleMonth.value.year,
      visibleMonth.value.month,
      1,
    );
    final daysInMonth =
        DateTime(visibleMonth.value.year, visibleMonth.value.month + 1, 0).day;
    final leading = firstDay.weekday - 1;
    final cells = <DateTime?>[];

    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }

    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(
        DateTime(visibleMonth.value.year, visibleMonth.value.month, day),
      );
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  bool get canSubmit =>
      !isSubmitting.value &&
      selectedService != null &&
      selectedSlot.value != null &&
      customerName.value.trim().isNotEmpty &&
      (!isOtherServiceSelected || customServiceLabel.value.trim().isNotEmpty);

  bool get isOtherServiceSelected => selectedServiceId.value == 'altro';

  bool get hasSelectedService => selectedService != null;

  bool get hasCustomSlots => customSlots.isNotEmpty;

  bool get canCreateCustomSlot => customSlots.length < 10;

  bool get hasCustomerDirectory =>
      FirebaseAuth.instance.currentUser != null && customers.isNotEmpty;

  String get selectedServiceDisplayName {
    final service = selectedService;
    if (service == null) {
      return 'Seleziona un servizio';
    }

    final detail = customServiceLabel.value.trim();
    if (service.id == 'altro' && detail.isNotEmpty) {
      return '${service.name} - $detail';
    }

    return service.name;
  }

  @override
  void onInit() {
    super.onInit();
    _workspace = AppConfig.workspaceForEmail(
      FirebaseAuth.instance.currentUser?.email,
    );
    final workspaceId = _workspace?.id;
    if (workspaceId == null) {
      return;
    }

    final workspaceRef = FirebaseFirestore.instance
        .collection('workspaces')
        .doc(workspaceId);
    _servicesSubscription = workspaceRef
        .collection('services')
        .where('active', isEqualTo: true)
        .snapshots()
        .listen(_handleServices);
    _customersSubscription = workspaceRef
        .collection('customers')
        .orderBy('lastName')
        .snapshots()
        .listen((snapshot) {
          final docs = snapshot.docs
              .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
              .toList(growable: false);
          customers.assignAll(docs);
        });
    _availabilitySubscription = workspaceRef
        .collection('availability')
        .doc('default_week')
        .snapshots()
        .listen((snapshot) {
          availability.value = snapshot.exists
              ? AvailabilitySchedule.fromDocument(snapshot)
              : null;
          _normalizeSelection();
        });
  }

  void _handleServices(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final incoming = snapshot.docs
        .map(SalonService.fromDocument)
        .toList(growable: false)
      ..sort((left, right) {
        const order = {
          'piega': 0,
          'taglio': 1,
          'colore': 2,
          'altro': 3,
        };
        return (order[left.id] ?? 999).compareTo(order[right.id] ?? 999);
      });

    services.assignAll(incoming);

    if (selectedServiceId.value != null && selectedService == null) {
      selectedServiceId.value = null;
    }

    _normalizeSelection();
  }

  void _normalizeSelection() {
    final availableSlots = slots;
    final currentSlot = selectedSlot.value;
    if (currentSlot == null) {
      return;
    }

    final isCustomSlot = customSlots.any(
      (slot) => slot.start == currentSlot.start && slot.end == currentSlot.end,
    );
    if (isCustomSlot) {
      return;
    }

    final stillExists = availableSlots.any(
      (slot) => slot.start == currentSlot.start && slot.end == currentSlot.end,
    );
    if (!stillExists) {
      selectedSlot.value = null;
    }
  }

  void changeMonth(int delta) {
    visibleMonth.value = DateTime(
      visibleMonth.value.year,
      visibleMonth.value.month + delta,
    );

    if (selectedDate.value.year != visibleMonth.value.year ||
        selectedDate.value.month != visibleMonth.value.month) {
      selectedDate.value = DateTime(
        visibleMonth.value.year,
        visibleMonth.value.month,
        1,
      );
      selectedSlot.value = null;
      _clearCustomSlots();
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    visibleMonth.value = DateTime(date.year, date.month);
    selectedSlot.value = null;
    _clearCustomSlots();
    feedbackMessage.value = null;
  }

  void selectService(String serviceId) {
    selectedServiceId.value = serviceId;
    selectedSlot.value = null;
    _clearCustomSlots();
    feedbackMessage.value = null;
    if (serviceId != 'altro') {
      customServiceController.clear();
      customServiceLabel.value = '';
    }
  }

  void selectSlot(TimeSlot slot) {
    selectedSlot.value = slot;
    feedbackMessage.value = null;
  }

  void selectCustomTimeRange({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    int? index,
  }) {
    final start = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      startTime.hour,
      startTime.minute,
    );
    final end = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      endTime.hour,
      endTime.minute,
    );

    if (!end.isAfter(start)) {
      return;
    }

    final slot = TimeSlot(
      start: start,
      end: end,
    );

    if (index != null && index >= 0 && index < customSlots.length) {
      customSlots[index] = slot;
    } else if (canCreateCustomSlot) {
      customSlots.add(slot);
    } else {
      return;
    }

    selectedSlot.value = slot;
    isEditingCustomSlots.value = false;
    feedbackMessage.value = null;
  }

  void toggleCustomSlotsEditing() {
    if (customSlots.isEmpty) {
      isEditingCustomSlots.value = false;
      return;
    }

    isEditingCustomSlots.value = !isEditingCustomSlots.value;
  }

  void deleteCustomSlotAt(int index) {
    if (index < 0 || index >= customSlots.length) {
      return;
    }

    final removedSlot = customSlots[index];
    customSlots.removeAt(index);
    final selected = selectedSlot.value;
    if (selected?.start == removedSlot.start &&
        selected?.end == removedSlot.end) {
      selectedSlot.value = null;
    }

    if (customSlots.isEmpty) {
      isEditingCustomSlots.value = false;
    }
    feedbackMessage.value = null;
  }

  void resetConfirmationSection() {
    selectedSlot.value = null;
    _clearCustomSlots();
    feedbackMessage.value = null;
    notesController.clear();
  }

  void _clearCustomSlots() {
    customSlots.clear();
    isEditingCustomSlots.value = false;
  }

  void updateCustomerName(String value) {
    customerName.value = value;
    selectedCustomerId.value = null;
    feedbackMessage.value = null;
  }

  void clearCustomerName() {
    nameController.clear();
    customerName.value = '';
    selectedCustomerId.value = null;
    feedbackMessage.value = null;
  }

  void selectCustomer(Map<String, dynamic> customer) {
    final firstName = ((customer['firstName'] as String?) ?? '').trim();
    final lastName = ((customer['lastName'] as String?) ?? '').trim();
    final fullName = [firstName, lastName]
        .where((part) => part.isNotEmpty)
        .join(' ')
        .trim();
    nameController.text = fullName;
    customerName.value = fullName;
    selectedCustomerId.value = customer['id'] as String?;
    feedbackMessage.value = null;
  }

  void updateCustomServiceLabel(String value) {
    customServiceLabel.value = value;
    feedbackMessage.value = null;
  }

  Future<void> bookAppointment() async {
    final service = selectedService;
    final slot = selectedSlot.value;
    if (service == null || slot == null) {
      return;
    }

    isSubmitting.value = true;
    feedbackMessage.value = null;

    final docId =
        '${dateKey(slot.start)}_${twoDigits(slot.start.hour)}${twoDigits(slot.start.minute)}';

    try {
      final workspaceId = _workspace?.id;
      if (workspaceId == null) {
        feedbackMessage.value = 'Workspace non configurato per questo account.';
        return;
      }

      await FirebaseFirestore.instance
          .collection('workspaces')
          .doc(workspaceId)
          .collection('appointments')
          .doc(docId)
          .set(
        {
          'customerName': nameController.text.trim(),
          'customerId': selectedCustomerId.value,
          'serviceId': service.id,
          'serviceName': service.name,
          'serviceDisplayName': selectedServiceDisplayName,
          'serviceCustomLabel': customServiceLabel.value.trim(),
          'serviceDurationMinutes': service.durationMinutes ?? 0,
          'notes': notesController.text.trim(),
          'status': 'requested',
          'scheduledFor': slot.start,
          'scheduledDateKey': dateKey(slot.start),
          'slotLabel': formatTimeRange(slot.start, slot.end),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      if (selectedCustomerId.value == null) {
        await _createCustomerFromBooking(workspaceId);
      }

      feedbackMessage.value =
          'Richiesta inviata per $selectedServiceDisplayName il ${formatDate(selectedDate.value)} alle ${formatTime(slot.start)}.';
      selectedSlot.value = null;
      _clearCustomSlots();
      nameController.clear();
      notesController.clear();
      customServiceController.clear();
      customServiceLabel.value = '';
      customerName.value = '';
      selectedCustomerId.value = null;
    } on FirebaseException catch (error) {
      feedbackMessage.value = switch (error.code) {
        'permission-denied' =>
          'Prenotazione non consentita. Pubblica prima le regole Firestore aggiornate.',
        _ => 'Prenotazione non riuscita: ${error.message ?? error.code}',
      };
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _createCustomerFromBooking(String workspaceId) async {
    final fullName = nameController.text.trim();
    if (fullName.isEmpty) {
      return;
    }

    final normalizedFullName = fullName.toLowerCase();
    final alreadyExists = customers.any((customer) {
      final firstName = ((customer['firstName'] as String?) ?? '').trim();
      final lastName = ((customer['lastName'] as String?) ?? '').trim();
      return '$firstName $lastName'.trim().toLowerCase() == normalizedFullName;
    });

    if (alreadyExists) {
      return;
    }

    final parts = fullName.split(RegExp(r'\s+'));
    final firstName = parts.isEmpty ? fullName : parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    await FirebaseFirestore.instance
        .collection('workspaces')
        .doc(workspaceId)
        .collection('customers')
        .add({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': '',
          'notes': notesController.text.trim(),
          'createdFromAppointment': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  void onClose() {
    _servicesSubscription?.cancel();
    _customersSubscription?.cancel();
    _availabilitySubscription?.cancel();
    nameController.dispose();
    notesController.dispose();
    customServiceController.dispose();
    super.onClose();
  }
}
