import 'package:sqflite/sqflite.dart' hide Transaction;

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/entities/transaction.dart';
import 'package:expensetracker/domain/expense_validation.dart';
import 'package:expensetracker/domain/repositories/transaction_repository.dart';

import '../database/expense_database.dart';
import '../mappers/transaction_mapper.dart';
import '../models/transaction_record.dart';

/// SQLite-backed [TransactionRepository].
class SqliteTransactionRepository implements TransactionRepository {
  SqliteTransactionRepository(this._database);

  final ExpenseDatabase _database;

  Future<Database> get _db => _database.database;

  @override
  Future<int> insertTransaction(Transaction transaction) async {
    validateExpenseAmount(transaction.amount);
    return (await _db).insert(
      kTransactionsTable,
      transaction.toRecord().toMap()..remove(TransactionColumns.id),
    );
  }

  @override
  Future<int> updateTransaction(Transaction transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw ArgumentError('updateTransaction requires a persisted id');
    }
    validateExpenseAmount(transaction.amount);
    return (await _db).update(
      kTransactionsTable,
      transaction.toRecord().toMap()..remove(TransactionColumns.id),
      where: '${TransactionColumns.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteTransaction(int id) async {
    return (await _db).delete(
      kTransactionsTable,
      where: '${TransactionColumns.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final rows = await (await _db).query(
      kTransactionsTable,
      orderBy: '${TransactionColumns.date} DESC, ${TransactionColumns.id} DESC',
    );
    return rows
        .map(TransactionRecord.fromMap)
        .map((record) => record.toDomain())
        .toList();
  }

  /// Inclusive of [month]'s first day, exclusive of the next month.
  @override
  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    final bounds = _monthBounds(month);
    final rows = await (await _db).query(
      kTransactionsTable,
      where:
          '${TransactionColumns.date} >= ? AND ${TransactionColumns.date} < ?',
      whereArgs: [bounds.start, bounds.end],
      orderBy: '${TransactionColumns.date} DESC, ${TransactionColumns.id} DESC',
    );
    return rows
        .map(TransactionRecord.fromMap)
        .map((record) => record.toDomain())
        .toList();
  }

  @override
  Future<Map<ExpenseCategory, double>> getCategoryTotals(DateTime month) async {
    final bounds = _monthBounds(month);
    final rows = await (await _db).rawQuery(
      '''
SELECT ${TransactionColumns.category}, SUM(${TransactionColumns.amount}) AS total
FROM $kTransactionsTable
WHERE ${TransactionColumns.date} >= ? AND ${TransactionColumns.date} < ?
GROUP BY ${TransactionColumns.category}
''',
      [bounds.start, bounds.end],
    );
    return {
      for (final row in rows)
        ExpenseCategory.fromStorage(row[TransactionColumns.category] as String):
            (row['total'] as num).toDouble(),
    };
  }

  ({String start, String end}) _monthBounds(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return (start: start.toIso8601String(), end: end.toIso8601String());
  }
}
