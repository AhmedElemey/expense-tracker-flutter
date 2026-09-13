void validateAccountName(String name) {
  if (name.trim().isEmpty) {
    throw ArgumentError.value(name, 'name', 'must not be empty');
  }
}

void validateTransferAmount(double amount) {
  if (amount <= 0 || amount.isNaN) {
    throw ArgumentError.value(amount, 'amount', 'must be greater than 0');
  }
}

/// Exactly one of [toAccountId] or [toPersonName] must identify the
/// destination, and an account-to-account transfer must move between two
/// different accounts.
void validateTransferTarget({
  required int fromAccountId,
  int? toAccountId,
  String? toPersonName,
}) {
  final hasAccount = toAccountId != null;
  final hasPerson = toPersonName != null && toPersonName.trim().isNotEmpty;
  if (hasAccount == hasPerson) {
    throw ArgumentError(
      'exactly one of toAccountId or toPersonName must be set',
    );
  }
  if (hasAccount && toAccountId == fromAccountId) {
    throw ArgumentError.value(
      toAccountId,
      'toAccountId',
      'must differ from fromAccountId',
    );
  }
}
