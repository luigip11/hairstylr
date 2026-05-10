import 'package:web/web.dart' as web;

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

  web.window.open('tel:$phoneNumber', '_self');
  return true;
}
