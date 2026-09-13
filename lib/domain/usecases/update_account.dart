import '../account_validation.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class UpdateAccount {
  const UpdateAccount(this._repository);

  final AccountRepository _repository;

  Future<void> call(Account account) async {
    if (account.id == null) {
      throw ArgumentError('updateAccount requires a persisted id');
    }
    validateAccountName(account.name);
    await _repository.updateAccount(account);
  }
}
