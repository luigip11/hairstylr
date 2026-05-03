import 'package:cloud_firestore/cloud_firestore.dart';

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

class BootstrapService {
  BootstrapService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> seedInitialData({
    required String workspaceId,
    required String workspaceName,
  }) async {
    final batch = _firestore.batch();
    final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);

    batch.set(workspaceRef, {
      'name': workspaceName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final services = [
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

    for (final service in services) {
      final ref = workspaceRef
          .collection('services')
          .doc(service['id']! as String);
      batch.set(ref, {
        'name': service['name'],
        'description': service['description'],
        'durationMinutes': service['durationMinutes'],
        'price': service['price'],
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final availabilityRef = workspaceRef
        .collection('availability')
        .doc('default_week');
    batch.set(availabilityRef, {
      'timezone': 'Europe/Rome',
      'weeklySchedule': {
        'monday': _defaultSlots,
        'tuesday': _defaultSlots,
        'wednesday': _defaultSlots,
        'thursday': _defaultSlots,
        'friday': _defaultSlots,
        'saturday': _defaultSlots,
        'sunday': _defaultSlots,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final appointmentRef = workspaceRef.collection('appointments').doc('_bootstrap');
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

    await batch.commit();
  }
}
