import 'dart:io';

/// TEST AdMob identifiers. Replace every value here (and the matching native
/// App IDs) with production IDs immediately before release.
abstract final class AdIds {
  static const androidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const iosBanner = 'ca-app-pub-3940256099942544/2934735716';

  static String get banner {
    if (Platform.isIOS) {
      return iosBanner;
    }
    return androidBanner;
  }
}
