import '../entities/category.dart';
import '../entities/finance_transaction.dart';

/// Lançada ao tentar excluir uma categoria que ainda tem transações.
class CategoryInUseException implements Exception {
  const CategoryInUseException();

  @override
  String toString() =>
      'Esta categoria tem transações. Mova ou exclua as transações antes de removê-la.';
}

abstract interface class FinanceRepository {
  Stream<List<FinanceCategory>> watchCategories(String uid);

  /// Transações com `from <= date < to`, da mais recente para a mais antiga.
  Stream<List<FinanceTransaction>> watchTransactions(
    String uid, {
    required DateTime from,
    required DateTime to,
  });

  /// Cria (quando `id` está vazio) ou atualiza uma transação.
  Future<void> saveTransaction(String uid, FinanceTransaction transaction);
  Future<void> deleteTransaction(String uid, String transactionId);

  /// Cria (quando `id` está vazio) ou atualiza uma categoria.
  Future<void> saveCategory(String uid, FinanceCategory category);

  /// Lança [CategoryInUseException] se houver transações na categoria.
  Future<void> deleteCategory(String uid, String categoryId);

  /// Cria as categorias padrão se o usuário ainda não tiver nenhuma.
  Future<void> ensureDefaultCategories(String uid);
}
