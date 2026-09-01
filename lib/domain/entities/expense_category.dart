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

  static ExpenseCategory fromStorage(String value) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }

  static bool isKnownName(String value) {
    return ExpenseCategory.values.any((c) => c.name == value);
  }

  /// Reads the SQLite/CSV category string. Known enum names stay presets;
  /// anything else is [ExpenseCategory.other] with a custom label.
  static ({ExpenseCategory category, String? customCategory}) parseStored(
    String value,
  ) {
    if (isKnownName(value)) {
      return (category: fromStorage(value), customCategory: null);
    }
    final trimmed = value.trim();
    return (
      category: ExpenseCategory.other,
      customCategory: trimmed.isEmpty ? null : trimmed,
    );
  }
}
