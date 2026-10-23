import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/auth_cubit.dart';
import '../../domain/repositories/finance_repository.dart';
import '../cubits/finance_cubit.dart';
import '../widgets/month_selector.dart';
import 'budgets_page.dart';
import 'categories_page.dart';
import 'category_form_sheet.dart';
import 'dashboard_page.dart';
import 'transaction_form_page.dart';
import 'transactions_page.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanceCubit(getIt<FinanceRepository>(), uid)..start(),
      child: const _Shell(),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  static const _pages = <Widget>[
    DashboardPage(),
    TransactionsPage(),
    BudgetsPage(),
    CategoriesPage(),
  ];

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) await context.read<AuthCubit>().signOut();
  }

  Widget? _fab() {
    switch (_index) {
      case 0:
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => TransactionFormPage.open(context),
          icon: const Icon(Icons.add),
          label: const Text('Transação'),
        );
      case 3:
        return FloatingActionButton.extended(
          onPressed: () => CategoryFormSheet.open(context),
          icon: const Icon(Icons.add),
          label: const Text('Categoria'),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showMonth = _index != 3;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: showMonth ? const MonthSelector() : const Text('Categorias'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _fab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_vert),
            label: 'Transações',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Orçamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categorias',
          ),
        ],
      ),
    );
  }
}
