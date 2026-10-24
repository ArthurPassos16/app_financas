import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/finance_transaction.dart';
import 'category_avatar.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
    this.showDate = false,
  });

  final FinanceTransaction transaction;
  final FinanceCategory? category;
  final VoidCallback? onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final categoryName = category?.name ?? 'Sem categoria';
    final subtitle = showDate
        ? '$categoryName · ${DateFormat('dd/MM').format(t.date)}'
        : categoryName;
    return ListTile(
      onTap: onTap,
      leading: CategoryAvatar(category: category),
      title: Text(
        t.description.isEmpty ? categoryName : t.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        '${t.isIncome ? '+' : '-'} ${Money.format(t.amountCents)}',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: t.isIncome ? AppColors.income : AppColors.expense,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
