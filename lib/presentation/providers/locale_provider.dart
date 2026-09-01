import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kLocalePrefsKey = 'localeCode';

const kSupportedLocaleCodes = ['en', 'ar'];

final localeCodeProvider = StateProvider<String>((ref) => 'en');

String normalizeLocaleCode(String? code) {
  if (code != null && kSupportedLocaleCodes.contains(code)) {
    return code;
  }
  return 'en';
}

Future<String?> loadSavedLocaleCode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(kLocalePrefsKey);
}

Future<void> saveLocaleCode(String code) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(kLocalePrefsKey, code);
}

void setAppLocale(WidgetRef ref, String code) {
  final normalized = normalizeLocaleCode(code);
  ref.read(localeCodeProvider.notifier).state = normalized;
  saveLocaleCode(normalized);
}
