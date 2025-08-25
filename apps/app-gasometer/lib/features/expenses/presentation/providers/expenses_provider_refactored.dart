import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_filters_service.dart';
import '../../domain/services/expense_formatter_service.dart';
import '../../domain/services/expense_statistics_service.dart';
import '../../domain/services/expense_validation_service.dart';
import '../models/expense_form_model.dart';

/// Provider refatorado para gerenciar operações de despesas com responsabilidades bem definidas
class ExpensesProvider extends ChangeNotifier {
  final ExpensesRepository _repository;
  final VehiclesProvider _vehiclesProvider;
  final ExpenseValidationService _validator = const ExpenseValidationService();
  final ExpenseFormatterService _formatter = ExpenseFormatterService();
  final ExpenseStatisticsService _statisticsService = ExpenseStatisticsService();
  final ExpenseFiltersService _filtersService = ExpenseFiltersService();

  // Estado principal
  List<ExpenseEntity> _expenses = [];
  List<ExpenseEntity> _filteredExpenses = [];
  bool _isLoading = false;
  String? _error;
  
  // Configuração de filtros
  ExpenseFiltersConfig _filtersConfig = const ExpenseFiltersConfig();
  
  // Cache de estatísticas
  Map<String, dynamic> _cachedStats = {};
  ExpensePatternAnalysis? _patternAnalysis;

  ExpensesProvider(
    this._repository,
    this._vehiclesProvider,
  ) {
    _initialize();
  }

  // ===========================================
  // GETTERS PÚBLICOS
  // ===========================================

  List<ExpenseEntity> get expenses => _filteredExpenses;
  List<ExpenseEntity> get allExpenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Filtros
  ExpenseFiltersConfig get filtersConfig => _filtersConfig;
  String? get selectedVehicleId => _filtersConfig.vehicleId;
  ExpenseType? get selectedType => _filtersConfig.type;
  DateTime? get startDate => _filtersConfig.startDate;
  DateTime? get endDate => _filtersConfig.endDate;
  String get searchQuery => _filtersConfig.searchQuery;
  String get sortBy => _filtersConfig.sortBy;
  bool get sortAscending => _filtersConfig.sortAscending;
  bool get hasActiveFilters => _filtersConfig.hasActiveFilters;
  
  // Estatísticas
  Map<String, dynamic> get stats => _cachedStats;
  ExpensePatternAnalysis? get patternAnalysis => _patternAnalysis;

  // ===========================================
  // INICIALIZAÇÃO
  // ===========================================

  Future<void> _initialize() async {
    await loadExpenses();
  }

  // ===========================================
  // OPERAÇÕES CRUD
  // ===========================================

