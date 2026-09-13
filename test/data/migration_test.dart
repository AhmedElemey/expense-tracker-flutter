import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expensetracker/data/database/expense_database.dart';
import 'package:expensetracker/data/repositories/sqlite_account_repository.dart';
import 'package:expensetracker/data/repositories/sqlite_transaction_repository.dart';
import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/domain/entities/expense_category.dart';

/// Proves that installing an update that adds the accounts feature never
/// touches a real user's pre-existing expense data: it opens a database
/// file built with the *original* (pre-accounts) schema — exactly what an
/// upgrading user's device already has on disk — and confirms every
/// existing expense survives untouched once [ExpenseDatabase] upgrades it.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'upgrading a v1 (pre-accounts) database keeps existing expenses intact',
    () async {
      final dbPath = join(
        Directory.systemTemp.path,
        'migration_test_${DateTime.now().microsecondsSinceEpoch}.db',
      );
      addTearDown(() async {
        final file = File(dbPath);
        if (await file.exists()) {
          await file.delete();
        }
      });

      // 1. Build a v1 database exactly as the original (pre-accounts)
      // ExpenseDatabase._open() did — no accounts/transfers tables.
      final v1 = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
CREATE TABLE $kTransactionsTable (
  ${TransactionColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${TransactionColumns.amount} REAL NOT NULL,
  ${TransactionColumns.category} TEXT NOT NULL,
  ${TransactionColumns.date} TEXT NOT NULL,
  ${TransactionColumns.note} TEXT
)
''');
        },
      );
      final lunchId = await v1.insert(kTransactionsTable, {
        TransactionColumns.amount: 12.5,
        TransactionColumns.category: ExpenseCategory.food.name,
        TransactionColumns.date: DateTime(2026, 6, 1).toIso8601String(),
        TransactionColumns.note: 'Lunch before the update',
      });
      final rentId = await v1.insert(kTransactionsTable, {
        TransactionColumns.amount: 900,
        TransactionColumns.category: ExpenseCategory.bills.name,
        TransactionColumns.date: DateTime(2026, 6, 2).toIso8601String(),
        TransactionColumns.note: 'Rent',
      });
      await v1.close();

      // 2. Open that same file through the real (current) ExpenseDatabase —
      // this is exactly what happens the moment an upgraded app first runs.
      final database = ExpenseDatabase(path: dbPath);
      final transactions = SqliteTransactionRepository(database);
      final accounts = SqliteAccountRepository(database);

      final history = await transactions.getAllTransactions();
      expect(history, hasLength(2));
      final lunch = history.firstWhere((e) => e.id == lunchId);
      expect(lunch.amount, 12.5);
      expect(lunch.category, ExpenseCategory.food);
      expect(lunch.note, 'Lunch before the update');
      final rent = history.firstWhere((e) => e.id == rentId);
      expect(rent.amount, 900);
      expect(rent.note, 'Rent');

      // 3. The new accounts feature works immediately on the upgraded file.
      final accountId = await accounts.insertAccount(
        Account(
          name: 'Visa',
          type: AccountType.card,
          initialBalance: 500,
          colorValue: 0xFF1565C0,
          createdAt: DateTime(2026, 6, 3),
        ),
      );
      await accounts.setExpenseAccount(rentId, accountId);
      final balance = (await accounts.getAccounts()).single.balance;
      expect(balance, 500 - 900); // -400, rent now linked to Visa

      // The pre-existing expenses are still exactly as they were.
      final historyAfter = await transactions.getAllTransactions();
      expect(historyAfter, hasLength(2));

      await database.close();
    },
  );
}
