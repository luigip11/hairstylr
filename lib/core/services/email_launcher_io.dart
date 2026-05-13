import 'package:flutter/services.dart';

const _emailChannel = MethodChannel('hairstylr/email');

Future<bool> launchSupportEmail({
  required String recipient,
  required String subject,
  required String body,
}) async {
  if (recipient.trim().isEmpty) {
    return false;
  }

  try {
    final result = await _emailChannel.invokeMethod<bool>(
      'send',
      <String, String>{
        'recipient': recipient.trim(),
        'subject': subject.trim(),
        'body': body.trim(),
      },
    );
    return result ?? false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}
