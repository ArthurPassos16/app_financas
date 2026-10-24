import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../domain/services/finance_calculator.dart';
import 'category_avatar.dart';

Color budgetColor(BudgetLevel level, ColorScheme scheme) => switch (level) {
  BudgetLevel.ok => scheme.primary,
  BudgetLevel.warning => AppColors.warning,
  BudgetLevel.exceeded => AppColors.expense,
};

class BudgetProgressTile extends StatelessWidget {
  const BudgetProgressTile({super.key, required this.status, this.onTap});

  final BudgetStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = budgetColor(status.level, theme.colorScheme);
    final remaining = status.remainingCents;
    final caption = remaining >= 0
        ? 'Restam ${Money.format(remaining)}'
        : 'Passou ${Money.format(-remaining)} do limite';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CategoryAvatar(category: status.category),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          status.category.name,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        '${Money.format(status.spentCents)} / ${Money.format(status.limitCents)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: status.ratio.clamp(0, 1).toDouble(),
                      minHeight: 8,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caption,
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
