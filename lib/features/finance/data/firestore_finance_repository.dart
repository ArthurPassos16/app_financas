import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/default_categories.dart';
import '../domain/entities/category.dart';
import '../domain/entities/finance_transaction.dart';
import '../domain/repositories/finance_repository.dart';
import 'firestore_mappers.dart';

/// Estrutura no Firestore:
///
/// ```
/// users/{uid}/categories/{categoryId}
/// users/{uid}/transactions/{transactionId}
/// ```
class FirestoreFinanceRepository implements FinanceRepository {
  FirestoreFinanceRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _categories(String uid) =>
      _user(uid).collection('categories');

  CollectionReference<Map<String, dynamic>> _transactions(String uid) =>
      _user(uid).collection('transactions');

  @override
  Stream<List<FinanceCategory>> watchCategories(String uid) {
    return _categories(uid)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(CategoryMapper.fromDoc).toList());
  }

  @override
  Stream<List<FinanceTransaction>> watchTransactions(
    String uid, {
    required DateTime from,
    required DateTime to,
  }) {
    return _transactions(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThan: Timestamp.fromDate(to))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TransactionMapper.fromDoc).toList());
  }

  @override
  Future<void> saveTransaction(
    String uid,
    FinanceTransaction transaction,
  ) async {
    final data = TransactionMapper.toMap(transaction);
    if (transaction.isNew) {
      await _transactions(
        uid,
      ).add({...data, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      await _transactions(
        uid,
      ).doc(transaction.id).set(data, SetOptions(merge: true));
    }
  }

  @override
  Future<void> deleteTransaction(String uid, String transactionId) =>
      _transactions(uid).doc(transactionId).delete();

  @override
  Future<void> saveCategory(String uid, FinanceCategory category) async {
    final data = CategoryMapper.toMap(category);
    if (category.isNew) {
      await _categories(uid).add(data);
    } else {
      await _categories(uid).doc(category.id).set(data);
    }
  }

  @override
  Future<void> deleteCategory(String uid, String categoryId) async {
    final inUse = await _transactions(
      uid,
    ).where('categoryId', isEqualTo: categoryId).limit(1).get();
    if (inUse.docs.isNotEmpty) throw const CategoryInUseException();
    await _categories(uid).doc(categoryId).delete();
  }

  @override
  Future<void> ensureDefaultCategories(String uid) async {
    final existing = await _categories(uid).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final c in defaultCategories) {
      batch.set(_categories(uid).doc(c.id), CategoryMapper.toMap(c));
    }
    await batch.commit();
  }
}
