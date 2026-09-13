import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/account_l10n.dart';
import 'package:expensetracker/presentation/account_visuals.dart';
import 'package:expensetracker/presentation/providers/account_providers.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';

class AccountForm extends ConsumerStatefulWidget {
  const AccountForm({super.key, this.existing, this.onSaved});

  final Account? existing;
  final VoidCallback? onSaved;

  @override
  ConsumerState<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  late AccountType _type;
  late Color _color;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  var _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController.text = existing?.name ?? '';
    _balanceController.text = existing == null
        ? '0'
        : _formatAmount(existing.initialBalance);
    _type = existing?.type ?? AccountType.card;
    _color = existing == null
        ? kAccountColorPalette.first
        : Color(existing.colorValue);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currencySymbol = ref.watch(currencySymbolProvider);
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            key: const Key('account-name'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.accountNameLabel,
              hintText: l10n.accountNameHint,
              prefixIcon: const Icon(Icons.label_outline),
            ),
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          Text(l10n.accountTypeLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<AccountType>(
            key: const Key('account-type'),
            segments: [
              for (final type in AccountType.values)
                ButtonSegment(
                  value: type,
                  label: Text(type.localizedName(l10n)),
                  icon: Icon(type.icon),
                ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) =>
                setState(() => _type = selection.first),
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('account-initial-balance'),
            controller: _balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.accountInitialBalanceLabel,
              prefixText: currencySymbol,
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
            ),
            validator: _validateBalance,
          ),
          const SizedBox(height: 16),
          Text(l10n.accountColorLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in kAccountColorPalette)
                _ColorSwatch(
                  color: color,
                  selected: color.toARGB32() == _color.toARGB32(),
                  onTap: () => setState(() => _color = color),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('account-save'),
            onPressed: _saving ? null : _submit,
            child: Text(
              _saving
                  ? l10n.saving
                  : (_isEditing ? l10n.saveChanges : l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context).enterAccountName;
    }
    return null;
  }

  String? _validateBalance(String? value) {
    if (_parseAmount(value) == null) {
      return AppLocalizations.of(context).enterValidAmount;
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final account = Account(
      id: widget.existing?.id,
      name: _nameController.text.trim(),
      type: _type,
      initialBalance: _parseAmount(_balanceController.text)!,
      colorValue: _color.toARGB32(),
      archived: widget.existing?.archived ?? false,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    setState(() => _saving = true);
    try {
      final notifier = ref.read(accountsProvider.notifier);
      if (_isEditing) {
        await notifier.edit(account);
      } else {
        await notifier.add(account);
      }
      widget.onSaved?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotSaveAccount(error)),
        ),
      );
    }
  }

  static double? _parseAmount(String? value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toString();
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2,
                )
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
