import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final isSubmitting = false.obs;
  final feedbackMessage = RxnString();
  final customerName = ''.obs;
  final customServiceLabel = ''.obs;

  final services = <SalonService>[].obs;
  final availability = Rxn<AvailabilitySchedule>();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _servicesSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _availabilitySubscription;

  SalonService? get selectedService {
    if (services.isEmpty) {
      return null;
    }

    final activeId = selectedServiceId.value;
    for (final service in services) {
      if (service.id == activeId) {
        return service;
      }
    }

    return services.first;
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
    final firstDay = DateTime(visibleMonth.value.year, visibleMonth.value.month, 1);
    final daysInMonth =
        DateTime(visibleMonth.value.year, visibleMonth.value.month + 1, 0).day;
    final leading = firstDay.weekday - 1;
    final cells = <DateTime?>[];

    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }

    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(visibleMonth.value.year, visibleMonth.value.month, day));
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
    _servicesSubscription = FirebaseFirestore.instance
        .collection('services')
        .where('active', isEqualTo: true)
        .snapshots()
        .listen(_handleServices);
    _availabilitySubscription = FirebaseFirestore.instance
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

    if (selectedServiceId.value == null && services.isNotEmpty) {
      selectedServiceId.value = services.first.id;
    } else if (selectedService == null && services.isNotEmpty) {
      selectedServiceId.value = services.first.id;
    }

    _normalizeSelection();
  }

  void _normalizeSelection() {
    final availableSlots = slots;
    final currentSlot = selectedSlot.value;
    if (currentSlot == null) {
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
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    visibleMonth.value = DateTime(date.year, date.month);
    selectedSlot.value = null;
    feedbackMessage.value = null;
  }

  void selectService(String serviceId) {
    selectedServiceId.value = serviceId;
    selectedSlot.value = null;
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

  void updateCustomerName(String value) {
    customerName.value = value;
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
      await FirebaseFirestore.instance.collection('appointments').doc(docId).set(
        {
          'customerName': nameController.text.trim(),
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

      feedbackMessage.value =
          'Richiesta inviata per $selectedServiceDisplayName il ${formatDate(selectedDate.value)} alle ${formatTime(slot.start)}.';
      selectedSlot.value = null;
      nameController.clear();
      notesController.clear();
      customServiceController.clear();
      customServiceLabel.value = '';
      customerName.value = '';
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

  @override
  void onClose() {
    _servicesSubscription?.cancel();
    _availabilitySubscription?.cancel();
    nameController.dispose();
    notesController.dispose();
    customServiceController.dispose();
    super.onClose();
  }
}
