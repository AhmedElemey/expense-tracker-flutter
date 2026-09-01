import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const kTransactionsTable = 'transactions';

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
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  note TEXT
)
''');
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
