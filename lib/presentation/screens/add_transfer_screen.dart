import 'package:flutter/material.dart';

import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/widgets/transfer_form.dart';

class AddTransferScreen extends StatelessWidget {
  const AddTransferScreen({super.key, required this.fromAccountId});

  final int fromAccountId;

  static Future<bool> open(BuildContext context, {required int fromAccountId}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTransferScreen(fromAccountId: fromAccountId),
        fullscreenDialog: true,
      ),
    );
    return saved ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addTransferTitle)),
      body: TransferForm(
        fromAccountId: fromAccountId,
        onSaved: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
