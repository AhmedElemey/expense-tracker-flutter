import 'package:flutter/material.dart';

import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/category_l10n.dart';
import 'package:expensetracker/presentation/category_visuals.dart';
import 'package:expensetracker/presentation/format.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    this.currencySymbol = kDefaultCurrencySymbol,
    this.onTap,
    this.onDelete,
  });

  final Expense transaction;
  final String currencySymbol;
  final VoidCallback? onTap;
  final Future<void> Function(Expense transaction)? onDelete;

  @override
  Widget build(BuildContext context) {
    final category = transaction.category;
    final note = transaction.note?.trim();
    final hasNote = note != null && note.isNotEmpty;
    final l10n = AppLocalizations.of(context);
    final categoryName = category.displayName(
      l10n,
      customCategory: transaction.customCategory,
    );
    final dateLabel = formatDay(
      transaction.date,
      Localizations.localeOf(context).toString(),
    );
    final tile = ListTile(
      leading: CircleAvatar(
        backgroundColor: category.color.withValues(alpha: 0.18),
        child: Icon(category.icon, color: category.color),
      ),
      title: Text(hasNote ? note : categoryName),
      subtitle: Text([if (hasNote) categoryName, dateLabel].join(' · ')),
      trailing: Text(
        formatAmount(transaction.amount, symbol: currencySymbol),
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
        alignment: AlignmentDirectional.centerEnd,
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
