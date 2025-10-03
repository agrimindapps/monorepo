import 'package:equatable/equatable.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_filters_service.dart';

/// Estado completo do provider de despesas
class ExpensesState extends Equatable {
  const ExpensesState({
    required this.expenses,
    required this.filteredExpenses,
    required this.filtersConfig,
    required this.stats,
    this.patternAnalysis,
    required this.isLoading,
    this.error,
  });

  /// Estado inicial
  factory ExpensesState.initial() {
    return const ExpensesState(
      expenses: [],
      filteredExpenses: [],
      filtersConfig: ExpenseFiltersConfig(),
      stats: {},
      patternAnalysis: null,
      isLoading: false,
      error: null,
    );
  }

  /// Todas as despesas (não filtradas)
  final List<ExpenseEntity> expenses;

  /// Despesas filtradas (exibidas na UI)
  final List<ExpenseEntity> filteredExpenses;

  /// Configuração de filtros
  final ExpenseFiltersConfig filtersConfig;

  /// Estatísticas calculadas
  final Map<String, dynamic> stats;

  /// Análise de padrões (quando há veículo selecionado)
  final ExpensePatternAnalysis? patternAnalysis;

  /// Loading state
  final bool isLoading;

  /// Error message (se houver)
  final String? error;

  @override
  List<Object?> get props => [
        expenses,
        filteredExpenses,
        filtersConfig,
        stats,
        patternAnalysis,
        isLoading,
        error,
      ];

  /// Verifica se há filtros ativos
  bool get hasActiveFilters => filtersConfig.hasActiveFilters;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se está vazio
  bool get isEmpty => filteredExpenses.isEmpty && !isLoading;

  /// ID do veículo selecionado (se houver)
  String? get selectedVehicleId => filtersConfig.vehicleId;

  /// Tipo de despesa selecionado (se houver)
  ExpenseType? get selectedType => filtersConfig.type;

  /// Data inicial do filtro (se houver)
  DateTime? get startDate => filtersConfig.startDate;

  /// Data final do filtro (se houver)
  DateTime? get endDate => filtersConfig.endDate;

  /// Query de busca
  String get searchQuery => filtersConfig.searchQuery;

  /// Campo de ordenação
  String get sortBy => filtersConfig.sortBy;

  /// Ordem ascendente?
  bool get sortAscending => filtersConfig.sortAscending;

  /// Cria cópia com valores atualizados
  ExpensesState copyWith({
    List<ExpenseEntity>? expenses,
    List<ExpenseEntity>? filteredExpenses,
    ExpenseFiltersConfig? filtersConfig,
    Map<String, dynamic>? stats,
    ExpensePatternAnalysis? patternAnalysis,
    bool clearPatternAnalysis = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      filtersConfig: filtersConfig ?? this.filtersConfig,
      stats: stats ?? this.stats,
      patternAnalysis: clearPatternAnalysis
          ? null
          : (patternAnalysis ?? this.patternAnalysis),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Cria estado de loading
  ExpensesState setLoading() {
    return copyWith(isLoading: true, clearError: true);
  }

  /// Cria estado de erro
  ExpensesState setError(String errorMessage) {
    return copyWith(isLoading: false, error: errorMessage);
  }

  /// Cria estado de sucesso
  ExpensesState setSuccess({
    required List<ExpenseEntity> expenses,
    required List<ExpenseEntity> filteredExpenses,
    required Map<String, dynamic> stats,
    ExpensePatternAnalysis? patternAnalysis,
  }) {
    return copyWith(
      expenses: expenses,
      filteredExpenses: filteredExpenses,
      stats: stats,
      patternAnalysis: patternAnalysis,
      isLoading: false,
      clearError: true,
    );
  }
}

/// Análise de padrões de despesas
class ExpensePatternAnalysis extends Equatable {
  const ExpensePatternAnalysis({
    required this.vehicleId,
    required this.totalExpenses,
    required this.averageMonthly,
    required this.mostFrequentType,
    required this.mostExpensiveType,
    required this.trends,
    required this.anomalies,
  });

  final String vehicleId;
  final double totalExpenses;
  final double averageMonthly;
  final ExpenseType mostFrequentType;
  final ExpenseType mostExpensiveType;
  final Map<String, dynamic> trends;
  final List<ExpenseAnomaly> anomalies;

  @override
  List<Object?> get props => [
        vehicleId,
        totalExpenses,
        averageMonthly,
        mostFrequentType,
        mostExpensiveType,
        trends,
        anomalies,
      ];
}

/// Anomalia detectada em despesas
class ExpenseAnomaly extends Equatable {
  const ExpenseAnomaly({
    required this.expenseId,
    required this.type,
    required this.description,
    required this.severity,
  });

  final String expenseId;
  final String type;
  final String description;
  final String severity; // 'low', 'medium', 'high'

  @override
  List<Object?> get props => [expenseId, type, description, severity];
}
