import '../csv/expense_csv.dart';
import '../repositories/transaction_repository.dart';

class ExportExpenses {
  const ExportExpenses(this._repository);

  final TransactionRepository _repository;

  Future<String> call() async {
    final expenses = await _repository.getAllTransactions();
    return ExpenseCsv.encode(expenses);
  }
}
