import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/monthly_totals.dart';

import 'app_providers.dart';
import 'dashboard_providers.dart';
import 'transactions_provider.dart';

final monthlyTotalsProvider = FutureProvider<MonthlyTotals>((ref) async {
  final dateRange = ref.watch(dashboardDateRangeProvider);
  if (dateRange != null) {
    final items = await ref.watch(transactionsProvider.future);
    final byCategory = <ExpenseCategory, double>{};
    for (final item in items) {
      if (!isInDateRange(item.date, dateRange)) {
        continue;
      }
      byCategory[item.category] = (byCategory[item.category] ?? 0) + item.amount;
    }
    return MonthlyTotals(month: dateRange.start, byCategory: byCategory);
  }
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(getMonthlyTotalsProvider)(month);
});
