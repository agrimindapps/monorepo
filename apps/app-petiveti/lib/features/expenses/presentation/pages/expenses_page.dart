import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../providers/expenses_provider.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/expense_categories_tab.dart';
import '../widgets/expense_list_tab.dart';
import '../widgets/expense_summary_tab.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  final String userId;

  const ExpensesPage({super.key, required this.userId});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(expensesProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expensesProvider.notifier).loadExpenses(widget.userId);
    });

    final expensesState = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Despesas'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              child: Semantics(
                label: 'Aba todas as despesas',
                hint: 'Toque para ver todas as despesas cadastradas',
                button: true,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.list), Text('Todas')],
                ),
              ),
            ),
            Tab(
              child: Semantics(
                label: 'Aba despesas deste mês',
                hint: 'Toque para ver as despesas do mês atual',
                button: true,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.calendar_month), Text('Este Mês')],
                ),
              ),
            ),
            Tab(
              child: Semantics(
                label: 'Aba categorias de despesas',
                hint: 'Toque para ver despesas organizadas por categoria',
                button: true,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.category), Text('Categorias')],
                ),
              ),
            ),
            Tab(
              child: Semantics(
                label: 'Aba resumo de despesas',
                hint: 'Toque para ver resumo e estatísticas das despesas',
                button: true,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.analytics), Text('Resumo')],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Semantics(
        label: 'Conteúdo das abas de despesas',
        child: TabBarView(
          controller: _tabController,
          children: [
            ExpenseListTab(
              state: expensesState,
              expenses: expensesState.expenses,
              emptyTitle: 'Nenhuma Despesa Cadastrada',
              emptySubtitle: 'Comece adicionando sua primeira despesa.',
              emptyIcon: Icons.receipt_long,
            ),
            ExpenseListTab(
              state: expensesState,
              expenses: expensesState.monthlyExpenses,
              emptyTitle: 'Nenhuma Despesa Este Mês',
              emptySubtitle:
                  'Adicione despesas para visualizar o resumo mensal.',
              emptyIcon: Icons.calendar_today,
            ),
            ExpenseCategoriesTab(
              state: expensesState,
              onCategoryTap: _showCategoryDetails,
            ),
            ExpenseSummaryTab(state: expensesState),
          ],
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Adicionar nova despesa',
        hint: 'Botão flutuante para cadastrar uma nova despesa veterinária',
        button: true,
        child: FloatingActionButton(
          onPressed: () => _showAddExpenseDialog(context),
          tooltip: 'Adicionar Despesa',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );
  }

  void _showCategoryDetails(String categoryName) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Despesas - $categoryName'),
        content: const Text(
          'Lista de despesas desta categoria será exibida aqui.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
