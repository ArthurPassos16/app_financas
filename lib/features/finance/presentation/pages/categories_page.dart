import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/finance_repository.dart';
import '../cubits/finance_cubit.dart';
import '../widgets/category_avatar.dart';
import 'category_form_sheet.dart';
import 'finance_state_view.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FinanceStateView(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            for (final type in TransactionType.values) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                child: Text(
                  type == TransactionType.expense ? 'Despesas' : 'Receitas',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Card(
                child: Column(
                  children: [
                    for (final c in state.categoriesOf(type))
                      ListTile(
                        leading: CategoryAvatar(category: c),
                        title: Text(c.name),
                        subtitle: c.hasBudget
                            ? Text(
                                'Orçamento: ${Money.format(c.monthlyBudgetCents!)}',
                              )
                            : null,
                        onTap: () =>
                            CategoryFormSheet.open(context, category: c),
                        trailing: IconButton(
                          tooltip: 'Excluir',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(context, c),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, FinanceCategory category) async {
    final cubit = context.read<FinanceCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await cubit.deleteCategory(category.id);
    } on CategoryInUseException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir a categoria.')),
      );
    }
  }
}
