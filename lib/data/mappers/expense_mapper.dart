import 'package:expensetracker/domain/entities/expense.dart';

import '../models/expense_record.dart';

extension ExpenseRecordMapper on ExpenseRecord {
  Expense toDomain() => Expense(
    id: id,
    amount: amount,
    category: category,
    date: date,
    note: note,
    customCategory: customCategory,
  );
}

extension ExpenseMapper on Expense {
  ExpenseRecord toRecord() => ExpenseRecord(
    id: id,
    amount: amount,
    category: category,
    date: date,
    note: note,
    customCategory: customCategory,
  );
}
