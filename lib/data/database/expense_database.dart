import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const kTransactionsTable = 'transactions';
const kAccountsTable = 'accounts';
const kAccountTransfersTable = 'account_transfers';
const kTransactionAccountsTable = 'transaction_accounts';

/// Column names for [kTransactionsTable].
abstract final class TransactionColumns {
  static const id = 'id';
  static const amount = 'amount';
  static const category = 'category';
  static const date = 'date';
  static const note = 'note';
}

/// Column names for [kAccountsTable] — a card or cash the user tracks.
abstract final class AccountColumns {
  static const id = 'id';
  static const name = 'name';
  static const type = 'type';
  static const initialBalance = 'initial_balance';
  static const colorValue = 'color_value';
  static const archived = 'archived';
  static const createdAt = 'created_at';
}

/// Column names for [kAccountTransfersTable] — money moved out of an
/// account, into either another account or an external person.
abstract final class AccountTransferColumns {
  static const id = 'id';
  static const fromAccountId = 'from_account_id';
  static const toAccountId = 'to_account_id';
  static const toPersonName = 'to_person_name';
  static const amount = 'amount';
  static const note = 'note';
  static const receiptImagePath = 'receipt_image_path';
  static const date = 'date';
}

/// Column names for [kTransactionAccountsTable] — links a `transactions`
/// row to the account it was paid from. Kept as a side table (rather than a
/// column on `transactions`) so the existing, code-generated `Expense` /
/// `ExpenseRecord` models never need to change shape.
abstract final class TransactionAccountColumns {
  static const transactionId = 'transaction_id';
  static const accountId = 'account_id';
}

/// Opens (and creates/upgrades) the local SQLite database.
class ExpenseDatabase {
  ExpenseDatabase({this.path});

  /// File path, or [inMemoryDatabasePath] in tests.
  final String? path;

  static const _version = 2;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dbPath = path ?? join(await getDatabasesPath(), 'expense_tracker.db');
    return openDatabase(
      dbPath,
      version: _version,
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
        await _createAccountTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createAccountTables(db);
        }
      },
    );
  }

  Future<void> _createAccountTables(DatabaseExecutor db) async {
    await db.execute('''
CREATE TABLE $kAccountsTable (
  ${AccountColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${AccountColumns.name} TEXT NOT NULL,
  ${AccountColumns.type} TEXT NOT NULL,
  ${AccountColumns.initialBalance} REAL NOT NULL DEFAULT 0,
  ${AccountColumns.colorValue} INTEGER NOT NULL,
  ${AccountColumns.archived} INTEGER NOT NULL DEFAULT 0,
  ${AccountColumns.createdAt} TEXT NOT NULL
)
''');
    await db.execute('''
CREATE TABLE $kAccountTransfersTable (
  ${AccountTransferColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${AccountTransferColumns.fromAccountId} INTEGER NOT NULL,
  ${AccountTransferColumns.toAccountId} INTEGER,
  ${AccountTransferColumns.toPersonName} TEXT,
  ${AccountTransferColumns.amount} REAL NOT NULL,
  ${AccountTransferColumns.note} TEXT,
  ${AccountTransferColumns.receiptImagePath} TEXT,
  ${AccountTransferColumns.date} TEXT NOT NULL
)
''');
    await db.execute('''
CREATE INDEX idx_account_transfers_from
ON $kAccountTransfersTable (${AccountTransferColumns.fromAccountId})
''');
    await db.execute('''
CREATE INDEX idx_account_transfers_to
ON $kAccountTransfersTable (${AccountTransferColumns.toAccountId})
''');
    await db.execute('''
CREATE TABLE $kTransactionAccountsTable (
  ${TransactionAccountColumns.transactionId} INTEGER PRIMARY KEY,
  ${TransactionAccountColumns.accountId} INTEGER NOT NULL
)
''');
    await db.execute('''
CREATE INDEX idx_transaction_accounts_account
ON $kTransactionAccountsTable (${TransactionAccountColumns.accountId})
''');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
