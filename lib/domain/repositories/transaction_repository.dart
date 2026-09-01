import '../entities/expense_category.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<int> insertTransaction(Transaction transaction);

  Future<int> updateTransaction(Transaction transaction);

  Future<int> deleteTransaction(int id);

  Future<List<Transaction>> getAllTransactions();

  Future<List<Transaction>> getTransactionsByMonth(DateTime month);

  Future<Map<ExpenseCategory, double>> getCategoryTotals(DateTime month);
}
