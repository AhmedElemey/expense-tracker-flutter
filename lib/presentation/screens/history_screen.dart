import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/providers/transactions_provider.dart';
import 'package:expensetracker/presentation/screens/add_expense_screen.dart';
import 'package:expensetracker/presentation/widgets/empty_state.dart';
import 'package:expensetracker/presentation/widgets/transaction_list.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(transactionsProvider);
    final grouping = ref.watch(historyGroupingProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SegmentedButton<HistoryGrouping>(
                segments: [
                  ButtonSegment(
                    value: HistoryGrouping.day,
                    label: Text(l10n.groupByDay),
                    icon: const Icon(Icons.today),
                  ),
                  ButtonSegment(
                    value: HistoryGrouping.month,
                    label: Text(l10n.groupByMonth),
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
                selected: {grouping},
                onSelectionChanged: (selected) {
                  ref.read(historyGroupingProvider.notifier).state =
                      selected.first;
                },
              ),
            ),
          ),
          Expanded(
            child: history.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                message: l10n.couldNotLoadHistory(error),
                onRetry: () => ref.invalidate(transactionsProvider),
              ),
              data: (items) => TransactionList(
                transactions: items,
                grouping: grouping,
                currencySymbol: currencySymbol,
                markThisMonth: true,
                emptyMessage: l10n.noExpensesYet,
                onRefresh: () =>
                    ref.read(transactionsProvider.notifier).refresh(),
                onEdit: (transaction) =>
                    AddExpenseScreen.open(context, existing: transaction),
                onDelete: (expense) => _deleteWithUndo(context, ref, expense),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWithUndo(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final id = expense.id;
    if (id == null) {
      return;
    }
    await ref.read(transactionsProvider.notifier).delete(id);
    if (!context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.expenseDeleted),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          key: const Key('undo-delete'),
          label: l10n.undo,
          onPressed: () {
            ref
                .read(transactionsProvider.notifier)
                .add(expense.copyWith(id: null));
          },
        ),
      ),
    );
  }
}
