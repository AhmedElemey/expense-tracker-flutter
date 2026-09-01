import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/presentation/ads/ads_runtime.dart';
import 'package:expensetracker/presentation/providers/ads_consent_provider.dart';

class AdsTrackingState {
  const AdsTrackingState({required this.ready, required this.allowsTracking});

  /// ATT prompt finished, skipped (Android), or unavailable.
  final bool ready;

  /// IDFA tracking authorized (or not applicable). False → non-personalized ads.
  final bool allowsTracking;

  static const pending = AdsTrackingState(ready: false, allowsTracking: false);
  static const skipped = AdsTrackingState(ready: true, allowsTracking: true);
}

/// Requests App Tracking Transparency once on iOS after GDPR consent is ready.
class AdsTrackingNotifier extends Notifier<AdsTrackingState> {
  var _started = false;

  @override
  AdsTrackingState build() {
    ref.listen<AdsConsentState>(adsConsentProvider, (_, next) {
      if (next.ready) {
        _ensureRequested();
      }
    });
    if (ref.read(adsConsentProvider).ready) {
      _ensureRequested();
    }
    if (!adsRuntimeEnabled) {
      return AdsTrackingState.skipped;
    }
    return AdsTrackingState.pending;
  }

  Future<void> _ensureRequested() async {
    if (_started) {
      return;
    }
    _started = true;
    if (!adsRuntimeEnabled || !Platform.isIOS) {
      state = AdsTrackingState.skipped;
      return;
    }

    await Future<void>.delayed(Duration.zero);
    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }
      final allows =
          status == TrackingStatus.authorized ||
          status == TrackingStatus.notSupported;
      state = AdsTrackingState(ready: true, allowsTracking: allows);
    } catch (_) {
      state = AdsTrackingState(ready: true, allowsTracking: false);
    }
  }
}

final adsTrackingProvider =
    NotifierProvider<AdsTrackingNotifier, AdsTrackingState>(
      AdsTrackingNotifier.new,
    );

/// Combined gate: do not load ads until UMP and ATT have finished.
final adsLoadGateProvider = Provider<AdsConsentState>((ref) {
  final consent = ref.watch(adsConsentProvider);
  final tracking = ref.watch(adsTrackingProvider);
  if (!consent.ready || !tracking.ready) {
    return AdsConsentState.pending;
  }
  if (!consent.canRequestAds) {
    return AdsConsentState.unavailable;
  }
  return AdsConsentState(
    ready: true,
    canRequestAds: true,
    nonPersonalizedOnly:
        consent.nonPersonalizedOnly || !tracking.allowsTracking,
  );
});
