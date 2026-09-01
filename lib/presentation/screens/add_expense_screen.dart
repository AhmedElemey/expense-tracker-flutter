import 'package:flutter/material.dart';

import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/widgets/expense_form.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key, this.existing});

  final Expense? existing;

  static Future<bool> open(BuildContext context, {Expense? existing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(existing: existing),
        fullscreenDialog: true,
      ),
    );
    return saved ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editExpenseTitle : l10n.addExpenseTitle),
      ),
      body: ExpenseForm(
        existing: existing,
        onSaved: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
