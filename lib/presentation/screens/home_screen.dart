import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/monthly_totals.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/providers/monthly_totals_provider.dart';
import 'package:expensetracker/presentation/providers/transactions_provider.dart';
import 'package:expensetracker/presentation/screens/add_expense_screen.dart';
import 'package:expensetracker/presentation/screens/history_screen.dart';
import 'package:expensetracker/presentation/widgets/category_pie_chart.dart';
import 'package:expensetracker/presentation/widgets/empty_state.dart';
import 'package:expensetracker/presentation/widgets/transaction_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final filter = ref.watch(categoryFilterProvider);
    final totals = ref.watch(monthlyTotalsProvider);
    final filtered = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ExpenseTracker'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => HistoryScreen.open(context),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add expense',
        onPressed: () => AddExpenseScreen.open(context),
        child: const Icon(Icons.add),
      ),
      body: _body(context, ref, month, filter, totals, filtered),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    DateTime month,
    ExpenseCategory? filter,
    AsyncValue<MonthlyTotals> totals,
    AsyncValue<List<Expense>> filtered,
  ) {
    if ((totals.isLoading && !totals.hasValue) ||
        (filtered.isLoading && !filtered.hasValue)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (totals.hasError && !totals.hasValue) {
      return ErrorState(
        message: 'Could not load totals: ${totals.error}',
        onRetry: () => _retry(ref),
      );
    }

    if (filtered.hasError && !filtered.hasValue) {
      return ErrorState(
        message: 'Could not load expenses: ${filtered.error}',
        onRetry: () => _retry(ref),
      );
    }

    final monthly = totals.requireValue;
    final items = filtered.requireValue;

    return RefreshIndicator(
      onRefresh: () => ref.read(transactionsProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  _MonthSelector(month: month),
                  const SizedBox(height: 16),
                  Text(
                    'Spent this month',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    formatAmount(monthly.total),
                    key: const Key('month-total'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CategoryPieChart(
                    totals: monthly.byCategory,
                    selected: filter,
                    onCategoryTapped: (category) => ref
                        .read(categoryFilterProvider.notifier)
                        .toggle(category),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      filter == null
                          ? 'This month'
                          : '${filter.label} this month',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: TransactionList(
              nested: true,
              transactions: items,
              grouping: HistoryGrouping.day,
              emptyMessage: filter == null
                  ? 'No expenses this month.\nTap + to add one.'
                  : 'No ${filter.label.toLowerCase()} expenses this month.',
              onEdit: (transaction) =>
                  AddExpenseScreen.open(context, existing: transaction),
              onDelete: (transaction) => ref
                  .read(transactionsProvider.notifier)
                  .delete(transaction.id!),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
    );
  }

  void _retry(WidgetRef ref) {
    ref.invalidate(transactionsProvider);
    ref.invalidate(monthlyTotalsProvider);
  }
}

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrent = !calendarMonth(month).isBefore(calendarMonth());
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: () => ref.read(selectedMonthProvider.notifier).previous(),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            DateFormat.yMMMM().format(month),
            key: const Key('selected-month'),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: isCurrent
              ? null
              : () => ref.read(selectedMonthProvider.notifier).next(),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
