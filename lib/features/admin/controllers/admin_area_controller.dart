import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/booking_support.dart';
import '../../../core/services/bootstrap_service.dart';

enum AdminUtilizationRange { daily, weekly, monthly }

enum AdminDashboardSection { dashboard, user, appointments, customers }

extension AdminUtilizationRangeX on AdminUtilizationRange {
  String get label => switch (this) {
    AdminUtilizationRange.daily => 'Giornaliero',
    AdminUtilizationRange.weekly => 'Settimanale',
    AdminUtilizationRange.monthly => 'Mensile',
  };

  String get title => switch (this) {
    AdminUtilizationRange.daily => 'Occupazione giornaliera',
    AdminUtilizationRange.weekly => 'Occupazione settimanale',
    AdminUtilizationRange.monthly => 'Occupazione mensile',
  };

  String get subtitle => switch (this) {
    AdminUtilizationRange.daily =>
      'Appuntamenti presi rispetto agli slot disponibili per oggi.',
    AdminUtilizationRange.weekly =>
      'Appuntamenti presi rispetto agli slot disponibili nella settimana corrente.',
    AdminUtilizationRange.monthly =>
      'Appuntamenti presi rispetto agli slot disponibili nel mese corrente.',
  };

  String get totalLabel => switch (this) {
    AdminUtilizationRange.daily => 'Totale slot giornalieri',
    AdminUtilizationRange.weekly => 'Totale slot settimanali',
    AdminUtilizationRange.monthly => 'Totale slot mensili',
  };
}

class AdminAreaController extends GetxController {
  AdminAreaController()
    : _bootstrapService = BootstrapService(FirebaseFirestore.instance);

  final BootstrapService _bootstrapService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final customerSearchController = TextEditingController();

  final currentUser = Rxn<User>();
  final isSubmitting = false.obs;
  final isSeeding = false.obs;
  final errorMessage = RxnString();
  final infoMessage = RxnString();
  final appointments = <Map<String, dynamic>>[].obs;
  final customers = <Map<String, dynamic>>[].obs;
  final busyAppointmentIds = <String>{}.obs;
  final isCreatingCustomer = false.obs;
  final customerSearchQuery = ''.obs;
  final availability = Rxn<AvailabilitySchedule>();
  final selectedSection = AdminDashboardSection.dashboard.obs;
  final isSidebarCollapsed = false.obs;
  final selectedUtilizationRange = AdminUtilizationRange.weekly.obs;
  final selectedAppointmentDate = dateOnly(DateTime.now()).obs;
  final visibleAppointmentsMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;
  final currentWorkspace = Rxn<WorkspaceConfig>();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _appointmentsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _customersSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _availabilitySubscription;

  bool get isAuthorizedAdmin {
    return currentWorkspace.value != null;
  }

  String? get currentWorkspaceId => currentWorkspace.value?.id;

  String get currentWorkspaceName =>
      currentWorkspace.value?.name ?? 'Workspace';

  List<AdminUtilizationRange> get utilizationRanges =>
      AdminUtilizationRange.values;

  int get activeSlotCapacity => slotCapacityFor(selectedUtilizationRange.value);

  int get activeBookedAppointments =>
      bookedAppointmentsFor(selectedUtilizationRange.value);

  int get activeRemainingSlots =>
      remainingSlotsFor(selectedUtilizationRange.value);

  double get activeBookedRatio =>
      bookedRatioFor(selectedUtilizationRange.value);

  List<Map<String, dynamic>> get selectedDateAppointments =>
      appointmentsForDate(selectedAppointmentDate.value);

  List<Map<String, dynamic>> get filteredCustomers {
    final query = customerSearchQuery.value.trim().toLowerCase();
    final filtered = customers.where((customer) {
      if (query.isEmpty) {
        return true;
      }

      final firstName = ((customer['firstName'] as String?) ?? '').toLowerCase();
      final lastName = ((customer['lastName'] as String?) ?? '').toLowerCase();
      final fullName = '$firstName $lastName';
      final reverseFullName = '$lastName $firstName';
      return firstName.contains(query) ||
          lastName.contains(query) ||
          fullName.contains(query) ||
          reverseFullName.contains(query);
    }).toList(growable: false);

    return filtered
      ..sort((left, right) {
        final leftLastName = (left['lastName'] as String?) ?? '';
        final rightLastName = (right['lastName'] as String?) ?? '';
        final lastNameCompare = leftLastName.toLowerCase().compareTo(
          rightLastName.toLowerCase(),
        );
        if (lastNameCompare != 0) {
          return lastNameCompare;
        }

        final leftFirstName = (left['firstName'] as String?) ?? '';
        final rightFirstName = (right['firstName'] as String?) ?? '';
        return leftFirstName.toLowerCase().compareTo(
          rightFirstName.toLowerCase(),
        );
      });
  }

