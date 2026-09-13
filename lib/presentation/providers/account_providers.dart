import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/data/receipts/receipt_storage.dart';
import 'package:expensetracker/data/repositories/sqlite_account_repository.dart';
import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/domain/entities/account_balance.dart';
import 'package:expensetracker/domain/entities/account_transfer.dart';
import 'package:expensetracker/domain/repositories/account_repository.dart';
import 'package:expensetracker/domain/usecases/add_account.dart';
import 'package:expensetracker/domain/usecases/add_transfer.dart';
import 'package:expensetracker/domain/usecases/delete_transfer.dart';
import 'package:expensetracker/domain/usecases/get_account_transfers.dart';
import 'package:expensetracker/domain/usecases/get_accounts.dart';
import 'package:expensetracker/domain/usecases/get_expense_account.dart';
import 'package:expensetracker/domain/usecases/set_account_archived.dart';
import 'package:expensetracker/domain/usecases/set_expense_account.dart';
import 'package:expensetracker/domain/usecases/update_account.dart';

import 'app_providers.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return SqliteAccountRepository(ref.watch(expenseDatabaseProvider));
});

final receiptStorageProvider = Provider<ReceiptStorage>((ref) {
  return const ReceiptStorage();
});

final addAccountProvider = Provider<AddAccount>((ref) {
  return AddAccount(ref.watch(accountRepositoryProvider));
});

final updateAccountProvider = Provider<UpdateAccount>((ref) {
  return UpdateAccount(ref.watch(accountRepositoryProvider));
});

final setAccountArchivedProvider = Provider<SetAccountArchived>((ref) {
  return SetAccountArchived(ref.watch(accountRepositoryProvider));
});

final getAccountsProvider = Provider<GetAccounts>((ref) {
  return GetAccounts(ref.watch(accountRepositoryProvider));
});

final addTransferProvider = Provider<AddTransfer>((ref) {
  return AddTransfer(ref.watch(accountRepositoryProvider));
});

final deleteTransferProvider = Provider<DeleteTransfer>((ref) {
  return DeleteTransfer(ref.watch(accountRepositoryProvider));
});

final getAccountTransfersProvider = Provider<GetAccountTransfers>((ref) {
  return GetAccountTransfers(ref.watch(accountRepositoryProvider));
});

final setExpenseAccountProvider = Provider<SetExpenseAccount>((ref) {
  return SetExpenseAccount(ref.watch(accountRepositoryProvider));
});

final getExpenseAccountProvider = Provider<GetExpenseAccount>((ref) {
  return GetExpenseAccount(ref.watch(accountRepositoryProvider));
});

final showArchivedAccountsProvider = StateProvider<bool>((ref) => false);

class AccountsNotifier extends AsyncNotifier<List<AccountBalance>> {
  @override
  Future<List<AccountBalance>> build() {
    final includeArchived = ref.watch(showArchivedAccountsProvider);
    return ref.watch(getAccountsProvider)(includeArchived: includeArchived);
  }

  Future<Account> add(Account account) async {
    final saved = await ref.read(addAccountProvider)(account);
    await refresh();
    return saved;
  }

  Future<void> edit(Account account) async {
    await ref.read(updateAccountProvider)(account);
    await refresh();
  }

  Future<void> setArchived(int id, bool archived) async {
    await ref.read(setAccountArchivedProvider)(id, archived);
    await refresh();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<AccountBalance>>(
      AccountsNotifier.new,
    );

/// Non-archived accounts only, regardless of [showArchivedAccountsProvider]
/// — for pickers where paying from / transferring into a retired account
/// would not make sense.
final activeAccountsProvider = Provider<AsyncValue<List<AccountBalance>>>((
  ref,
) {
  return ref
      .watch(accountsProvider)
      .whenData(
        (accounts) => accounts.where((a) => !a.account.archived).toList(),
      );
});

/// Sum of every active account's live balance.
final totalBalanceProvider = Provider<AsyncValue<double>>((ref) {
  return ref
      .watch(activeAccountsProvider)
      .whenData(
        (accounts) => accounts.fold<double>(0, (sum, a) => sum + a.balance),
      );
});

class AccountTransfersNotifier
    extends FamilyAsyncNotifier<List<AccountTransfer>, int> {
  @override
  Future<List<AccountTransfer>> build(int arg) {
    return ref.watch(getAccountTransfersProvider)(arg);
  }

  Future<AccountTransfer> add(AccountTransfer transfer) async {
    final saved = await ref.read(addTransferProvider)(transfer);
    await _reload();
    _invalidateOtherAccount(transfer.toAccountId);
    return saved;
  }

  Future<void> delete(AccountTransfer transfer) async {
    final id = transfer.id;
    if (id == null) {
      return;
    }
    await ref.read(deleteTransferProvider)(id);
    await _reload();
    _invalidateOtherAccount(transfer.toAccountId);
  }

  void _invalidateOtherAccount(int? otherAccountId) {
    ref.invalidate(accountsProvider);
    if (otherAccountId != null && otherAccountId != arg) {
      ref.invalidate(accountTransfersProvider(otherAccountId));
    }
  }

  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final accountTransfersProvider = AsyncNotifierProvider.family<
  AccountTransfersNotifier,
  List<AccountTransfer>,
  int
>(AccountTransfersNotifier.new);

/// Optional From/To range narrowing one account's transfer list on its
/// detail screen. Keyed per account so switching accounts doesn't carry a
/// filter over, and independent of the History screen's own date filter.
final accountTransferDateRangeProvider =
    StateProvider.family<DateTimeRange?, int>((ref, accountId) => null);
