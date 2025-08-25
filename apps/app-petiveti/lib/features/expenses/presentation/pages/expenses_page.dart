import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          _buildAllExpensesTab(),
          _buildMonthlyExpensesTab(),
          _buildCategoriesTab(),
          _buildSummaryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        tooltip: 'Adicionar Despesa',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllExpensesTab() {
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
            'Todas as Despesas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Lista completa de despesas será exibida aqui.',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyExpensesTab() {
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
            'Despesas do Mês',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Despesas do mês atual serão exibidas aqui.',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final categories = [
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
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
                      'R\$ 0,00',
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

  Widget _buildSummaryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(
            'Total Geral',
            'R\$ 0,00',
            Icons.account_balance_wallet,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Este Mês',
            'R\$ 0,00',
            Icons.calendar_month,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Este Ano',
            'R\$ 0,00',
            Icons.calendar_today,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Média Mensal',
            'R\$ 0,00',
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
}