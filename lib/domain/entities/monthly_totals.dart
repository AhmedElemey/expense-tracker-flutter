import 'expense_category.dart';

/// Spend for one calendar month, broken down by category.
class MonthlyTotals {
  const MonthlyTotals({required this.month, required this.byCategory});

  /// First day of the month these totals cover.
  final DateTime month;

  final Map<ExpenseCategory, double> byCategory;

  double get total => byCategory.values.fold(0.0, (sum, value) => sum + value);
}
