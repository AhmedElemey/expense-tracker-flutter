import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/expense.dart';

import 'app_providers.dart';
import 'dashboard_providers.dart';
import 'monthly_totals_provider.dart';

class TransactionsNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() {
    return ref.watch(getHistoryProvider)();
  }

  Future<Expense> add(Expense expense) async {
    final saved = await ref.read(addExpenseProvider)(expense);
    await _reload();
    return saved;
  }

  Future<void> edit(Expense expense) async {
    await ref.read(updateExpenseProvider)(expense);
    await _reload();
  }

  Future<void> delete(int id) async {
    await ref.read(deleteExpenseProvider)(id);
    await _reload();
  }

  Future<void> refresh() => _reload();

  Future<void> _reload() async {
    ref.invalidate(monthlyTotalsProvider);
    ref.invalidateSelf();
    await future;
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Expense>>(
      TransactionsNotifier.new,
    );

/// Dashboard list: selected month (or, if set, a custom date range),
/// optionally narrowed further by one category (pie-slice filter).
final filteredTransactionsProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final dateRange = ref.watch(dashboardDateRangeProvider);
  final category = ref.watch(categoryFilterProvider);
  return ref.watch(transactionsProvider).whenData((items) {
    return items.where((item) {
      final inDateWindow = dateRange != null
          ? isInDateRange(item.date, dateRange)
          : _inMonth(item.date, month);
      if (!inDateWindow) {
        return false;
      }
      if (category != null && item.category != category) {
        return false;
      }
      return true;
    }).toList();
  });
});

bool _inMonth(DateTime date, DateTime month) {
  final start = DateTime(month.year, month.month);
  final end = DateTime(month.year, month.month + 1);
  return !date.isBefore(start) && date.isBefore(end);
}
