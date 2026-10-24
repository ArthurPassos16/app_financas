import 'package:app_financas/core/utils/year_month.dart';
import 'package:app_financas/features/finance/domain/services/finance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures.dart';

void main() {
  const october = YearMonth(2026, 10);

  final transactions = [
    income(500000, DateTime(2026, 10, 5)),
    expense(85000, 'food', DateTime(2026, 10, 10)),
    expense(15000, 'food', DateTime(2026, 10, 20)),
    expense(25000, 'transport', DateTime(2026, 10, 12)),
    expense(4000, 'leisure', DateTime(2026, 10, 31, 22)),
    // Fora de outubro: não entram no resumo do mês.
    expense(99900, 'food', DateTime(2026, 9, 30)),
    income(300000, DateTime(2026, 8, 5)),
  ];

  group('summarize', () {
    test('soma receitas e despesas apenas do mês', () {
      final s = FinanceCalculator.summarize(transactions, october);
      expect(s.incomeCents, 500000);
      expect(s.expenseCents, 129000);
      expect(s.balanceCents, 371000);
    });

    test('mês sem transações tem saldo zero', () {
      final s = FinanceCalculator.summarize(
        transactions,
        const YearMonth(2026, 1),
      );
      expect(s.balanceCents, 0);
    });
  });

  test('expensesByCategory agrupa e ordena do maior para o menor', () {
    final byCategory = FinanceCalculator.expensesByCategory(
      transactions,
      october,
    );
    expect(byCategory, {'food': 100000, 'transport': 25000, 'leisure': 4000});
    expect(byCategory.keys.first, 'food');
  });

  test(
    'monthlyTotals devolve os meses em ordem cronológica, incluindo vazios',
    () {
      final history = FinanceCalculator.monthlyTotals(
        transactions,
        october,
        count: 3,
      );
      expect(history.map((m) => m.month), const [
        YearMonth(2026, 8),
        YearMonth(2026, 9),
        YearMonth(2026, 10),
      ]);
      expect(history[0].incomeCents, 300000);
      expect(history[1].expenseCents, 99900);
      expect(history[2].expenseCents, 129000);
    },
  );

  group('budgets', () {
    final statuses = FinanceCalculator.budgets(
      [food, transport, leisure, salary],
      transactions,
      october,
    );

    test('considera só categorias de despesa com limite', () {
      expect(statuses.map((s) => s.category.id), ['transport', 'food']);
    });

    test('classifica o nível de alerta', () {
      final transportStatus = statuses.firstWhere(
        (s) => s.category.id == 'transport',
      );
      final foodStatus = statuses.firstWhere((s) => s.category.id == 'food');

      // 250 de 200: estourou.
      expect(transportStatus.level, BudgetLevel.exceeded);
      expect(transportStatus.remainingCents, -5000);

      // 1000 de 1000: exatamente no limite conta como estourado.
      expect(foodStatus.ratio, 1.0);
      expect(foodStatus.level, BudgetLevel.exceeded);
    });

    test('alerta a partir de 80%', () {
      final s = FinanceCalculator.budgets(
        [food],
        [expense(80000, 'food', DateTime(2026, 10, 1))],
        october,
      ).single;
      expect(s.level, BudgetLevel.warning);

      final ok = FinanceCalculator.budgets(
        [food],
        [expense(79999, 'food', DateTime(2026, 10, 1))],
        october,
      ).single;
      expect(ok.level, BudgetLevel.ok);
    });
  });
}
