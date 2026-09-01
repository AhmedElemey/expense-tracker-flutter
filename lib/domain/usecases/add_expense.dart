import '../entities/expense.dart';
import '../expense_validation.dart';
import '../repositories/transaction_repository.dart';

class AddExpense {
  const AddExpense(this._repository);

  final TransactionRepository _repository;

  Future<Expense> call(Expense expense) async {
    validateExpenseAmount(expense.amount);
    final id = await _repository.insertTransaction(expense);
    return expense.copyWith(id: id);
  }
}
