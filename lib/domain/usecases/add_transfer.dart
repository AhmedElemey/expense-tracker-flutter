import '../account_validation.dart';
import '../entities/account_transfer.dart';
import '../repositories/account_repository.dart';

class AddTransfer {
  const AddTransfer(this._repository);

  final AccountRepository _repository;

  Future<AccountTransfer> call(AccountTransfer transfer) async {
    validateTransferAmount(transfer.amount);
    validateTransferTarget(
      fromAccountId: transfer.fromAccountId,
      toAccountId: transfer.toAccountId,
      toPersonName: transfer.toPersonName,
    );
    final id = await _repository.insertTransfer(transfer);
    return transfer.copyWith(id: id);
  }
}
