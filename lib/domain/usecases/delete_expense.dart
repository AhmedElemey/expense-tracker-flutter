import '../repositories/transaction_repository.dart';

class DeleteExpense {
  const DeleteExpense(this._repository);

  final TransactionRepository _repository;

  Future<void> call(int id) async {
    await _repository.deleteTransaction(id);
  }
}
