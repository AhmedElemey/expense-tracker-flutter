import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/presentation/format.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  final Expense transaction;
  final VoidCallback? onTap;
  final Future<void> Function(Expense transaction)? onDelete;

  @override
  Widget build(BuildContext context) {
    final category = transaction.category;
    final note = transaction.note?.trim();
    final hasNote = note != null && note.isNotEmpty;
    final dateLabel = DateFormat.yMMMd().format(transaction.date);
    final tile = ListTile(
      leading: CircleAvatar(
        backgroundColor: category.color.withValues(alpha: 0.18),
        child: Icon(category.icon, color: category.color),
      ),
      title: Text(hasNote ? note : category.label),
      subtitle: Text([if (hasNote) category.label, dateLabel].join(' · ')),
      trailing: Text(
        formatAmount(transaction.amount),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );

    final id = transaction.id;
    if (id == null || onDelete == null) {
      return tile;
    }

    return Dismissible(
      key: ValueKey('transaction-$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        try {
          await onDelete!(transaction);
          return true;
        } catch (_) {
          return false;
        }
      },
      child: tile,
    );
  }
}