  /// Carrega todas as despesas
  Future<void> loadExpenses() async {
    try {
      _setLoading(true);
      _clearError();

      _expenses = await _repository.getAllExpenses();
      _applyFiltersAndRecalculate();

    } catch (e) {
      _setError('Erro ao carregar despesas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega despesas por veículo
  Future<void> loadExpensesByVehicle(String vehicleId) async {
    try {
      _setLoading(true);
      _clearError();

      _expenses = await _repository.getExpensesByVehicle(vehicleId);
      
      // Atualizar filtro para refletir o veículo selecionado
      _filtersConfig = _filtersConfig.copyWith(vehicleId: vehicleId);
      _applyFiltersAndRecalculate();

    } catch (e) {
      _setError('Erro ao carregar despesas do veículo: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona nova despesa
  Future<bool> addExpense(ExpenseFormModel formModel) async {
    try {
      _clearError();

      // Validar dados
      final validationErrors = formModel.validate();
      if (validationErrors.isNotEmpty) {
        _setError('Dados inválidos: ${validationErrors.values.first}');
        return false;
      }

      // Converter para entidade
      final expense = formModel.toExpenseEntity();

      // Salvar no repositório
      final saved = await _repository.saveExpense(expense);
      
      if (saved != null) {
        // Atualizar lista local
        _expenses.add(saved);
        _applyFiltersAndRecalculate();
        return true;
      }

      return false;
    } catch (e) {
      _setError('Erro ao salvar despesa: $e');
      return false;
    }
  }

  /// Atualiza despesa existente
  Future<bool> updateExpense(ExpenseFormModel formModel) async {
    try {
      _clearError();

      if (!formModel.isEditing) {
        _setError('Despesa não existe para edição');
        return false;
      }

      // Validar dados
      final validationErrors = formModel.validate();
      if (validationErrors.isNotEmpty) {
        _setError('Dados inválidos: ${validationErrors.values.first}');
        return false;
      }

      // Converter para entidade
      final expense = formModel.toExpenseEntity();

      // Atualizar no repositório
      final updated = await _repository.updateExpense(expense);
      
      if (updated != null) {
        // Atualizar lista local
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        if (index >= 0) {
          _expenses[index] = updated;
          _applyFiltersAndRecalculate();
        }
        return true;
      }

      return false;
    } catch (e) {
      _setError('Erro ao atualizar despesa: $e');
      return false;
    }
  }

  /// Remove despesa
  Future<bool> removeExpense(String expenseId) async {
    try {
      _clearError();

      final success = await _repository.deleteExpense(expenseId);
      
      if (success) {
        _expenses.removeWhere((e) => e.id == expenseId);
        _applyFiltersAndRecalculate();
        return true;
      }

      return false;
    } catch (e) {
      _setError('Erro ao remover despesa: $e');
      return false;
    }
  }

  /// Busca despesa por ID
  ExpenseEntity? getExpenseById(String expenseId) {
    try {
      return _expenses.firstWhere((e) => e.id == expenseId);
    } catch (e) {
      return null;
    }
  }

  // ===========================================
  // FILTROS E BUSCA
  // ===========================================

  /// Aplica filtro por veículo
  void filterByVehicle(String? vehicleId) {
    _filtersConfig = _filtersConfig.copyWith(
      vehicleId: vehicleId,
      clearVehicleId: vehicleId == null,
    );
    _applyFiltersAndRecalculate();
  }

  /// Aplica filtro por tipo
  void filterByType(ExpenseType? type) {
    _filtersConfig = _filtersConfig.copyWith(
      type: type,
      clearType: type == null,
    );
    _applyFiltersAndRecalculate();
  }

  /// Aplica filtro por período
  void filterByPeriod(DateTime? start, DateTime? end) {
    _filtersConfig = _filtersConfig.copyWith(
      startDate: start,
      endDate: end,
      clearDates: start == null && end == null,
    );
    _applyFiltersAndRecalculate();
  }

  /// Aplica busca por texto
  void search(String query) {
    _filtersConfig = _filtersConfig.copyWith(searchQuery: query);
    _applyFiltersAndRecalculate();
  }

  /// Define ordenação
  void setSortBy(String field, {bool? ascending}) {
    _filtersConfig = _filtersConfig.copyWith(
      sortBy: field,
      sortAscending: ascending ?? (_filtersConfig.sortBy == field ? !_filtersConfig.sortAscending : false),
    );
    _applyFiltersAndRecalculate();
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _filtersConfig = _filtersConfig.cleared();
    _applyFiltersAndRecalculate();
  }

  // ===========================================
  // ESTATÍSTICAS
  // ===========================================

  /// Recalcula estatísticas dos dados filtrados
  void _calculateStats() {
    _cachedStats = _statisticsService.calculateStats(_filteredExpenses);
    
    // Calcular análise de padrões se há veículo selecionado
    if (_filtersConfig.vehicleId != null) {
      _calculatePatternAnalysis();
    }
  }

  /// Calcula análise de padrões para o veículo atual
  Future<void> _calculatePatternAnalysis() async {
    if (_filtersConfig.vehicleId == null) {
      _patternAnalysis = null;
      return;
    }

    try {
      final vehicle = await _vehiclesProvider.getVehicleById(_filtersConfig.vehicleId!);
      if (vehicle != null) {
        _patternAnalysis = _validator.analyzeExpensePatterns(_expenses, vehicle);
      }
    } catch (e) {
      debugPrint('Erro ao calcular análise de padrões: $e');
    }
  }

  /// Obtém estatísticas por período
  Map<String, dynamic> getStatsByPeriod(DateTime start, DateTime end) {
    return _statisticsService.calculateStatsByPeriod(_expenses, start, end);
  }

  /// Obtém estatísticas de crescimento
  Map<String, dynamic> getGrowthStats() {
    return _statisticsService.calculateGrowthStats(_expenses);
  }

  /// Obtém estatísticas de anomalias
  Map<String, dynamic> getAnomalies() {
    return _statisticsService.calculateAnomalies(_expenses);
  }

  /// Obtém comparação entre períodos
  Map<String, dynamic> comparePeriods(
    DateTime period1Start,
    DateTime period1End,
    DateTime period2Start,
    DateTime period2End,
  ) {
    return _statisticsService.comparePeriods(
      _expenses,
      period1Start,
      period1End,
      period2Start,
      period2End,
    );
  }

  // ===========================================
  // MÉTODOS AUXILIARES
  // ===========================================

  /// Aplica filtros e recalcula estatísticas
  void _applyFiltersAndRecalculate() {
    // Aplicar filtros
    _filteredExpenses = _filtersService.applyFilters(_expenses, _filtersConfig);
    
    // Recalcular estatísticas
    _calculateStats();
    
    notifyListeners();
  }

  /// Define estado de loading
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Define erro
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Limpa erro
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Limpa erro atual
  void clearError() {
    _clearError();
  }

  /// Recarrega dados
  Future<void> refresh() async {
    await loadExpenses();
  }

  // ===========================================
  // MÉTODOS DE CONVENIÊNCIA
  // ===========================================

  /// Obtém despesas de alto valor
  List<ExpenseEntity> getHighValueExpenses({double threshold = 1000.0}) {
    return _filtersService.getHighValueExpenses(_filteredExpenses, threshold: threshold);
  }

  /// Obtém despesas recorrentes
  List<ExpenseEntity> getRecurringExpenses({double amountTolerance = 0.1}) {
    return _filtersService.getRecurringExpenses(_filteredExpenses, amountTolerance: amountTolerance);
  }

  /// Agrupa despesas por faixa de valores
  Map<String, List<ExpenseEntity>> groupByValueRange() {
    return _filtersService.groupByValueRange(_filteredExpenses);
  }

  /// Agrupa despesas por mês
  Map<String, List<ExpenseEntity>> groupByMonth() {
    return _filtersService.groupByMonth(_filteredExpenses);
  }

  /// Agrupa despesas por tipo
  Map<ExpenseType, List<ExpenseEntity>> groupByType() {
    return _filtersService.groupByType(_filteredExpenses);
  }
}