import 'package:app_financas/features/finance/domain/entities/category.dart';
import 'package:app_financas/features/finance/domain/entities/finance_transaction.dart';

const food = FinanceCategory(
  id: 'food',
  name: 'Alimentação',
  type: TransactionType.expense,
  iconKey: 'restaurant',
  colorValue: 0xFFEF6C00,
  monthlyBudgetCents: 100000,
);

const transport = FinanceCategory(
  id: 'transport',
  name: 'Transporte',
  type: TransactionType.expense,
  iconKey: 'car',
  colorValue: 0xFF6A1B9A,
  monthlyBudgetCents: 20000,
);

const leisure = FinanceCategory(
  id: 'leisure',
  name: 'Lazer',
  type: TransactionType.expense,
  iconKey: 'movie',
  colorValue: 0xFF00838F,
);

const salary = FinanceCategory(
  id: 'salary',
  name: 'Salário',
  type: TransactionType.income,
  iconKey: 'work',
  colorValue: 0xFF2E7D32,
);

FinanceTransaction expense(int cents, String categoryId, DateTime date) =>
    FinanceTransaction(
      id: 'e-$categoryId-${date.toIso8601String()}-$cents',
      type: TransactionType.expense,
      amountCents: cents,
      description: '',
      categoryId: categoryId,
      date: date,
    );

FinanceTransaction income(int cents, DateTime date) => FinanceTransaction(
  id: 'i-${date.toIso8601String()}-$cents',
  type: TransactionType.income,
  amountCents: cents,
  description: 'Salário',
  categoryId: 'salary',
  date: date,
);
