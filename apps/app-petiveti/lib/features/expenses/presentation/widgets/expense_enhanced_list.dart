import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';
import '../providers/expenses_provider.dart';

/// Enhanced expense list with rich interactions and visual feedback
class ExpenseEnhancedList extends ConsumerStatefulWidget {
  final List<Expense> expenses;
  final bool showAnimations;
  
  const ExpenseEnhancedList({
    super.key,
    required this.expenses,
    this.showAnimations = true,
  });

  @override
  ConsumerState<ExpenseEnhancedList> createState() => _ExpenseEnhancedListState();
}

class _ExpenseEnhancedListState extends ConsumerState<ExpenseEnhancedList>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late Animation<double> _fadeAnimation;
  
  String _searchQuery = '';
  ExpenseCategory? _filterCategory;
  DateRange? _dateRange;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listAnimationController, curve: Curves.easeOut),
    );
    
    if (widget.showAnimations) {
      _listAnimationController.forward();
    } else {
      _listAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredExpenses = _filterExpenses(widget.expenses);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildSearchAndFilters(theme),
          if (filteredExpenses.isEmpty)
            _buildEmptyState(theme)
          else
            Expanded(child: _buildExpensesList(theme, filteredExpenses)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar despesas...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list : Icons.filter_list_off,
                  color: _showFilters ? theme.colorScheme.primary : null,
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          // Filters
          if (_showFilters) ...[
            const SizedBox(height: 16),
            _buildFiltersRow(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildFiltersRow(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Category filter
        DropdownButton<ExpenseCategory?>(
          value: _filterCategory,
          hint: const Text('Categoria'),
          items: [
            const DropdownMenuItem<ExpenseCategory?>(
              value: null,
              child: Text('Todas as categorias'),
            ),
            ...ExpenseCategory.values.map(
              (category) => DropdownMenuItem<ExpenseCategory?>(
                value: category,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: _getCategoryColor(category),
                    ),
                    const SizedBox(width: 8),
                    Text(_getCategoryName(category)),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _filterCategory = value;
            });
          },
        ),
        
        // Date range filter
        FilterChip(
          label: Text(_dateRange == null ? 'Período' : _formatDateRange(_dateRange!)),
          selected: _dateRange != null,
          onSelected: (_) => _selectDateRange(),
        ),
        
        // Clear filters
        if (_filterCategory != null || _dateRange != null)
          ActionChip(
            label: const Text('Limpar'),
            onPressed: () {
              setState(() {
                _filterCategory = null;
                _dateRange = null;
              });
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final hasFilters = _searchQuery.isNotEmpty || _filterCategory != null || _dateRange != null;
    
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters 
                  ? 'Nenhuma despesa encontrada'
                  : 'Nenhuma despesa registrada',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Tente ajustar os filtros de pesquisa'
                  : 'Comece adicionando sua primeira despesa',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _filterCategory = null;
                    _dateRange = null;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpar Filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList(ThemeData theme, List<Expense> expenses) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh expenses data
        await ref.read(expensesProvider.notifier).loadExpenses('default_user');
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 50)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildExpenseCard(theme, expense, index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildExpenseCard(ThemeData theme, Expense expense, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _showExpenseDetails(expense),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Category avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(expense.category),
                        color: _getCategoryColor(expense.category),
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Main content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            expense.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildInfoChip(
                                _getCategoryName(expense.category),
                                _getCategoryColor(expense.category),
                              ),
                              if (expense.veterinarianName != null)
                                _buildInfoChip(
                                  expense.veterinarianName!,
                                  Colors.blue,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Amount and actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'R\$ ${expense.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(expense.category),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(expense.expenseDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onSelected: (action) => _handleAction(action, expense),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility),
                                  SizedBox(width: 8),
                                  Text('Ver Detalhes'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            if (expense.hasAttachments)
                              const PopupMenuItem(
                                value: 'attachments',
                                child: Row(
                                  children: [
                                    Icon(Icons.attach_file),
                                    SizedBox(width: 8),
                                    Text('Ver Anexos'),
                                  ],
                                ),
                              ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Excluir', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Additional info if present
                if (expense.invoiceNumber != null || expense.veterinaryClinic != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (expense.invoiceNumber != null) ...[
                        Icon(
                          Icons.receipt,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'NF: ${expense.invoiceNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                      if (expense.invoiceNumber != null && expense.veterinaryClinic != null)
                        const SizedBox(width: 16),
                      if (expense.veterinaryClinic != null) ...[
                        Icon(
                          Icons.local_hospital,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            expense.veterinaryClinic!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    var filtered = expenses.toList();
    
    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((expense) {
        final query = _searchQuery.toLowerCase();
        return expense.title.toLowerCase().contains(query) ||
               expense.description.toLowerCase().contains(query) ||
               (expense.veterinarianName?.toLowerCase().contains(query) ?? false) ||
               (expense.veterinaryClinic?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    // Category filter
    if (_filterCategory != null) {
      filtered = filtered.where((expense) => expense.category == _filterCategory).toList();
    }
    
    // Date range filter
    if (_dateRange != null) {
      filtered = filtered.where((expense) {
        return expense.expenseDate.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
               expense.expenseDate.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    
    return filtered;
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (range != null) {
      setState(() {
        _dateRange = range;
      });
    }
  }

  void _showExpenseDetails(Expense expense) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => ExpenseDetailsSheet(
          expense: expense,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _handleAction(String action, Expense expense) {
    switch (action) {
      case 'view':
        _showExpenseDetails(expense);
        break;
      case 'edit':
        // Navigate to edit form
        break;
      case 'delete':
        _showDeleteConfirmation(expense);
        break;
      case 'attachments':
        // Show attachments
        break;
    }
  }

  void _showDeleteConfirmation(Expense expense) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Despesa'),
        content: Text('Tem certeza que deseja excluir "${expense.title}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(expensesProvider.notifier).deleteExpense(expense.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Despesa excluída com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getCategoryColor(ExpenseCategory category) {
    const categoryColors = {
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
    return categoryColors[category] ?? Colors.grey;
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    const categoryIcons = {
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
    return categoryIcons[category] ?? Icons.more_horiz;
  }

  String _getCategoryName(ExpenseCategory category) {
    const categoryNames = {
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
    return categoryNames[category] ?? 'Outros';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateRange(DateRange range) {
    return '${_formatDate(range.start)} - ${_formatDate(range.end)}';
  }
}

/// Expense details bottom sheet
class ExpenseDetailsSheet extends StatelessWidget {
  final Expense expense;
  final ScrollController scrollController;

  const ExpenseDetailsSheet({
    super.key,
    required this.expense,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Header with category
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getCategoryIcon(expense.category),
                        color: _getCategoryColor(expense.category),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getCategoryName(expense.category),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _getCategoryColor(expense.category),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Amount
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'R\$ ${expense.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(expense.category),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Details
                _buildDetailItem('Descrição', expense.description, Icons.description),
                _buildDetailItem('Data', _formatDate(expense.expenseDate), Icons.calendar_today),
                _buildDetailItem('Forma de Pagamento', _getPaymentMethodName(expense.paymentMethod), Icons.payment),
                
                if (expense.veterinarianName != null)
                  _buildDetailItem('Veterinário', expense.veterinarianName!, Icons.person),
                
                if (expense.veterinaryClinic != null)
                  _buildDetailItem('Clínica', expense.veterinaryClinic!, Icons.local_hospital),
                
                if (expense.invoiceNumber != null)
                  _buildDetailItem('Número NF', expense.invoiceNumber!, Icons.receipt),
                
                if (expense.hasAttachments) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Anexos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...expense.attachments.map((attachment) => ListTile(
                        leading: const Icon(Icons.attach_file),
                        title: Text(attachment),
                        onTap: () {
                          // Open attachment
                        },
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods (copied from parent for consistency)
  Color _getCategoryColor(ExpenseCategory category) {
    const categoryColors = {
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
    return categoryColors[category] ?? Colors.grey;
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    const categoryIcons = {
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
    return categoryIcons[category] ?? Icons.more_horiz;
  }

  String _getCategoryName(ExpenseCategory category) {
    const categoryNames = {
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
    return categoryNames[category] ?? 'Outros';
  }

  String _getPaymentMethodName(PaymentMethod method) {
    const methodNames = {
      PaymentMethod.cash: 'Dinheiro',
      PaymentMethod.creditCard: 'Cartão de Crédito',
      PaymentMethod.debitCard: 'Cartão de Débito',
      PaymentMethod.pix: 'PIX',
      PaymentMethod.bankTransfer: 'Transferência Bancária',
      PaymentMethod.insurance: 'Plano de Saúde',
      PaymentMethod.other: 'Outros',
    };
    return methodNames[method] ?? 'Outros';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}