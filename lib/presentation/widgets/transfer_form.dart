import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/domain/entities/account_transfer.dart';
import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/presentation/providers/account_providers.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';

enum _TransferDestination { account, person }

class TransferForm extends ConsumerStatefulWidget {
  const TransferForm({super.key, required this.fromAccountId, this.onSaved});

  final int fromAccountId;
  final VoidCallback? onSaved;

  @override
  ConsumerState<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<TransferForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _personNameController = TextEditingController();

  _TransferDestination _destination = _TransferDestination.account;
  int? _toAccountId;
  DateTime _date = DateTime.now();
  String? _pickedImagePath;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  var _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _personNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final accounts = ref.watch(activeAccountsProvider);

    return accounts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text(l10n.couldNotLoadAccounts(error))),
      data: (list) {
        final otherAccounts = list
            .map((a) => a.account)
            .where((a) => a.id != widget.fromAccountId)
            .toList();
        _toAccountId ??= otherAccounts.isEmpty ? null : otherAccounts.first.id;

        return Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                key: const Key('transfer-amount'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                key: const Key('transfer-date'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(l10n.dateLabel),
                subtitle: Text(
                  '${formatDay(_date, Localizations.localeOf(context).toString())} '
                  '${TimeOfDay.fromDateTime(_date).format(context)}',
                ),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 16),
              Text(l10n.transferToLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<_TransferDestination>(
                key: const Key('transfer-destination'),
                segments: [
                  ButtonSegment(
                    value: _TransferDestination.account,
                    label: Text(l10n.transferToAccount),
                    icon: const Icon(Icons.swap_horiz),
                  ),
                  ButtonSegment(
                    value: _TransferDestination.person,
                    label: Text(l10n.transferToPerson),
                    icon: const Icon(Icons.person_outline),
                  ),
                ],
                selected: {_destination},
                onSelectionChanged: (selection) =>
                    setState(() => _destination = selection.first),
              ),
              const SizedBox(height: 16),
              if (_destination == _TransferDestination.account)
                _AccountDestinationField(
                  accounts: otherAccounts,
                  selectedId: _toAccountId,
                  onChanged: (id) => setState(() => _toAccountId = id),
                )
              else
                _PersonDestinationField(nameController: _personNameController),
              const SizedBox(height: 16),
              _ReceiptPicker(
                imagePath: _pickedImagePath,
                onPickCamera: () => _pickImage(ImageSource.camera),
                onPickGallery: () => _pickImage(ImageSource.gallery),
                onRemoveImage: () => setState(() => _pickedImagePath = null),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('transfer-note'),
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
                key: const Key('transfer-save'),
                onPressed: _saving ? null : () => _submit(otherAccounts),
                child: Text(_saving ? l10n.saving : l10n.save),
              ),
            ],
          ),
        );
      },
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

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(_date.year + 5, 12, 31),
    );
    if (pickedDate == null || !mounted) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (pickedTime == null) {
      return;
    }
    setState(() {
      _date = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) {
      return;
    }
    setState(() => _pickedImagePath = picked.path);
  }

  Future<void> _submit(List<Account> otherAccounts) async {
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    final l10n = AppLocalizations.of(context);
    final isPerson = _destination == _TransferDestination.person;
    final personName = _personNameController.text.trim();
    if (isPerson && personName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterRecipientName)));
      return;
    }
    if (!isPerson && (_toAccountId == null || otherAccounts.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noOtherAccounts)));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    try {
      String? receiptPath;
      if (_pickedImagePath != null) {
        receiptPath = await ref
            .read(receiptStorageProvider)
            .save(_pickedImagePath!);
      }
      final note = _noteController.text.trim();
      final transfer = AccountTransfer(
        fromAccountId: widget.fromAccountId,
        toAccountId: isPerson ? null : _toAccountId,
        toPersonName: isPerson ? personName : null,
        amount: _parseAmount(_amountController.text)!,
        note: note.isEmpty ? null : note,
        receiptImagePath: receiptPath,
        date: _date,
      );
      await ref
          .read(accountTransfersProvider(widget.fromAccountId).notifier)
          .add(transfer);
      widget.onSaved?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotSaveTransfer(error))),
      );
    }
  }

  static double? _parseAmount(String? value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }
}

class _AccountDestinationField extends StatelessWidget {
  const _AccountDestinationField({
    required this.accounts,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Account> accounts;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (accounts.isEmpty) {
      return Text(
        l10n.noOtherAccounts,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return DropdownButtonFormField<int>(
      key: const Key('transfer-to-account'),
      initialValue: selectedId,
      decoration: InputDecoration(
        labelText: l10n.transferToAccountLabel,
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
      ),
      items: [
        for (final account in accounts)
          DropdownMenuItem(value: account.id, child: Text(account.name)),
      ],
      onChanged: onChanged,
    );
  }
}

class _PersonDestinationField extends StatelessWidget {
  const _PersonDestinationField({required this.nameController});

  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      key: const Key('transfer-person-name'),
      controller: nameController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: l10n.recipientNameLabel,
        prefixIcon: const Icon(Icons.person_outline),
      ),
    );
  }
}

/// Optional receipt/screenshot, available for any transfer destination —
/// a card↔cash move (e.g. an ATM slip) or a payment to a person alike.
class _ReceiptPicker extends StatelessWidget {
  const _ReceiptPicker({
    required this.imagePath,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onRemoveImage,
  });

  final String? imagePath;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.receiptLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (imagePath != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              PositionedDirectional(
                top: 4,
                end: 4,
                child: IconButton.filledTonal(
                  key: const Key('transfer-remove-receipt'),
                  icon: const Icon(Icons.close),
                  onPressed: onRemoveImage,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('transfer-pick-camera'),
                  onPressed: onPickCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(l10n.takePhoto),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('transfer-pick-gallery'),
                  onPressed: onPickGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.chooseFromGallery),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
