import 'package:flutter_test/flutter_test.dart';
import 'package:hairstylr/core/services/support_email_message.dart';

void main() {
  test('builds support email from a mocked compiled form', () {
    final body = buildSupportEmailBody(
      fullName: 'Mario Rossi',
      message: 'Non riesco a confermare un appuntamento.',
    );

    expect(supportEmailRecipient, 'luigi.irons11@gmail.com');
    expect(supportEmailSubject, 'Hairstylr - Segnalazione problema');
    expect(
      body,
      'Nome e Cognome: Mario Rossi\n\n'
      'Messaggio:\nNon riesco a confermare un appuntamento.',
    );
  });
}
