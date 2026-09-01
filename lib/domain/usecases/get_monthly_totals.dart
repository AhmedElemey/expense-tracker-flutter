import '../entities/monthly_totals.dart';
import '../repositories/transaction_repository.dart';

class GetMonthlyTotals {
  const GetMonthlyTotals(this._repository);

  final TransactionRepository _repository;

  Future<MonthlyTotals> call(DateTime month) async {
    final byCategory = await _repository.getCategoryTotals(month);
    return MonthlyTotals(
      month: DateTime(month.year, month.month),
      byCategory: byCategory,
    );
  }
}
