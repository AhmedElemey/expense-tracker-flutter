import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense_category.dart';

part 'transaction.freezed.dart';

/// Domain expense. [id] is null until persisted.
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    int? id,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) = _Transaction;
}
