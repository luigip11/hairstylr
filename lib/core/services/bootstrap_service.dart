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

const List<Map<String, String>> _mockCustomers = [
  {
    'id': 'mock-alberti-anna',
    'firstName': 'Anna',
    'lastName': 'Alberti',
    'phoneNumber': '3331002001',
    'notes': 'Preferisce appuntamenti serali.',
  },
  {
    'id': 'mock-amato-alice',
    'firstName': 'Alice',
    'lastName': 'Amato',
    'phoneNumber': '3331002002',
    'notes': 'Colore ogni 6 settimane.',
  },
  {
    'id': 'mock-conti-chiara',
    'firstName': 'Chiara',
    'lastName': 'Conti',
    'phoneNumber': '3331002003',
    'notes': 'Capello mosso, piega naturale.',
  },
  {
    'id': 'mock-costa-camilla',
    'firstName': 'Camilla',
    'lastName': 'Costa',
    'phoneNumber': '3331002004',
    'notes': 'Richiede sempre conferma WhatsApp.',
  },
  {
    'id': 'mock-de-luca-denise',
    'firstName': 'Denise',
    'lastName': 'De Luca',
    'phoneNumber': '3331002005',
    'notes': 'Taglio medio scalato.',
  },
  {
    'id': 'mock-damiani-daria',
    'firstName': 'Daria',
    'lastName': 'Damiani',
    'phoneNumber': '3331002006',
    'notes': 'Cliente demo.',
  },
  {
    'id': 'mock-esposito-elena',
    'firstName': 'Elena',
    'lastName': 'Esposito',
    'phoneNumber': '3331002007',
    'notes': 'Preferisce la mattina.',
  },
  {
    'id': 'mock-errico-emma',
    'firstName': 'Emma',
    'lastName': 'Errico',
    'phoneNumber': '3331002008',
    'notes': 'Piega liscia.',
  },
  {
    'id': 'mock-ferrari-francesca',
    'firstName': 'Francesca',
    'lastName': 'Ferrari',
    'phoneNumber': '3331002009',
    'notes': 'Colore castano freddo.',
  },
  {
    'id': 'mock-fontana-federica',
    'firstName': 'Federica',
    'lastName': 'Fontana',
    'phoneNumber': '3331002010',
    'notes': 'Cliente demo.',
  },
  {
    'id': 'mock-gallo-giulia',
    'firstName': 'Giulia',
    'lastName': 'Gallo',
    'phoneNumber': '3331002011',
    'notes': 'Taglio corto.',
  },
  {
    'id': 'mock-greco-gaia',
    'firstName': 'Gaia',
    'lastName': 'Greco',
    'phoneNumber': '3331002012',
    'notes': 'Preferisce sabato.',
  },
  {
    'id': 'mock-lombardi-laura',
    'firstName': 'Laura',
    'lastName': 'Lombardi',
    'phoneNumber': '3331002013',
    'notes': 'Piega morbida.',
  },
  {
    'id': 'mock-leone-livia',
    'firstName': 'Livia',
    'lastName': 'Leone',
    'phoneNumber': '3331002014',
    'notes': 'Colore senza ammoniaca.',
  },
  {
    'id': 'mock-martini-marta',
    'firstName': 'Marta',
    'lastName': 'Martini',
    'phoneNumber': '3331002015',
    'notes': 'Cliente demo.',
  },
  {
    'id': 'mock-moretti-monica',
    'firstName': 'Monica',
    'lastName': 'Moretti',
    'phoneNumber': '3331002016',
    'notes': 'Preferisce pausa pranzo.',
  },
  {
    'id': 'mock-neri-nadia',
    'firstName': 'Nadia',
    'lastName': 'Neri',
    'phoneNumber': '3331002017',
    'notes': 'Taglio punte.',
  },
  {
    'id': 'mock-nardi-noemi',
    'firstName': 'Noemi',
    'lastName': 'Nardi',
    'phoneNumber': '3331002018',
    'notes': 'Piega volume.',
  },
  {
    'id': 'mock-pellegrini-paola',
    'firstName': 'Paola',
    'lastName': 'Pellegrini',
    'phoneNumber': '3331002019',
    'notes': 'Cliente demo.',
  },
  {
    'id': 'mock-pagani-petra',
    'firstName': 'Petra',
    'lastName': 'Pagani',
    'phoneNumber': '3331002020',
    'notes': 'Colore ramato.',
  },
  {
    'id': 'mock-ricci-rita',
    'firstName': 'Rita',
    'lastName': 'Ricci',
    'phoneNumber': '3331002021',
    'notes': 'Taglio bob.',
  },
  {
    'id': 'mock-rizzo-rossella',
    'firstName': 'Rossella',
    'lastName': 'Rizzo',
    'phoneNumber': '3331002022',
    'notes': 'Preferisce appuntamenti brevi.',
  },
  {
    'id': 'mock-santoro-sara',
    'firstName': 'Sara',
    'lastName': 'Santoro',
    'phoneNumber': '3331002023',
    'notes': 'Piega onde.',
  },
  {
    'id': 'mock-serra-silvia',
    'firstName': 'Silvia',
    'lastName': 'Serra',
    'phoneNumber': '3331002024',
    'notes': 'Cliente demo.',
  },
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

    for (final customer in _mockCustomers) {
      final customerRef = workspaceRef.collection('customers').doc(
        customer['id']!,
      );
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

    await batch.commit();
  }
}
