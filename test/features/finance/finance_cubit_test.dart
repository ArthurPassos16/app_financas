import 'dart:async';

import 'package:app_financas/core/utils/year_month.dart';
import 'package:app_financas/features/finance/domain/entities/category.dart';
import 'package:app_financas/features/finance/domain/entities/finance_transaction.dart';
import 'package:app_financas/features/finance/domain/repositories/finance_repository.dart';
import 'package:app_financas/features/finance/presentation/cubits/finance_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures.dart';

class _MockFinanceRepository extends Mock implements FinanceRepository {}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late _MockFinanceRepository repository;
  late StreamController<List<FinanceCategory>> categories;
  late StreamController<List<FinanceTransaction>> transactions;

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(food);
  });

  setUp(() {
    repository = _MockFinanceRepository();
    categories = StreamController.broadcast();
    transactions = StreamController.broadcast();

    when(
      () => repository.ensureDefaultCategories(any()),
    ).thenAnswer((_) async {});
    when(
      () => repository.watchCategories(any()),
    ).thenAnswer((_) => categories.stream);
    when(
      () => repository.watchTransactions(
        any(),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) => transactions.stream);
  });

  tearDown(() async {
    await categories.close();
    await transactions.close();
  });

  FinanceCubit build() =>
      FinanceCubit(repository, 'u1', initialMonth: const YearMonth(2026, 10));

  test('cria categorias padrão e busca a janela de 6 meses', () async {
    final cubit = build();
    await cubit.start();

    verify(() => repository.ensureDefaultCategories('u1')).called(1);
    verify(
      () => repository.watchTransactions(
        'u1',
        from: DateTime(2026, 5),
        to: DateTime(2026, 11),
      ),
    ).called(1);
    await cubit.close();
  });

  test('só fica pronto quando categorias e transações chegam', () async {
    final cubit = build();
    await cubit.start();
    expect(cubit.state.status, FinanceStatus.loading);

    categories.add([food, salary]);
    await _flush();
    expect(cubit.state.status, FinanceStatus.loading);

    transactions.add([
      income(500000, DateTime(2026, 10, 5)),
      expense(12000, 'food', DateTime(2026, 10, 6)),
      expense(3000, 'food', DateTime(2026, 9, 6)),
    ]);
    await _flush();

    final state = cubit.state;
    expect(state.status, FinanceStatus.ready);
    expect(state.monthTransactions, hasLength(2));
    expect(state.summary.balanceCents, 488000);
    expect(state.history.last.expenseCents, 12000);
    expect(state.categoriesById['food'], food);
    await cubit.close();
  });

  test('trocar de mês refaz a consulta com a nova janela', () async {
    final cubit = build();
    await cubit.start();

    cubit.nextMonth();
    expect(cubit.state.month, const YearMonth(2026, 11));
    verify(
      () => repository.watchTransactions(
        'u1',
        from: DateTime(2026, 6),
        to: DateTime(2026, 12),
      ),
    ).called(1);

    cubit.selectMonth(const YearMonth(2026, 11));
    verifyNever(
      () => repository.watchTransactions(
        'u1',
        from: DateTime(2026, 6),
        to: DateTime(2026, 12),
      ),
    );
    await cubit.close();
  });

  test('erro no stream vira estado de falha', () async {
    final cubit = build();
    await cubit.start();

    categories.addError(Exception('offline'));
    await _flush();

    expect(cubit.state.status, FinanceStatus.failure);
    expect(cubit.state.error, isNotNull);
    await cubit.close();
  });

  test('setBudget nulo remove o limite da categoria', () async {
    when(() => repository.saveCategory(any(), any())).thenAnswer((_) async {});

    final cubit = build();
    await cubit.setBudget(food, null);

    final saved =
        verify(
              () => repository.saveCategory('u1', captureAny()),
            ).captured.single
            as FinanceCategory;
    expect(saved.monthlyBudgetCents, isNull);
    await cubit.close();
  });
}
