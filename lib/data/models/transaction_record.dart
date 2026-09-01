import 'expense_category.dart';

/// Row in the `transactions` SQLite table.
class TransactionRecord {
  const TransactionRecord({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  final int? id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;

  TransactionRecord copyWith({
    int? id,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'amount': amount,
        'category': category.name,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory TransactionRecord.fromMap(Map<String, Object?> map) {
    return TransactionRecord(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.fromStorage(map['category'] as String),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }
}
