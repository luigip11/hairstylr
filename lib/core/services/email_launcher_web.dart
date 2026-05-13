import 'package:web/web.dart' as web;

Future<bool> launchSupportEmail({
  required String recipient,
  required String subject,
  required String body,
}) async {
  if (recipient.trim().isEmpty) {
    return false;
  }

  final uri = Uri(
    scheme: 'mailto',
    path: recipient.trim(),
    queryParameters: <String, String>{
      'subject': subject.trim(),
      'body': body.trim(),
    },
  );
  web.window.open(uri.toString(), '_self');
  return true;
}
