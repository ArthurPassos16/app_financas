import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/finance_transaction.dart';
import '../cubits/finance_cubit.dart';
import '../widgets/budget_progress_tile.dart';
import '../widgets/category_avatar.dart';
import 'finance_state_view.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FinanceStateView(
      builder: (context, state) {
        final budgets = state.budgets;
        final withoutBudget = state
            .categoriesOf(TransactionType.expense)
            .where((c) => !c.hasBudget)
            .toList();
        final totalLimit = budgets.fold<int>(0, (a, b) => a + b.limitCents);
        final totalSpent = budgets.fold<int>(0, (a, b) => a + b.spentCents);
        final theme = Theme.of(context);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (budgets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(
                  icon: Icons.savings_outlined,
                  message:
                      'Defina um limite mensal para as categorias que você quer controlar.',
                ),
              )
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total orçado no mês',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Money.format(totalSpent)} de ${Money.format(totalLimit)}',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    for (final b in budgets)
                      BudgetProgressTile(
                        status: b,
                        onTap: () => _editBudget(context, b.category),
                      ),
                  ],
                ),
              ),
            ],
            if (withoutBudget.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Sem orçamento', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (final c in withoutBudget)
                      ListTile(
                        leading: CategoryAvatar(category: c),
                        title: Text(c.name),
                        trailing: const Icon(Icons.add),
                        onTap: () => _editBudget(context, c),
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

  Future<void> _editBudget(
    BuildContext context,
    FinanceCategory category,
  ) async {
    final cubit = context.read<FinanceCubit>();
    final result = await showDialog<_BudgetResult>(
      context: context,
      builder: (_) => _BudgetDialog(category: category),
    );
    if (result == null) return;
    await cubit.setBudget(category, result.limitCents);
  }
}

class _BudgetResult {
  const _BudgetResult(this.limitCents);

  /// `null` remove o orçamento.
  final int? limitCents;
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({required this.category});

  final FinanceCategory category;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = widget.category.monthlyBudgetCents;
    _controller = TextEditingController(
      text: current == null ? '' : Money.toInput(current),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _BudgetResult(Money.parseToCents(_controller.text)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Orçamento: ${widget.category.name}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Limite mensal',
            prefixText: r'R$ ',
          ),
          validator: (v) => Money.parseToCents(v ?? '') == null
              ? 'Informe um valor maior que zero'
              : null,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        if (widget.category.hasBudget)
          TextButton(
            onPressed: () => Navigator.pop(context, const _BudgetResult(null)),
            child: const Text('Remover'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}
