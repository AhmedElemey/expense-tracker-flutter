import '../entities/account_transfer.dart';
import '../repositories/account_repository.dart';

class GetAccountTransfers {
  const GetAccountTransfers(this._repository);

  final AccountRepository _repository;

  Future<List<AccountTransfer>> call(int accountId) {
    return _repository.getTransfersForAccount(accountId);
  }
}
