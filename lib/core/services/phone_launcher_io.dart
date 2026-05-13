import 'package:flutter/services.dart';

const _phoneChannel = MethodChannel('hairstylr/phone');

String normalizePhoneNumber(String value) {
  return value.replaceAll(RegExp(r'[^0-9+]'), '');
}

bool hasCallablePhoneNumber(String value) {
  return normalizePhoneNumber(value).isNotEmpty;
}

Future<bool> launchPhoneCall(String value) async {
  final phoneNumber = normalizePhoneNumber(value);
  if (phoneNumber.isEmpty) {
    return false;
  }

  try {
    final result = await _phoneChannel.invokeMethod<bool>(
      'dial',
      <String, String>{'phoneNumber': phoneNumber},
    );
    return result ?? false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}
