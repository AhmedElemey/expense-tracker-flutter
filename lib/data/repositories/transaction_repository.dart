import 'package:sqflite/sqflite.dart';

import '../database/expense_database.dart';
import '../models/expense_category.dart';
import '../models/transaction_record.dart';

class TransactionRepository {
  TransactionRepository(this._database);

  final ExpenseDatabase _database;

  Future<Database> get _db => _database.database;

  Future<int> insertTransaction(TransactionRecord record) async {
    _assertValidAmount(record.amount);
    return (await _db).insert(
      kTransactionsTable,
      record.toMap()..remove('id'),
    );
  }

  Future<int> updateTransaction(TransactionRecord record) async {
    final id = record.id;
    if (id == null) {
      throw ArgumentError('updateTransaction requires a persisted id');
    }
    _assertValidAmount(record.amount);
    return (await _db).update(
      kTransactionsTable,
      record.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    return (await _db).delete(
      kTransactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionRecord>> getAllTransactions() async {
    final rows = await (await _db).query(
      kTransactionsTable,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(TransactionRecord.fromMap).toList();
  }

  /// Inclusive of [month]'s first day, exclusive of the next month.
  Future<List<TransactionRecord>> getTransactionsByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final rows = await (await _db).query(
      kTransactionsTable,
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(TransactionRecord.fromMap).toList();
  }

  Future<Map<ExpenseCategory, double>> getCategoryTotals(DateTime month) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final rows = await (await _db).rawQuery(
      '''
SELECT category, SUM(amount) AS total
FROM $kTransactionsTable
WHERE date >= ? AND date < ?
GROUP BY category
''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return {
      for (final row in rows)
        ExpenseCategory.fromStorage(row['category'] as String):
            (row['total'] as num).toDouble(),
    };
  }

  void _assertValidAmount(double amount) {
    if (amount <= 0 || amount.isNaN) {
      throw ArgumentError.value(amount, 'amount', 'must be greater than 0');
    }
  }
}
