import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/year_month.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/services/finance_calculator.dart';

enum FinanceStatus { loading, ready, failure }

class FinanceState extends Equatable {
  const FinanceState({
    required this.month,
    this.status = FinanceStatus.loading,
    this.categories = const [],
    this.transactions = const [],
    this.error,
  });

  /// Quantos meses o gráfico de evolução mostra (incluindo o mês atual).
  static const historyMonths = 6;

  final YearMonth month;
  final FinanceStatus status;
  final List<FinanceCategory> categories;

  /// Transações dos últimos [historyMonths] meses até [month].
  final List<FinanceTransaction> transactions;
  final String? error;

  List<FinanceTransaction> get monthTransactions =>
      transactions.where((t) => month.contains(t.date)).toList();

  MonthSummary get summary => FinanceCalculator.summarize(transactions, month);

  Map<String, int> get expensesByCategory =>
      FinanceCalculator.expensesByCategory(transactions, month);

  List<MonthTotals> get history => FinanceCalculator.monthlyTotals(
    transactions,
    month,
    count: historyMonths,
  );

  List<BudgetStatus> get budgets =>
      FinanceCalculator.budgets(categories, transactions, month);

  Map<String, FinanceCategory> get categoriesById => {
    for (final c in categories) c.id: c,
  };

  List<FinanceCategory> categoriesOf(TransactionType type) =>
      categories.where((c) => c.type == type).toList();

  FinanceState copyWith({
    YearMonth? month,
    FinanceStatus? status,
    List<FinanceCategory>? categories,
    List<FinanceTransaction>? transactions,
    String? error,
  }) {
    return FinanceState(
      month: month ?? this.month,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
      error: error,
    );
  }

  @override
  List<Object?> get props => [month, status, categories, transactions, error];
}

class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit(this._repository, this._uid, {YearMonth? initialMonth})
    : super(
        FinanceState(month: initialMonth ?? YearMonth.fromDate(DateTime.now())),
      );

  final FinanceRepository _repository;
  final String _uid;

  StreamSubscription<List<FinanceCategory>>? _categoriesSub;
  StreamSubscription<List<FinanceTransaction>>? _transactionsSub;
  bool _categoriesLoaded = false;
  bool _transactionsLoaded = false;

  Future<void> start() async {
    try {
      await _repository.ensureDefaultCategories(_uid);
    } catch (_) {
      // Sem conexão: as categorias padrão são criadas na próxima abertura.
    }
    if (isClosed) return;
    _categoriesSub = _repository.watchCategories(_uid).listen((categories) {
      _categoriesLoaded = true;
      emit(state.copyWith(categories: categories, status: _statusAfterLoad()));
    }, onError: _onStreamError);
    _watchTransactions();
  }

  void selectMonth(YearMonth month) {
    if (month == state.month) return;
    emit(state.copyWith(month: month));
    _watchTransactions();
  }

  void previousMonth() => selectMonth(state.month.addMonths(-1));
  void nextMonth() => selectMonth(state.month.addMonths(1));

  Future<void> saveTransaction(FinanceTransaction transaction) =>
      _repository.saveTransaction(_uid, transaction);

  Future<void> deleteTransaction(String id) =>
      _repository.deleteTransaction(_uid, id);

  Future<void> saveCategory(FinanceCategory category) =>
      _repository.saveCategory(_uid, category);

  /// Pode lançar [CategoryInUseException].
  Future<void> deleteCategory(String id) =>
      _repository.deleteCategory(_uid, id);

  Future<void> setBudget(FinanceCategory category, int? limitCents) =>
      _repository.saveCategory(
        _uid,
        limitCents == null
            ? category.copyWith(clearBudget: true)
            : category.copyWith(monthlyBudgetCents: limitCents),
      );

  void _watchTransactions() {
    _transactionsSub?.cancel();
    _transactionsLoaded = false;
    final month = state.month;
    _transactionsSub = _repository
        .watchTransactions(
          _uid,
          from: month.addMonths(-(FinanceState.historyMonths - 1)).start,
          to: month.end,
        )
        .listen((transactions) {
          _transactionsLoaded = true;
          emit(
            state.copyWith(
              transactions: transactions,
              status: _statusAfterLoad(),
            ),
          );
        }, onError: _onStreamError);
  }

  FinanceStatus _statusAfterLoad() => _categoriesLoaded && _transactionsLoaded
      ? FinanceStatus.ready
      : state.status;

  void _onStreamError(Object error) {
    emit(
      state.copyWith(
        status: FinanceStatus.failure,
        error: 'Não foi possível carregar seus dados. Verifique a conexão.',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _categoriesSub?.cancel();
    await _transactionsSub?.cancel();
    return super.close();
  }
}
