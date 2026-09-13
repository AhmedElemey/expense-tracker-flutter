import 'dart:io';

import 'package:flutter/material.dart';

import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/domain/entities/account_transfer.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/format.dart';

class TransferListItem extends StatelessWidget {
  const TransferListItem({
    super.key,
    required this.transfer,
    required this.viewingAccountId,
    this.accountsById = const {},
    this.currencySymbol = kDefaultCurrencySymbol,
    this.onDelete,
  });

  final AccountTransfer transfer;
  final int viewingAccountId;
  final Map<int, Account> accountsById;
  final String currencySymbol;
  final Future<void> Function(AccountTransfer transfer)? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isOutgoing = transfer.fromAccountId == viewingAccountId;
    final counterpartName = transfer.isToPerson
        ? (transfer.toPersonName ?? l10n.transferToPerson)
        : (isOutgoing
              ? accountsById[transfer.toAccountId]?.name ?? l10n.accountTypeCard
              : accountsById[transfer.fromAccountId]?.name ??
                    l10n.accountTypeCard);
    final dateLabel =
        '${formatDay(transfer.date, Localizations.localeOf(context).toString())} '
        '${TimeOfDay.fromDateTime(transfer.date).format(context)}';
    final amountText =
        '${isOutgoing ? '-' : '+'}${formatAmount(transfer.amount, symbol: currencySymbol)}';

    final tile = ListTile(
      leading: CircleAvatar(
        backgroundColor: (isOutgoing ? theme.colorScheme.error : theme.colorScheme.primary)
            .withValues(alpha: 0.14),
        child: Icon(
          transfer.isToPerson
              ? Icons.person_outline
              : (isOutgoing ? Icons.call_made : Icons.call_received),
          color: isOutgoing ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
      ),
      title: Text(
        isOutgoing
            ? l10n.transferToName(counterpartName)
            : l10n.transferFromName(counterpartName),
      ),
      subtitle: Text(
        [dateLabel, if ((transfer.note ?? '').trim().isNotEmpty) transfer.note!.trim()]
            .join(' · '),
      ),
      trailing: Text(
        amountText,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isOutgoing ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
      ),
      onTap: transfer.receiptImagePath == null
          ? null
          : () => _showReceipt(context, transfer.receiptImagePath!),
    );

    final id = transfer.id;
    if (id == null || onDelete == null) {
      return tile;
    }

    return Dismissible(
      key: ValueKey('transfer-$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        try {
          await onDelete!(transfer);
          return true;
        } catch (_) {
          return false;
        }
      },
      child: tile,
    );
  }

  void _showReceipt(BuildContext context, String path) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(child: Image.file(File(path))),
      ),
    );
  }
}
