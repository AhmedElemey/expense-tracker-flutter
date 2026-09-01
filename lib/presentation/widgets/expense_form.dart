import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/providers/transactions_provider.dart';
import 'package:expensetracker/presentation/widgets/category_chip.dart';

class ExpenseForm extends ConsumerStatefulWidget {
  const ExpenseForm({super.key, this.existing, this.onSaved});

  final Expense? existing;
  final VoidCallback? onSaved;

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customCategoryController = TextEditingController();

  late DateTime _date;
  late ExpenseCategory _category;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  var _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _amountController.text = existing == null
        ? ''
        : _formatAmount(existing.amount);
    _noteController.text = existing?.note ?? '';
    _customCategoryController.text = existing?.customCategory ?? '';
    _date = existing?.date ?? DateTime.now();
    _category = existing?.category ?? ExpenseCategory.food;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
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
            key: const Key('expense-amount'),
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.amountLabel,
              hintText: l10n.amountHint,
              prefixText: currencySymbol,
              prefixIcon: const Icon(Icons.attach_money),
            ),
            validator: _validateAmount,
          ),
          const SizedBox(height: 8),
          ListTile(
            key: const Key('expense-date'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(l10n.dateLabel),
            subtitle: Text(
              formatDay(_date, Localizations.localeOf(context).toString()),
            ),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          Text(l10n.categoryLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final category in ExpenseCategory.values)
                CategoryChip(
                  key: Key('category-${category.name}'),
                  category: category,
                  selected: _category == category,
                  onSelected: (_) => setState(() {
                    _category = category;
                    if (category != ExpenseCategory.other) {
                      _customCategoryController.clear();
                    }
                  }),
                ),
            ],
          ),
          if (_category == ExpenseCategory.other) ...[
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('expense-custom-category'),
              controller: _customCategoryController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.customCategoryLabel,
                hintText: l10n.customCategoryHint,
                prefixIcon: const Icon(Icons.edit_outlined),
              ),
              validator: _validateCustomCategory,
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('expense-note'),
            controller: _noteController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.noteLabel,
              prefixIcon: const Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('expense-save'),
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

  String? _validateAmount(String? value) {
    final l10n = AppLocalizations.of(context);
    final amount = _parseAmount(value);
    if (amount == null) {
      return l10n.enterAmount;
    }
    if (amount <= 0) {
      return l10n.amountMustBePositive;
    }
    return null;
  }

  String? _validateCustomCategory(String? value) {
    if (_category != ExpenseCategory.other) {
      return null;
    }
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context).enterCustomCategory;
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(_date.year + 5, 12, 31),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
    });
  }

  Future<void> _submit() async {
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final note = _noteController.text.trim();
    final custom = _category == ExpenseCategory.other
        ? _customCategoryController.text.trim()
        : '';
    final expense = Expense(
      id: widget.existing?.id,
      amount: _parseAmount(_amountController.text)!,
      category: _category,
      date: _date,
      note: note.isEmpty ? null : note,
      customCategory: custom.isEmpty ? null : custom,
    );

    setState(() => _saving = true);
    try {
      final notifier = ref.read(transactionsProvider.notifier);
      if (_isEditing) {
        await notifier.edit(expense);
      } else {
        await notifier.add(expense);
      }
      widget.onSaved?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).couldNotSaveExpense(error),
          ),
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
