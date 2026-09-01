import 'package:intl/intl.dart';

String formatAmount(double amount) => NumberFormat('#,##0.00').format(amount);
