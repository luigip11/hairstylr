import 'package:web/web.dart' as web;

Future<bool> launchExternalLink(String url) async {
  final normalizedUrl = url.trim();
  if (normalizedUrl.isEmpty) {
    return false;
  }

  web.window.open(normalizedUrl, '_blank');
  return true;
}
