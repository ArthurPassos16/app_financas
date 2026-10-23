import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/finance_transaction.dart';
import '../cubits/finance_cubit.dart';
import '../widgets/transaction_tile.dart';
import 'finance_state_view.dart';
import 'transaction_form_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  /// `null` mostra todas.
  TransactionType? _filter;

  Future<bool> _confirmDelete(FinanceTransaction t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir transação?'),
        content: Text(
          t.description.isEmpty
              ? 'Esta ação não pode ser desfeita.'
              : t.description,
        ),
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
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FinanceStateView(
      builder: (context, state) {
        final categories = state.categoriesById;
        final items = state.monthTransactions
            .where((t) => _filter == null || t.type == _filter)
            .toList();

        // Agrupa por dia mantendo a ordem (mais recente primeiro).
        final groups = <DateTime, List<FinanceTransaction>>{};
        for (final t in items) {
          final day = DateTime(t.date.year, t.date.month, t.date.day);
          groups.putIfAbsent(day, () => []).add(t);
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SegmentedButton<TransactionType?>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: null, label: Text('Todas')),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Receitas'),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Despesas'),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message:
                          'Nenhuma transação neste mês.\nToque em "Transação" para adicionar.',
                    )
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 96),
                      children: [
                        for (final entry in groups.entries) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text(
                              DateFormat(
                                "EEEE, d 'de' MMMM",
                                'pt_BR',
                              ).format(entry.key),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          for (final t in entry.value)
                            Dismissible(
                              key: ValueKey(t.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                child: const Icon(Icons.delete_outline),
                              ),
                              confirmDismiss: (_) => _confirmDelete(t),
                              onDismissed: (_) => context
                                  .read<FinanceCubit>()
                                  .deleteTransaction(t.id),
                              child: TransactionTile(
                                transaction: t,
                                category: categories[t.categoryId],
                                onTap: () => TransactionFormPage.open(
                                  context,
                                  transaction: t,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
