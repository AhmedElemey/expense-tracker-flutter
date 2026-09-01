void validateExpenseAmount(double amount) {
  if (amount <= 0 || amount.isNaN) {
    throw ArgumentError.value(amount, 'amount', 'must be greater than 0');
  }
}
