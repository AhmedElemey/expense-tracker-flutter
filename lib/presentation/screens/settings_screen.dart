import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:expensetracker/presentation/providers/app_providers.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            key: const Key('export-data'),
            leading: const Icon(Icons.ios_share),
            title: const Text('Export data'),
            subtitle: const Text('Share all expenses as a CSV file'),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            key: const Key('import-data'),
            leading: const Icon(Icons.file_open),
            title: const Text('Import data'),
            subtitle: const Text('Add expenses from a CSV export'),
            onTap: () => _import(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    try {
      final csv = await ref.read(exportExpensesProvider)();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/expenses.csv');
      await file.writeAsString(csv);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'ExpenseTracker export',
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
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
          content: Text(
            'Imported ${result.inserted}, skipped ${result.skipped} duplicate${result.skipped == 1 ? '' : 's'}.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $error')));
    }
  }
}
