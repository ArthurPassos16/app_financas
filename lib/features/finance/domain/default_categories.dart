import 'entities/category.dart';
import 'entities/finance_transaction.dart';

/// Categorias criadas no primeiro acesso. Os ids são fixos para que a
/// criação seja idempotente.
const defaultCategories = <FinanceCategory>[
  FinanceCategory(
    id: 'food',
    name: 'Alimentação',
    type: TransactionType.expense,
    iconKey: 'restaurant',
    colorValue: 0xFFEF6C00,
  ),
  FinanceCategory(
    id: 'housing',
    name: 'Moradia',
    type: TransactionType.expense,
    iconKey: 'home',
    colorValue: 0xFF1565C0,
  ),
  FinanceCategory(
    id: 'transport',
    name: 'Transporte',
    type: TransactionType.expense,
    iconKey: 'car',
    colorValue: 0xFF6A1B9A,
  ),
  FinanceCategory(
    id: 'health',
    name: 'Saúde',
    type: TransactionType.expense,
    iconKey: 'health',
    colorValue: 0xFFD81B60,
  ),
  FinanceCategory(
    id: 'leisure',
    name: 'Lazer',
    type: TransactionType.expense,
    iconKey: 'movie',
    colorValue: 0xFF00838F,
  ),
  FinanceCategory(
    id: 'education',
    name: 'Educação',
    type: TransactionType.expense,
    iconKey: 'school',
    colorValue: 0xFF5D4037,
  ),
  FinanceCategory(
    id: 'shopping',
    name: 'Compras',
    type: TransactionType.expense,
    iconKey: 'shopping',
    colorValue: 0xFFAD1457,
  ),
  FinanceCategory(
    id: 'bills',
    name: 'Contas',
    type: TransactionType.expense,
    iconKey: 'receipt',
    colorValue: 0xFF455A64,
  ),
  FinanceCategory(
    id: 'other_expense',
    name: 'Outros',
    type: TransactionType.expense,
    iconKey: 'more',
    colorValue: 0xFF757575,
  ),
  FinanceCategory(
    id: 'salary',
    name: 'Salário',
    type: TransactionType.income,
    iconKey: 'work',
    colorValue: 0xFF2E7D32,
  ),
  FinanceCategory(
    id: 'freelance',
    name: 'Freelance',
    type: TransactionType.income,
    iconKey: 'laptop',
    colorValue: 0xFF00897B,
  ),
  FinanceCategory(
    id: 'investments',
    name: 'Investimentos',
    type: TransactionType.income,
    iconKey: 'trending',
    colorValue: 0xFF558B2F,
  ),
  FinanceCategory(
    id: 'other_income',
    name: 'Outros',
    type: TransactionType.income,
    iconKey: 'more',
    colorValue: 0xFF757575,
  ),
];
