import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_paginated_provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_formatter_service.dart';
import '../../../../core/widgets/paginated_list_view.dart';

/// Widget de lista paginada de despesas com lazy loading
class ExpensesPaginatedList extends StatelessWidget {
  final VoidCallback? onExpenseTap;
  final bool showVehicleInfo;
  final PaginationConfig? paginationConfig;

  const ExpensesPaginatedList({
    super.key,
    this.onExpenseTap,
    this.showVehicleInfo = false,
    this.paginationConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesPaginatedProvider>(
      builder: (context, provider, child) {
        return PaginatedListView<ExpenseEntity>(
          loadPage: provider.loadPage,
          itemBuilder: _buildExpenseItem,
          separatorBuilder: _buildSeparator,
          emptyWidget: _buildEmptyWidget(context),
          loadingWidget: _buildLoadingWidget(context),
          errorBuilder: _buildErrorWidget,
          config: paginationConfig ?? const PaginationConfig(
            pageSize: 15, // Menor para melhor performance
            initialPageSize: 20,
            scrollThreshold: 0.7,
          ),
          cacheKey: 'expenses_${provider.filtersConfig.hashCode}',
          enableVirtualization: true,
          padding: const EdgeInsets.all(16),
        );
      },
    );
  }

  Widget _buildExpenseItem(BuildContext context, ExpenseEntity expense, int index) {
    final formatter = ExpenseFormatterService();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onExpenseTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com título e valor
              Row(
                children: [
                  Expanded(
                    child: Text(
                      expense.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatter.formatAmount(expense.amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Tipo e data
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: expense.type.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: expense.type.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          expense.type.icon,
                          size: 14,
                          color: expense.type.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          expense.type.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: expense.type.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  Text(
                    formatter.formatDate(expense.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Descrição se houver
              if (expense.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  expense.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Informações adicionais
              if (showVehicleInfo || expense.establishmentName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (expense.establishmentName != null) ...[
                      Icon(
                        Icons.store,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          expense.establishmentName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    
                    if (expense.odometer > 0) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.speed,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatter.formatOdometer(expense.odometer),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              
              // Indicadores especiais
              if (expense.amount >= 1000.0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 12,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Alto valor',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator(BuildContext context, int index) {
    return const SizedBox(height: 8);
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma despesa encontrada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione uma nova despesa ou ajuste os filtros',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando despesas...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback retry) {
    return Builder(
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar despesas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de filtros para a lista paginada
class ExpensesPaginatedFilters extends StatelessWidget {
  const ExpensesPaginatedFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesPaginatedProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtros',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (provider.hasActiveFilters)
                      TextButton(
                        onPressed: provider.clearFilters,
                        child: const Text('Limpar'),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Busca
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar despesas...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: provider.search,
                ),
                
                const SizedBox(height: 16),
                
                // Filtros rápidos
                Wrap(
                  spacing: 8,
                  children: ExpenseType.values.map((type) {
                    final isSelected = provider.filtersConfig.type == type;
                    return FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(type.displayName),
                        ],
                      ),
                      onSelected: (selected) {
                        provider.filterByType(selected ? type : null);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}