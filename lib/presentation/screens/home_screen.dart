import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/monthly_totals.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/category_l10n.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/presentation/providers/ads_tracking_provider.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/providers/monthly_totals_provider.dart';
import 'package:expensetracker/presentation/providers/transactions_provider.dart';
import 'package:expensetracker/presentation/screens/accounts_screen.dart';
import 'package:expensetracker/presentation/screens/add_expense_screen.dart';
import 'package:expensetracker/presentation/screens/history_screen.dart';
import 'package:expensetracker/presentation/screens/settings_screen.dart';
import 'package:expensetracker/presentation/widgets/category_pie_chart.dart';
import 'package:expensetracker/presentation/widgets/dashboard_banner_ad.dart';
import 'package:expensetracker/presentation/widgets/empty_state.dart';
import 'package:expensetracker/presentation/widgets/transaction_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final month = ref.watch(selectedMonthProvider);
    final filter = ref.watch(categoryFilterProvider);
    final totals = ref.watch(monthlyTotalsProvider);
    final filtered = ref.watch(filteredTransactionsProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    // First relevant screen: request ATT after consent, before personalized ads.
    ref.watch(adsTrackingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.accountsTitle,
            onPressed: () => AccountsScreen.open(context),
            icon: const Icon(Icons.credit_card_outlined),
          ),
          IconButton(
            tooltip: l10n.historyTooltip,
            onPressed: () => HistoryScreen.open(context),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: l10n.settingsTooltip,
            onPressed: () => SettingsScreen.open(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addExpenseTooltip,
        onPressed: () => AddExpenseScreen.open(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const DashboardBannerAd(),
      body: _body(
        context,
        ref,
        month,
        filter,
        totals,
        filtered,
        currencySymbol,
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    DateTime month,
    ExpenseCategory? filter,
    AsyncValue<MonthlyTotals> totals,
    AsyncValue<List<Expense>> filtered,
    String currencySymbol,
  ) {
    final l10n = AppLocalizations.of(context);
    if ((totals.isLoading && !totals.hasValue) ||
        (filtered.isLoading && !filtered.hasValue)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (totals.hasError && !totals.hasValue) {
      return ErrorState(
        message: l10n.couldNotLoadTotals(totals.error!),
        onRetry: () => _retry(ref),
      );
    }

    if (filtered.hasError && !filtered.hasValue) {
      return ErrorState(
        message: l10n.couldNotLoadExpenses(filtered.error!),
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
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
              child: Column(
                children: [
                  _MonthSelector(month: month),
                  const SizedBox(height: 16),
                  Text(
                    l10n.spentThisMonth,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    formatAmount(monthly.total, symbol: currencySymbol),
                    key: const Key('month-total'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CategoryPieChart(
                    totals: monthly.byCategory,
                    selected: filter,
                    currencySymbol: currencySymbol,
                    onCategoryTapped: (category) => ref
                        .read(categoryFilterProvider.notifier)
                        .toggle(category),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      filter == null
                          ? l10n.thisMonth
                          : l10n.categoryThisMonth(filter.localizedName(l10n)),
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
              currencySymbol: currencySymbol,
              emptyMessage: filter == null
                  ? l10n.noExpensesThisMonth
                  : l10n.noCategoryExpensesThisMonth(
                      filter.localizedName(l10n),
                    ),
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
    final l10n = AppLocalizations.of(context);
    final isCurrent = !calendarMonth(month).isBefore(calendarMonth());
    return Row(
      children: [
        IconButton(
          tooltip: l10n.previousMonthTooltip,
          onPressed: () => ref.read(selectedMonthProvider.notifier).previous(),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            formatMonth(month, Localizations.localeOf(context).toString()),
            key: const Key('selected-month'),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          tooltip: l10n.nextMonthTooltip,
          onPressed: isCurrent
              ? null
              : () => ref.read(selectedMonthProvider.notifier).next(),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
