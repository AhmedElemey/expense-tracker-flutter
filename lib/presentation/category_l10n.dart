import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/l10n/app_localizations.dart';

extension ExpenseCategoryL10n on ExpenseCategory {
  String localizedName(AppLocalizations l10n) {
    return switch (this) {
      ExpenseCategory.food => l10n.categoryFood,
      ExpenseCategory.transport => l10n.categoryTransport,
      ExpenseCategory.bills => l10n.categoryBills,
      ExpenseCategory.entertainment => l10n.categoryEntertainment,
      ExpenseCategory.shopping => l10n.categoryShopping,
      ExpenseCategory.health => l10n.categoryHealth,
      ExpenseCategory.other => l10n.categoryOther,
    };
  }

  String displayName(AppLocalizations l10n, {String? customCategory}) {
    final custom = customCategory?.trim();
    if (this == ExpenseCategory.other && custom != null && custom.isNotEmpty) {
      return custom;
    }
    return localizedName(l10n);
  }
}
