import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/expense.dart';
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
    final history = ref.watch(transactionsProvider);
    final grouping = ref.watch(historyGroupingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<HistoryGrouping>(
                segments: const [
                  ButtonSegment(
                    value: HistoryGrouping.day,
                    label: Text('Day'),
                    icon: Icon(Icons.today),
                  ),
                  ButtonSegment(
                    value: HistoryGrouping.month,
                    label: Text('Month'),
                    icon: Icon(Icons.calendar_month),
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
                message: 'Could not load history: $error',
                onRetry: () => ref.invalidate(transactionsProvider),
              ),
              data: (items) => TransactionList(
                transactions: items,
                grouping: grouping,
                emptyMessage: 'No expenses yet.\nAdd one from the home screen.',
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          key: const Key('undo-delete'),
          label: 'Undo',
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
