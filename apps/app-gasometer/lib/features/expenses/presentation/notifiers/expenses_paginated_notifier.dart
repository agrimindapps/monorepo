import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container_modular.dart';
import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_filters_service.dart';
import '../../domain/services/expense_statistics_service.dart';
import 'expenses_paginated_state.dart';

part 'expenses_paginated_notifier.g.dart';

/// Notifier para paginação eficiente de despesas
/// Implementa real pagination sem carregar todos os dados em memória
@riverpod
class ExpensesPaginatedNotifier extends _$ExpensesPaginatedNotifier {
  late final IExpensesRepository _repository;
  late final ExpenseStatisticsService _statisticsService;

  @override
  Future<ExpensesPaginatedState> build() async {
    // Inicializa dependências via GetIt
    _repository = getIt<IExpensesRepository>();
    _statisticsService = ExpenseStatisticsService();

    // Carrega primeira página automaticamente
    return await _loadFirstPageInternal();
  }

  /// Carrega primeira página
  Future<void> loadFirstPage() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadFirstPageInternal());
  }

  /// Implementação interna do carregamento da primeira página
  Future<ExpensesPaginatedState> _loadFirstPageInternal() async {
    final currentState = state.valueOrNull ?? const ExpensesPaginatedState();

    final result = await _repository.getExpensesPaginated(
      page: 0,
      pageSize: ExpenseConstants.defaultPageSize,
      vehicleId: currentState.filtersConfig.vehicleId,
      type: currentState.filtersConfig.type,
      startDate: currentState.filtersConfig.startDate,
      endDate: currentState.filtersConfig.endDate,
      sortBy: currentState.sortBy,
      sortOrder: currentState.sortOrder,
    );

    // Carrega estatísticas para primeira página
    Map<String, dynamic>? stats;
    try {
      final allFilteredExpenses = await _repository.getExpensesWithFilters(
        vehicleId: currentState.filtersConfig.vehicleId,
        type: currentState.filtersConfig.type,
        startDate: currentState.filtersConfig.startDate,
        endDate: currentState.filtersConfig.endDate,
        searchText: currentState.filtersConfig.searchQuery.isNotEmpty
            ? currentState.filtersConfig.searchQuery
            : null,
      );
      stats = _statisticsService.calculateStats(allFilteredExpenses);
    } catch (e) {
      // Falha nas stats não deve impedir o carregamento
      stats = null;
    }

    return currentState.copyWith(
      items: result.items,
      currentPage: 0,
      hasNextPage: result.hasNext,
      isLoadingMore: false,
      cachedStats: stats,
    );
  }

  /// Carrega próxima página
  Future<void> loadNextPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null ||
        !currentState.hasNextPage ||
        currentState.isLoadingMore) {
      return;
    }

    // Marca como carregando mais (sem resetar estado)
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;

      final result = await _repository.getExpensesPaginated(
        page: nextPage,
        pageSize: ExpenseConstants.defaultPageSize,
        vehicleId: currentState.filtersConfig.vehicleId,
        type: currentState.filtersConfig.type,
        startDate: currentState.filtersConfig.startDate,
        endDate: currentState.filtersConfig.endDate,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      );

      final updatedItems = [...currentState.items, ...result.items];

      state = AsyncValue.data(
        currentState.copyWith(
          items: updatedItems,
          currentPage: nextPage,
          hasNextPage: result.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      // Mantém items carregados em caso de erro
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      // Re-throw para captura no UI se necessário
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Refresh (recarrega primeira página)
  Future<void> refresh() async {
    await loadFirstPage();
  }

  /// Aplica filtros e recarrega dados
  Future<void> applyFilters(ExpenseFiltersConfig newFilters) async {
    final currentState = state.valueOrNull ?? const ExpensesPaginatedState();

    if (currentState.filtersConfig == newFilters) return;

    // Atualiza filtros e recarrega
    state = AsyncValue.data(
      currentState.copyWith(
        filtersConfig: newFilters,
        cachedStats: null, // Invalida cache de stats
      ),
    );

    await loadFirstPage();
  }

  /// Atualiza ordenação
  Future<void> setSortBy(ExpenseSortBy sortBy, SortOrder sortOrder) async {
    final currentState = state.valueOrNull ?? const ExpensesPaginatedState();

    if (currentState.sortBy == sortBy && currentState.sortOrder == sortOrder) {
      return;
    }

    // Atualiza ordenação e recarrega
    state = AsyncValue.data(
      currentState.copyWith(
        sortBy: sortBy,
        sortOrder: sortOrder,
      ),
    );

    await loadFirstPage();
  }

  /// Toggle sort order para o mesmo campo
  Future<void> toggleSortOrder(ExpenseSortBy sortBy) async {
    final currentState = state.valueOrNull ?? const ExpensesPaginatedState();

    SortOrder newOrder;
    if (currentState.sortBy == sortBy) {
      // Mesmo campo, inverte ordem
      newOrder = currentState.sortOrder == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending;
    } else {
      // Campo diferente, padrão descendente
      newOrder = SortOrder.descending;
    }

    await setSortBy(sortBy, newOrder);
  }

  /// Aplica filtro por veículo
  Future<void> filterByVehicle(String? vehicleId) async {
    final currentState = state.valueOrNull ?? const ExpensesPaginatedState();

    final newFilters = currentState.filtersConfig.copyWith(
      vehicleId: vehicleId,
      clearVehicleId: vehicleId == null,
    );
    await applyFilters(newFilters);
  }

  /// Aplica filtro por tipo
  Future<void> filterByType(ExpenseType? type) async {
    final currentState = state.valueOrNull ?? const ExpensesPaginatedState();

    final newFilters = currentState.filtersConfig.copyWith(
      type: type,
      clearType: type == null,
    );
    await applyFilters(newFilters);
  }

  /// Aplica filtro por período
  Future<void> filterByPeriod(DateTime? start, DateTime? end) async {
    final currentState = state.valueOrNull ?? const ExpensesPaginatedState();

    final newFilters = currentState.filtersConfig.copyWith(
      startDate: start,
      endDate: end,
      clearDates: start == null && end == null,
    );
    await applyFilters(newFilters);
  }

  /// Aplica busca por texto
  Future<void> search(String query) async {
    final currentState = state.valueOrNull ?? const ExpensesPaginatedState();

    final newFilters = currentState.filtersConfig.copyWith(searchQuery: query);
    await applyFilters(newFilters);
  }

  /// Limpa todos os filtros
  Future<void> clearFilters() async {
    await applyFilters(const ExpenseFiltersConfig());
  }

  /// Busca despesa específica na lista paginada atual
  ExpenseEntity? findInCurrentPage(String expenseId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    try {
      return currentState.items.firstWhere((expense) => expense.id == expenseId);
    } catch (_) {
      return null;
    }
  }

  /// Recarrega mantendo página atual (best effort)
  Future<void> reloadCurrentPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final currentPageBackup = currentState.currentPage;

    // Recarrega primeira página
    await refresh();

    // Tenta restaurar até a mesma página
    if (currentPageBackup > 0) {
      final newState = state.valueOrNull;
      if (newState != null && newState.hasNextPage) {
        for (int i = 0; i < currentPageBackup && newState.hasNextPage; i++) {
          await loadNextPage();
        }
      }
    }
  }
}
