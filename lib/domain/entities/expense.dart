import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense_category.dart';

part 'expense.freezed.dart';

/// Domain expense. [id] is null until persisted.
@freezed
class Expense with _$Expense {
  const factory Expense({
    int? id,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) = _Expense;
}
