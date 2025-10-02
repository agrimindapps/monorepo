import 'dart:async';

import 'package:core/core.dart' hide ValidationError;
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_filters_service.dart';
import '../../domain/services/expense_formatter_service.dart';
import '../../domain/services/expense_statistics_service.dart';
import '../../domain/services/expense_validation_service.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_all_expenses.dart';
import '../../domain/usecases/get_expenses_by_vehicle.dart';
import '../../domain/usecases/update_expense.dart';
import '../models/expense_form_model.dart';

/// Provider principal para gerenciar estado e operações de despesas
@injectable
class ExpensesProvider extends BaseProvider {
  ExpensesProvider(
    this._getAllExpensesUseCase,
    this._getExpensesByVehicleUseCase,
    this._addExpenseUseCase,
    this._updateExpenseUseCase,
    this._deleteExpenseUseCase,
    this._vehiclesProvider,
  ) {
    _initialize();
  }

  final GetAllExpensesUseCase _getAllExpensesUseCase;
  final GetExpensesByVehicleUseCase _getExpensesByVehicleUseCase;
  final AddExpenseUseCase _addExpenseUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final VehiclesProvider _vehiclesProvider;
  final ExpenseValidationService _validator = const ExpenseValidationService();
  final ExpenseFormatterService _formatter = ExpenseFormatterService();
  final ExpenseStatisticsService _statisticsService = ExpenseStatisticsService();
  final ExpenseFiltersService _filtersService = ExpenseFiltersService();

  // Estado da listagem de despesas
  List<ExpenseEntity> _expenses = [];
  List<ExpenseEntity> _filteredExpenses = [];
  
  // Configuração de filtros usando service
  ExpenseFiltersConfig _filtersConfig = const ExpenseFiltersConfig();
  
  // Estado de estatísticas
  Map<String, dynamic> _stats = {};
  ExpensePatternAnalysis? _patternAnalysis;

  // Getters públicos
  List<ExpenseEntity> get expenses => _filteredExpenses;
  List<ExpenseEntity> get allExpenses => _expenses;
  ExpenseFiltersConfig get filtersConfig => _filtersConfig;
  String? get selectedVehicleId => _filtersConfig.vehicleId;
  ExpenseType? get selectedType => _filtersConfig.type;
  DateTime? get startDate => _filtersConfig.startDate;
  DateTime? get endDate => _filtersConfig.endDate;
  String get searchQuery => _filtersConfig.searchQuery;
  String get sortBy => _filtersConfig.sortBy;
  bool get sortAscending => _filtersConfig.sortAscending;
  bool get hasActiveFilters => _filtersConfig.hasActiveFilters;
  Map<String, dynamic> get stats => _stats;
  ExpensePatternAnalysis? get patternAnalysis => _patternAnalysis;

  /// Inicialização do provider
  Future<void> _initialize() async {
    await loadExpenses();
  }

  /// Carrega todas as despesas
  Future<void> loadExpenses() async {
    await executeListOperation(
      () async {
        final result = await _getAllExpensesUseCase(NoParams());
        return result.fold(
          (failure) => throw failure,
          (expenses) => expenses,
        );
      },
      operationName: 'loadExpenses',
      onSuccess: (expenses) {
        _expenses = expenses;
        _applyFiltersAndRecalculate();
      },
    );
  }

  /// Carrega despesas por veículo
  Future<void> loadExpensesByVehicle(String vehicleId) async {
    await executeListOperation(
      () async {
        final result = await _getExpensesByVehicleUseCase(vehicleId);
        return result.fold(
          (failure) => throw failure,
          (expenses) => expenses,
        );
      },
      operationName: 'loadExpensesByVehicle',
      parameters: {'vehicleId': vehicleId},
      onSuccess: (expenses) {
        _expenses = expenses;
        _filtersConfig = _filtersConfig.copyWith(vehicleId: vehicleId);
        _applyFiltersAndRecalculate();
      },
    );
  }

