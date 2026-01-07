import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/enhanced_animal_selector.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../domain/entities/expense.dart';
import '../providers/expenses_provider.dart';
import '../widgets/add_expense_dialog.dart';

/// Página de despesas simplificada seguindo padrão Odometer
class ExpensesPage extends ConsumerStatefulWidget {
  final String userId;

  const ExpensesPage({super.key, required this.userId});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  String? _selectedAnimalId;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expensesProvider.notifier).loadExpenses(widget.userId);
    });
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

    final expensesState = ref.watch(expensesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildAnimalSelector(),
            if (_selectedAnimalId != null && expensesState.expenses.isNotEmpty)
              _buildMonthSelector(expensesState.expenses),
            Expanded(child: _buildContent(context, expensesState)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedAnimalId != null
            ? () => _showAddExpenseDialog(context)
            : null,
        tooltip: _selectedAnimalId != null
            ? 'Adicionar Despesa'
            : 'Selecione um pet primeiro',
        backgroundColor: _selectedAnimalId != null
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: _selectedAnimalId != null
            ? null
            : Theme.of(context).colorScheme.onSurfaceVariant,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: PetivetiPageHeader(
        icon: Icons.receipt_long,
        title: 'Despesas',
        subtitle: 'Controle de gastos com pets',
        showBackButton: true,
        actions: [
          _buildHeaderAction(
            icon: _showStats ? Icons.analytics : Icons.analytics_outlined,
            onTap: () => setState(() => _showStats = !_showStats),
            tooltip: _showStats ? 'Ocultar estatísticas' : 'Mostrar estatísticas',
          ),
          _buildHeaderAction(
            icon: Icons.refresh,
            onTap: () => ref.read(expensesProvider.notifier).loadExpenses(widget.userId),
            tooltip: 'Atualizar',
          ),
        ],
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

  Widget _buildAnimalSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: EnhancedAnimalSelector(
        selectedAnimalId: _selectedAnimalId,
        onAnimalChanged: (animalId) {
          setState(() => _selectedAnimalId = animalId);
          if (animalId != null) {
            ref.read(expensesProvider.notifier).filterByAnimal(animalId);
          } else {
            ref.read(expensesProvider.notifier).clearAnimalFilter();
          }
        },
        hintText: 'Selecione um pet',
      ),
    );
  }

  Widget _buildMonthSelector(List<Expense> expenses) {
    final months = _getMonths(expenses);
    final selectedMonth = ref.watch(expensesProvider).selectedMonth;

    if (months.isEmpty) return const SizedBox.shrink();

    // Auto-select current month if none selected
    if (selectedMonth == null && months.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);
        final hasCurrentMonth = months.any((m) =>
            m.year == currentMonth.year && m.month == currentMonth.month);
        
        if (hasCurrentMonth) {
          ref.read(expensesProvider.notifier).selectMonth(currentMonth);
        } else {
          ref.read(expensesProvider.notifier).selectMonth(months.first);
        }
      });
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = selectedMonth != null &&
              month.year == selectedMonth.year &&
              month.month == selectedMonth.month;

          final monthName = DateFormat('MMM yy', 'pt_BR').format(month);
          final formattedMonth =
              monthName[0].toUpperCase() + monthName.substring(1);

          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                ref.read(expensesProvider.notifier).selectMonth(month);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  formattedMonth,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExpensesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(expensesProvider.notifier).loadExpenses(widget.userId),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_selectedAnimalId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Selecione um pet', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Escolha um pet acima para ver suas despesas'),
          ],
        ),
      );
    }

    final filteredExpenses = _getFilteredExpenses(state.expenses);

    if (filteredExpenses.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        if (_showStats) _buildStatsPanel(filteredExpenses),
        Expanded(child: _buildExpensesList(filteredExpenses)),
      ],
    );
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    final selectedMonth = ref.watch(expensesProvider).selectedMonth;
    if (selectedMonth == null) return expenses;

    return expenses.where((e) {
      final date = e.expenseDate;
      return date.year == selectedMonth.year &&
          date.month == selectedMonth.month;
    }).toList();
  }

  Widget _buildStatsPanel(List<Expense> expenses) {
    final total = expenses.fold<double>(0, (acc, e) => acc + e.amount);
    final count = expenses.length;
    final average = count > 0 ? total / count : 0.0;
    
    // Group by category
    final categories = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      categories[expense.category] = (categories[expense.category] ?? 0) + expense.amount;
    }
    final topCategory = categories.entries.isEmpty 
        ? 'N/A' 
        : _getCategoryDisplayName(categories.entries.reduce((a, b) => a.value > b.value ? a : b).key);

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Estatísticas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.attach_money,
                  label: 'Total',
                  value: currencyFormat.format(total),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.receipt,
                  label: 'Qtd',
                  value: count.toString(),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  label: 'Média',
                  value: currencyFormat.format(average),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.category,
                  label: 'Maior Categoria',
                  value: topCategory,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(expensesProvider.notifier).loadExpenses(widget.userId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return Dismissible(
            key: ValueKey(expense.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Excluir',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) => _confirmDeleteExpense(expense),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(expense.description),
                subtitle: Text(
                  '${_getCategoryDisplayName(expense.category)} • ${DateFormat('dd/MM/yyyy').format(expense.expenseDate)}',
                ),
                trailing: Text(
                  currencyFormat.format(expense.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onTap: () => _showEditExpenseDialog(context, expense),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.consultation:
        return Icons.medical_services;
      case ExpenseCategory.medication:
        return Icons.medication;
      case ExpenseCategory.grooming:
        return Icons.cleaning_services;
      case ExpenseCategory.accessory:
        return Icons.shopping_bag;
      case ExpenseCategory.vaccine:
        return Icons.vaccines;
      case ExpenseCategory.surgery:
        return Icons.local_hospital;
      case ExpenseCategory.exam:
        return Icons.science;
      case ExpenseCategory.insurance:
        return Icons.security;
      case ExpenseCategory.emergency:
        return Icons.emergency;
      case ExpenseCategory.other:
        return Icons.receipt;
    }
  }

  String _getCategoryDisplayName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return 'Alimentação';
      case ExpenseCategory.consultation:
        return 'Consulta';
      case ExpenseCategory.medication:
        return 'Medicamento';
      case ExpenseCategory.grooming:
        return 'Higiene';
      case ExpenseCategory.accessory:
        return 'Acessório';
      case ExpenseCategory.vaccine:
        return 'Vacina';
      case ExpenseCategory.surgery:
        return 'Cirurgia';
      case ExpenseCategory.exam:
        return 'Exame';
      case ExpenseCategory.insurance:
        return 'Seguro';
      case ExpenseCategory.emergency:
        return 'Emergência';
      case ExpenseCategory.other:
        return 'Outro';
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withAlpha(127),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma despesa encontrada',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione despesas para controlar os gastos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(127),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<DateTime> _getMonths(List<Expense> expenses) {
    if (expenses.isEmpty) return [];
    
    final dates = expenses.map((e) => e.expenseDate).toList();
    final uniqueMonths = <DateTime>{};
    
    for (final date in dates) {
      uniqueMonths.add(DateTime(date.year, date.month));
    }
    
    final sortedMonths = uniqueMonths.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first
    
    return sortedMonths;
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AddExpenseDialog(
        initialAnimalId: _selectedAnimalId,
      ),
    );
  }

  void _showEditExpenseDialog(BuildContext context, Expense expense) {
    showDialog<void>(
      context: context,
      builder: (context) => AddExpenseDialog(expense: expense),
    );
  }

  Future<bool> _confirmDeleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Despesa'),
        content: Text('Tem certeza que deseja excluir "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(expensesProvider.notifier).deleteExpense(expense.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Despesa excluída com sucesso')),
        );
      }
      return true;
    }
    return false;
  }
}
