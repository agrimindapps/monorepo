import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/expenses_provider.dart';
import '../../domain/entities/expense.dart';

// Constantes para categorias (extraído para performance)
const List<Map<String, dynamic>> _expenseCategories = [
  {'name': 'Consultas', 'icon': Icons.medical_services, 'color': Colors.blue},
  {'name': 'Medicamentos', 'icon': Icons.medication, 'color': Colors.green},
  {'name': 'Vacinas', 'icon': Icons.vaccines, 'color': Colors.purple},
  {'name': 'Cirurgias', 'icon': Icons.healing, 'color': Colors.red},
  {'name': 'Exames', 'icon': Icons.biotech, 'color': Colors.orange},
  {'name': 'Ração', 'icon': Icons.pets, 'color': Colors.brown},
  {'name': 'Acessórios', 'icon': Icons.shopping_bag, 'color': Colors.pink},
  {'name': 'Banho/Tosa', 'icon': Icons.content_cut, 'color': Colors.cyan},
  {'name': 'Seguro', 'icon': Icons.shield, 'color': Colors.indigo},
  {'name': 'Emergência', 'icon': Icons.emergency, 'color': Colors.deepOrange},
  {'name': 'Outros', 'icon': Icons.more_horiz, 'color': Colors.grey},
];

class ExpensesPage extends ConsumerStatefulWidget {
  final String userId;

  const ExpensesPage({
    super.key,
    required this.userId,
  });

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
    // Usar provider para carregar dados do usuário
    ref.listen(expensesProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Inicializar carregamento se necessário
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
          tabs: const [
            Tab(
              text: 'Todas',
              icon: Icon(Icons.list),
            ),
            Tab(
              text: 'Este Mês',
              icon: Icon(Icons.calendar_month),
            ),
            Tab(
              text: 'Categorias',
              icon: Icon(Icons.category),
            ),
            Tab(
              text: 'Resumo',
              icon: Icon(Icons.analytics),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllExpensesTab(expensesState),
          _buildMonthlyExpensesTab(expensesState),
          _buildCategoriesTab(expensesState),
          _buildSummaryTab(expensesState),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        tooltip: 'Adicionar Despesa',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllExpensesTab(ExpensesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.expenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma Despesa Cadastrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Comece adicionando sua primeira despesa.',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.expenses.length,
      itemBuilder: (context, index) {
        final expense = state.expenses[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(expense.category).withAlpha(30),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
              ),
            ),
            title: Text(expense.description),
            subtitle: Text(
              '${_getCategoryName(expense.category)} • ${_formatDate(expense.expenseDate)}',
            ),
            trailing: Text(
              'R\${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyExpensesTab(ExpensesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.monthlyExpenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma Despesa Este Mês',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione despesas para visualizar o resumo mensal.',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.monthlyExpenses.length,
      itemBuilder: (context, index) {
        final expense = state.monthlyExpenses[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(expense.category).withAlpha(30),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
              ),
            ),
            title: Text(expense.description),
            subtitle: Text(
              '${_getCategoryName(expense.category)} • ${_formatDate(expense.expenseDate)}',
            ),
            trailing: Text(
              'R\${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab(ExpensesState state) {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _expenseCategories.length,
        itemBuilder: (context, index) {
          final category = _expenseCategories[index];
          return Card(
            child: InkWell(
              onTap: () => _showCategoryDetails(category['name'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 32,
                      color: category['color'] as Color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\${state.getCategoryAmount(_getExpenseCategory(category['name'] as String)).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryTab(ExpensesState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(
            'Total Geral',
            'R\${state.totalAmount.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Este Mês',
            'R\${state.monthlyAmount.toStringAsFixed(2)}',
            Icons.calendar_month,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Este Ano',
            'R\${state.yearlyAmount.toStringAsFixed(2)}',
            Icons.calendar_today,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Média Mensal',
            'R\${state.averageExpense.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.purple,
          ),
          const SizedBox(height: 32),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Gráficos e Análises',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gráficos detalhados serão implementados em breve.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de adicionar despesa será implementada em breve'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCategoryDetails(String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Despesas - $categoryName'),
        content: const Text('Lista de despesas desta categoria será exibida aqui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para mapear categorias
  Color _getCategoryColor(ExpenseCategory category) {
    final categoryMap = {
      ExpenseCategory.consultation: Colors.blue,
      ExpenseCategory.medication: Colors.green,
      ExpenseCategory.vaccine: Colors.purple,
      ExpenseCategory.surgery: Colors.red,
      ExpenseCategory.exam: Colors.orange,
      ExpenseCategory.food: Colors.brown,
      ExpenseCategory.accessory: Colors.pink,
      ExpenseCategory.grooming: Colors.cyan,
      ExpenseCategory.insurance: Colors.indigo,
      ExpenseCategory.emergency: Colors.deepOrange,
      ExpenseCategory.other: Colors.grey,
    };
    return categoryMap[category] ?? Colors.grey;
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    final iconMap = {
      ExpenseCategory.consultation: Icons.medical_services,
      ExpenseCategory.medication: Icons.medication,
      ExpenseCategory.vaccine: Icons.vaccines,
      ExpenseCategory.surgery: Icons.healing,
      ExpenseCategory.exam: Icons.biotech,
      ExpenseCategory.food: Icons.pets,
      ExpenseCategory.accessory: Icons.shopping_bag,
      ExpenseCategory.grooming: Icons.content_cut,
      ExpenseCategory.insurance: Icons.shield,
      ExpenseCategory.emergency: Icons.emergency,
      ExpenseCategory.other: Icons.more_horiz,
    };
    return iconMap[category] ?? Icons.more_horiz;
  }

  String _getCategoryName(ExpenseCategory category) {
    final nameMap = {
      ExpenseCategory.consultation: 'Consultas',
      ExpenseCategory.medication: 'Medicamentos',
      ExpenseCategory.vaccine: 'Vacinas',
      ExpenseCategory.surgery: 'Cirurgias',
      ExpenseCategory.exam: 'Exames',
      ExpenseCategory.food: 'Ração',
      ExpenseCategory.accessory: 'Acessórios',
      ExpenseCategory.grooming: 'Banho/Tosa',
      ExpenseCategory.insurance: 'Seguro',
      ExpenseCategory.emergency: 'Emergência',
      ExpenseCategory.other: 'Outros',
    };
    return nameMap[category] ?? 'Outros';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  double _getCategoryAmount(ExpensesState state, String categoryName) {
    // Mapear nome da categoria para enum
    final categoryMap = {
      'Consultas': ExpenseCategory.consultation,
      'Medicamentos': ExpenseCategory.medication,
      'Vacinas': ExpenseCategory.vaccine,
      'Cirurgias': ExpenseCategory.surgery,
      'Exames': ExpenseCategory.exam,
      'Ração': ExpenseCategory.food,
      'Acessórios': ExpenseCategory.accessory,
      'Banho/Tosa': ExpenseCategory.grooming,
      'Seguro': ExpenseCategory.insurance,
      'Emergência': ExpenseCategory.emergency,
      'Outros': ExpenseCategory.other,
    };
    
    final category = categoryMap[categoryName];
    if (category == null) return 0.0;
    
    return state.categoryAmounts[category] ?? 0.0;
  }
}