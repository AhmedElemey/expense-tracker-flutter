import 'package:sqflite/sqflite.dart';

import 'package:expensetracker/domain/account_validation.dart';
import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/domain/entities/account_balance.dart';
import 'package:expensetracker/domain/entities/account_transfer.dart';
import 'package:expensetracker/domain/repositories/account_repository.dart';

import '../database/expense_database.dart';

/// SQLite-backed [AccountRepository].
class SqliteAccountRepository implements AccountRepository {
  SqliteAccountRepository(this._database);

  final ExpenseDatabase _database;

  Future<Database> get _db => _database.database;

  @override
  Future<int> insertAccount(Account account) async {
    validateAccountName(account.name);
    return (await _db).insert(kAccountsTable, _accountToMap(account)..remove(
      AccountColumns.id,
    ));
  }

  @override
  Future<int> updateAccount(Account account) async {
    final id = account.id;
    if (id == null) {
      throw ArgumentError('updateAccount requires a persisted id');
    }
    validateAccountName(account.name);
    return (await _db).update(
      kAccountsTable,
      _accountToMap(account)..remove(AccountColumns.id),
      where: '${AccountColumns.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> setAccountArchived(int id, bool archived) async {
    return (await _db).update(
      kAccountsTable,
      {AccountColumns.archived: archived ? 1 : 0},
      where: '${AccountColumns.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<AccountBalance>> getAccounts({
    bool includeArchived = false,
  }) async {
    final rows = await (await _db).rawQuery('''
SELECT
  a.${AccountColumns.id} AS id,
  a.${AccountColumns.name} AS name,
  a.${AccountColumns.type} AS type,
  a.${AccountColumns.initialBalance} AS initial_balance,
  a.${AccountColumns.colorValue} AS color_value,
  a.${AccountColumns.archived} AS archived,
  a.${AccountColumns.createdAt} AS created_at,
  a.${AccountColumns.initialBalance}
    + COALESCE((
        SELECT SUM(${AccountTransferColumns.amount})
        FROM $kAccountTransfersTable
        WHERE ${AccountTransferColumns.toAccountId} = a.${AccountColumns.id}
      ), 0)
    - COALESCE((
        SELECT SUM(${AccountTransferColumns.amount})
        FROM $kAccountTransfersTable
        WHERE ${AccountTransferColumns.fromAccountId} = a.${AccountColumns.id}
      ), 0)
    - COALESCE((
        SELECT SUM(t.${TransactionColumns.amount})
        FROM $kTransactionsTable t
        JOIN $kTransactionAccountsTable ta
          ON ta.${TransactionAccountColumns.transactionId} = t.${TransactionColumns.id}
        WHERE ta.${TransactionAccountColumns.accountId} = a.${AccountColumns.id}
      ), 0) AS balance
FROM $kAccountsTable a
WHERE (? = 1 OR a.${AccountColumns.archived} = 0)
ORDER BY a.${AccountColumns.createdAt} ASC, a.${AccountColumns.id} ASC
''', [includeArchived ? 1 : 0]);
    return rows.map(_accountBalanceFromRow).toList();
  }

  @override
  Future<int> insertTransfer(AccountTransfer transfer) async {
    validateTransferAmount(transfer.amount);
    validateTransferTarget(
      fromAccountId: transfer.fromAccountId,
      toAccountId: transfer.toAccountId,
      toPersonName: transfer.toPersonName,
    );
    return (await _db).insert(
      kAccountTransfersTable,
      _transferToMap(transfer)..remove(AccountTransferColumns.id),
    );
  }

  @override
  Future<int> deleteTransfer(int id) async {
    return (await _db).delete(
      kAccountTransfersTable,
      where: '${AccountTransferColumns.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<AccountTransfer>> getTransfersForAccount(int accountId) async {
    final rows = await (await _db).query(
      kAccountTransfersTable,
      where:
          '${AccountTransferColumns.fromAccountId} = ? OR '
          '${AccountTransferColumns.toAccountId} = ?',
      whereArgs: [accountId, accountId],
      orderBy:
          '${AccountTransferColumns.date} DESC, ${AccountTransferColumns.id} DESC',
    );
    return rows.map(_transferFromMap).toList();
  }

  @override
  Future<void> setExpenseAccount(int transactionId, int? accountId) async {
    final db = await _db;
    if (accountId == null) {
      await db.delete(
        kTransactionAccountsTable,
        where: '${TransactionAccountColumns.transactionId} = ?',
        whereArgs: [transactionId],
      );
      return;
    }
    await db.insert(kTransactionAccountsTable, {
      TransactionAccountColumns.transactionId: transactionId,
      TransactionAccountColumns.accountId: accountId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int?> getExpenseAccount(int transactionId) async {
    final rows = await (await _db).query(
      kTransactionAccountsTable,
      columns: [TransactionAccountColumns.accountId],
      where: '${TransactionAccountColumns.transactionId} = ?',
      whereArgs: [transactionId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first[TransactionAccountColumns.accountId] as int?;
  }

  Map<String, Object?> _accountToMap(Account account) => {
    if (account.id != null) AccountColumns.id: account.id,
    AccountColumns.name: account.name,
    AccountColumns.type: account.type.name,
    AccountColumns.initialBalance: account.initialBalance,
    AccountColumns.colorValue: account.colorValue,
    AccountColumns.archived: account.archived ? 1 : 0,
    AccountColumns.createdAt: account.createdAt.toIso8601String(),
  };

  AccountBalance _accountBalanceFromRow(Map<String, Object?> row) {
    final account = Account(
      id: row['id'] as int?,
      name: row['name'] as String,
      type: AccountType.fromStorage(row['type'] as String),
      initialBalance: (row['initial_balance'] as num).toDouble(),
      colorValue: row['color_value'] as int,
      archived: (row['archived'] as int) != 0,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
    return AccountBalance(
      account: account,
      balance: (row['balance'] as num).toDouble(),
    );
  }

  Map<String, Object?> _transferToMap(AccountTransfer transfer) => {
    if (transfer.id != null) AccountTransferColumns.id: transfer.id,
    AccountTransferColumns.fromAccountId: transfer.fromAccountId,
    AccountTransferColumns.toAccountId: transfer.toAccountId,
    AccountTransferColumns.toPersonName: transfer.toPersonName,
    AccountTransferColumns.amount: transfer.amount,
    AccountTransferColumns.note: transfer.note,
    AccountTransferColumns.receiptImagePath: transfer.receiptImagePath,
    AccountTransferColumns.date: transfer.date.toIso8601String(),
  };

  AccountTransfer _transferFromMap(Map<String, Object?> map) {
    return AccountTransfer(
      id: map[AccountTransferColumns.id] as int?,
      fromAccountId: map[AccountTransferColumns.fromAccountId] as int,
      toAccountId: map[AccountTransferColumns.toAccountId] as int?,
      toPersonName: map[AccountTransferColumns.toPersonName] as String?,
      amount: (map[AccountTransferColumns.amount] as num).toDouble(),
      note: map[AccountTransferColumns.note] as String?,
      receiptImagePath:
          map[AccountTransferColumns.receiptImagePath] as String?,
      date: DateTime.parse(map[AccountTransferColumns.date] as String),
    );
  }
}
