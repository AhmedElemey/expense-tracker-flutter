import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/main.dart';
import 'package:expensetracker/presentation/providers/account_providers.dart';
import 'package:expensetracker/presentation/providers/app_providers.dart';
import 'package:expensetracker/presentation/screens/add_expense_screen.dart';

import '../domain/fake_account_repository.dart';
import '../domain/fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository repository;
  late FakeAccountRepository accountRepository;

  List<Override> overrides() => [
    transactionRepositoryProvider.overrideWithValue(repository),
    accountRepositoryProvider.overrideWithValue(accountRepository),
  ];

  Widget app() {
    return ProviderScope(overrides: overrides(), child: const ExpenseTrackerApp());
  }

  setUp(() {
    repository = FakeTransactionRepository();
    accountRepository = FakeAccountRepository();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('settings shows export and import actions', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Export data'), findsOneWidget);
    expect(find.text('Import data'), findsOneWidget);
    expect(find.byKey(const Key('currency-E£')), findsOneWidget);
    expect(find.text('Egyptian Pound E£'), findsOneWidget);
    expect(find.byKey(const Key(r'currency-$')), findsOneWidget);
    expect(find.text('Dollar \$'), findsOneWidget);
    expect(find.text('Euro €'), findsOneWidget);
    expect(find.text('Sterling £'), findsOneWidget);
    expect(find.text('Yen ¥'), findsOneWidget);
    expect(find.byKey(const Key('language-en')), findsOneWidget);
    expect(find.byKey(const Key('language-ar')), findsOneWidget);
  });

  testWidgets('switching to Arabic localizes settings and uses RTL', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('language-ar')));
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('تصدير البيانات'), findsOneWidget);
    expect(find.text('Export data'), findsNothing);
    expect(
      Directionality.of(tester.element(find.text('الإعدادات'))),
      TextDirection.rtl,
    );
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
        overrides: overrides(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: AddExpenseScreen(existing: existing),
        ),
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

  testWidgets('Other shows a custom category field and saves the typed name', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('expense-custom-category')), findsNothing);

    await tester.enterText(find.byKey(const Key('expense-amount')), '30');
    await tester.tap(find.byKey(const Key('category-other')));
    await tester.pump();

    expect(find.byKey(const Key('expense-custom-category')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('expense-custom-category')),
      'Gym',
    );
    await tester.tap(find.byKey(const Key('expense-save')));
    await tester.pumpAndSettle();

    expect(repository.items, hasLength(1));
    final saved = repository.items.single;
    expect(saved.category, ExpenseCategory.other);
    expect(saved.customCategory, 'Gym');
    expect(find.text('Gym'), findsOneWidget);
  });

  testWidgets('edit screen prefills a custom Other category', (tester) async {
    final existing = Expense(
      id: 1,
      amount: 30,
      category: ExpenseCategory.other,
      date: DateTime(2026, 9, 1, 12),
      customCategory: 'Gym',
    );
    repository.items.add(existing);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: AddExpenseScreen(existing: existing),
        ),
      ),
    );

    expect(find.byKey(const Key('expense-custom-category')), findsOneWidget);
    expect(find.text('Gym'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('expense-custom-category')),
      'Pets',
    );
    await tester.tap(find.byKey(const Key('expense-save')));
    await tester.pumpAndSettle();

    expect(repository.items.single.category, ExpenseCategory.other);
    expect(repository.items.single.customCategory, 'Pets');
  });
}