  /// Adiciona nova despesa
  Future<bool> addExpense(ExpenseFormModel formModel) async {
    // Validate form data
    final validationErrors = formModel.validate();
    if (validationErrors.isNotEmpty) {
      final fieldErrorsMap = validationErrors.map(
        (key, value) => MapEntry(key, [value]),
      );
      final error = ValidationError(
        message: 'Invalid form data',
        fieldErrors: fieldErrorsMap,
        userFriendlyMessage: 'Dados inválidos: ${validationErrors.values.first}',
      );
      logError(error);
      setState(ProviderState.error, error: error);
      return false;
    }

    final expense = formModel.toExpenseEntity();

    // Contextual validation
    final vehicle = await _vehiclesProvider.getVehicleById(expense.vehicleId);
    if (vehicle != null) {
      final validationResult = _validator.validateExpenseRecord(
        expense,
        vehicle,
        _expenses.where((e) => e.vehicleId == expense.vehicleId).toList(),
      );

      if (!validationResult.isValid) {
        final error = ValidationError(
          message: 'Expense validation failed',
          userFriendlyMessage: validationResult.errors.values.first,
        );
        logError(error);
        setState(ProviderState.error, error: error);
        return false;
      }
    }

    // Save expense
    final savedExpense = await executeDataOperation(
      () async {
        final result = await _addExpenseUseCase(expense);
        return result.fold(
          (failure) => throw failure,
          (expense) => expense,
        );
      },
      operationName: 'addExpense',
      parameters: {
        'vehicleId': expense.vehicleId,
        'type': expense.type.name,
        'amount': expense.amount,
      },
      showLoading: false,
    );

    if (savedExpense != null) {
      _expenses.add(savedExpense);
      _applyFiltersAndRecalculate();
      
      logInfo('Expense added successfully', metadata: {
        'expenseId': savedExpense.id,
        'vehicleId': savedExpense.vehicleId,
        'amount': savedExpense.amount,
      });
      
      return true;
    }

    return false;
  }

  /// Atualiza despesa existente
  Future<bool> updateExpense(ExpenseFormModel formModel) async {
    if (!formModel.isEditing) {
      const error = BusinessLogicError(
        message: 'Cannot update: expense not in edit mode',
        userFriendlyMessage: 'Despesa não existe para edição',
      );
      logError(error);
      setState(ProviderState.error, error: error);
      return false;
    }

    // Validate form data
    final validationErrors = formModel.validate();
    if (validationErrors.isNotEmpty) {
      final fieldErrorsMap = validationErrors.map(
        (key, value) => MapEntry(key, [value]),
      );
      final error = ValidationError(
        message: 'Invalid form data',
        fieldErrors: fieldErrorsMap,
        userFriendlyMessage: 'Dados inválidos: ${validationErrors.values.first}',
      );
      logError(error);
      setState(ProviderState.error, error: error);
      return false;
    }

    final expense = formModel.toExpenseEntity();

    // Contextual validation
    final vehicle = await _vehiclesProvider.getVehicleById(expense.vehicleId);
    if (vehicle != null) {
      final otherExpenses = _expenses
          .where((e) => e.vehicleId == expense.vehicleId && e.id != expense.id)
          .toList();
      
      final validationResult = _validator.validateExpenseRecord(
        expense,
        vehicle,
        otherExpenses,
      );

      if (!validationResult.isValid) {
        final error = ValidationError(
          message: 'Expense validation failed',
          userFriendlyMessage: validationResult.errors.values.first,
        );
        logError(error);
        setState(ProviderState.error, error: error);
        return false;
      }
    }

    // Update expense
    final updatedExpense = await executeDataOperation(
      () async {
        final result = await _updateExpenseUseCase(expense);
        return result.fold(
          (failure) => throw failure,
          (expense) => expense,
        );
      },
      operationName: 'updateExpense',
      parameters: {
        'expenseId': expense.id,
        'vehicleId': expense.vehicleId,
        'amount': expense.amount,
      },
      showLoading: false,
    );

    if (updatedExpense != null) {
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        _applyFiltersAndRecalculate();
        
        logInfo('Expense updated successfully', metadata: {
          'expenseId': updatedExpense.id,
          'vehicleId': updatedExpense.vehicleId,
        });
        
        return true;
      }
    }

