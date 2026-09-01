import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/main.dart';
import 'package:expensetracker/presentation/providers/app_providers.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/widgets/transaction_list.dart';

import '../domain/fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository repository;

  Expense expense({
    required int id,
    double amount = 12.5,
    ExpenseCategory category = ExpenseCategory.food,
    required DateTime date,
    String? note,
  }) {
    return Expense(
      id: id,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
  }

  Widget app() {
    return ProviderScope(
      overrides: [transactionRepositoryProvider.overrideWithValue(repository)],
      child: const ExpenseTrackerApp(),
    );
  }

  setUp(() {
    repository = FakeTransactionRepository();
  });

  test('groupTransactions buckets by day and month in newest-first order', () {
    final items = [
      expense(id: 3, amount: 5, date: DateTime(2026, 10, 2)),
      expense(id: 2, amount: 8, date: DateTime(2026, 9, 15)),
      expense(id: 1, amount: 3, date: DateTime(2026, 9, 1)),
    ];

    final byDay = groupTransactions(items, HistoryGrouping.day);
    expect(byDay.map((s) => s.keyDate), [
      DateTime(2026, 10, 2),
      DateTime(2026, 9, 15),
      DateTime(2026, 9, 1),
    ]);

    final byMonth = groupTransactions(items, HistoryGrouping.month);
    expect(byMonth.map((s) => s.keyDate), [
      DateTime(2026, 10),
      DateTime(2026, 9),
    ]);
    expect(byMonth.last.transactions.map((t) => t.id), [2, 1]);
  });

  testWidgets('history lists items under day headers and swipe deletes', (
    tester,
  ) async {
    repository.items.addAll([
      expense(id: 1, amount: 8, date: DateTime(2026, 9, 1, 12), note: 'Lunch'),
      expense(
        id: 2,
        amount: 20,
        category: ExpenseCategory.transport,
        date: DateTime(2026, 9, 15, 9),
        note: 'Taxi',
      ),
    ]);

    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(
      find.text(DateFormat.yMMMd().format(DateTime(2026, 9, 1))),
      findsWidgets,
    );
    expect(
      find.text(DateFormat.yMMMd().format(DateTime(2026, 9, 15))),
      findsWidgets,
    );
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text(r'$8.00'), findsOneWidget);
    expect(find.text(r'$20.00'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('transaction-1')),
      const Offset(-500, 0),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repository.items.map((e) => e.id), [2]);
    expect(find.text('Lunch'), findsNothing);
    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text('Expense deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('undo restores a swipe-deleted expense', (tester) async {
    repository.items.add(
      expense(id: 1, amount: 8, date: DateTime(2026, 9, 1, 12), note: 'Lunch'),
    );

    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('transaction-1')),
      const Offset(-500, 0),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Expense deleted'), findsOneWidget);
    tester.widget<SnackBarAction>(find.byKey(const Key('undo-delete'))).onPressed();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Lunch'), findsOneWidget);
    expect(repository.items, hasLength(1));
    expect(repository.items.single.note, 'Lunch');
    expect(repository.items.single.amount, 8);
  });

  testWidgets('month grouping uses month headers', (tester) async {
    repository.items.addAll([
      expense(id: 1, amount: 8, date: DateTime(2026, 9, 1)),
      expense(id: 2, amount: 4, date: DateTime(2026, 10, 2)),
    ]);

    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();

    expect(
      find.text(DateFormat.yMMMM().format(DateTime(2026, 9))),
      findsOneWidget,
    );
    expect(
      find.text(DateFormat.yMMMM().format(DateTime(2026, 10))),
      findsOneWidget,
    );
  });

  testWidgets('tap opens edit and saving updates the row', (tester) async {
    repository.items.add(
      expense(id: 1, amount: 8, date: DateTime(2026, 9, 1, 12), note: 'Lunch'),
    );

    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lunch'));
    await tester.pumpAndSettle();
    expect(find.text('Edit expense'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('expense-amount')), '40');
    await tester.tap(find.byKey(const Key('expense-save')));
    await tester.pumpAndSettle();

    expect(find.text(r'$40.00'), findsOneWidget);
    expect(find.text(r'$8.00'), findsNothing);
    expect(repository.items.single.amount, 40);
  });

  testWidgets('empty history shows a placeholder', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No expenses yet'), findsOneWidget);
  });
}
