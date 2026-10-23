import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/category.dart';
import '../domain/entities/finance_transaction.dart';

TransactionType _parseType(Object? value) =>
    value == 'income' ? TransactionType.income : TransactionType.expense;

abstract final class TransactionMapper {
  static FinanceTransaction fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return FinanceTransaction(
      id: doc.id,
      type: _parseType(data['type']),
      amountCents: (data['amountCents'] as num).toInt(),
      description: data['description'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> toMap(FinanceTransaction t) => {
    'type': t.type.name,
    'amountCents': t.amountCents,
    'description': t.description,
    'categoryId': t.categoryId,
    'date': Timestamp.fromDate(t.date),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

abstract final class CategoryMapper {
  static FinanceCategory fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return FinanceCategory(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: _parseType(data['type']),
      iconKey: data['iconKey'] as String? ?? 'more',
      colorValue: (data['colorValue'] as num?)?.toInt() ?? 0xFF757575,
      monthlyBudgetCents: (data['monthlyBudgetCents'] as num?)?.toInt(),
    );
  }

  static Map<String, dynamic> toMap(FinanceCategory c) => {
    'name': c.name,
    'type': c.type.name,
    'iconKey': c.iconKey,
    'colorValue': c.colorValue,
    'monthlyBudgetCents': c.monthlyBudgetCents,
  };
}
