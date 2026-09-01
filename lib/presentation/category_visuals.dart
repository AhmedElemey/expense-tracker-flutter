import 'package:flutter/material.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';

extension ExpenseCategoryVisuals on ExpenseCategory {
  IconData get icon => switch (this) {
    ExpenseCategory.food => Icons.restaurant,
    ExpenseCategory.transport => Icons.directions_car,
    ExpenseCategory.bills => Icons.receipt_long,
    ExpenseCategory.entertainment => Icons.movie,
    ExpenseCategory.shopping => Icons.shopping_bag,
    ExpenseCategory.health => Icons.favorite,
    ExpenseCategory.other => Icons.more_horiz,
  };

  Color get color => switch (this) {
    ExpenseCategory.food => const Color(0xFFEF5350),
    ExpenseCategory.transport => const Color(0xFF42A5F5),
    ExpenseCategory.bills => const Color(0xFFFFA726),
    ExpenseCategory.entertainment => const Color(0xFFAB47BC),
    ExpenseCategory.shopping => const Color(0xFFEC407A),
    ExpenseCategory.health => const Color(0xFF66BB6A),
    ExpenseCategory.other => const Color(0xFF78909C),
  };
}
