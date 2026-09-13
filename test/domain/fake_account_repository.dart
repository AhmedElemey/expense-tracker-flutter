import 'package:expensetracker/domain/account_validation.dart';
import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/domain/entities/account_balance.dart';
import 'package:expensetracker/domain/entities/account_transfer.dart';
import 'package:expensetracker/domain/repositories/account_repository.dart';

class FakeAccountRepository implements AccountRepository {
  final List<Account> accounts = [];
  final List<AccountTransfer> transfers = [];
  final Map<int, int> expenseAccounts = {};
  int _nextAccountId = 1;
  int _nextTransferId = 1;

  @override
  Future<int> insertAccount(Account account) async {
    validateAccountName(account.name);
    final id = _nextAccountId++;
    accounts.add(account.copyWith(id: id));
    return id;
  }

  @override
  Future<int> updateAccount(Account account) async {
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index == -1) {
      return 0;
    }
    accounts[index] = account;
    return 1;
  }

  @override
  Future<int> setAccountArchived(int id, bool archived) async {
    final index = accounts.indexWhere((a) => a.id == id);
    if (index == -1) {
      return 0;
    }
    accounts[index] = accounts[index].copyWith(archived: archived);
    return 1;
  }

  @override
  Future<List<AccountBalance>> getAccounts({
    bool includeArchived = false,
  }) async {
    return accounts
        .where((a) => includeArchived || !a.archived)
        .map((a) => AccountBalance(account: a, balance: _balanceOf(a.id!)))
        .toList();
  }

  double _balanceOf(int accountId) {
    var balance =
        accounts.firstWhere((a) => a.id == accountId).initialBalance;
    for (final transfer in transfers) {
      if (transfer.toAccountId == accountId) {
        balance += transfer.amount;
      }
      if (transfer.fromAccountId == accountId) {
        balance -= transfer.amount;
      }
    }
    return balance;
  }

  @override
  Future<int> insertTransfer(AccountTransfer transfer) async {
    validateTransferAmount(transfer.amount);
    validateTransferTarget(
      fromAccountId: transfer.fromAccountId,
      toAccountId: transfer.toAccountId,
      toPersonName: transfer.toPersonName,
    );
    final id = _nextTransferId++;
    transfers.add(transfer.copyWith(id: id));
    return id;
  }

  @override
  Future<int> deleteTransfer(int id) async {
    final before = transfers.length;
    transfers.removeWhere((t) => t.id == id);
    return before - transfers.length;
  }

  @override
  Future<List<AccountTransfer>> getTransfersForAccount(int accountId) async {
    return transfers
        .where(
          (t) => t.fromAccountId == accountId || t.toAccountId == accountId,
        )
        .toList();
  }

  @override
  Future<void> setExpenseAccount(int transactionId, int? accountId) async {
    if (accountId == null) {
      expenseAccounts.remove(transactionId);
      return;
    }
    expenseAccounts[transactionId] = accountId;
  }

  @override
  Future<int?> getExpenseAccount(int transactionId) async {
    return expenseAccounts[transactionId];
  }
}
