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
}
