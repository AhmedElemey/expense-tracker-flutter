import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expensetracker/domain/entities/expense.dart';
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

String historySectionLabel(DateTime keyDate, HistoryGrouping grouping) {
  return switch (grouping) {
    HistoryGrouping.day => DateFormat.yMMMd().format(keyDate),
    HistoryGrouping.month => DateFormat.yMMMM().format(keyDate),
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
    this.emptyMessage = 'No expenses yet.',
    this.nested = false,
  });

  final List<Expense> transactions;
  final HistoryGrouping grouping;
  final Future<void> Function()? onRefresh;
  final void Function(Expense transaction)? onEdit;
  final Future<void> Function(Expense transaction)? onDelete;
  final String emptyMessage;
  final bool nested;

  @override
  Widget build(BuildContext context) {
    final body = transactions.isEmpty ? _empty() : _sections();
    if (nested) {
      return body;
    }
    return RefreshIndicator(onRefresh: onRefresh ?? () async {}, child: body);
  }

  Widget _empty() {
    return ListView(
      shrinkWrap: nested,
      physics: nested
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 48),
        EmptyState(message: emptyMessage),
      ],
    );
  }

  Widget _sections() {
    final sections = groupTransactions(transactions, grouping);
    final children = [
      for (final section in sections)
        _HistorySectionView(
          label: historySectionLabel(section.keyDate, grouping),
          transactions: section.transactions,
          onEdit: onEdit,
          onDelete: onDelete,
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
    required this.transactions,
    this.onEdit,
    this.onDelete,
  });

  final String label;
  final List<Expense> transactions;
  final void Function(Expense transaction)? onEdit;
  final Future<void> Function(Expense transaction)? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (final transaction in transactions)
          TransactionListItem(
            transaction: transaction,
            onTap: onEdit == null ? null : () => onEdit!(transaction),
            onDelete: onDelete,
          ),
      ],
    );
  }
}
