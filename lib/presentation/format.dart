import 'package:intl/intl.dart';

const kDefaultCurrencySymbol = r'$';

const kCurrencySymbols = <String>[r'$', '€', '£', '¥'];

String formatAmount(
  double amount, {
  String symbol = kDefaultCurrencySymbol,
}) {
  return '$symbol${NumberFormat('#,##0.00').format(amount)}';
}
