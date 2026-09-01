import '../csv/expense_csv.dart';
import '../entities/expense.dart';
import '../expense_validation.dart';
import '../repositories/transaction_repository.dart';

class ImportResult {
  const ImportResult({required this.inserted, required this.skipped});

  final int inserted;
  final int skipped;
}

class ImportExpenses {
  const ImportExpenses(this._repository);

  final TransactionRepository _repository;

  Future<ImportResult> call(String csv) async {
    final incoming = ExpenseCsv.decode(csv);
    final existing = await _repository.getAllTransactions();
    final seen = {for (final expense in existing) fingerprint(expense)};

    var inserted = 0;
    var skipped = 0;
    for (final expense in incoming) {
      validateExpenseAmount(expense.amount);
      final key = fingerprint(expense);
      if (seen.contains(key)) {
        skipped++;
        continue;
      }
      await _repository.insertTransaction(expense.copyWith(id: null));
      seen.add(key);
      inserted++;
    }
    return ImportResult(inserted: inserted, skipped: skipped);
  }

  static String fingerprint(Expense expense) {
    return [
      expense.date.toIso8601String(),
      expense.amount.toString(),
      expense.categoryStorage,
      expense.note ?? '',
    ].join('|');
  }
}
