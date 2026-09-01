import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:expensetracker/presentation/ads/ads_runtime.dart';

class AdsConsentState {
  const AdsConsentState({
    required this.ready,
    required this.canRequestAds,
    required this.nonPersonalizedOnly,
  });

  /// Consent flow finished (success, skip, or error). Ads must not load before this.
  final bool ready;

  final bool canRequestAds;

  /// True when GDPR consent was declined or is still required — request NPA only.
  final bool nonPersonalizedOnly;

  static const pending = AdsConsentState(
    ready: false,
    canRequestAds: false,
    nonPersonalizedOnly: true,
  );

  static const unavailable = AdsConsentState(
    ready: true,
    canRequestAds: false,
    nonPersonalizedOnly: true,
  );

  AdRequest get adRequest => AdRequest(nonPersonalizedAds: nonPersonalizedOnly);
}

/// Runs the UMP GDPR flow at launch and exposes whether ads may be requested.
class AdsConsentNotifier extends Notifier<AdsConsentState> {
  @override
  AdsConsentState build() {
    _gather();
    return AdsConsentState.pending;
  }

  Future<void> _gather() async {
    if (!adsRuntimeEnabled) {
      state = AdsConsentState.unavailable;
      return;
    }

    try {
      await _requestConsentInfoUpdate();
      await _loadAndShowConsentFormIfRequired();
      await _publishFromSdk();
    } catch (_) {
      try {
        await _publishFromSdk();
      } catch (_) {
        state = AdsConsentState.unavailable;
      }
    }
  }

  Future<void> _requestConsentInfoUpdate() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      completer.complete,
      (error) => completer.completeError(error),
    );
    return completer.future;
  }

  Future<void> _loadAndShowConsentFormIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((_) {
      completer.complete();
    });
    return completer.future;
  }

  Future<void> _publishFromSdk() async {
    final canRequest = await ConsentInformation.instance.canRequestAds();
    final status = await ConsentInformation.instance.getConsentStatus();
    final personalized =
        status == ConsentStatus.obtained || status == ConsentStatus.notRequired;
    state = AdsConsentState(
      ready: true,
      canRequestAds: canRequest,
      nonPersonalizedOnly: !personalized,
    );
  }
}

final adsConsentProvider =
    NotifierProvider<AdsConsentNotifier, AdsConsentState>(
      AdsConsentNotifier.new,
    );
