import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/transaction.dart';
import 'package:expensetracker/presentation/providers/app_providers.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/providers/monthly_totals_provider.dart';
import 'package:expensetracker/presentation/providers/transactions_provider.dart';

import '../domain/fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository repository;
  late ProviderContainer container;

  Transaction expense({
    double amount = 12.5,
    ExpenseCategory category = ExpenseCategory.food,
    DateTime? date,
    String? note = 'Lunch',
  }) {
    return Transaction(
      amount: amount,
      category: category,
      date: date ?? DateTime(2026, 9, 1, 12),
      note: note,
    );
  }

  setUp(() {
    repository = FakeTransactionRepository();
    container = ProviderContainer(
      overrides: [transactionRepositoryProvider.overrideWithValue(repository)],
    );
    container.read(selectedMonthProvider.notifier).setMonth(DateTime(2026, 9));
  });

  tearDown(() => container.dispose());

  test('transactions start empty', () async {
    final list = await container.read(transactionsProvider.future);
    expect(list, isEmpty);
    final totals = await container.read(monthlyTotalsProvider.future);
    expect(totals.total, 0);
  });

  test('add updates history and monthly totals', () async {
    await container
        .read(transactionsProvider.notifier)
        .add(expense(amount: 20));
    await container
        .read(transactionsProvider.notifier)
        .add(expense(amount: 5, category: ExpenseCategory.transport));

    final list = container.read(transactionsProvider).requireValue;
    expect(list, hasLength(2));
    expect(list.first.id, isNotNull);

    final totals = await container.read(monthlyTotalsProvider.future);
    expect(totals.byCategory[ExpenseCategory.food], 20);
    expect(totals.byCategory[ExpenseCategory.transport], 5);
    expect(totals.total, 25);
  });

  test('filteredTransactionsProvider applies month and category', () async {
    await container
        .read(transactionsProvider.notifier)
        .add(expense(amount: 10, date: DateTime(2026, 8, 31)));
    await container
        .read(transactionsProvider.notifier)
        .add(expense(amount: 20, date: DateTime(2026, 9, 2)));
    await container
        .read(transactionsProvider.notifier)
        .add(
          expense(
            amount: 5,
            category: ExpenseCategory.transport,
            date: DateTime(2026, 9, 15),
          ),
        );

    expect(
      container
          .read(filteredTransactionsProvider)
          .requireValue
          .map((e) => e.amount),
      [5, 20],
    );

    container
        .read(categoryFilterProvider.notifier)
        .toggle(ExpenseCategory.food);
    expect(
      container
          .read(filteredTransactionsProvider)
          .requireValue
          .map((e) => e.amount),
      [20],
    );

    container
        .read(categoryFilterProvider.notifier)
        .toggle(ExpenseCategory.food);
    expect(
      container.read(filteredTransactionsProvider).requireValue,
      hasLength(2),
    );
  });

  test('changing month clears category filter and totals follow', () async {
    await container
        .read(transactionsProvider.notifier)
        .add(expense(amount: 20, date: DateTime(2026, 9, 2)));
    container
        .read(categoryFilterProvider.notifier)
        .toggle(ExpenseCategory.food);
    expect(container.read(categoryFilterProvider), ExpenseCategory.food);

    container.read(selectedMonthProvider.notifier).next();
    expect(container.read(categoryFilterProvider), isNull);
    expect(container.read(selectedMonthProvider), DateTime(2026, 10));

    final october = await container.read(monthlyTotalsProvider.future);
    expect(october.total, 0);
  });

  test('edit updates amount and monthly totals', () async {
    await container
        .read(transactionsProvider.notifier)
        .add(expense(amount: 10));
    final saved = container.read(transactionsProvider).requireValue.single;
    await container
        .read(transactionsProvider.notifier)
        .edit(saved.copyWith(amount: 40, category: ExpenseCategory.bills));

    final updated = container.read(transactionsProvider).requireValue.single;
    expect(updated.amount, 40);
    expect(updated.category, ExpenseCategory.bills);

    final totals = await container.read(monthlyTotalsProvider.future);
    expect(totals.byCategory[ExpenseCategory.bills], 40);
    expect(totals.total, 40);
  });

  test('delete removes the transaction', () async {
    await container.read(transactionsProvider.notifier).add(expense());
    final id = container.read(transactionsProvider).requireValue.single.id!;
    await container.read(transactionsProvider.notifier).delete(id);
    expect(container.read(transactionsProvider).requireValue, isEmpty);
  });

  test('add with invalid amount leaves state unchanged', () async {
    await container.read(transactionsProvider.future);
    expect(
      () =>
          container.read(transactionsProvider.notifier).add(expense(amount: 0)),
      throwsArgumentError,
    );
    expect(container.read(transactionsProvider).requireValue, isEmpty);
  });
}
