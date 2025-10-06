import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../domain/entities/expense_entity.dart';
import '../notifiers/expenses_paginated_notifier.dart';
import '../notifiers/expenses_paginated_state.dart';

/// Widget de lista paginada eficiente para despesas
/// Implementa infinite scrolling com lazy loading real
class ExpensesPaginatedList extends ConsumerStatefulWidget {
  
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
  ConsumerState<ExpensesPaginatedList> createState() => _ExpensesPaginatedListState();
}

class _ExpensesPaginatedListState extends ConsumerState<ExpensesPaginatedList> {
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
      final asyncState = ref.read(expensesPaginatedNotifierProvider);
      final state = asyncState.valueOrNull;
      if (state != null && state.hasNextPage && !state.isLoadingMore) {
        ref.read(expensesPaginatedNotifierProvider.notifier).loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(expensesPaginatedNotifierProvider);

    return asyncState.when(
      data: (state) {
        if (state.items.isEmpty) {
          return _buildEmpty();
        }
        return _buildList(state);
      },
      loading: () => _buildInitialLoading(),
      error: (error, stackTrace) => _buildError(error),
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

  Widget _buildError(Object error) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!;
    }

    return ErrorStateWidget(
      title: 'Erro ao carregar despesas',
      message: error.toString(),
      onRetry: () => ref.read(expensesPaginatedNotifierProvider.notifier).refresh(),
    );
  }

  Widget _buildEmpty() {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!;
    }

    final asyncState = ref.read(expensesPaginatedNotifierProvider);
    final hasFilters = asyncState.valueOrNull?.hasActiveFilters ?? false;

    return EmptyStateWidget(
      icon: Icons.receipt_long,
      title: hasFilters ? 'Nenhuma despesa encontrada' : 'Nenhuma despesa cadastrada',
      message: hasFilters
          ? 'Tente ajustar os filtros para encontrar despesas'
          : 'Adicione sua primeira despesa para começar a acompanhar os gastos',
      onAction: hasFilters
          ? () => ref.read(expensesPaginatedNotifierProvider.notifier).clearFilters()
          : null,
    );
  }

  Widget _buildList(ExpensesPaginatedState state) {
    final itemCount = state.itemCount + (state.hasNextPage ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () => ref.read(expensesPaginatedNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding ?? const EdgeInsets.all(16),
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemExtent: widget.itemExtent,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= state.itemCount) {
            return _buildLoadMoreIndicator(state);
          }
          final expense = state.items[index];
          return widget.itemBuilder(context, expense, index);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(ExpensesPaginatedState state) {
    if (state.isLoadingMore) {
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
class ExpensesPaginatedFilters extends ConsumerWidget {

  const ExpensesPaginatedFilters({
    super.key,
    this.showStats = true,
    this.onFiltersChanged,
  });
  final bool showStats;
  final VoidCallback? onFiltersChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(expensesPaginatedNotifierProvider);

    return asyncState.when(
      data: (state) {
        return Column(
          children: [
            _buildSortControls(context, ref, state),
            if (showStats && state.cachedStats != null) ...[
              const SizedBox(height: 8),
              _buildStatsCard(state.cachedStats!),
            ],
            if (state.hasActiveFilters) ...[
              const SizedBox(height: 8),
              _buildActiveFiltersIndicator(context, ref, state),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSortControls(BuildContext context, WidgetRef ref, ExpensesPaginatedState state) {
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
                  final isActive = state.sortBy == sortBy;
                  return FilterChip(
                    label: Text(_getSortLabel(sortBy)),
                    selected: isActive,
                    onSelected: (_) => ref.read(expensesPaginatedNotifierProvider.notifier).toggleSortOrder(sortBy),
                    avatar: isActive && state.sortOrder == SortOrder.ascending
                        ? const Icon(Icons.keyboard_arrow_up, size: 16)
                        : isActive && state.sortOrder == SortOrder.descending
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
    WidgetRef ref,
    ExpensesPaginatedState state,
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
                'Filtros ativos - ${state.itemCount} resultado(s)',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(expensesPaginatedNotifierProvider.notifier).clearFilters();
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
