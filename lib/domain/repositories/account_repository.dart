import '../entities/account.dart';
import '../entities/account_balance.dart';
import '../entities/account_transfer.dart';

abstract class AccountRepository {
  Future<int> insertAccount(Account account);

  Future<int> updateAccount(Account account);

  Future<int> setAccountArchived(int id, bool archived);

  /// Accounts with their live balance, oldest first. Archived accounts are
  /// excluded unless [includeArchived] is true.
  Future<List<AccountBalance>> getAccounts({bool includeArchived = false});

  Future<int> insertTransfer(AccountTransfer transfer);

  Future<int> deleteTransfer(int id);

  /// Newest first, both incoming and outgoing transfers for [accountId].
  Future<List<AccountTransfer>> getTransfersForAccount(int accountId);

  /// Links an expense (`transactions` row) to the account it was paid from.
  /// Pass `null` for [accountId] to clear the link.
  Future<void> setExpenseAccount(int transactionId, int? accountId);

  Future<int?> getExpenseAccount(int transactionId);
}