  List<DateTime?> get appointmentCalendarCells {
    final firstDay = DateTime(
      visibleAppointmentsMonth.value.year,
      visibleAppointmentsMonth.value.month,
      1,
    );
    final daysInMonth =
        DateTime(
          visibleAppointmentsMonth.value.year,
          visibleAppointmentsMonth.value.month + 1,
          0,
        ).day;
    final leading = firstDay.weekday - 1;
    final cells = <DateTime?>[];

    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }

    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(
        DateTime(
          visibleAppointmentsMonth.value.year,
          visibleAppointmentsMonth.value.month,
          day,
        ),
      );
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  int slotCapacityFor(AdminUtilizationRange range) {
    final schedule = availability.value;
    if (schedule == null) {
      return 0;
    }

    return switch (range) {
      AdminUtilizationRange.daily =>
        schedule.windowsForDate(DateTime.now()).length,
      AdminUtilizationRange.weekly => schedule.weeklySchedule.values.fold<int>(
        0,
        (total, slots) => total + slots.length,
      ),
      AdminUtilizationRange.monthly => _countSlotsInRange(
        schedule,
        _rangeStart(range),
        _rangeEnd(range),
      ),
    };
  }

  int bookedAppointmentsFor(AdminUtilizationRange range) {
    final rangeStart = _rangeStart(range);
    final rangeEnd = _rangeEnd(range);

    return appointments.where((appointment) {
      final scheduledFor = _appointmentDate(appointment);

      return scheduledFor != null &&
          !scheduledFor.isBefore(rangeStart) &&
          scheduledFor.isBefore(rangeEnd);
    }).length;
  }

  int remainingSlotsFor(AdminUtilizationRange range) {
    final remaining = slotCapacityFor(range) - bookedAppointmentsFor(range);
    return remaining < 0 ? 0 : remaining;
  }

  double bookedRatioFor(AdminUtilizationRange range) {
    final totalSlots = slotCapacityFor(range);
    if (totalSlots == 0) {
      return 0;
    }

    return bookedAppointmentsFor(range) / totalSlots;
  }

  void selectUtilizationRange(AdminUtilizationRange range) {
    selectedUtilizationRange.value = range;
  }

  void selectSection(AdminDashboardSection section) {
    selectedSection.value = section;
  }

