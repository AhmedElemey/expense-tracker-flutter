import 'package:flutter/material.dart';

import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/widgets/account_form.dart';

class AddAccountScreen extends StatelessWidget {
  const AddAccountScreen({super.key, this.existing});

  final Account? existing;

  static Future<bool> open(BuildContext context, {Account? existing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddAccountScreen(existing: existing),
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
        title: Text(isEditing ? l10n.editAccountTitle : l10n.addAccountTitle),
      ),
      body: AccountForm(
        existing: existing,
        onSaved: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
