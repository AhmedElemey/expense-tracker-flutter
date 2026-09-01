import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/data/database/expense_database.dart';
import 'package:expensetracker/data/repositories/sqlite_transaction_repository.dart';
import 'package:expensetracker/domain/repositories/transaction_repository.dart';
import 'package:expensetracker/domain/usecases/add_expense.dart';
import 'package:expensetracker/domain/usecases/delete_expense.dart';
import 'package:expensetracker/domain/usecases/get_history.dart';
import 'package:expensetracker/domain/usecases/get_monthly_totals.dart';
import 'package:expensetracker/domain/usecases/update_expense.dart';

final expenseDatabaseProvider = Provider<ExpenseDatabase>((ref) {
  final database = ExpenseDatabase();
  ref.onDispose(database.close);
  return database;
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return SqliteTransactionRepository(ref.watch(expenseDatabaseProvider));
});

final addExpenseProvider = Provider<AddExpense>((ref) {
  return AddExpense(ref.watch(transactionRepositoryProvider));
});

final updateExpenseProvider = Provider<UpdateExpense>((ref) {
  return UpdateExpense(ref.watch(transactionRepositoryProvider));
});

final deleteExpenseProvider = Provider<DeleteExpense>((ref) {
  return DeleteExpense(ref.watch(transactionRepositoryProvider));
});

final getHistoryProvider = Provider<GetHistory>((ref) {
  return GetHistory(ref.watch(transactionRepositoryProvider));
});

final getMonthlyTotalsProvider = Provider<GetMonthlyTotals>((ref) {
  return GetMonthlyTotals(ref.watch(transactionRepositoryProvider));
});
