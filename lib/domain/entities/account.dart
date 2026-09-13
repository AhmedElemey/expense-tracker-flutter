/// A money source the user tracks: a bank/credit card or cash on hand.
enum AccountType {
  card,
  cash;

  static AccountType fromStorage(String value) {
    return AccountType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => AccountType.card,
    );
  }
}

/// Domain account. [id] is null until persisted. The live balance is derived
/// from [initialBalance] plus transfers and linked expenses, not stored here
/// — see [AccountBalance].
class Account {
  const Account({
    this.id,
    required this.name,
    required this.type,
    this.initialBalance = 0,
    required this.colorValue,
    this.archived = false,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final AccountType type;
  final double initialBalance;

  /// ARGB color the user picked for this account, e.g. `0xFF2E7D32`.
  final int colorValue;
  final bool archived;
  final DateTime createdAt;

  Account copyWith({
    int? id,
    String? name,
    AccountType? type,
    double? initialBalance,
    int? colorValue,
    bool? archived,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      colorValue: colorValue ?? this.colorValue,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Account &&
            other.id == id &&
            other.name == name &&
            other.type == type &&
            other.initialBalance == initialBalance &&
            other.colorValue == colorValue &&
            other.archived == archived &&
            other.createdAt == createdAt);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    initialBalance,
    colorValue,
    archived,
    createdAt,
  );

  @override
  String toString() =>
      'Account(id: $id, name: $name, type: $type, initialBalance: '
      '$initialBalance, colorValue: $colorValue, archived: $archived, '
      'createdAt: $createdAt)';
}
