import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/finance_transaction.dart';
import '../cubits/finance_cubit.dart';
import '../widgets/category_avatar.dart';

/// Bottom sheet para criar ou editar uma categoria.
class CategoryFormSheet extends StatefulWidget {
  const CategoryFormSheet({super.key, this.category});

  final FinanceCategory? category;

  static Future<void> open(BuildContext context, {FinanceCategory? category}) {
    final cubit = context.read<FinanceCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CategoryFormSheet(category: category),
      ),
    );
  }

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late TransactionType _type;
  late String _iconKey;
  late int _color;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _name = TextEditingController(text: c?.name ?? '');
    _type = c?.type ?? TransactionType.expense;
    _iconKey = c?.iconKey ?? categoryIcons.keys.first;
    _color = c?.colorValue ?? categoryColors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final base = widget.category;
    final category =
        (base ??
                FinanceCategory(
                  name: '',
                  type: _type,
                  iconKey: _iconKey,
                  colorValue: _color,
                ))
            .copyWith(
              name: _name.text.trim(),
              type: _type,
              iconKey: _iconKey,
              colorValue: _color,
            );

    final messenger = ScaffoldMessenger.of(context);
    context.read<FinanceCubit>().saveCategory(category).catchError((Object _) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar a categoria.')),
      );
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final preview = FinanceCategory(
      name: '',
      type: _type,
      iconKey: _iconKey,
      colorValue: _color,
    );
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Editar categoria' : 'Nova categoria',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CategoryAvatar(category: preview, radius: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _name,
                      autofocus: !_isEditing,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe um nome'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Despesa'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Receita'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              Text('Ícone', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in categoryIcons.entries)
                    ChoiceChip(
                      label: Icon(entry.value, size: 20),
                      selected: entry.key == _iconKey,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _iconKey = entry.key),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Cor', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final color in categoryColors)
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() => _color = color),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(color),
                        child: color == _color
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
