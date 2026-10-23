import 'package:flutter/material.dart';

import '../../domain/services/finance_calculator.dart';
import '../widgets/budget_progress_tile.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/history_bar_chart.dart';
import '../widgets/summary_cards.dart';
import '../widgets/transaction_tile.dart';
import 'finance_state_view.dart';
import 'transaction_form_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FinanceStateView(
      builder: (context, state) {
        final categories = state.categoriesById;
        final alerts = state.budgets
            .where((b) => b.level != BudgetLevel.ok)
            .toList();
        final recent = state.monthTransactions.take(5).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            SummaryCards(summary: state.summary),
            if (alerts.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'Orçamentos em alerta',
                child: Column(
                  children: [
                    for (final b in alerts) BudgetProgressTile(status: b),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SectionCard(
              title: 'Gastos por categoria',
              child: ExpensePieChart(
                expensesByCategory: state.expensesByCategory,
                categoriesById: categories,
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Últimos ${state.history.length} meses',
              child: HistoryBarChart(history: state.history),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Últimas transações',
              child: recent.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text('Nenhuma transação neste mês.'),
                      ),
                    )
                  : Column(
                      children: [
                        for (final t in recent)
                          TransactionTile(
                            transaction: t,
                            category: categories[t.categoryId],
                            showDate: true,
                            onTap: () => TransactionFormPage.open(
                              context,
                              transaction: t,
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
