import 'package:flutter/material.dart';

import 'package:expensetracker/domain/entities/account_balance.dart';
import 'package:expensetracker/presentation/account_l10n.dart';
import 'package:expensetracker/presentation/account_visuals.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/l10n/app_localizations.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.accountBalance,
    this.currencySymbol = kDefaultCurrencySymbol,
    this.onTap,
  });

  final AccountBalance accountBalance;
  final String currencySymbol;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final account = accountBalance.account;
    final color = Color(account.colorValue);
    final theme = Theme.of(context);
    return Opacity(
      opacity: account.archived ? 0.6 : 1,
      child: Card(
        key: Key('account-${account.id}'),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.18),
            child: Icon(account.type.icon, color: color),
          ),
          title: Text(account.name),
          subtitle: Text(
            account.archived
                ? '${account.type.localizedName(l10n)} · ${l10n.archivedLabel}'
                : account.type.localizedName(l10n),
          ),
          trailing: Text(
            formatAmount(accountBalance.balance, symbol: currencySymbol),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: accountBalance.balance < 0
                  ? theme.colorScheme.error
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
