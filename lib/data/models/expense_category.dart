import 'package:json_annotation/json_annotation.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';

export 'package:expensetracker/domain/entities/expense_category.dart';

/// Maps [ExpenseCategory] to its SQLite/JSON string (`food`, `transport`, …).
class ExpenseCategoryConverter
    implements JsonConverter<ExpenseCategory, String> {
  const ExpenseCategoryConverter();

  @override
  ExpenseCategory fromJson(String json) => ExpenseCategory.fromStorage(json);

  @override
  String toJson(ExpenseCategory object) => object.name;
}
