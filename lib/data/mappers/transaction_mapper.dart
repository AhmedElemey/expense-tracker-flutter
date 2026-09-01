import 'package:expensetracker/domain/entities/transaction.dart';

import '../models/transaction_record.dart';

extension TransactionRecordMapper on TransactionRecord {
  Transaction toDomain() => Transaction(
    id: id,
    amount: amount,
    category: category,
    date: date,
    note: note,
  );
}

extension TransactionMapper on Transaction {
  TransactionRecord toRecord() => TransactionRecord(
    id: id,
    amount: amount,
    category: category,
    date: date,
    note: note,
  );
}
