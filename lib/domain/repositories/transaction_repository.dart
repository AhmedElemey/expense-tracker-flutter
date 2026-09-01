import '../entities/expense.dart';
import '../entities/expense_category.dart';

abstract class TransactionRepository {
  Future<int> insertTransaction(Expense expense);

  Future<int> updateTransaction(Expense expense);

  Future<int> deleteTransaction(int id);

  Future<List<Expense>> getAllTransactions();

  Future<List<Expense>> getTransactionsByMonth(DateTime month);

  Future<Map<ExpenseCategory, double>> getCategoryTotals(DateTime month);
}
