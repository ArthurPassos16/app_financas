import 'package:equatable/equatable.dart';

import 'finance_transaction.dart';

/// Categoria de receita ou despesa. Categorias de despesa podem ter
/// um orçamento mensal ([monthlyBudgetCents]).
class FinanceCategory extends Equatable {
  const FinanceCategory({
    this.id = '',
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorValue,
    this.monthlyBudgetCents,
  });

  final String id;
  final String name;
  final TransactionType type;

  /// Chave do ícone (ver `categoryIcons` na camada de apresentação).
  final String iconKey;

  /// Cor em ARGB 32 bits.
  final int colorValue;

  final int? monthlyBudgetCents;

  bool get isNew => id.isEmpty;
  bool get hasBudget => (monthlyBudgetCents ?? 0) > 0;

  FinanceCategory copyWith({
    String? id,
    String? name,
    TransactionType? type,
    String? iconKey,
    int? colorValue,
    int? monthlyBudgetCents,
    bool clearBudget = false,
  }) {
    return FinanceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      monthlyBudgetCents: clearBudget
          ? null
          : (monthlyBudgetCents ?? this.monthlyBudgetCents),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    iconKey,
    colorValue,
    monthlyBudgetCents,
  ];
}
