import 'package:flutter/services.dart';

const _linkChannel = MethodChannel('hairstylr/link');

Future<bool> launchExternalLink(String url) async {
  final normalizedUrl = url.trim();
  if (normalizedUrl.isEmpty) {
    return false;
  }

  try {
    return await _linkChannel.invokeMethod<bool>('open', {
          'url': normalizedUrl,
        }) ??
        false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}
