import 'package:core/core.dart' show Equatable;

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_filters_service.dart';

/// State para paginação de despesas com filtros e estatísticas
class ExpensesPaginatedState extends Equatable {
  const ExpensesPaginatedState({
    this.items = const [],
    this.currentPage = 0,
    this.hasNextPage = true,
    this.isLoadingMore = false,
    this.filtersConfig = const ExpenseFiltersConfig(),
    this.sortBy = ExpenseSortBy.date,
    this.sortOrder = SortOrder.descending,
    this.cachedStats,
  });

  final List<ExpenseEntity> items;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingMore;
  final ExpenseFiltersConfig filtersConfig;
  final ExpenseSortBy sortBy;
  final SortOrder sortOrder;
  final Map<String, dynamic>? cachedStats;

  /// Verifica se tem filtros ativos
  bool get hasActiveFilters => filtersConfig.hasActiveFilters;

  /// Total de itens carregados
  int get itemCount => items.length;

  /// Obtém contexto de paginação para debug/logging
  Map<String, dynamic> get paginationContext => {
    'currentPage': currentPage,
    'itemCount': itemCount,
    'hasNextPage': hasNextPage,
    'isLoadingMore': isLoadingMore,
    'pageSize': ExpenseConstants.defaultPageSize,
    'sortBy': sortBy.name,
    'sortOrder': sortOrder.name,
    'activeFilters': hasActiveFilters,
    'filterDetails': filtersConfig.toString(),
  };

  ExpensesPaginatedState copyWith({
    List<ExpenseEntity>? items,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoadingMore,
    ExpenseFiltersConfig? filtersConfig,
    ExpenseSortBy? sortBy,
    SortOrder? sortOrder,
    Map<String, dynamic>? cachedStats,
  }) {
    return ExpensesPaginatedState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filtersConfig: filtersConfig ?? this.filtersConfig,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      cachedStats: cachedStats ?? this.cachedStats,
    );
  }

  @override
  List<Object?> get props => [
    items,
    currentPage,
    hasNextPage,
    isLoadingMore,
    filtersConfig,
    sortBy,
    sortOrder,
    cachedStats,
  ];
}
