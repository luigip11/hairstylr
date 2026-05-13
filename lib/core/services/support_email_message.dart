const supportEmailRecipient = 'luigi.irons11@gmail.com';
const supportEmailSubject = 'Hairstylr - Segnalazione problema';

String buildSupportEmailBody({
  required String fullName,
  required String message,
}) {
  return 'Nome e Cognome: ${fullName.trim()}\n\n'
      'Messaggio:\n${message.trim()}';
}
