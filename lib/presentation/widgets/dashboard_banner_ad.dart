import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:expensetracker/presentation/providers/ads_tracking_provider.dart';
import 'package:expensetracker/presentation/providers/dashboard_banner_ad_provider.dart';

/// Anchored banner under dashboard content. Renders nothing until an ad loads.
class DashboardBannerAd extends ConsumerStatefulWidget {
  const DashboardBannerAd({super.key});

  @override
  ConsumerState<DashboardBannerAd> createState() => _DashboardBannerAdState();
}

class _DashboardBannerAdState extends ConsumerState<DashboardBannerAd> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(adsLoadGateProvider, (_, next) {
      if (next.ready && next.canRequestAds) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _load());
      }
    });

    final gate = ref.watch(adsLoadGateProvider);
    final ad = ref.watch(dashboardBannerAdProvider);
    if (!gate.ready || !gate.canRequestAds || ad == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Align(
        alignment: AlignmentDirectional.bottomCenter,
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }

  void _load() {
    if (!mounted) {
      return;
    }
    final width = MediaQuery.sizeOf(context).width.truncate();
    ref.read(dashboardBannerAdProvider.notifier).loadIfNeeded(width);
  }
}
