import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/presentation/format.dart';

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

final currencySymbolProvider = StateProvider<String>(
  (ref) => kDefaultCurrencySymbol,
);

/// Optional From/To range narrowing the History screen. Null shows every
/// transaction, matching the screen's original behavior.
final historyDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Optional From/To range on the dashboard, replacing the selected-month
/// view (pie chart + list) while set. Null shows the usual whole-month view.
class DashboardDateRangeNotifier extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  void setRange(DateTimeRange range) {
    state = range;
    ref.read(categoryFilterProvider.notifier).clear();
  }

  void clear() {
    state = null;
    ref.read(categoryFilterProvider.notifier).clear();
  }
}

final dashboardDateRangeProvider =
    NotifierProvider<DashboardDateRangeNotifier, DateTimeRange?>(
      DashboardDateRangeNotifier.new,
    );

/// True when [date] falls within [range], inclusive of the whole end day
/// regardless of the transaction's time of day.
bool isInDateRange(DateTime date, DateTimeRange range) {
  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(
    range.end.year,
    range.end.month,
    range.end.day,
    23,
    59,
    59,
    999,
  );
  return !date.isBefore(start) && !date.isAfter(end);
}
