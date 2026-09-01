import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/main.dart';
import 'package:expensetracker/presentation/providers/app_providers.dart';
import 'package:expensetracker/presentation/screens/add_expense_screen.dart';

import '../domain/fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository repository;

  Widget app() {
    return ProviderScope(
      overrides: [transactionRepositoryProvider.overrideWithValue(repository)],
      child: const ExpenseTrackerApp(),
    );
  }

  setUp(() {
    repository = FakeTransactionRepository();
  });

  testWidgets('FAB opens the add expense screen', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();

    expect(find.text('Add expense'), findsOneWidget);
    expect(find.byKey(const Key('expense-amount')), findsOneWidget);
  });

  testWidgets('rejects empty and zero amounts', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('expense-save')));
    await tester.pump();
    expect(find.text('Enter an amount'), findsOneWidget);
    expect(repository.items, isEmpty);

    await tester.enterText(find.byKey(const Key('expense-amount')), '0');
    await tester.tap(find.byKey(const Key('expense-save')));
    await tester.pump();
    expect(find.text('Amount must be greater than 0'), findsOneWidget);
    expect(repository.items, isEmpty);
  });

  testWidgets('saves a valid expense', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('expense-amount')), '12.5');
    await tester.tap(find.byKey(const Key('category-transport')));
    await tester.enterText(find.byKey(const Key('expense-note')), 'Taxi');
    await tester.tap(find.byKey(const Key('expense-save')));
    await tester.pumpAndSettle();

    expect(find.text('Add expense'), findsNothing);
    expect(find.text('Taxi'), findsOneWidget);
    expect(repository.items, hasLength(1));
    final saved = repository.items.single;
    expect(saved.amount, 12.5);
    expect(saved.category, ExpenseCategory.transport);
    expect(saved.note, 'Taxi');
    final now = DateTime.now();
    expect(saved.date.year, now.year);
    expect(saved.date.month, now.month);
    expect(saved.date.day, now.day);
  });

  testWidgets('edit screen prefills and updates the expense', (tester) async {
    final existing = Expense(
      id: 1,
      amount: 8,
      category: ExpenseCategory.food,
      date: DateTime(2026, 9, 1, 12),
      note: 'Lunch',
    );
    repository.items.add(existing);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(home: AddExpenseScreen(existing: existing)),
      ),
    );

    expect(find.text('Edit expense'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('expense-amount')), '40');
    await tester.tap(find.byKey(const Key('category-bills')));
    await tester.tap(find.byKey(const Key('expense-save')));
    await tester.pumpAndSettle();

    expect(repository.items.single.amount, 40);
    expect(repository.items.single.category, ExpenseCategory.bills);
    expect(repository.items.single.note, 'Lunch');
  });
}
