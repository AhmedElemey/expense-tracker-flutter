import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kAdsRemovedPrefsKey = 'adsRemoved';

/// Local "Remove Ads" flag. Not a real purchase — see Settings TODO.
class AdsRemovedNotifier extends Notifier<bool> {
  var _hydrated = false;

  @override
  bool build() {
    _hydrate();
    return false;
  }

  Future<void> setRemoved(bool value) async {
    _hydrated = true;
    state = value;
    await _persist(value);
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_hydrated) {
        return;
      }
      _hydrated = true;
      state = prefs.getBool(kAdsRemovedPrefsKey) ?? false;
    } catch (_) {
      _hydrated = true;
    }
  }

  Future<void> _persist(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kAdsRemovedPrefsKey, value);
    } catch (_) {
      // Flag still applies for this session if prefs fail.
    }
  }
}

final adsRemovedProvider = NotifierProvider<AdsRemovedNotifier, bool>(
  AdsRemovedNotifier.new,
);
