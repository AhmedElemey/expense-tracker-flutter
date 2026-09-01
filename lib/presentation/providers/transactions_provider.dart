import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/transaction.dart';

import 'app_providers.dart';
import 'dashboard_providers.dart';
import 'monthly_totals_provider.dart';

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() {
    return ref.watch(getHistoryProvider)();
  }

  Future<void> add(Transaction expense) async {
    await ref.read(addExpenseProvider)(expense);
    await _reload();
  }

  Future<void> edit(Transaction expense) async {
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
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
      TransactionsNotifier.new,
    );

/// Dashboard list: selected month, optionally one category (pie-slice filter).
final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((
  ref,
) {
  final month = ref.watch(selectedMonthProvider);
  final category = ref.watch(categoryFilterProvider);
  return ref.watch(transactionsProvider).whenData((items) {
    return items.where((item) {
      if (!_inMonth(item.date, month)) {
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
