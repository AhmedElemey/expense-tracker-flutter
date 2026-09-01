import 'package:flutter/material.dart';

/// Preset spend categories. Persist [name] in SQLite (`category TEXT`).
enum ExpenseCategory {
  food,
  transport,
  bills,
  entertainment,
  shopping,
  health,
  other;

  String get label => switch (this) {
    ExpenseCategory.food => 'Food',
    ExpenseCategory.transport => 'Transport',
    ExpenseCategory.bills => 'Bills',
    ExpenseCategory.entertainment => 'Entertainment',
    ExpenseCategory.shopping => 'Shopping',
    ExpenseCategory.health => 'Health',
    ExpenseCategory.other => 'Other',
  };

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

  static ExpenseCategory fromStorage(String value) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
