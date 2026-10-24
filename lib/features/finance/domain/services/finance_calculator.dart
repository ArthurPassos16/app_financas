import 'package:equatable/equatable.dart';

import '../../../../core/utils/year_month.dart';
import '../entities/category.dart';
import '../entities/finance_transaction.dart';

class MonthSummary extends Equatable {
  const MonthSummary({required this.incomeCents, required this.expenseCents});

  final int incomeCents;
  final int expenseCents;

  int get balanceCents => incomeCents - expenseCents;

  @override
  List<Object?> get props => [incomeCents, expenseCents];
}

class MonthTotals extends Equatable {
  const MonthTotals({
    required this.month,
    required this.incomeCents,
    required this.expenseCents,
  });

  final YearMonth month;
  final int incomeCents;
  final int expenseCents;

  @override
  List<Object?> get props => [month, incomeCents, expenseCents];
}

enum BudgetLevel { ok, warning, exceeded }

class BudgetStatus extends Equatable {
  const BudgetStatus({required this.category, required this.spentCents});

  /// A partir de 80% do limite o orçamento entra em alerta.
  static const warningRatio = 0.8;

  final FinanceCategory category;
  final int spentCents;

  int get limitCents => category.monthlyBudgetCents ?? 0;
  int get remainingCents => limitCents - spentCents;
  double get ratio => limitCents == 0 ? 0 : spentCents / limitCents;

  BudgetLevel get level {
    if (ratio >= 1) return BudgetLevel.exceeded;
    if (ratio >= warningRatio) return BudgetLevel.warning;
    return BudgetLevel.ok;
  }

  @override
  List<Object?> get props => [category, spentCents];
}

/// Regras de cálculo puras, sem dependência de Flutter ou Firebase.
abstract final class FinanceCalculator {
  static MonthSummary summarize(
    Iterable<FinanceTransaction> transactions,
    YearMonth month,
  ) {
    var income = 0;
    var expense = 0;
    for (final t in transactions) {
      if (!month.contains(t.date)) continue;
      if (t.isIncome) {
        income += t.amountCents;
      } else {
        expense += t.amountCents;
      }
    }
    return MonthSummary(incomeCents: income, expenseCents: expense);
  }

  /// Total de despesas por categoria no mês, do maior para o menor.
  static Map<String, int> expensesByCategory(
    Iterable<FinanceTransaction> transactions,
    YearMonth month,
  ) {
    final totals = <String, int>{};
    for (final t in transactions) {
      if (t.isIncome || !month.contains(t.date)) continue;
      totals.update(
        t.categoryId,
        (v) => v + t.amountCents,
        ifAbsent: () => t.amountCents,
      );
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// Receitas e despesas dos [count] meses que terminam em [last], em ordem cronológica.
  static List<MonthTotals> monthlyTotals(
    Iterable<FinanceTransaction> transactions,
    YearMonth last, {
    int count = 6,
  }) {
    final list = transactions.toList();
    final result = <MonthTotals>[];
    for (var i = count - 1; i >= 0; i--) {
      final month = last.addMonths(-i);
      final s = summarize(list, month);
      result.add(
        MonthTotals(
          month: month,
          incomeCents: s.incomeCents,
          expenseCents: s.expenseCents,
        ),
      );
    }
    return result;
  }

  /// Situação dos orçamentos das categorias de despesa que têm limite,
  /// das mais comprometidas para as menos.
  static List<BudgetStatus> budgets(
    Iterable<FinanceCategory> categories,
    Iterable<FinanceTransaction> transactions,
    YearMonth month,
  ) {
    final spent = expensesByCategory(transactions, month);
    final result = [
      for (final c in categories)
        if (c.type == TransactionType.expense && c.hasBudget)
          BudgetStatus(category: c, spentCents: spent[c.id] ?? 0),
    ]..sort((a, b) => b.ratio.compareTo(a.ratio));
    return result;
  }
}
