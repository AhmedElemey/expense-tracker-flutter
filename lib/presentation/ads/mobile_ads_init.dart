import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Starts the Mobile Ads SDK. Safe to call when the plugin is missing
/// (widget tests, unsupported platforms) — the rest of the app still runs.
Future<void> initializeMobileAds() async {
  try {
    await MobileAds.instance.initialize();
  } catch (_) {
    // Ads stay unavailable; expense tracking does not depend on this.
  }
}
