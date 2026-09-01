import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/presentation/category_visuals.dart';
import 'package:expensetracker/presentation/format.dart';
import 'package:expensetracker/presentation/widgets/category_chip.dart';
import 'package:expensetracker/presentation/widgets/empty_state.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({
    super.key,
    required this.totals,
    required this.selected,
    required this.onCategoryTapped,
  });

  final Map<ExpenseCategory, double> totals;
  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory> onCategoryTapped;

  List<MapEntry<ExpenseCategory, double>> get _slices {
    final entries = totals.entries.where((entry) => entry.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final slices = _slices;
    if (slices.isEmpty) {
      return const EmptyState(
        icon: Icons.pie_chart_outline,
        message: 'No spending to chart this month.',
      );
    }

    final total = slices.fold(0.0, (sum, entry) => sum + entry.value);
    return Column(
      children: [
        SizedBox(
          key: const Key('category-pie-chart'),
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 42,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (event is! FlTapUpEvent) {
                    return;
                  }
                  final index = response?.touchedSection?.touchedSectionIndex;
                  if (index == null || index < 0 || index >= slices.length) {
                    return;
                  }
                  onCategoryTapped(slices[index].key);
                },
              ),
              sections: [
                for (final entry in slices)
                  PieChartSectionData(
                    value: entry.value,
                    color: entry.key.color,
                    radius: selected == entry.key ? 72 : 58,
                    title: _percentLabel(entry.value, total),
                    showTitle: entry.value / total >= 0.08,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            for (final entry in slices)
              CategoryChip(
                key: Key('legend-${entry.key.name}'),
                category: entry.key,
                selected: selected == entry.key,
                onSelected: (_) => onCategoryTapped(entry.key),
              ),
          ],
        ),
        if (selected != null)
          TextButton(
            onPressed: () => onCategoryTapped(selected!),
            child: Text('Show all · ${formatAmount(total)} total'),
          ),
      ],
    );
  }

  String _percentLabel(double value, double total) {
    if (total <= 0) {
      return '';
    }
    return '${((value / total) * 100).round()}%';
  }
}
