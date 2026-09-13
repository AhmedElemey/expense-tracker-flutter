/// A movement of money out of [fromAccountId], either into another tracked
/// account ([toAccountId]) or to an external person ([toPersonName]).
/// Exactly one of the two targets is set — see `validateTransferTarget`.
class AccountTransfer {
  const AccountTransfer({
    this.id,
    required this.fromAccountId,
    this.toAccountId,
    this.toPersonName,
    required this.amount,
    this.note,
    this.receiptImagePath,
    required this.date,
  });

  final int? id;
  final int fromAccountId;
  final int? toAccountId;
  final String? toPersonName;
  final double amount;
  final String? note;

  /// Local file path of the attached receipt screenshot/photo, if any.
  final String? receiptImagePath;

  /// When the transfer happened (date and time).
  final DateTime date;

  bool get isToPerson => toAccountId == null;

  AccountTransfer copyWith({
    int? id,
    int? fromAccountId,
    int? toAccountId,
    String? toPersonName,
    double? amount,
    String? note,
    String? receiptImagePath,
    DateTime? date,
    bool clearToAccountId = false,
    bool clearToPersonName = false,
    bool clearNote = false,
    bool clearReceiptImagePath = false,
  }) {
    return AccountTransfer(
      id: id ?? this.id,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: clearToAccountId ? null : (toAccountId ?? this.toAccountId),
      toPersonName: clearToPersonName
          ? null
          : (toPersonName ?? this.toPersonName),
      amount: amount ?? this.amount,
      note: clearNote ? null : (note ?? this.note),
      receiptImagePath: clearReceiptImagePath
          ? null
          : (receiptImagePath ?? this.receiptImagePath),
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AccountTransfer &&
            other.id == id &&
            other.fromAccountId == fromAccountId &&
            other.toAccountId == toAccountId &&
            other.toPersonName == toPersonName &&
            other.amount == amount &&
            other.note == note &&
            other.receiptImagePath == receiptImagePath &&
            other.date == date);
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromAccountId,
    toAccountId,
    toPersonName,
    amount,
    note,
    receiptImagePath,
    date,
  );

  @override
  String toString() =>
      'AccountTransfer(id: $id, fromAccountId: $fromAccountId, '
      'toAccountId: $toAccountId, toPersonName: $toPersonName, amount: '
      '$amount, note: $note, receiptImagePath: $receiptImagePath, date: $date)';
}