  void toggleSidebarCollapsed() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }

  void changeAppointmentsMonth(int delta) {
    visibleAppointmentsMonth.value = DateTime(
      visibleAppointmentsMonth.value.year,
      visibleAppointmentsMonth.value.month + delta,
    );
  }

  void selectAppointmentDate(DateTime date) {
    selectedAppointmentDate.value = dateOnly(date);
    visibleAppointmentsMonth.value = DateTime(date.year, date.month);
  }

  bool hasAppointmentsOn(DateTime date) {
    return appointments.any((appointment) {
      final scheduledFor = _appointmentDate(appointment);
      return scheduledFor != null && isSameDate(scheduledFor, date);
    });
  }

  List<Map<String, dynamic>> appointmentsForDate(DateTime date) {
    return appointments.where((appointment) {
      final scheduledFor = _appointmentDate(appointment);
      return scheduledFor != null && isSameDate(scheduledFor, date);
    }).toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      currentUser.value = user;
      currentWorkspace.value = AppConfig.workspaceForEmail(user?.email);
      _bindAvailability();
      _bindAppointments();
      _bindCustomers();
    });
  }

  DocumentReference<Map<String, dynamic>>? get _workspaceRef {
    final workspaceId = currentWorkspaceId;
    if (workspaceId == null) {
      return null;
    }

    return _firestore.collection('workspaces').doc(workspaceId);
  }

  void _bindAvailability() {
    _availabilitySubscription?.cancel();
    availability.value = null;

    final workspaceRef = _workspaceRef;
    if (workspaceRef == null) {
      return;
    }

    _availabilitySubscription = workspaceRef
        .collection('availability')
        .doc('default_week')
        .snapshots()
        .listen((snapshot) {
          availability.value = snapshot.exists
              ? AvailabilitySchedule.fromDocument(snapshot)
              : null;
        });
  }

  void _bindAppointments() {
    _appointmentsSubscription?.cancel();
    appointments.clear();

    if (!isAuthorizedAdmin) {
      return;
    }

    final workspaceRef = _workspaceRef;
    if (workspaceRef == null) {
      return;
    }

    _appointmentsSubscription = workspaceRef
        .collection('appointments')
        .orderBy('scheduledFor')
        .snapshots()
        .listen((snapshot) {
          final docs = snapshot.docs
              .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
              .where((data) => data['isSeed'] != true)
              .toList(growable: false);
          appointments.assignAll(docs);
        });
  }

  void _bindCustomers() {
    _customersSubscription?.cancel();
    customers.clear();

    if (!isAuthorizedAdmin) {
      return;
    }

    final workspaceRef = _workspaceRef;
    if (workspaceRef == null) {
      return;
    }

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
  }

  void updateCustomerSearch(String value) {
    customerSearchQuery.value = value;
  }

  void clearCustomerSearch() {
    customerSearchController.clear();
    customerSearchQuery.value = '';
  }

  bool isAppointmentBusy(String appointmentId) {
    return busyAppointmentIds.contains(appointmentId);
  }

  Future<void> signIn() async {
    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      errorMessage.value = switch (error.code) {
        'invalid-email' => 'Email non valida.',
        'invalid-credential' => 'Credenziali non valide.',
        'wrong-password' => 'Password non corretta.',
        'user-not-found' => 'Utente non trovato.',
        _ => error.message ?? 'Accesso non riuscito.',
      };
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> seedCollections() async {
    isSeeding.value = true;
    infoMessage.value = null;

    try {
      final workspace = currentWorkspace.value;
      if (workspace == null) {
        infoMessage.value = 'Workspace non configurato per questo account.';
        return;
      }

      await _bootstrapService.seedInitialData(
        workspaceId: workspace.id,
        workspaceName: workspace.name,
      );
      infoMessage.value =
          'Servizi e disponibilità iniziali aggiornati per ${workspace.name}.';
    } catch (error) {
      infoMessage.value = 'Seed non riuscito: $error';
    } finally {
      isSeeding.value = false;
    }
  }

  Future<bool> confirmAppointment(String appointmentId) async {
    return _runAppointmentAction(
      appointmentId,
      () async {
        final workspaceRef = _workspaceRef;
        if (workspaceRef == null) {
          throw StateError('Workspace non configurato.');
        }

        await workspaceRef.collection('appointments').doc(appointmentId).update(
          {'status': 'confirmed', 'updatedAt': FieldValue.serverTimestamp()},
        );
      },
      successMessage: 'Appuntamento confermato.',
      errorPrefix: 'Conferma non riuscita',
    );
  }

  Future<bool> updateAppointment({
    required String appointmentId,
    required String customerName,
    required String serviceName,
    required String notes,
    required String status,
  }) async {
    return _runAppointmentAction(
      appointmentId,
      () async {
        final workspaceRef = _workspaceRef;
        if (workspaceRef == null) {
          throw StateError('Workspace non configurato.');
        }

        await workspaceRef
            .collection('appointments')
            .doc(appointmentId)
            .update({
              'customerName': customerName.trim(),
              'serviceName': serviceName.trim(),
              'notes': notes.trim(),
              'status': status,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      },
      successMessage: 'Appuntamento aggiornato.',
      errorPrefix: 'Modifica non riuscita',
    );
  }

  Future<bool> deleteAppointment(String appointmentId) async {
    return _runAppointmentAction(
      appointmentId,
      () async {
        final workspaceRef = _workspaceRef;
        if (workspaceRef == null) {
          throw StateError('Workspace non configurato.');
        }

        await workspaceRef
            .collection('appointments')
            .doc(appointmentId)
            .delete();
      },
      successMessage: 'Appuntamento eliminato.',
      errorPrefix: 'Eliminazione non riuscita',
    );
  }

  Future<bool> createCustomer({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String notes,
  }) async {
    if (isCreatingCustomer.value) {
      return false;
    }

    isCreatingCustomer.value = true;
    infoMessage.value = null;

    try {
      final workspaceRef = _workspaceRef;
      if (workspaceRef == null) {
        throw StateError('Workspace non configurato.');
      }

      await workspaceRef.collection('customers').add({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'notes': notes.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      infoMessage.value = 'Cliente censito.';
      return true;
    } on FirebaseException catch (error) {
      infoMessage.value =
          'Creazione cliente non riuscita: ${error.message ?? error.code}';
    } catch (error) {
      infoMessage.value = 'Creazione cliente non riuscita: $error';
    } finally {
      isCreatingCustomer.value = false;
    }

    return false;
  }

  Future<bool> updateCustomer({
    required String customerId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String notes,
  }) async {
    if (isCreatingCustomer.value) {
      return false;
    }

    isCreatingCustomer.value = true;
    infoMessage.value = null;

    try {
      final workspaceRef = _workspaceRef;
      if (workspaceRef == null) {
        throw StateError('Workspace non configurato.');
      }

      await workspaceRef.collection('customers').doc(customerId).update({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'notes': notes.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      infoMessage.value = 'Cliente aggiornato.';
      return true;
    } on FirebaseException catch (error) {
      infoMessage.value =
          'Aggiornamento cliente non riuscito: ${error.message ?? error.code}';
    } catch (error) {
      infoMessage.value = 'Aggiornamento cliente non riuscito: $error';
    } finally {
      isCreatingCustomer.value = false;
    }

    return false;
  }

  Future<bool> deleteCustomer(String customerId) async {
    if (isCreatingCustomer.value) {
      return false;
    }

    isCreatingCustomer.value = true;
    infoMessage.value = null;

    try {
      final workspaceRef = _workspaceRef;
      if (workspaceRef == null) {
        throw StateError('Workspace non configurato.');
      }

      await workspaceRef.collection('customers').doc(customerId).delete();

      infoMessage.value = 'Cliente eliminato.';
      return true;
    } on FirebaseException catch (error) {
      infoMessage.value =
          'Eliminazione cliente non riuscita: ${error.message ?? error.code}';
    } catch (error) {
      infoMessage.value = 'Eliminazione cliente non riuscita: $error';
    } finally {
      isCreatingCustomer.value = false;
    }

    return false;
  }

  Future<bool> _runAppointmentAction(
    String appointmentId,
    Future<void> Function() action, {
    required String successMessage,
    required String errorPrefix,
  }) async {
    if (busyAppointmentIds.contains(appointmentId)) {
      return false;
    }

    busyAppointmentIds.add(appointmentId);

    try {
      await action();
      infoMessage.value = successMessage;
      return true;
    } on FirebaseException catch (error) {
      infoMessage.value = '$errorPrefix: ${error.message ?? error.code}';
    } catch (error) {
      infoMessage.value = '$errorPrefix: $error';
    } finally {
      busyAppointmentIds.remove(appointmentId);
    }

    return false;
  }

  DateTime _rangeStart(AdminUtilizationRange range) {
    final now = dateOnly(DateTime.now());

    return switch (range) {
      AdminUtilizationRange.daily => now,
      AdminUtilizationRange.weekly => now.subtract(
        Duration(days: now.weekday - 1),
      ),
      AdminUtilizationRange.monthly => DateTime(now.year, now.month),
    };
  }

  DateTime _rangeEnd(AdminUtilizationRange range) {
    final start = _rangeStart(range);

    return switch (range) {
      AdminUtilizationRange.daily => start.add(const Duration(days: 1)),
      AdminUtilizationRange.weekly => start.add(const Duration(days: 7)),
      AdminUtilizationRange.monthly => DateTime(start.year, start.month + 1),
    };
  }

  int _countSlotsInRange(
    AvailabilitySchedule schedule,
    DateTime start,
    DateTime end,
  ) {
    var total = 0;
    var cursor = start;

    while (cursor.isBefore(end)) {
      total += schedule.windowsForDate(cursor).length;
      cursor = cursor.add(const Duration(days: 1));
    }

    return total;
  }

  DateTime? _appointmentDate(Map<String, dynamic> appointment) {
    final timestamp = appointment['scheduledFor'];
    return switch (timestamp) {
      Timestamp value => value.toDate(),
      DateTime value => value,
      _ => null,
    };
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _appointmentsSubscription?.cancel();
    _customersSubscription?.cancel();
    _availabilitySubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    customerSearchController.dispose();
    super.onClose();
  }
}
