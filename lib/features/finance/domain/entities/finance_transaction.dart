import 'package:equatable/equatable.dart';

enum TransactionType {
  income,
  expense;

  String get label => this == income ? 'Receita' : 'Despesa';
}

/// Uma receita ou despesa registrada pelo usuário.
class FinanceTransaction extends Equatable {
  const FinanceTransaction({
    this.id = '',
    required this.type,
    required this.amountCents,
    required this.description,
    required this.categoryId,
    required this.date,
  }) : assert(amountCents > 0);

  /// Vazio enquanto a transação não foi salva.
  final String id;
  final TransactionType type;
  final int amountCents;
  final String description;
  final String categoryId;
  final DateTime date;

  bool get isNew => id.isEmpty;
  bool get isIncome => type == TransactionType.income;

  /// Valor com sinal: positivo para receita, negativo para despesa.
  int get signedCents => isIncome ? amountCents : -amountCents;

  FinanceTransaction copyWith({
    String? id,
    TransactionType? type,
    int? amountCents,
    String? description,
    String? categoryId,
    DateTime? date,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amountCents: amountCents ?? this.amountCents,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    amountCents,
    description,
    categoryId,
    date,
  ];
}
