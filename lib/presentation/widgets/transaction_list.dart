import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/widgets/empty_state.dart';
import 'package:expensetracker/presentation/widgets/transaction_list_item.dart';

class HistorySection {
  const HistorySection({required this.keyDate, required this.transactions});

  final DateTime keyDate;
  final List<Expense> transactions;
}

/// Groups already-sorted (newest first) transactions by day or month.
List<HistorySection> groupTransactions(
  List<Expense> items,
  HistoryGrouping grouping,
) {
  final grouped = <DateTime, List<Expense>>{};
  for (final item in items) {
    final key = switch (grouping) {
      HistoryGrouping.day => DateTime(
        item.date.year,
        item.date.month,
        item.date.day,
      ),
      HistoryGrouping.month => DateTime(item.date.year, item.date.month),
    };
    grouped.putIfAbsent(key, () => []).add(item);
  }
  return [
    for (final entry in grouped.entries)
      HistorySection(keyDate: entry.key, transactions: entry.value),
  ];
}

String historySectionLabel(
  DateTime keyDate,
  HistoryGrouping grouping, [
  String? localeName,
]) {
  final locale = localeName ?? Intl.getCurrentLocale();
  return switch (grouping) {
    HistoryGrouping.day => formatDay(keyDate, locale),
    HistoryGrouping.month => formatMonth(keyDate, locale),
  };
}

class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    required this.grouping,
    this.onRefresh,
    this.onEdit,
    this.onDelete,
    this.emptyMessage,
    this.nested = false,
    this.currencySymbol = kDefaultCurrencySymbol,
    this.markThisMonth = false,
  });

  final List<Expense> transactions;
  final HistoryGrouping grouping;
  final Future<void> Function()? onRefresh;
  final void Function(Expense transaction)? onEdit;
  final Future<void> Function(Expense transaction)? onDelete;
  final String? emptyMessage;
  final bool nested;
  final String currencySymbol;
  final bool markThisMonth;

  @override
  Widget build(BuildContext context) {
    final body = transactions.isEmpty ? _empty(context) : _sections(context);
    if (nested) {
      return body;
    }
    return RefreshIndicator(onRefresh: onRefresh ?? () async {}, child: body);
  }

  Widget _empty(BuildContext context) {
    return ListView(
      shrinkWrap: nested,
      physics: nested
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 48),
        EmptyState(
          message: emptyMessage ?? AppLocalizations.of(context).noExpensesYet,
        ),
      ],
    );
  }

  Widget _sections(BuildContext context) {
    final sections = groupTransactions(transactions, grouping);
    final children = [
      for (final section in sections)
        _HistorySectionView(
          label: historySectionLabel(
            section.keyDate,
            grouping,
            Localizations.localeOf(context).toString(),
          ),
          keyDate: section.keyDate,
          transactions: section.transactions,
          onEdit: onEdit,
          onDelete: onDelete,
          currencySymbol: currencySymbol,
          isThisMonth: markThisMonth &&
              calendarMonth(section.keyDate) == calendarMonth(),
        ),
    ];

    if (nested) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _HistorySectionView extends StatelessWidget {
  const _HistorySectionView({
    required this.label,
    required this.keyDate,
    required this.transactions,
    this.onEdit,
    this.onDelete,
    required this.currencySymbol,
    this.isThisMonth = false,
  });

  final String label;
  final DateTime keyDate;
  final List<Expense> transactions;
  final void Function(Expense transaction)? onEdit;
  final Future<void> Function(Expense transaction)? onDelete;
  final String currencySymbol;
  final bool isThisMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: isThisMonth
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.28)
          : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isThisMonth)
                  Chip(
                    key: ValueKey(
                      'this-month-badge-${keyDate.millisecondsSinceEpoch}',
                    ),
                    visualDensity: VisualDensity.compact,
                    label: Text(AppLocalizations.of(context).thisMonth),
                    padding: EdgeInsets.zero,
                    side: BorderSide.none,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          for (final transaction in transactions)
            TransactionListItem(
              transaction: transaction,
              currencySymbol: currencySymbol,
              onTap: onEdit == null ? null : () => onEdit!(transaction),
              onDelete: onDelete,
            ),
        ],
      ),
    );
  }
}
