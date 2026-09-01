import '../entities/transaction.dart';
import '../expense_validation.dart';
import '../repositories/transaction_repository.dart';

class UpdateExpense {
  const UpdateExpense(this._repository);

  final TransactionRepository _repository;

  Future<Transaction> call(Transaction expense) async {
    if (expense.id == null) {
      throw ArgumentError('update requires a persisted id');
    }
    validateExpenseAmount(expense.amount);
    await _repository.updateTransaction(expense);
    return expense;
  }
}
