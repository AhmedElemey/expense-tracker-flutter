import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/expense.dart';
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
    _date = existing?.date ?? DateTime.now();
    _category = existing?.category ?? ExpenseCategory.food;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: '0.00',
              prefixIcon: Icon(Icons.attach_money),
            ),
            validator: _validateAmount,
          ),
          const SizedBox(height: 8),
          ListTile(
            key: const Key('expense-date'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(DateFormat.yMMMd().format(_date)),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          Text('Category', style: theme.textTheme.titleSmall),
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
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('expense-note'),
            controller: _noteController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('expense-save'),
            onPressed: _saving ? null : _submit,
            child: Text(
              _saving ? 'Saving…' : (_isEditing ? 'Save changes' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateAmount(String? value) {
    final amount = _parseAmount(value);
    if (amount == null) {
      return 'Enter an amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
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
    final expense = Expense(
      id: widget.existing?.id,
      amount: _parseAmount(_amountController.text)!,
      category: _category,
      date: _date,
      note: note.isEmpty ? null : note,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save expense: $error')));
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
