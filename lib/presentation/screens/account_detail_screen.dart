import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/domain/entities/account_balance.dart';
import 'package:expensetracker/domain/entities/account_transfer.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/account_l10n.dart';
import 'package:expensetracker/presentation/account_visuals.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/presentation/providers/account_providers.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/screens/add_account_screen.dart';
import 'package:expensetracker/presentation/screens/add_transfer_screen.dart';
import 'package:expensetracker/presentation/widgets/empty_state.dart';
import 'package:expensetracker/presentation/widgets/transfer_list_item.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final int accountId;

  static Future<void> open(BuildContext context, {required int accountId}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountDetailScreen(accountId: accountId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountsProvider);
    final transfers = ref.watch(accountTransfersProvider(accountId));
    final currencySymbol = ref.watch(currencySymbolProvider);
    final dateRange = ref.watch(accountTransferDateRangeProvider(accountId));
    final localeName = Localizations.localeOf(context).toString();

    return accounts.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(message: l10n.couldNotLoadAccounts(error)),
      ),
      data: (list) {
        final match = list.where((a) => a.account.id == accountId);
        if (match.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(message: l10n.accountArchived),
          );
        }
        final accountBalance = match.first;
        final account = accountBalance.account;
        final accountsById = {for (final a in list) a.account.id!: a.account};

        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              IconButton(
                key: const Key('account-date-filter'),
                tooltip: l10n.filterByDateTooltip,
                icon: const Icon(Icons.date_range_outlined),
                onPressed: () => _pickDateRange(context, ref, dateRange),
              ),
              IconButton(
                tooltip: l10n.editAccountTitle,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    AddAccountScreen.open(context, existing: account),
              ),
              IconButton(
                tooltip: account.archived
                    ? l10n.unarchiveAccount
                    : l10n.archiveAccount,
                icon: Icon(
                  account.archived
                      ? Icons.unarchive_outlined
                      : Icons.archive_outlined,
                ),
                onPressed: () => _toggleArchived(context, ref, account),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: l10n.addTransferTitle,
            onPressed: () =>
                AddTransferScreen.open(context, fromAccountId: accountId),
            child: const Icon(Icons.add),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.read(accountsProvider.notifier).refresh();
              ref.invalidate(accountTransfersProvider(accountId));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _BalanceHeader(
                    accountBalance: accountBalance,
                    currencySymbol: currencySymbol,
                  ),
                ),
                if (dateRange != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        0,
                        16,
                        8,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Chip(
                          key: const Key('account-date-filter-chip'),
                          avatar: const Icon(
                            Icons.date_range_outlined,
                            size: 18,
                          ),
                          label: Text(
                            '${formatDay(dateRange.start, localeName)} – '
                            '${formatDay(dateRange.end, localeName)}',
                          ),
                          onDeleted: () => ref
                              .read(
                                accountTransferDateRangeProvider(
                                  accountId,
                                ).notifier,
                              )
                              .state = null,
                          deleteButtonTooltipMessage:
                              l10n.clearDateFilterTooltip,
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: transfers.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => ErrorState(
                      message: l10n.couldNotLoadTransfers(error),
                    ),
                    data: (items) {
                      final filtered = dateRange == null
                          ? items
                          : items
                                .where(
                                  (t) => isInDateRange(t.date, dateRange),
                                )
                                .toList();
                      return _TransferList(
                        items: filtered,
                        accountId: accountId,
                        accountsById: accountsById,
                        currencySymbol: currencySymbol,
                        emptyMessage: dateRange == null
                            ? l10n.noTransfersYet
                            : l10n.noTransfersInRange,
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 88)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleArchived(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    await ref
        .read(accountsProvider.notifier)
        .setArchived(account.id!, !account.archived);
    if (!context.mounted) {
      return;
    }
    if (!account.archived) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDateRange(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange? current,
  ) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5, 12, 31),
      initialDateRange: current,
    );
    if (picked == null) {
      return;
    }
    ref.read(accountTransferDateRangeProvider(accountId).notifier).state =
        picked;
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({
    required this.accountBalance,
    required this.currencySymbol,
  });

  final AccountBalance accountBalance;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final account = accountBalance.account;
    final balance = accountBalance.balance;
    final color = Color(account.colorValue);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.18),
            child: Icon(account.type.icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(account.type.localizedName(l10n), style: theme.textTheme.bodyMedium),
          Text(
            formatAmount(balance, symbol: currencySymbol),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: balance < 0 ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferList extends ConsumerWidget {
  const _TransferList({
    required this.items,
    required this.accountId,
    required this.accountsById,
    required this.currencySymbol,
    required this.emptyMessage,
  });

  final List<AccountTransfer> items;
  final int accountId;
  final Map<int, Account> accountsById;
  final String currencySymbol;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: EmptyState(message: emptyMessage),
      );
    }
    return Column(
      children: [
        for (final transfer in items)
          TransferListItem(
            transfer: transfer,
            viewingAccountId: accountId,
            accountsById: accountsById,
            currencySymbol: currencySymbol,
            onDelete: (transfer) => ref
                .read(accountTransfersProvider(accountId).notifier)
                .delete(transfer),
          ),
      ],
    );
  }
}
