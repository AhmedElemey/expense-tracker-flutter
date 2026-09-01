import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:expensetracker/presentation/ads/ad_ids.dart';
import 'package:expensetracker/presentation/ads/ads_runtime.dart';
import 'package:expensetracker/presentation/providers/ads_removed_provider.dart';
import 'package:expensetracker/presentation/providers/ads_tracking_provider.dart';

/// Loaded dashboard banner, or null when hidden / failed / still loading.
class DashboardBannerAdNotifier extends Notifier<BannerAd?> {
  var _inFlight = false;
  var _disposed = false;

  @override
  BannerAd? build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      state?.dispose();
    });
    ref.listen<bool>(adsRemovedProvider, (_, removed) {
      if (removed) {
        state?.dispose();
        state = null;
        _inFlight = false;
      }
    });
    return null;
  }

  Future<void> loadIfNeeded(int widthDp) async {
    if (_disposed || _inFlight || state != null) {
      return;
    }
    if (ref.read(adsRemovedProvider)) {
      return;
    }
    final gate = ref.read(adsLoadGateProvider);
    if (!adsRuntimeEnabled || !gate.ready || !gate.canRequestAds) {
      return;
    }
    if (widthDp <= 0) {
      return;
    }

    _inFlight = true;
    try {
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            widthDp,
          ) ??
          AdSize.banner;
      if (_disposed) {
        return;
      }
      final ad = BannerAd(
        adUnitId: AdIds.banner,
        size: size,
        request: gate.adRequest,
        listener: BannerAdListener(
          onAdLoaded: (loaded) {
            if (_disposed) {
              loaded.dispose();
              return;
            }
            state = loaded as BannerAd;
          },
          onAdFailedToLoad: (failed, _) {
            failed.dispose();
            _inFlight = false;
            if (!_disposed) {
              state = null;
            }
          },
        ),
      );
      await ad.load();
    } catch (_) {
      _inFlight = false;
      if (!_disposed) {
        state = null;
      }
    }
  }
}

final dashboardBannerAdProvider =
    NotifierProvider<DashboardBannerAdNotifier, BannerAd?>(
      DashboardBannerAdNotifier.new,
    );
