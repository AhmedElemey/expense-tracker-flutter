import 'package:freezed_annotation/freezed_annotation.dart';

import '../database/expense_database.dart';
import 'expense_category.dart';

part 'expense_record.freezed.dart';
part 'expense_record.g.dart';

/// Row in the `transactions` SQLite table.
@freezed
class ExpenseRecord with _$ExpenseRecord {
  const ExpenseRecord._();

  const factory ExpenseRecord({
    int? id,
    required double amount,
    @ExpenseCategoryConverter() required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) = _ExpenseRecord;

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) =>
      _$ExpenseRecordFromJson(json);

  factory ExpenseRecord.fromMap(Map<String, Object?> map) {
    return ExpenseRecord.fromJson(Map<String, dynamic>.from(map));
  }

  Map<String, Object?> toMap() => {
    if (id != null) TransactionColumns.id: id,
    TransactionColumns.amount: amount,
    TransactionColumns.category: category.name,
    TransactionColumns.date: date.toIso8601String(),
    TransactionColumns.note: note,
  };
}
