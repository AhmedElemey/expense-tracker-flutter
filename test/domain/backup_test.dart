import 'package:flutter_test/flutter_test.dart';

import 'package:expensetracker/domain/csv/expense_csv.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/usecases/export_expenses.dart';
import 'package:expensetracker/domain/usecases/import_expenses.dart';

import 'fake_transaction_repository.dart';

void main() {
  Expense lunch() => Expense(
    id: 1,
    amount: 12.5,
    category: ExpenseCategory.food,
    date: DateTime(2026, 9, 1, 12),
    note: 'Lunch, extra',
  );

  test('CSV round-trips notes that contain commas', () {
    final csv = ExpenseCsv.encode([lunch()]);
    expect(csv, contains('"Lunch, extra"'));
    final decoded = ExpenseCsv.decode(csv);
    expect(decoded, hasLength(1));
    expect(decoded.single.note, 'Lunch, extra');
    expect(decoded.single.amount, 12.5);
    expect(decoded.single.category, ExpenseCategory.food);
  });

  test('CSV round-trips a custom Other category', () {
    final gym = Expense(
      id: 2,
      amount: 30,
      category: ExpenseCategory.other,
      date: DateTime(2026, 9, 3),
      customCategory: 'Gym',
    );
    final decoded = ExpenseCsv.decode(ExpenseCsv.encode([gym]));
    expect(decoded.single.category, ExpenseCategory.other);
    expect(decoded.single.customCategory, 'Gym');
  });

  test('ExportExpenses writes every stored expense', () async {
    final repository = FakeTransactionRepository();
    await repository.insertTransaction(lunch());
    final csv = await ExportExpenses(repository)();
    expect(csv, startsWith(ExpenseCsv.header));
    expect(ExpenseCsv.decode(csv), hasLength(1));
  });

  test('ImportExpenses inserts new rows and skips duplicates', () async {
    final repository = FakeTransactionRepository();
    await repository.insertTransaction(lunch());
    final csv = ExpenseCsv.encode([
      lunch(),
      Expense(
        amount: 40,
        category: ExpenseCategory.bills,
        date: DateTime(2026, 9, 2),
        note: 'Rent',
      ),
    ]);

    final result = await ImportExpenses(repository)(csv);
    expect(result.inserted, 1);
    expect(result.skipped, 1);
    expect(repository.items, hasLength(2));
    expect(
      repository.items.map((e) => e.note),
      containsAll(['Lunch, extra', 'Rent']),
    );
  });

  test(
    'ImportExpenses treats different custom categories as distinct',
    () async {
      final repository = FakeTransactionRepository();
      final gym = Expense(
        amount: 30,
        category: ExpenseCategory.other,
        date: DateTime(2026, 9, 3),
        customCategory: 'Gym',
      );
      await repository.insertTransaction(gym);
      final csv = ExpenseCsv.encode([
        gym.copyWith(id: 1),
        gym.copyWith(customCategory: 'Pets'),
      ]);

      final result = await ImportExpenses(repository)(csv);
      expect(result.inserted, 1);
      expect(result.skipped, 1);
      expect(
        repository.items.map((e) => e.customCategory),
        containsAll(['Gym', 'Pets']),
      );
    },
  );
}
