import 'package:intl/intl.dart';

import 'package:expensetracker/l10n/app_localizations.dart';

const kDefaultCurrencySymbol = 'E£';

class AppCurrency {
  const AppCurrency({required this.symbol, required this.id});

  final String symbol;
  final String id;

  String localizedName(AppLocalizations l10n) {
    return switch (id) {
      'egp' => l10n.currencyEgyptianPound,
      'usd' => l10n.currencyDollar,
      'eur' => l10n.currencyEuro,
      'gbp' => l10n.currencyPound,
      'jpy' => l10n.currencyYen,
      _ => symbol,
    };
  }

  String chipLabel(AppLocalizations l10n) => '${localizedName(l10n)} $symbol';
}

const kCurrencies = <AppCurrency>[
  AppCurrency(symbol: 'E£', id: 'egp'),
  AppCurrency(symbol: r'$', id: 'usd'),
  AppCurrency(symbol: '€', id: 'eur'),
  AppCurrency(symbol: '£', id: 'gbp'),
  AppCurrency(symbol: '¥', id: 'jpy'),
];

/// Currency amounts always use Western digits so they stay readable next to
/// the selected currency symbol, regardless of the UI locale.
String formatAmount(double amount, {String symbol = kDefaultCurrencySymbol}) {
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
