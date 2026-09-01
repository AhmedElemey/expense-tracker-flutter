import 'package:flutter/material.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/category_l10n.dart';
import 'package:expensetracker/presentation/category_visuals.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final ExpenseCategory category;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : category.color;
    return ChoiceChip(
      avatar: Icon(category.icon, size: 18, color: foreground),
      label: Text(category.localizedName(AppLocalizations.of(context))),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      selectedColor: category.color,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}
