import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/paginated_list_view.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_formatter_service.dart';
import '../providers/expenses_paginated_provider.dart';

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
    // Usar Selector para otimizar rebuilds - só reconstrói quando dados relevantes mudam
    return Selector<ExpensesPaginatedProvider, (bool, String?, String)>(
      selector: (context, provider) => (
        provider.isLoading,
        provider.error,
        'expenses_${provider.hashCode}',
      ),
      builder: (context, data, child) {
        final (isLoading, error, cacheKey) = data;
        final provider = Provider.of<ExpensesPaginatedProvider>(context, listen: false);
        
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
          cacheKey: cacheKey,
          enableVirtualization: true,
          padding: const EdgeInsets.all(16),
        );
      },
    );
  }

  Widget _buildExpenseItem(BuildContext context, ExpenseEntity expense, int index) {
    // Cache do formatter para evitar instanciação repetida
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
                      color: expense.type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: expense.type.color.withValues(alpha: 0.3),
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
              if (showVehicleInfo || expense.establishmentName.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...[
                    Icon(
                      Icons.store,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        expense.establishmentName,
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
                    color: Colors.orange.withValues(alpha: 0.1),
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
    // Selector para otimizar rebuilds dos filtros
    return Selector<ExpensesPaginatedProvider, (bool, String)>(
      selector: (context, provider) => (
        provider.hasActiveFilters,
        provider.filtersConfig.searchQuery ?? '',
      ),
      builder: (context, filterData, child) {
        final (hasActiveFilters, searchQuery) = filterData;
        final provider = Provider.of<ExpensesPaginatedProvider>(context, listen: false);
        
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
                    if (hasActiveFilters)
                      TextButton(
                        onPressed: provider.clearFilters,
                        child: const Text('Limpar'),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Busca - Widget otimizado para reconstruir apenas quando necessário
                _OptimizedSearchField(
                  initialValue: searchQuery,
                  onChanged: provider.search,
                ),
                
                const SizedBox(height: 16),
                
                // Filtros rápidos - Widget cache para chips
                _OptimizedFilterChips(
                  onFilterChanged: () => provider.clearFilters(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget otimizado para campo de busca
class _OptimizedSearchField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  
  const _OptimizedSearchField({
    required this.initialValue,
    required this.onChanged,
  });
  
  @override
  State<_OptimizedSearchField> createState() => _OptimizedSearchFieldState();
}

class _OptimizedSearchFieldState extends State<_OptimizedSearchField> {
  late final TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }
  
  @override
  void didUpdateWidget(_OptimizedSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: 'Buscar despesas...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
    );
  }
}

/// Widget otimizado para chips de filtro
class _OptimizedFilterChips extends StatelessWidget {
  final VoidCallback onFilterChanged;
  
  const _OptimizedFilterChips({
    required this.onFilterChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          selected: false,
          label: const Text('Todos'),
          onSelected: (selected) {
            onFilterChanged();
          },
        ),
      ],
    );
  }
}

