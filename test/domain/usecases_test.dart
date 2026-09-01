import 'package:flutter_test/flutter_test.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/domain/usecases/add_expense.dart';
import 'package:expensetracker/domain/usecases/delete_expense.dart';
import 'package:expensetracker/domain/usecases/get_history.dart';
import 'package:expensetracker/domain/usecases/get_monthly_totals.dart';
import 'package:expensetracker/domain/usecases/update_expense.dart';

import 'fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository repository;
  late AddExpense addExpense;
  late UpdateExpense updateExpense;
  late DeleteExpense deleteExpense;
  late GetHistory getHistory;
  late GetMonthlyTotals getMonthlyTotals;

  setUp(() {
    repository = FakeTransactionRepository();
    addExpense = AddExpense(repository);
    updateExpense = UpdateExpense(repository);
    deleteExpense = DeleteExpense(repository);
    getHistory = GetHistory(repository);
    getMonthlyTotals = GetMonthlyTotals(repository);
  });

  Expense expense({
    int? id,
    double amount = 12.5,
    ExpenseCategory category = ExpenseCategory.food,
    DateTime? date,
    String? note = 'Lunch',
  }) {
    return Expense(
      id: id,
      amount: amount,
      category: category,
      date: date ?? DateTime(2026, 9, 1, 12),
      note: note,
    );
  }

  test('AddExpense persists and returns an id', () async {
    final saved = await addExpense(expense());
    expect(saved.id, 1);
    expect(repository.items, hasLength(1));
    expect(repository.items.single.amount, 12.5);
  });

  test('AddExpense rejects amount <= 0', () async {
    expect(() => addExpense(expense(amount: 0)), throwsArgumentError);
    expect(() => addExpense(expense(amount: -1)), throwsArgumentError);
    expect(repository.items, isEmpty);
  });

  test('UpdateExpense changes fields', () async {
    final saved = await addExpense(expense());
    await updateExpense(
      saved.copyWith(
        amount: 40,
        category: ExpenseCategory.transport,
        note: 'Taxi',
      ),
    );

    expect(repository.items.single.amount, 40);
    expect(repository.items.single.category, ExpenseCategory.transport);
    expect(repository.items.single.note, 'Taxi');
  });

  test('UpdateExpense requires an id', () async {
    expect(() => updateExpense(expense()), throwsArgumentError);
  });

  test('DeleteExpense removes the row', () async {
    final saved = await addExpense(expense());
    await deleteExpense(saved.id!);
    expect(repository.items, isEmpty);
  });

  test('GetHistory returns all, or filters by month and category', () async {
    await addExpense(expense(amount: 10, date: DateTime(2026, 8, 31)));
    await addExpense(
      expense(
        amount: 20,
        category: ExpenseCategory.food,
        date: DateTime(2026, 9, 2),
      ),
    );
    await addExpense(
      expense(
        amount: 5,
        category: ExpenseCategory.transport,
        date: DateTime(2026, 9, 15),
      ),
    );

    expect(await getHistory(), hasLength(3));

    final september = await getHistory(month: DateTime(2026, 9));
    expect(september.map((e) => e.amount), [5, 20]);

    final foodInSeptember = await getHistory(
      month: DateTime(2026, 9),
      category: ExpenseCategory.food,
    );
    expect(foodInSeptember.map((e) => e.amount), [20]);
  });

  test('GetMonthlyTotals sums by category for that month', () async {
    await addExpense(expense(amount: 10, date: DateTime(2026, 8, 31)));
    await addExpense(
      expense(
        amount: 20,
        category: ExpenseCategory.food,
        date: DateTime(2026, 9, 2),
      ),
    );
    await addExpense(
      expense(
        amount: 5,
        category: ExpenseCategory.transport,
        date: DateTime(2026, 9, 15),
      ),
    );

    final totals = await getMonthlyTotals(DateTime(2026, 9, 20));
    expect(totals.month, DateTime(2026, 9));
    expect(totals.byCategory[ExpenseCategory.food], 20);
    expect(totals.byCategory[ExpenseCategory.transport], 5);
    expect(totals.total, 25);
  });
}
