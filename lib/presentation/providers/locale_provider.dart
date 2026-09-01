import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kLocalePrefsKey = 'localeCode';

const kSupportedLocaleCodes = ['en', 'ar'];

String normalizeLocaleCode(String? code) {
  if (code != null && kSupportedLocaleCodes.contains(code)) {
    return code;
  }
  return 'en';
}

class LocaleCodeNotifier extends Notifier<String> {
  var _hydrated = false;

  @override
  String build() {
    _hydrate();
    return 'en';
  }

  Future<void> setLocale(String code) async {
    _hydrated = true;
    final normalized = normalizeLocaleCode(code);
    state = normalized;
    await _persist(normalized);
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_hydrated) {
        return;
      }
      _hydrated = true;
      final saved = prefs.getString(kLocalePrefsKey);
      if (saved == null) {
        return;
      }
      state = normalizeLocaleCode(saved);
    } catch (_) {
      _hydrated = true;
    }
  }

  Future<void> _persist(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kLocalePrefsKey, code);
    } catch (_) {
      // Locale still applies for this session if prefs fail.
    }
  }
}

final localeCodeProvider = NotifierProvider<LocaleCodeNotifier, String>(
  LocaleCodeNotifier.new,
);
