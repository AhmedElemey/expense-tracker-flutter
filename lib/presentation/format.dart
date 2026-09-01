import 'package:intl/intl.dart';

const kDefaultCurrencySymbol = r'$';

const kCurrencySymbols = <String>[r'$', '€', '£', '¥'];

/// Currency amounts always use Western digits so they stay readable next to
/// `$` / `€` / `£` / `¥`, regardless of the UI locale.
String formatAmount(
  double amount, {
  String symbol = kDefaultCurrencySymbol,
}) {
  return '$symbol${NumberFormat('#,##0.00', 'en_US').format(amount)}';
}

String formatDay(DateTime date, String localeName) {
  return toWesternDigits(DateFormat.yMMMd(localeName).format(date));
}

String formatMonth(DateTime date, String localeName) {
  return toWesternDigits(DateFormat.yMMMM(localeName).format(date));
}

/// Maps Arabic-Indic / Eastern Arabic digits to 0-9 after locale-aware
/// date formatting (month names stay translated).
String toWesternDigits(String value) {
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    final easternIndex = eastern.indexOf(char);
    if (easternIndex >= 0) {
      buffer.write(easternIndex);
      continue;
    }
    final persianIndex = persian.indexOf(char);
    if (persianIndex >= 0) {
      buffer.write(persianIndex);
      continue;
    }
    buffer.write(char);
  }
  return buffer.toString();
}
