import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/money.dart';
import '../../domain/entities/category.dart';

/// Gráfico de rosca com as despesas do mês por categoria e legenda.
class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({
    super.key,
    required this.expensesByCategory,
    required this.categoriesById,
  });

  final Map<String, int> expensesByCategory;
  final Map<String, FinanceCategory> categoriesById;

  @override
  Widget build(BuildContext context) {
    final total = expensesByCategory.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Nenhuma despesa neste mês.')),
      );
    }

    final entries = expensesByCategory.entries.toList();
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 50,
              sectionsSpace: 2,
              sections: [
                for (final e in entries)
                  PieChartSectionData(
                    value: e.value.toDouble(),
                    color: Color(
                      categoriesById[e.key]?.colorValue ?? 0xFF757575,
                    ),
                    radius: 34,
                    showTitle: false,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final e in entries.take(6))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(
                      categoriesById[e.key]?.colorValue ?? 0xFF757575,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(categoriesById[e.key]?.name ?? 'Sem categoria'),
                ),
                Text(
                  '${(e.value * 100 / total).round()}%',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Text(Money.format(e.value), style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }
}
