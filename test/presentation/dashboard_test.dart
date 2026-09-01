import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/transaction.dart';
import 'package:expensetracker/main.dart';
import 'package:expensetracker/presentation/providers/app_providers.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/screens/home_screen.dart';

import '../domain/fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository repository;

  Transaction expense({
    required int id,
    double amount = 12.5,
    ExpenseCategory category = ExpenseCategory.food,
    required DateTime date,
    String? note,
  }) {
    return Transaction(
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

  Future<void> pumpDashboard(WidgetTester tester, {DateTime? month}) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    container
        .read(selectedMonthProvider.notifier)
        .setMonth(month ?? DateTime(2026, 9));
    await tester.pumpAndSettle();
  }

  setUp(() {
    repository = FakeTransactionRepository();
  });

  testWidgets('shows monthly total, pie legend, and this month’s expenses', (
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
      expense(
        id: 3,
        amount: 99,
        date: DateTime(2026, 8, 20),
        note: 'August only',
      ),
    ]);

    await pumpDashboard(tester);

    expect(
      find.text(DateFormat.yMMMM().format(DateTime(2026, 9))),
      findsOneWidget,
    );
    expect(find.byKey(const Key('month-total')), findsOneWidget);
    expect(find.text('28.00'), findsOneWidget);
    expect(find.byKey(const Key('category-pie-chart')), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text('August only'), findsNothing);
  });

  testWidgets('tapping a category legend filters the list below', (
    tester,
  ) async {
    repository.items.addAll([
      expense(id: 1, amount: 8, date: DateTime(2026, 9, 1), note: 'Lunch'),
      expense(
        id: 2,
        amount: 20,
        category: ExpenseCategory.transport,
        date: DateTime(2026, 9, 15),
        note: 'Taxi',
      ),
    ]);

    await pumpDashboard(tester);

    await tester.tap(find.byKey(const Key('legend-food')));
    await tester.pumpAndSettle();

    expect(find.text('Food this month'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Taxi'), findsNothing);

    await tester.tap(find.byKey(const Key('legend-food')));
    await tester.pumpAndSettle();
    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
  });

  testWidgets('month navigation changes totals and the list', (tester) async {
    repository.items.addAll([
      expense(
        id: 1,
        amount: 8,
        date: DateTime(2026, 9, 1),
        note: 'September lunch',
      ),
      expense(
        id: 2,
        amount: 15,
        date: DateTime(2026, 8, 10),
        note: 'August bill',
      ),
    ]);

    await pumpDashboard(tester, month: DateTime(2026, 8));

    expect(find.text('August bill'), findsOneWidget);
    expect(find.text('15.00'), findsWidgets);
    expect(find.text('September lunch'), findsNothing);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();

    expect(
      find.text(DateFormat.yMMMM().format(DateTime(2026, 9))),
      findsOneWidget,
    );
    expect(find.text('September lunch'), findsOneWidget);
    expect(find.text('August bill'), findsNothing);
  });

  testWidgets('empty month shows placeholder copy', (tester) async {
    await pumpDashboard(tester);
    expect(find.textContaining('No expenses this month'), findsOneWidget);
    expect(
      find.textContaining('No spending to chart this month'),
      findsOneWidget,
    );
  });
}
