import '../entities/account_balance.dart';
import '../repositories/account_repository.dart';

class GetAccounts {
  const GetAccounts(this._repository);

  final AccountRepository _repository;

  Future<List<AccountBalance>> call({bool includeArchived = false}) {
    return _repository.getAccounts(includeArchived: includeArchived);
  }
}
