import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/petiveti_page_header.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            PetivetiPageHeader(
              icon: Icons.receipt_long,
              title: 'Controle de Despesas',
              subtitle: 'Gerencie gastos com seus pets',
              actions: [
                _buildHeaderAction(
                  icon: Icons.add,
                  onTap: () => _showAddExpenseDialog(context),
                  tooltip: 'Adicionar Despesa',
                ),
              ],
            ),
            _buildTabBar(),
            Expanded(
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

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.list), text: 'Todas'),
          Tab(icon: Icon(Icons.calendar_month), text: 'Este Mês'),
          Tab(icon: Icon(Icons.category), text: 'Categorias'),
          Tab(icon: Icon(Icons.analytics), text: 'Resumo'),
        ],
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
