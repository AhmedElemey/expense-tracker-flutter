import '../repositories/account_repository.dart';

class DeleteTransfer {
  const DeleteTransfer(this._repository);

  final AccountRepository _repository;

  Future<void> call(int id) async {
    await _repository.deleteTransfer(id);
  }
}
