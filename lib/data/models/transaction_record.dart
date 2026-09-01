import 'package:freezed_annotation/freezed_annotation.dart';

import '../database/expense_database.dart';
import 'expense_category.dart';

part 'transaction_record.freezed.dart';
part 'transaction_record.g.dart';

/// Row in the `transactions` SQLite table.
@freezed
class TransactionRecord with _$TransactionRecord {
  const TransactionRecord._();

  const factory TransactionRecord({
    int? id,
    required double amount,
    @ExpenseCategoryConverter() required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) = _TransactionRecord;

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      _$TransactionRecordFromJson(json);

  factory TransactionRecord.fromMap(Map<String, Object?> map) {
    return TransactionRecord.fromJson(Map<String, dynamic>.from(map));
  }

  Map<String, Object?> toMap() => {
    if (id != null) TransactionColumns.id: id,
    TransactionColumns.amount: amount,
    TransactionColumns.category: category.name,
    TransactionColumns.date: date.toIso8601String(),
    TransactionColumns.note: note,
  };
}
