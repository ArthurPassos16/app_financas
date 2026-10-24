import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money.dart';
import '../../domain/entities/finance_transaction.dart';
import '../cubits/finance_cubit.dart';
import '../widgets/category_avatar.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key, this.transaction});

  /// `null` para criar uma nova transação.
  final FinanceTransaction? transaction;

  static Future<void> open(
    BuildContext context, {
    FinanceTransaction? transaction,
  }) {
    final cubit = context.read<FinanceCubit>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: TransactionFormPage(transaction: transaction),
        ),
      ),
    );
  }

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late TransactionType _type;
  late DateTime _date;
  String? _categoryId;
  bool _saving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _type = t?.type ?? TransactionType.expense;
    _date = t?.date ?? DateTime.now();
    _categoryId = t?.categoryId;
    _amount = TextEditingController(
      text: t == null ? '' : Money.toInput(t.amountCents),
    );
    _description = TextEditingController(text: t?.description ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      // Mantém o horário para preservar a ordem entre transações do mesmo dia.
      setState(
        () => _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        ),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final base = widget.transaction;
    final transaction = FinanceTransaction(
      id: base?.id ?? '',
      type: _type,
      amountCents: Money.parseToCents(_amount.text)!,
      description: _description.text.trim(),
      categoryId: _categoryId!,
      date: _date,
    );

    // O Firestore grava primeiro no cache local e sincroniza depois, então
    // a tela fecha na hora (funciona offline) e só avisa se a gravação falhar.
    final messenger = ScaffoldMessenger.of(context);
    context.read<FinanceCubit>().saveTransaction(transaction).catchError((
      Object _,
    ) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar a transação.')),
      );
    });
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final cubit = context.read<FinanceCubit>();
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir transação?'),
        content: const Text('Esta ação não pode ser desfeita.'),
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
    cubit.deleteTransaction(widget.transaction!.id).ignore();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.select(
      (FinanceCubit c) => c.state.categoriesOf(_type),
    );
    // Se a categoria escolhida não pertence ao tipo atual, limpa a seleção.
    final selected = categories.any((c) => c.id == _categoryId)
        ? _categoryId
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar transação' : 'Nova transação'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Despesa'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Receita'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amount,
              autofocus: !_isEditing,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: Theme.of(context).textTheme.headlineSmall,
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: r'R$ ',
              ),
              validator: (v) => Money.parseToCents(v ?? '') == null
                  ? 'Informe um valor maior que zero'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('category-$_type'),
              initialValue: selected,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                for (final c in categories)
                  DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        CategoryAvatar(category: c, radius: 14),
                        const SizedBox(width: 12),
                        Text(c.name),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? 'Escolha uma categoria' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Data'),
              subtitle: Text(
                DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(_date),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
