import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expensetracker/data/database/expense_database.dart';
import 'package:expensetracker/data/models/expense_category.dart';
import 'package:expensetracker/data/models/transaction_record.dart';
import 'package:expensetracker/data/repositories/transaction_repository.dart';

void main() {
  late ExpenseDatabase database;
  late TransactionRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = ExpenseDatabase(path: inMemoryDatabasePath);
    repository = TransactionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  TransactionRecord record({
    int? id,
    double amount = 12.5,
    ExpenseCategory category = ExpenseCategory.food,
    DateTime? date,
    String? note = 'Lunch',
  }) {
    return TransactionRecord(
      id: id,
      amount: amount,
      category: category,
      date: date ?? DateTime(2026, 9, 1, 12),
      note: note,
    );
  }

  test('insertTransaction assigns an id and getAllTransactions returns it',
      () async {
    final id = await repository.insertTransaction(record());
    expect(id, greaterThan(0));

    final all = await repository.getAllTransactions();
    expect(all, hasLength(1));
    expect(all.single.id, id);
    expect(all.single.amount, 12.5);
    expect(all.single.category, ExpenseCategory.food);
    expect(all.single.note, 'Lunch');
  });

  test('insertTransaction rejects amount <= 0', () async {
    expect(
      () => repository.insertTransaction(record(amount: 0)),
      throwsArgumentError,
    );
    expect(
      () => repository.insertTransaction(record(amount: -3)),
      throwsArgumentError,
    );
  });

  test('updateTransaction changes amount, category, and note', () async {
    final id = await repository.insertTransaction(record());
    await repository.updateTransaction(
      record(
        id: id,
        amount: 40,
        category: ExpenseCategory.transport,
        note: 'Taxi',
      ),
    );

    final all = await repository.getAllTransactions();
    expect(all.single.amount, 40);
    expect(all.single.category, ExpenseCategory.transport);
    expect(all.single.note, 'Taxi');
  });

  test('deleteTransaction removes the row', () async {
    final id = await repository.insertTransaction(record());
    expect(await repository.deleteTransaction(id), 1);
    expect(await repository.getAllTransactions(), isEmpty);
  });

  test('getTransactionsByMonth and getCategoryTotals isolate that month',
      () async {
    await repository.insertTransaction(
      record(amount: 10, date: DateTime(2026, 8, 31, 23)),
    );
    await repository.insertTransaction(
      record(
        amount: 20,
        category: ExpenseCategory.food,
        date: DateTime(2026, 9, 2),
      ),
    );
    await repository.insertTransaction(
      record(
        amount: 5,
        category: ExpenseCategory.transport,
        date: DateTime(2026, 9, 15),
      ),
    );
    await repository.insertTransaction(
      record(amount: 99, date: DateTime(2026, 10, 1)),
    );

    final september =
        await repository.getTransactionsByMonth(DateTime(2026, 9));
    expect(september.map((e) => e.amount), [5, 20]);

    final totals = await repository.getCategoryTotals(DateTime(2026, 9));
    expect(totals[ExpenseCategory.food], 20);
    expect(totals[ExpenseCategory.transport], 5);
    expect(totals.containsKey(ExpenseCategory.bills), isFalse);
  });
}
