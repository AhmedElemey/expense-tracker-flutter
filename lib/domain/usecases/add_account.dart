import '../account_validation.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class AddAccount {
  const AddAccount(this._repository);

  final AccountRepository _repository;

  Future<Account> call(Account account) async {
    validateAccountName(account.name);
    final id = await _repository.insertAccount(account);
    return account.copyWith(id: id);
  }
}
