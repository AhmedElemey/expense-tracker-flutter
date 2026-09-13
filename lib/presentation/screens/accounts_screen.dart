import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/presentation/providers/account_providers.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/screens/account_detail_screen.dart';
import 'package:expensetracker/presentation/screens/add_account_screen.dart';
import 'package:expensetracker/presentation/widgets/account_card.dart';
import 'package:expensetracker/presentation/widgets/empty_state.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AccountsScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final showArchived = ref.watch(showArchivedAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountsTitle),
        actions: [
          IconButton(
            tooltip: showArchived
                ? l10n.hideArchivedAccounts
                : l10n.showArchivedAccounts,
            onPressed: () => ref
                .read(showArchivedAccountsProvider.notifier)
                .state = !showArchived,
            icon: Icon(
              showArchived ? Icons.archive : Icons.archive_outlined,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addAccountTitle,
        onPressed: () => AddAccountScreen.open(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
        child: accounts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 48),
              EmptyState(
                icon: Icons.error_outline,
                message: l10n.couldNotLoadAccounts(error),
              ),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 48),
                  EmptyState(
                    icon: Icons.credit_card_outlined,
                    message: l10n.noAccountsYet,
                  ),
                ],
              );
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        l10n.totalBalance,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        formatAmount(
                          totalBalance.valueOrNull ?? 0,
                          symbol: currencySymbol,
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final accountBalance in list)
                  AccountCard(
                    accountBalance: accountBalance,
                    currencySymbol: currencySymbol,
                    onTap: () => AccountDetailScreen.open(
                      context,
                      accountId: accountBalance.account.id!,
                    ),
                  ),
                const SizedBox(height: 88),
              ],
            );
          },
        ),
      ),
    );
  }
}
