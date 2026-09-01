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
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? customCategory,
  }) = _ExpenseRecord;

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) =>
      _$ExpenseRecordFromJson(json);

  factory ExpenseRecord.fromMap(Map<String, Object?> map) {
    final stored = ExpenseCategory.parseStored(
      map[TransactionColumns.category] as String? ?? ExpenseCategory.other.name,
    );
    return ExpenseRecord(
      id: map[TransactionColumns.id] as int?,
      amount: (map[TransactionColumns.amount] as num).toDouble(),
      category: stored.category,
      date: DateTime.parse(map[TransactionColumns.date] as String),
      note: map[TransactionColumns.note] as String?,
      customCategory: stored.customCategory,
    );
  }

  String get storageCategory {
    final custom = customCategory?.trim();
    if (category == ExpenseCategory.other &&
        custom != null &&
        custom.isNotEmpty) {
      return custom;
    }
    return category.name;
  }

  Map<String, Object?> toMap() => {
    if (id != null) TransactionColumns.id: id,
    TransactionColumns.amount: amount,
    TransactionColumns.category: storageCategory,
    TransactionColumns.date: date.toIso8601String(),
    TransactionColumns.note: note,
  };
}
