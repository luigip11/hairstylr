import 'package:cloud_firestore/cloud_firestore.dart';

class BootstrapService {
  BootstrapService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> seedInitialData() async {
    final batch = _firestore.batch();

    final serviceRef = _firestore.collection('services').doc('basic_cut');
    batch.set(serviceRef, {
      'name': 'Basic Cut',
      'description': 'Classic haircut appointment.',
      'durationMinutes': 45,
      'price': 25,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final availabilityRef = _firestore
        .collection('availability')
        .doc('default_week');
    batch.set(availabilityRef, {
      'timezone': 'Europe/Rome',
      'weeklySchedule': {
        'monday': ['09:00-13:00', '14:00-18:00'],
        'tuesday': ['09:00-13:00', '14:00-18:00'],
        'wednesday': ['09:00-13:00', '14:00-18:00'],
        'thursday': ['09:00-13:00', '14:00-18:00'],
        'friday': ['09:00-13:00', '14:00-18:00'],
        'saturday': ['09:00-13:00'],
        'sunday': <String>[],
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final appointmentRef = _firestore
        .collection('appointments')
        .doc('example_appointment');
    batch.set(appointmentRef, {
      'clientName': 'Demo Client',
      'serviceId': 'basic_cut',
      'status': 'pending',
      'notes': 'Seed appointment created during setup.',
      'scheduledFor': DateTime.now().add(const Duration(days: 1)),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
