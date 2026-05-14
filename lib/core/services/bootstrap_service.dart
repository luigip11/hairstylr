import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../models/booking_support.dart';

const String luigiTestSeedAssetPath = 'assets/mock/luigi_test_seed.json';

const List<String> _defaultSlots = [
  '07:00-07:30',
  '07:40-08:15',
  '08:30-09:00',
  '13:00-13:30',
  '13:45-14:15',
  '19:00-19:30',
  '19:45-20:15',
  '20:30-21:00',
];

const List<Map<String, Object?>> _defaultServices = [
  {
    'id': 'piega',
    'name': 'Piega',
    'description': 'Piega e finish.',
    'durationMinutes': 60,
    'price': 30,
  },
  {
    'id': 'taglio',
    'name': 'Taglio',
    'description': 'Taglio donna a domicilio.',
    'durationMinutes': 45,
    'price': 25,
  },
  {
    'id': 'colore',
    'name': 'Colore',
    'description': 'Colore base o ritocco.',
    'durationMinutes': 120,
    'price': 55,
  },
  {
    'id': 'altro',
    'name': 'Altro',
    'description': 'Servizio personalizzato su richiesta.',
  },
];

class BootstrapService {
  BootstrapService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> seedInitialData({
    required String workspaceId,
    required String workspaceName,
    bool includeMockData = false,
    String? seedAssetPath,
  }) async {
    final seedData = includeMockData
        ? await _loadSeedData(seedAssetPath ?? luigiTestSeedAssetPath)
        : const <String, dynamic>{};
    final batch = _firestore.batch();
    final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);

    batch.set(workspaceRef, {
      'name': workspaceName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final services = _mapList(seedData['services']);
    for (final service in services.isEmpty ? _defaultServices : services) {
      final id = service['id'] as String?;
      if (id == null || id.isEmpty) {
        continue;
      }

      final ref = workspaceRef.collection('services').doc(id);
      batch.set(ref, {
        'name': service['name'],
        'description': service['description'],
        'durationMinutes': service['durationMinutes'],
        'price': service['price'],
        'active': (service['active'] as bool?) ?? true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final availability = _map(seedData['availability']);
    final weeklySchedule = _map(availability['weeklySchedule']);
    final availabilityRef = workspaceRef
        .collection('availability')
        .doc('default_week');
    batch.set(availabilityRef, {
      'timezone': (availability['timezone'] as String?) ?? 'Europe/Rome',
      'weeklySchedule': weeklySchedule.isEmpty
          ? {
              'monday': _defaultSlots,
              'tuesday': _defaultSlots,
              'wednesday': _defaultSlots,
              'thursday': _defaultSlots,
              'friday': _defaultSlots,
              'saturday': _defaultSlots,
              'sunday': _defaultSlots,
            }
          : weeklySchedule.map(
              (key, value) => MapEntry(
                key,
                value is List
                    ? value.map((slot) => slot.toString()).toList()
                    : const <String>[],
              ),
            ),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final appointmentRef = workspaceRef
        .collection('appointments')
        .doc('_bootstrap');
    batch.set(appointmentRef, {
      'customerName': 'Seed',
      'serviceId': 'taglio',
      'serviceName': 'Taglio',
      'serviceDurationMinutes': 45,
      'status': 'seed',
      'notes': 'Documento placeholder per inizializzare la collezione.',
      'scheduledFor': DateTime.now(),
      'scheduledDateKey': 'bootstrap',
      'slotLabel': 'bootstrap',
      'isSeed': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (includeMockData) {
      _seedMockCustomers(batch, workspaceRef, _mapList(seedData['customers']));
      _seedMockAppointments(
        batch,
        workspaceRef,
        _mapList(seedData['appointments']),
      );
    }

    await batch.commit();
  }

  Future<Map<String, dynamic>> _loadSeedData(String assetPath) async {
    final rawJson = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(rawJson);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw FormatException('Seed JSON non valido: $assetPath');
  }

  void _seedMockCustomers(
    WriteBatch batch,
    DocumentReference<Map<String, dynamic>> workspaceRef,
    List<Map<String, Object?>> customers,
  ) {
    for (final customer in customers) {
      final id = customer['id'] as String?;
      if (id == null || id.isEmpty) {
        continue;
      }

      final customerRef = workspaceRef.collection('customers').doc(id);
      batch.set(customerRef, {
        'firstName': customer['firstName'],
        'lastName': customer['lastName'],
        'phoneNumber': customer['phoneNumber'],
        'notes': customer['notes'],
        'isMock': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  void _seedMockAppointments(
    WriteBatch batch,
    DocumentReference<Map<String, dynamic>> workspaceRef,
    List<Map<String, Object?>> appointments,
  ) {
    for (final appointment in appointments) {
      final id = appointment['id'] as String?;
      final scheduledForRaw = appointment['scheduledFor'] as String?;
      final scheduledFor = scheduledForRaw == null
          ? null
          : DateTime.tryParse(scheduledForRaw);
      if (id == null || id.isEmpty || scheduledFor == null) {
        continue;
      }

      final appointmentRef = workspaceRef.collection('appointments').doc(id);
      batch.set(appointmentRef, {
        'customerId': appointment['customerId'],
        'customerName': appointment['customerName'],
        'serviceId': appointment['serviceId'],
        'serviceName': appointment['serviceName'],
        'serviceDisplayName': appointment['serviceDisplayName'],
        'serviceDurationMinutes': appointment['serviceDurationMinutes'],
        'status': appointment['status'],
        'notes': appointment['notes'],
        'scheduledFor': scheduledFor,
        'scheduledDateKey': dateKey(scheduledFor),
        'slotLabel': appointment['slotLabel'],
        'isMock': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return const <String, dynamic>{};
  }

  List<Map<String, Object?>> _mapList(Object? value) {
    if (value is! List) {
      return const <Map<String, Object?>>[];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, Object?>.from(item))
        .toList(growable: false);
  }
}
