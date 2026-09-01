import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expensetracker/domain/entities/monthly_totals.dart';

import 'app_providers.dart';
import 'dashboard_providers.dart';

final monthlyTotalsProvider = FutureProvider<MonthlyTotals>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(getMonthlyTotalsProvider)(month);
});
