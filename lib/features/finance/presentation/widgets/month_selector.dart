import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/finance_cubit.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FinanceCubit>();
    final month = context.select((FinanceCubit c) => c.state.month);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Mês anterior',
          icon: const Icon(Icons.chevron_left),
          onPressed: cubit.previousMonth,
        ),
        Text(month.label, style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          tooltip: 'Próximo mês',
          icon: const Icon(Icons.chevron_right),
          onPressed: cubit.nextMonth,
        ),
      ],
    );
  }
}
