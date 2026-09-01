import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const kTransactionsTable = 'transactions';

/// Column names for [kTransactionsTable].
abstract final class TransactionColumns {
  static const id = 'id';
  static const amount = 'amount';
  static const category = 'category';
  static const date = 'date';
  static const note = 'note';
}

/// Opens (and creates) the local SQLite database.
class ExpenseDatabase {
  ExpenseDatabase({this.path});

  /// File path, or [inMemoryDatabasePath] in tests.
  final String? path;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dbPath = path ?? join(await getDatabasesPath(), 'expense_tracker.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE $kTransactionsTable (
  ${TransactionColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${TransactionColumns.amount} REAL NOT NULL,
  ${TransactionColumns.category} TEXT NOT NULL,
  ${TransactionColumns.date} TEXT NOT NULL,
  ${TransactionColumns.note} TEXT
)
''');
        await db.execute('''
CREATE INDEX idx_transactions_date
ON $kTransactionsTable (${TransactionColumns.date})
''');
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
