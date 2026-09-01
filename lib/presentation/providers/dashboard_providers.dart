import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';

/// How the history list is sectioned.
enum HistoryGrouping { day, month }

DateTime calendarMonth([DateTime? date]) {
  final value = date ?? DateTime.now();
  return DateTime(value.year, value.month);
}

final historyGroupingProvider = StateProvider<HistoryGrouping>(
  (ref) => HistoryGrouping.day,
);

class CategoryFilterNotifier extends Notifier<ExpenseCategory?> {
  @override
  ExpenseCategory? build() => null;

  /// Tap a pie slice: select it, or clear if it is already selected.
  void toggle(ExpenseCategory category) {
    state = state == category ? null : category;
  }

  void clear() => state = null;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, ExpenseCategory?>(
      CategoryFilterNotifier.new,
    );

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => calendarMonth();

  void previous() => setMonth(DateTime(state.year, state.month - 1));

  void next() => setMonth(DateTime(state.year, state.month + 1));

  void setMonth(DateTime month) {
    state = calendarMonth(month);
    ref.read(categoryFilterProvider.notifier).clear();
  }
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(
  SelectedMonthNotifier.new,
);
