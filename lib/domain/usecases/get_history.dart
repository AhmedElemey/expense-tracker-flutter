import '../entities/expense.dart';
import '../entities/expense_category.dart';
import '../repositories/transaction_repository.dart';

class GetHistory {
  const GetHistory(this._repository);

  final TransactionRepository _repository;

  /// Newest first. Pass [month] and/or [category] to filter.
  Future<List<Expense>> call({
    DateTime? month,
    ExpenseCategory? category,
  }) async {
    final list = month == null
        ? await _repository.getAllTransactions()
        : await _repository.getTransactionsByMonth(month);
    if (category == null) {
      return list;
    }
    return list.where((item) => item.category == category).toList();
  }
}
