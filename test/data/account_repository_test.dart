import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expensetracker/data/database/expense_database.dart';
import 'package:expensetracker/data/repositories/sqlite_account_repository.dart';
import 'package:expensetracker/data/repositories/sqlite_transaction_repository.dart';
import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/domain/entities/account_transfer.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/domain/entities/expense_category.dart';

void main() {
  late ExpenseDatabase database;
  late SqliteAccountRepository repository;
  late SqliteTransactionRepository transactionRepository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = ExpenseDatabase(path: inMemoryDatabasePath);
    repository = SqliteAccountRepository(database);
    transactionRepository = SqliteTransactionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Account account({
    int? id,
    String name = 'Visa',
    AccountType type = AccountType.card,
    double initialBalance = 100,
    bool archived = false,
  }) {
    return Account(
      id: id,
      name: name,
      type: type,
      initialBalance: initialBalance,
      colorValue: 0xFF2E7D32,
      archived: archived,
      createdAt: DateTime(2026, 9, 1),
    );
  }

  test('insertAccount assigns an id and getAccounts returns its balance', () async {
    final id = await repository.insertAccount(account());
    final all = await repository.getAccounts();
    expect(all, hasLength(1));
    expect(all.single.account.id, id);
    expect(all.single.balance, 100);
  });

  test('archived accounts are excluded unless includeArchived is true', () async {
    final id = await repository.insertAccount(account());
    await repository.setAccountArchived(id, true);

    expect(await repository.getAccounts(), isEmpty);
    final all = await repository.getAccounts(includeArchived: true);
    expect(all.single.account.archived, isTrue);
  });

  test('a transfer moves balance from one account to another', () async {
    final cardId = await repository.insertAccount(
      account(name: 'Visa', initialBalance: 200),
    );
    final cashId = await repository.insertAccount(
      account(name: 'Cash', type: AccountType.cash, initialBalance: 0),
    );

    await repository.insertTransfer(
      AccountTransfer(
        fromAccountId: cardId,
        toAccountId: cashId,
        amount: 50,
        date: DateTime(2026, 9, 2),
      ),
    );

    final balances = {
      for (final a in await repository.getAccounts()) a.account.id: a.balance,
    };
    expect(balances[cardId], 150);
    expect(balances[cashId], 50);
  });

  test('a transfer to a person only debits the source account', () async {
    final cardId = await repository.insertAccount(
      account(initialBalance: 200),
    );

    await repository.insertTransfer(
      AccountTransfer(
        fromAccountId: cardId,
        toPersonName: 'Sam',
        amount: 30,
        date: DateTime(2026, 9, 2),
        receiptImagePath: '/tmp/receipt.png',
      ),
    );

    final balance = (await repository.getAccounts()).single.balance;
    expect(balance, 170);

    final transfers = await repository.getTransfersForAccount(cardId);
    expect(transfers.single.toPersonName, 'Sam');
    expect(transfers.single.receiptImagePath, '/tmp/receipt.png');
  });

  test('deleteTransfer restores the balance', () async {
    final cardId = await repository.insertAccount(
      account(initialBalance: 200),
    );
    final transferId = await repository.insertTransfer(
      AccountTransfer(
        fromAccountId: cardId,
        toPersonName: 'Sam',
        amount: 30,
        date: DateTime(2026, 9, 2),
      ),
    );

    await repository.deleteTransfer(transferId);

    final balance = (await repository.getAccounts()).single.balance;
    expect(balance, 200);
  });

  test('a linked expense debits its account', () async {
    final cardId = await repository.insertAccount(
      account(initialBalance: 200),
    );
    final expenseId = await transactionRepository.insertTransaction(
      Expense(
        amount: 40,
        category: ExpenseCategory.food,
        date: DateTime(2026, 9, 2),
      ),
    );
    await repository.setExpenseAccount(expenseId, cardId);

    final balance = (await repository.getAccounts()).single.balance;
    expect(balance, 160);
    expect(await repository.getExpenseAccount(expenseId), cardId);
  });

  test('clearing the expense-account link restores the balance', () async {
    final cardId = await repository.insertAccount(
      account(initialBalance: 200),
    );
    final expenseId = await transactionRepository.insertTransaction(
      Expense(
        amount: 40,
        category: ExpenseCategory.food,
        date: DateTime(2026, 9, 2),
      ),
    );
    await repository.setExpenseAccount(expenseId, cardId);
    await repository.setExpenseAccount(expenseId, null);

    final balance = (await repository.getAccounts()).single.balance;
    expect(balance, 200);
    expect(await repository.getExpenseAccount(expenseId), isNull);
  });

  test('insertTransfer rejects a non-positive amount', () async {
    final cardId = await repository.insertAccount(account());
    expect(
      () => repository.insertTransfer(
        AccountTransfer(
          fromAccountId: cardId,
          toPersonName: 'Sam',
          amount: 0,
          date: DateTime(2026, 9, 2),
        ),
      ),
      throwsArgumentError,
    );
  });
}
