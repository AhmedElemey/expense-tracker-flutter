import '../repositories/account_repository.dart';

class SetAccountArchived {
  const SetAccountArchived(this._repository);

  final AccountRepository _repository;

  Future<void> call(int id, bool archived) async {
    await _repository.setAccountArchived(id, archived);
  }
}
