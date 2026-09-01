import 'dart:io';

/// Mobile ads, UMP, and ATT run only on Android/iOS outside widget tests.
bool get adsRuntimeEnabled {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return false;
  }
  return Platform.isAndroid || Platform.isIOS;
}
