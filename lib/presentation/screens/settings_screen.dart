import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/presentation/providers/app_providers.dart';
import 'package:expensetracker/presentation/providers/dashboard_providers.dart';
import 'package:expensetracker/presentation/providers/locale_provider.dart';
import 'package:expensetracker/presentation/providers/transactions_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final localeCode = ref.watch(localeCodeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.languageTitle),
            subtitle: Text(l10n.languageSubtitle),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('language-en'),
                  label: Text(l10n.languageEnglish),
                  selected: localeCode == 'en',
                  onSelected: (selected) {
                    if (selected) {
                      setAppLocale(ref, 'en');
                    }
                  },
                ),
                ChoiceChip(
                  key: const Key('language-ar'),
                  label: Text(l10n.languageArabic),
                  selected: localeCode == 'ar',
                  onSelected: (selected) {
                    if (selected) {
                      setAppLocale(ref, 'ar');
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(l10n.currencyTitle),
            subtitle: Text(l10n.currencySubtitle),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              children: [
                for (final symbol in kCurrencySymbols)
                  ChoiceChip(
                    key: Key('currency-$symbol'),
                    label: Text(symbol),
                    selected: currencySymbol == symbol,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(currencySymbolProvider.notifier).state =
                            symbol;
                      }
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            key: const Key('export-data'),
            leading: const Icon(Icons.ios_share),
            title: Text(l10n.exportData),
            subtitle: Text(l10n.exportDataSubtitle),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            key: const Key('import-data'),
            leading: const Icon(Icons.file_open),
            title: Text(l10n.importData),
            subtitle: Text(l10n.importDataSubtitle),
            onTap: () => _import(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final csv = await ref.read(exportExpensesProvider)();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/expenses.csv');
      await file.writeAsString(csv);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: l10n.exportShareSubject,
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportFailed(error))));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        return;
      }
      final file = picked.files.single;
      final csv = file.bytes != null
          ? utf8.decode(file.bytes!)
          : await File(file.path!).readAsString();
      final result = await ref.read(importExpensesProvider)(csv);
      await ref.read(transactionsProvider.notifier).refresh();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.importResult(result.inserted, result.skipped)),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.importFailed(error))));
    }
  }
}
