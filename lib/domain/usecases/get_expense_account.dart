import '../repositories/account_repository.dart';

class GetExpenseAccount {
  const GetExpenseAccount(this._repository);

  final AccountRepository _repository;

  Future<int?> call(int transactionId) {
    return _repository.getExpenseAccount(transactionId);
  }
}
