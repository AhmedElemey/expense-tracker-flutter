import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/domain/expense_validation.dart';
import 'package:expensetracker/domain/repositories/transaction_repository.dart';

class FakeTransactionRepository implements TransactionRepository {
  final List<Expense> items = [];
  int _nextId = 1;

  @override
  Future<int> insertTransaction(Expense expense) async {
    validateExpenseAmount(expense.amount);
    final id = _nextId++;
    items.add(expense.copyWith(id: id));
    return id;
  }

  @override
  Future<int> updateTransaction(Expense expense) async {
    final id = expense.id;
    if (id == null) {
      throw ArgumentError('updateTransaction requires a persisted id');
    }
    validateExpenseAmount(expense.amount);
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return 0;
    }
    items[index] = expense;
    return 1;
  }

  @override
  Future<int> deleteTransaction(int id) async {
    final before = items.length;
    items.removeWhere((item) => item.id == id);
    return before - items.length;
  }

  @override
  Future<List<Expense>> getAllTransactions() async {
    return _sorted(List.of(items));
  }

  @override
  Future<List<Expense>> getTransactionsByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return _sorted(
      items
          .where(
            (item) => !item.date.isBefore(start) && item.date.isBefore(end),
          )
          .toList(),
    );
  }

  @override
  Future<Map<ExpenseCategory, double>> getCategoryTotals(DateTime month) async {
    final inMonth = await getTransactionsByMonth(month);
    final totals = <ExpenseCategory, double>{};
    for (final item in inMonth) {
      totals[item.category] = (totals[item.category] ?? 0) + item.amount;
    }
    return totals;
  }

  List<Expense> _sorted(List<Expense> list) {
    list.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) {
        return byDate;
      }
      return (b.id ?? 0).compareTo(a.id ?? 0);
    });
    return list;
  }
}