    return false;
  }

  /// Remove despesa
  Future<bool> removeExpense(String expenseId) async {
    final expense = _expenses.where((e) => e.id == expenseId).firstOrNull;
    if (expense == null) {
      final error = ExpenseNotFoundError(
        technicalDetails: 'Expense ID: $expenseId',
      );
      logError(error);
      setState(ProviderState.error, error: error);
      return false;
    }

    final success = await executeDataOperation(
      () async {
        final result = await _deleteExpenseUseCase(expenseId);
        return result.fold(
          (failure) => throw failure,
          (deleted) => deleted,
        );
      },
      operationName: 'deleteExpense',
      parameters: {'expenseId': expenseId},
      showLoading: false,
    );

    if (success == true) {
      _expenses.removeWhere((e) => e.id == expenseId);
      _applyFiltersAndRecalculate();
      
      logInfo('Expense deleted successfully', metadata: {
        'expenseId': expenseId,
        'vehicleId': expense.vehicleId,
      });
      
      return true;
    }

    return false;
  }

  /// Busca despesa por ID
  ExpenseEntity? getExpenseById(String expenseId) {
    try {
      return _expenses.firstWhere((e) => e.id == expenseId);
    } catch (e) {
      return null;
    }
  }

  // Métodos de filtragem

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

  /// Limpa todos os filtros
  void clearFilters() {
    _filtersConfig = _filtersConfig.cleared();
    _applyFiltersAndRecalculate();
  }

  // Métodos de ordenação

  /// Ordena por campo específico
  void setSortBy(String field, {bool? ascending}) {
    _filtersConfig = _filtersConfig.copyWith(
      sortBy: field,
      sortAscending: ascending ?? (_filtersConfig.sortBy == field ? !_filtersConfig.sortAscending : false),
    );
    _applyFiltersAndRecalculate();
  }

  /// Aplica filtros e recalcula estatísticas
  void _applyFiltersAndRecalculate() {
    // Aplicar filtros usando o service
    _filteredExpenses = _filtersService.applyFilters(_expenses, _filtersConfig);
    
    // Recalcular estatísticas usando o service
    _stats = _statisticsService.calculateStats(_filteredExpenses);
    
    // Calcular análise de padrões se há veículo selecionado
    if (_filtersConfig.vehicleId != null) {
      _updatePatternAnalysis();
    }
    
    notifyListeners();
  }

  /// Atualiza análise de padrões para o veículo atual
  Future<void> _updatePatternAnalysis() async {
    if (_filtersConfig.vehicleId == null) {
      _patternAnalysis = null;
      return;
    }

    try {
      final vehicle = await _vehiclesProvider.getVehicleById(_filtersConfig.vehicleId!);
      if (vehicle != null) {
        _patternAnalysis = _validator.analyzeExpensePatterns(
          _expenses.where((e) => e.vehicleId == _filtersConfig.vehicleId).toList(),
          vehicle,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao calcular análise de padrões: $e');
    }
  }

  // Note: _calculateStats is now handled by _statisticsService in _applyFiltersAndRecalculate

  /// Recarrega dados
  Future<void> refresh() async {
    clearError();
    
    if (_filtersConfig.vehicleId != null) {
      await loadExpensesByVehicle(_filtersConfig.vehicleId!);
    } else {
      await loadExpenses();
    }
  }

  /// Limpa erro atual (inherited from BaseProvider)
  void clearCurrentError() {
    clearError();
  }

  /// Obtém relatório detalhado de uma despesa
  Future<Map<String, dynamic>> getExpenseReport(String expenseId) async {
    final expense = getExpenseById(expenseId);
    if (expense == null) return {};

    final vehicle = await _vehiclesProvider.getVehicleById(expense.vehicleId);
    if (vehicle == null) return {};

    // Validação contextual
    final otherExpenses = _expenses
        .where((e) => e.vehicleId == expense.vehicleId && e.id != expense.id)
        .toList();
        
    final validationResult = _validator.validateExpenseRecord(
      expense,
      vehicle,
      otherExpenses,
    );

    // Análise de padrões similar
    final similarExpenses = _expenses
        .where((e) => e.type == expense.type && e.id != expense.id)
        .toList();

    double? averageSimilar;
    if (similarExpenses.isNotEmpty) {
      averageSimilar = similarExpenses.fold<double>(0, (sum, e) => sum + e.amount) / similarExpenses.length;
    }

    return {
      'expense': expense,
      'vehicle': vehicle,
      'validation': {
        'isValid': validationResult.isValid,
        'errors': validationResult.errors,
        'warnings': validationResult.warnings,
      },
      'analysis': {
        'totalSimilar': similarExpenses.length,
        'averageSimilar': averageSimilar,
        'deviationFromAverage': averageSimilar != null 
            ? ((expense.amount - averageSimilar) / averageSimilar * 100) 
            : null,
      },
    };
  }

  // ===========================================
  // MÉTODOS DE CONVENIÊNCIA ADICIONAIS
  // ===========================================

  /// Obtém despesas de alto valor
  List<ExpenseEntity> getHighValueExpenses({double threshold = ExpenseConstants.reportAmountThousands}) {
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

  /// Obtém estatísticas por período específico
  Map<String, dynamic> getStatsByPeriod(DateTime start, DateTime end) {
    return _statisticsService.calculateStatsByPeriod(_expenses, start, end);
  }

  /// Obtém estatísticas de crescimento
  Map<String, dynamic> getGrowthStats() {
    return _statisticsService.calculateGrowthStats(_expenses);
  }

  /// Obtém anomalias detectadas
  Map<String, dynamic> getAnomalies() {
    return _statisticsService.calculateAnomalies(_expenses);
  }

  /// Compara períodos diferentes
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
}