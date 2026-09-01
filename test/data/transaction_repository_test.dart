import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expensetracker/data/database/expense_database.dart';
import 'package:expensetracker/data/repositories/sqlite_transaction_repository.dart';
import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/expense.dart';

void main() {
  late ExpenseDatabase database;
  late SqliteTransactionRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = ExpenseDatabase(path: inMemoryDatabasePath);
    repository = SqliteTransactionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Expense record({
    int? id,
    double amount = 12.5,
    ExpenseCategory category = ExpenseCategory.food,
    DateTime? date,
    String? note = 'Lunch',
    String? customCategory,
  }) {
    return Expense(
      id: id,
      amount: amount,
      category: category,
      date: date ?? DateTime(2026, 9, 1, 12),
      note: note,
      customCategory: customCategory,
    );
  }

  test(
    'insertTransaction assigns an id and getAllTransactions returns it',
    () async {
      final id = await repository.insertTransaction(record());
      expect(id, greaterThan(0));

      final all = await repository.getAllTransactions();
      expect(all, hasLength(1));
      expect(all.single.id, id);
      expect(all.single.amount, 12.5);
      expect(all.single.category, ExpenseCategory.food);
      expect(all.single.note, 'Lunch');
    },
  );

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

  test('updateTransaction without an id throws', () async {
    expect(() => repository.updateTransaction(record()), throwsArgumentError);
  });

  test('unknown category strings map to other', () {
    expect(
      ExpenseCategory.fromStorage('not_a_category'),
      ExpenseCategory.other,
    );
  });

  test(
    'getTransactionsByMonth and getCategoryTotals isolate that month',
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

      final september = await repository.getTransactionsByMonth(
        DateTime(2026, 9),
      );
      expect(september.map((e) => e.amount), [5, 20]);

      final totals = await repository.getCategoryTotals(DateTime(2026, 9));
      expect(totals[ExpenseCategory.food], 20);
      expect(totals[ExpenseCategory.transport], 5);
      expect(totals.containsKey(ExpenseCategory.bills), isFalse);
    },
  );

  test(
    'getTransactionsByMonth includes December and excludes January',
    () async {
      await repository.insertTransaction(
        record(amount: 8, date: DateTime(2026, 12, 31, 23)),
      );
      await repository.insertTransaction(
        record(amount: 50, date: DateTime(2027, 1, 1)),
      );

      final december = await repository.getTransactionsByMonth(
        DateTime(2026, 12),
      );
      expect(december.map((e) => e.amount), [8]);
      expect(await repository.getCategoryTotals(DateTime(2026, 12)), {
        ExpenseCategory.food: 8,
      });
    },
  );

  test('getCategoryTotals is empty when the month has no rows', () async {
    expect(await repository.getCategoryTotals(DateTime(2026, 1)), isEmpty);
  });

  test('custom Other category round-trips through SQLite', () async {
    final id = await repository.insertTransaction(
      record(
        category: ExpenseCategory.other,
        customCategory: 'Gym',
        note: null,
      ),
    );

    final all = await repository.getAllTransactions();
    expect(all.single.id, id);
    expect(all.single.category, ExpenseCategory.other);
    expect(all.single.customCategory, 'Gym');
  });

  test('getCategoryTotals merges custom Other labels into other', () async {
    await repository.insertTransaction(
      record(
        amount: 10,
        category: ExpenseCategory.other,
        customCategory: 'Gym',
      ),
    );
    await repository.insertTransaction(
      record(
        amount: 7,
        category: ExpenseCategory.other,
        customCategory: 'Pets',
        date: DateTime(2026, 9, 2),
      ),
    );
    await repository.insertTransaction(
      record(
        amount: 3,
        category: ExpenseCategory.food,
        date: DateTime(2026, 9, 3),
      ),
    );

    expect(await repository.getCategoryTotals(DateTime(2026, 9)), {
      ExpenseCategory.other: 17,
      ExpenseCategory.food: 3,
    });
  });
}
