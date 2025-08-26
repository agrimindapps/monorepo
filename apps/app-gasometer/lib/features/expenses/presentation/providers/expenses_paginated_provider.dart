import 'dart:async';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../../../core/providers/base_provider.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_filters_service.dart';
import '../../domain/services/expense_statistics_service.dart';

/// Provider especializado em paginação eficiente de despesas
/// Implementa real pagination sem carregar todos os dados em memória
class ExpensesPaginatedProvider extends BaseProvider with PaginatedProviderMixin<ExpenseEntity> {
  final IExpensesRepository _repository;
  final ExpenseStatisticsService _statisticsService = ExpenseStatisticsService();

  // Filtros ativos
  ExpenseFiltersConfig _filtersConfig = const ExpenseFiltersConfig();
  
  // Sort configuration
  ExpenseSortBy _sortBy = ExpenseSortBy.date;
  SortOrder _sortOrder = SortOrder.descending;
  
  // Statistics cache for current filter set
  Map<String, dynamic>? _cachedStats;

  ExpensesPaginatedProvider(this._repository);

  // Getters públicos
  ExpenseFiltersConfig get filtersConfig => _filtersConfig;
  ExpenseSortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;
  bool get hasActiveFilters => _filtersConfig.hasActiveFilters;
  Map<String, dynamic>? get stats => _cachedStats;

  @override
  int getPageSize() => ExpenseConstants.defaultPageSize;

  /// Implementa a busca paginada real do mixin
  @override
  Future<List<ExpenseEntity>> fetchPage(int page) async {
    logInfo('Fetching page $page with filters', metadata: {
      'page': page,
      'pageSize': getPageSize(),
      'sortBy': _sortBy.name,
      'sortOrder': _sortOrder.name,
      'hasFilters': hasActiveFilters,
    });

    final result = await _repository.getExpensesPaginated(
      page: page,
      pageSize: getPageSize(),
      vehicleId: _filtersConfig.vehicleId,
      type: _filtersConfig.type,
      startDate: _filtersConfig.startDate,
      endDate: _filtersConfig.endDate,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    // Cache stats only for first page
    if (page == 0) {
      await _updateStatsForCurrentFilters();
    }

    logInfo('Page $page fetched successfully', metadata: {
      'itemsReturned': result.items.length,
      'totalItems': result.totalItems,
      'hasNext': result.hasNext,
    });

    return result.items;
  }

  /// Aplica filtros e recarrega dados
  Future<void> applyFilters(ExpenseFiltersConfig newFilters) async {
    if (_filtersConfig == newFilters) return;

    logInfo('Applying new filters', metadata: {
      'previousFilters': _filtersConfig.toString(),
      'newFilters': newFilters.toString(),
    });

    _filtersConfig = newFilters;
    _cachedStats = null; // Invalidate stats cache
    
    await loadFirstPage(); // This will trigger a complete reload
  }

  /// Atualiza ordenação
  Future<void> setSortBy(ExpenseSortBy sortBy, SortOrder sortOrder) async {
    if (_sortBy == sortBy && _sortOrder == sortOrder) return;

    logInfo('Changing sort order', metadata: {
      'previousSort': '${_sortBy.name} ${_sortOrder.name}',
      'newSort': '${sortBy.name} ${sortOrder.name}',
    });

    _sortBy = sortBy;
    _sortOrder = sortOrder;
    
    await loadFirstPage(); // Reload with new sort
  }

  /// Aplica filtro por veículo
  Future<void> filterByVehicle(String? vehicleId) async {
    final newFilters = _filtersConfig.copyWith(
      vehicleId: vehicleId,
      clearVehicleId: vehicleId == null,
    );
    await applyFilters(newFilters);
  }

  /// Aplica filtro por tipo
  Future<void> filterByType(ExpenseType? type) async {
    final newFilters = _filtersConfig.copyWith(
      type: type,
      clearType: type == null,
    );
    await applyFilters(newFilters);
  }

  /// Aplica filtro por período
  Future<void> filterByPeriod(DateTime? start, DateTime? end) async {
    final newFilters = _filtersConfig.copyWith(
      startDate: start,
      endDate: end,
      clearDates: start == null && end == null,
    );
    await applyFilters(newFilters);
  }

  /// Aplica busca por texto (note: this may affect performance for large datasets)
  Future<void> search(String query) async {
    final newFilters = _filtersConfig.copyWith(searchQuery: query);
    await applyFilters(newFilters);
  }

  /// Limpa todos os filtros
  Future<void> clearFilters() async {
    await applyFilters(const ExpenseFiltersConfig());
  }

  /// Toggle sort order for the same field
  Future<void> toggleSortOrder(ExpenseSortBy sortBy) async {
    SortOrder newOrder;
    if (_sortBy == sortBy) {
      // Same field, toggle order
      newOrder = _sortOrder == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending;
    } else {
      // Different field, default to descending
      newOrder = SortOrder.descending;
    }
    
    await setSortBy(sortBy, newOrder);
  }

  /// Atualiza estatísticas para o conjunto de filtros atual
  Future<void> _updateStatsForCurrentFilters() async {
    try {
      // For stats, we need all filtered data, but this is a separate concern
      // In production, this should ideally be computed server-side or cached
      final allFilteredExpenses = await _repository.getExpensesWithFilters(
        vehicleId: _filtersConfig.vehicleId,
        type: _filtersConfig.type,
        startDate: _filtersConfig.startDate,
        endDate: _filtersConfig.endDate,
        searchText: _filtersConfig.searchQuery.isNotEmpty ? _filtersConfig.searchQuery : null,
      );

      _cachedStats = _statisticsService.calculateStats(allFilteredExpenses);
      notifyListeners();

      logInfo('Stats updated for current filters', metadata: {
        'totalExpenses': allFilteredExpenses.length,
        'totalAmount': _cachedStats?['totalAmount'] ?? 0,
      });
    } catch (e) {
      logWarning('Failed to update stats', metadata: {'error': e.toString()});
      // Don't fail the whole operation if stats fail
    }
  }

  /// Busca despesa específica na lista paginada atual
  ExpenseEntity? findInCurrentPage(String expenseId) {
    return items.where((expense) => expense.id == expenseId).firstOrNull;
  }

  /// Obtém contexto da paginação atual para debug/logging
  Map<String, dynamic> getPaginationContext() {
    return {
      'currentPage': currentPage,
      'itemCount': itemCount,
      'hasNextPage': hasNextPage,
      'isLoadingMore': isLoadingMore,
      'pageSize': getPageSize(),
      'sortBy': _sortBy.name,
      'sortOrder': _sortOrder.name,
      'activeFilters': _filtersConfig.hasActiveFilters,
      'filterDetails': _filtersConfig.toString(),
    };
  }

  /// Override the retry method to provide specific context
  @override
  void onRetry() {
    logInfo('Retrying paginated expenses load', metadata: getPaginationContext());
    refresh();
  }

  /// Método de conveniência para recarregar mantendo página atual
  Future<void> reloadCurrentPage() async {
    final currentPageBackup = currentPage;
    await refresh();
    
    // Try to restore to the same page if possible
    if (currentPageBackup > 0 && hasNextPage) {
      for (int i = 0; i < currentPageBackup && hasNextPage; i++) {
        await loadNextPage();
      }
    }
  }

  @override
  void dispose() {
    _cachedStats = null;
    super.dispose();
  }
}