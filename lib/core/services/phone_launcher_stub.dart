String normalizePhoneNumber(String value) {
  return value.replaceAll(RegExp(r'[^0-9+]'), '');
}

bool hasCallablePhoneNumber(String value) {
  return normalizePhoneNumber(value).isNotEmpty;
}

Future<bool> launchPhoneCall(String value) async {
  return false;
}
