import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/empty_state_widget.dart';
import '../../../../core/presentation/widgets/error_state_widget.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_paginated_provider.dart';

/// Widget de lista paginada eficiente para despesas
/// Implementa infinite scrolling com lazy loading real
class ExpensesPaginatedList extends StatefulWidget {
  
  const ExpensesPaginatedList({
    super.key,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.padding,
    this.itemExtent,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
  });
  final Widget Function(BuildContext context, ExpenseEntity expense, int index) itemBuilder;
  final Widget? loadingBuilder;
  final Widget? errorBuilder;
  final Widget? emptyBuilder;
  final EdgeInsets? padding;
  final double? itemExtent;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  State<ExpensesPaginatedList> createState() => _ExpensesPaginatedListState();
}

class _ExpensesPaginatedListState extends State<ExpensesPaginatedList> {
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // User reached the bottom, load next page
      final provider = context.read<ExpensesPaginatedProvider>();
      if (provider.hasNextPage && !provider.isLoadingMore) {
        provider.loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesPaginatedProvider>(
      builder: (context, provider, child) {
        // Initial loading state
        if (provider.isInitial && provider.isLoading) {
          return _buildInitialLoading();
        }

        // Error state
        if (provider.hasError) {
          return _buildError(provider);
        }

        // Empty state
        if (provider.isEmpty) {
          return _buildEmpty();
        }

        // Main list with items
        return _buildList(provider);
      },
    );
  }

  Widget _buildInitialLoading() {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!;
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando despesas...'),
        ],
      ),
    );
  }

  Widget _buildError(ExpensesPaginatedProvider provider) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!;
    }

    return ErrorStateWidget(
      title: 'Erro ao carregar despesas',
      message: provider.error?.displayMessage ?? 'Erro desconhecido',
      onRetry: provider.hasError ? provider.retry : null,
    );
  }

  Widget _buildEmpty() {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!;
    }

    final hasFilters = context.read<ExpensesPaginatedProvider>().hasActiveFilters;
    
    return EmptyStateWidget(
      icon: Icons.receipt_long,
      title: hasFilters ? 'Nenhuma despesa encontrada' : 'Nenhuma despesa cadastrada',
      message: hasFilters
          ? 'Tente ajustar os filtros para encontrar despesas'
          : 'Adicione sua primeira despesa para começar a acompanhar os gastos',
      onAction: hasFilters
          ? () => context.read<ExpensesPaginatedProvider>().clearFilters()
          : null,
    );
  }

  Widget _buildList(ExpensesPaginatedProvider provider) {
    final itemCount = provider.itemCount + (provider.hasNextPage ? 1 : 0);
    
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding ?? const EdgeInsets.all(16),
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemExtent: widget.itemExtent,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Loading more indicator at the bottom
          if (index >= provider.itemCount) {
            return _buildLoadMoreIndicator(provider);
          }

          // Regular expense item
          final expense = provider.items[index];
          return widget.itemBuilder(context, expense, index);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(ExpensesPaginatedProvider provider) {
    if (provider.isLoadingMore) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Carregando mais despesas...',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // End of list indicator
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        'Todas as despesas foram carregadas',
        style: AppTheme.textStyles.bodySmall?.copyWith(
          color: AppTheme.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Widget de filtros para a lista paginada
class ExpensesPaginatedFilters extends StatelessWidget {
  
  const ExpensesPaginatedFilters({
    super.key,
    this.showStats = true,
    this.onFiltersChanged,
  });
  final bool showStats;
  final VoidCallback? onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesPaginatedProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Sort controls
            _buildSortControls(context, provider),
            
            // Stats summary if available
            if (showStats && provider.stats != null) ...[
              const SizedBox(height: 8),
              _buildStatsCard(provider.stats!),
            ],
            
            // Active filters indicator
            if (provider.hasActiveFilters) ...[
              const SizedBox(height: 8),
              _buildActiveFiltersIndicator(context, provider),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSortControls(BuildContext context, ExpensesPaginatedProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.sort, size: 20),
            const SizedBox(width: 8),
            const Text('Ordenar por:'),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: ExpenseSortBy.values.map((sortBy) {
                  final isActive = provider.sortBy == sortBy;
                  return FilterChip(
                    label: Text(_getSortLabel(sortBy)),
                    selected: isActive,
                    onSelected: (_) => provider.toggleSortOrder(sortBy),
                    avatar: isActive && provider.sortOrder == SortOrder.ascending
                        ? const Icon(Icons.keyboard_arrow_up, size: 16)
                        : isActive && provider.sortOrder == SortOrder.descending
                        ? const Icon(Icons.keyboard_arrow_down, size: 16)
                        : null,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total',
              'R\$ ${(stats['totalAmount'] as double? ?? 0).toStringAsFixed(2)}',
              Icons.attach_money,
            ),
            _buildStatItem(
              'Qtd',
              (stats['totalRecords'] as int? ?? 0).toString(),
              Icons.receipt,
            ),
            _buildStatItem(
              'Média',
              'R\$ ${(stats['averageAmount'] as double? ?? 0).toStringAsFixed(2)}',
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.textStyles.titleSmall,
        ),
        Text(
          label,
          style: AppTheme.textStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildActiveFiltersIndicator(
    BuildContext context, 
    ExpensesPaginatedProvider provider,
  ) {
    return Card(
      color: AppTheme.colors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt,
              color: AppTheme.colors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Filtros ativos - ${provider.itemCount} resultado(s)',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.clearFilters();
                onFiltersChanged?.call();
              },
              child: Text(
                'Limpar',
                style: TextStyle(color: AppTheme.colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(ExpenseSortBy sortBy) {
    switch (sortBy) {
      case ExpenseSortBy.date:
        return 'Data';
      case ExpenseSortBy.amount:
        return 'Valor';
      case ExpenseSortBy.type:
        return 'Tipo';
      case ExpenseSortBy.description:
        return 'Descrição';
      case ExpenseSortBy.odometer:
        return 'Km';
    }
  }
}