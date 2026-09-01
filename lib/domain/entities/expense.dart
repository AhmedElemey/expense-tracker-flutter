import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense_category.dart';

part 'expense.freezed.dart';

/// Domain expense. [id] is null until persisted.
@freezed
class Expense with _$Expense {
  const Expense._();

  const factory Expense({
    int? id,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
    String? customCategory,
  }) = _Expense;

  /// Value written to SQLite `category TEXT`. Custom Other labels are stored
  /// as the typed string; unknown strings map back to [ExpenseCategory.other].
  String get categoryStorage {
    final custom = customCategory?.trim();
    if (category == ExpenseCategory.other &&
        custom != null &&
        custom.isNotEmpty) {
      return custom;
    }
    return category.name;
  }
}
