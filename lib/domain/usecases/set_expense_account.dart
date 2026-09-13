import '../repositories/account_repository.dart';

/// Links (or unlinks, when [accountId] is null) an expense to the account
/// it was paid from.
class SetExpenseAccount {
  const SetExpenseAccount(this._repository);

  final AccountRepository _repository;

  Future<void> call(int transactionId, int? accountId) {
    return _repository.setExpenseAccount(transactionId, accountId);
  }
}
