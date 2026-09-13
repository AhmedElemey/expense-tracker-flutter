import 'account.dart';

/// An [Account] paired with its live balance, computed as initial balance
/// plus incoming transfers minus outgoing transfers minus linked expenses.
class AccountBalance {
  const AccountBalance({required this.account, required this.balance});

  final Account account;
  final double balance;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AccountBalance &&
            other.account == account &&
            other.balance == balance);
  }

  @override
  int get hashCode => Object.hash(account, balance);

  @override
  String toString() => 'AccountBalance(account: $account, balance: $balance)';
}
