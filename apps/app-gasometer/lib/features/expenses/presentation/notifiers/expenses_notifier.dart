import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_filters_service.dart';
import '../../domain/services/expense_statistics_service.dart';
import '../../domain/services/expense_validation_service.dart'
    hide ExpensePatternAnalysis;
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_all_expenses.dart';
import '../../domain/usecases/get_expenses_by_vehicle.dart';
import '../../domain/usecases/update_expense.dart';
import '../models/expense_form_model.dart';
import '../state/expenses_state.dart';

part 'expenses_notifier.g.dart';

/// Provider de dependências (use cases via GetIt)
@riverpod
GetAllExpensesUseCase getAllExpensesUseCase(Ref ref) {
  return getIt<GetAllExpensesUseCase>();
}

@riverpod
GetExpensesByVehicleUseCase getExpensesByVehicleUseCase(Ref ref) {
  return getIt<GetExpensesByVehicleUseCase>();
}

@riverpod
AddExpenseUseCase addExpenseUseCase(Ref ref) {
  return getIt<AddExpenseUseCase>();
}

@riverpod
UpdateExpenseUseCase updateExpenseUseCase(Ref ref) {
  return getIt<UpdateExpenseUseCase>();
}

@riverpod
DeleteExpenseUseCase deleteExpenseUseCase(Ref ref) {
  return getIt<DeleteExpenseUseCase>();
}

/// Notifier principal para gerenciar estado de despesas
@riverpod
class ExpensesNotifier extends _$ExpensesNotifier {
  // Services (stateless - podem ser const)
  final _validator = const ExpenseValidationService();
  final _statisticsService = ExpenseStatisticsService();
  final _filtersService = ExpenseFiltersService();

  // Use cases (lazy loaded via ref)
  late final GetAllExpensesUseCase _getAllExpensesUseCase;
  late final GetExpensesByVehicleUseCase _getExpensesByVehicleUseCase;
  late final AddExpenseUseCase _addExpenseUseCase;
  late final UpdateExpenseUseCase _updateExpenseUseCase;
  late final DeleteExpenseUseCase _deleteExpenseUseCase;

  @override
  ExpensesState build() {
    // Inicializa use cases via providers
    _getAllExpensesUseCase = ref.watch(getAllExpensesUseCaseProvider);
    _getExpensesByVehicleUseCase = ref.watch(getExpensesByVehicleUseCaseProvider);
    _addExpenseUseCase = ref.watch(addExpenseUseCaseProvider);
    _updateExpenseUseCase = ref.watch(updateExpenseUseCaseProvider);
    _deleteExpenseUseCase = ref.watch(deleteExpenseUseCaseProvider);

    // Carrega despesas no init
    _loadInitialData();

    return ExpensesState.initial();
  }

  /// Carrega dados iniciais
  Future<void> _loadInitialData() async {
    await loadExpenses();
  }

  // ===========================================
  // CRUD OPERATIONS
  // ===========================================

  /// Carrega todas as despesas
  Future<void> loadExpenses() async {
    state = state.setLoading();

    final result = await _getAllExpensesUseCase(const NoParams());

    result.fold(
      (failure) {
        debugPrint('[ExpensesNotifier] Error loading expenses: ${failure.message}');
        state = state.setError(failure.message);
      },
      (expenses) {
        _updateStateWithExpenses(expenses);
      },
    );
  }

  /// Carrega despesas por veículo
  Future<void> loadExpensesByVehicle(String vehicleId) async {
    state = state.setLoading();

    final result = await _getExpensesByVehicleUseCase(vehicleId);

    result.fold(
      (failure) {
        debugPrint('[ExpensesNotifier] Error loading expenses by vehicle: ${failure.message}');
        state = state.setError(failure.message);
      },
      (expenses) {
        // Atualiza filtro de veículo
        final newFiltersConfig = state.filtersConfig.copyWith(vehicleId: vehicleId);
        _updateStateWithExpenses(expenses, filtersConfig: newFiltersConfig);
      },
    );
  }

  /// Adiciona nova despesa
  Future<bool> addExpense(ExpenseFormModel formModel) async {
    // Validate form data
    final validationErrors = formModel.validate();
    if (validationErrors.isNotEmpty) {
      final errorMessage = 'Dados inválidos: ${validationErrors.values.first}';
      debugPrint('[ExpensesNotifier] Validation error: $errorMessage');
      state = state.setError(errorMessage);
      return false;
    }

    final expense = formModel.toExpenseEntity();

    // Contextual validation
    final vehicle = await _getVehicleById(expense.vehicleId);
    if (vehicle != null) {
      final validationResult = _validator.validateExpenseRecord(
        expense,
        vehicle,
        state.expenses.where((e) => e.vehicleId == expense.vehicleId).toList(),
      );

      if (!validationResult.isValid) {
        final errorMessage = validationResult.errors.values.first;
        debugPrint('[ExpensesNotifier] Contextual validation error: $errorMessage');
        state = state.setError(errorMessage);
        return false;
      }
    }

    // Save expense
    state = state.setLoading();

    final result = await _addExpenseUseCase(expense);

    return result.fold(
      (failure) {
        debugPrint('[ExpensesNotifier] Error adding expense: ${failure.message}');
        state = state.setError(failure.message);
        return false;
      },
      (savedExpense) {
        // Add to list and recalculate (savedExpense is guaranteed non-null here)
        final updatedExpenses = List<ExpenseEntity>.from(state.expenses)
          ..add(savedExpense!);
        _updateStateWithExpenses(updatedExpenses);

        debugPrint('[ExpensesNotifier] Expense added successfully: ${savedExpense.id}');
        return true;
      },
    );
  }

  /// Atualiza despesa existente
  Future<bool> updateExpense(ExpenseFormModel formModel) async {
    if (!formModel.isEditing) {
      const errorMessage = 'Despesa não existe para edição';
      debugPrint('[ExpensesNotifier] Error: $errorMessage');
      state = state.setError(errorMessage);
      return false;
    }

    // Validate form data
    final validationErrors = formModel.validate();
    if (validationErrors.isNotEmpty) {
      final errorMessage = 'Dados inválidos: ${validationErrors.values.first}';
      debugPrint('[ExpensesNotifier] Validation error: $errorMessage');
      state = state.setError(errorMessage);
      return false;
    }

    final expense = formModel.toExpenseEntity();

    // Contextual validation
    final vehicle = await _getVehicleById(expense.vehicleId);
    if (vehicle != null) {
      final otherExpenses = state.expenses
          .where((e) => e.vehicleId == expense.vehicleId && e.id != expense.id)
          .toList();

      final validationResult = _validator.validateExpenseRecord(
        expense,
        vehicle,
        otherExpenses,
      );

      if (!validationResult.isValid) {
        final errorMessage = validationResult.errors.values.first;
        debugPrint('[ExpensesNotifier] Contextual validation error: $errorMessage');
        state = state.setError(errorMessage);
        return false;
      }
    }

    // Update expense
    state = state.setLoading();

    final result = await _updateExpenseUseCase(expense);

    return result.fold(
      (failure) {
        debugPrint('[ExpensesNotifier] Error updating expense: ${failure.message}');
        state = state.setError(failure.message);
        return false;
      },
      (updatedExpense) {
        // Update in list and recalculate (updatedExpense is guaranteed non-null here)
        final updatedExpenses = List<ExpenseEntity>.from(
          state.expenses.map((e) {
            if (e.id == expense.id) {
              return updatedExpense!;
            }
            return e;
          }),
        );
        _updateStateWithExpenses(updatedExpenses);

        debugPrint('[ExpensesNotifier] Expense updated successfully: ${updatedExpense!.id}');
        return true;
      },
    );
  }

  /// Remove despesa
  Future<bool> removeExpense(String expenseId) async {
    final expense = state.expenses.where((e) => e.id == expenseId).firstOrNull;
    if (expense == null) {
      const errorMessage = 'Despesa não encontrada';
      debugPrint('[ExpensesNotifier] Error: $errorMessage');
      state = state.setError(errorMessage);
      return false;
    }

    state = state.setLoading();

    final result = await _deleteExpenseUseCase(expenseId);

    return result.fold(
      (failure) {
        debugPrint('[ExpensesNotifier] Error deleting expense: ${failure.message}');
        state = state.setError(failure.message);
        return false;
      },
      (deleted) {
        if (deleted) {
          // Remove from list and recalculate
          final updatedExpenses = state.expenses.where((e) => e.id != expenseId).toList();
          _updateStateWithExpenses(updatedExpenses);

          debugPrint('[ExpensesNotifier] Expense deleted successfully: $expenseId');
          return true;
        }

        state = state.setError('Erro ao deletar despesa');
        return false;
      },
    );
  }

  // ===========================================
  // FILTER OPERATIONS
  // ===========================================

  /// Aplica filtro por veículo
  void filterByVehicle(String? vehicleId) {
    final newFiltersConfig = state.filtersConfig.copyWith(
      vehicleId: vehicleId,
      clearVehicleId: vehicleId == null,
    );
    _applyFiltersAndRecalculate(newFiltersConfig);
  }

  /// Aplica filtro por tipo
  void filterByType(ExpenseType? type) {
    final newFiltersConfig = state.filtersConfig.copyWith(
      type: type,
      clearType: type == null,
    );
    _applyFiltersAndRecalculate(newFiltersConfig);
  }

  /// Aplica filtro por período
  void filterByPeriod(DateTime? start, DateTime? end) {
    final newFiltersConfig = state.filtersConfig.copyWith(
      startDate: start,
      endDate: end,
      clearDates: start == null && end == null,
    );
    _applyFiltersAndRecalculate(newFiltersConfig);
  }

  /// Aplica busca por texto
  void search(String query) {
    final newFiltersConfig = state.filtersConfig.copyWith(searchQuery: query);
    _applyFiltersAndRecalculate(newFiltersConfig);
  }

  /// Limpa todos os filtros
  void clearFilters() {
    final newFiltersConfig = state.filtersConfig.cleared();
    _applyFiltersAndRecalculate(newFiltersConfig);
  }

  /// Ordena por campo específico
  void setSortBy(String field, {bool? ascending}) {
    final newFiltersConfig = state.filtersConfig.copyWith(
      sortBy: field,
      sortAscending: ascending ??
          (state.filtersConfig.sortBy == field
              ? !state.filtersConfig.sortAscending
              : false),
    );
    _applyFiltersAndRecalculate(newFiltersConfig);
  }

  // ===========================================
  // QUERY OPERATIONS
  // ===========================================

  /// Busca despesa por ID
  ExpenseEntity? getExpenseById(String expenseId) {
    try {
      return state.expenses.firstWhere((e) => e.id == expenseId);
    } catch (e) {
      return null;
    }
  }

  /// Obtém relatório detalhado de uma despesa
  Future<Map<String, dynamic>> getExpenseReport(String expenseId) async {
    final expense = getExpenseById(expenseId);
    if (expense == null) return {};

    final vehicle = await _getVehicleById(expense.vehicleId);
    if (vehicle == null) return {};

    // Validação contextual
    final otherExpenses = state.expenses
        .where((e) => e.vehicleId == expense.vehicleId && e.id != expense.id)
        .toList();

    final validationResult = _validator.validateExpenseRecord(
      expense,
      vehicle,
      otherExpenses,
    );

    // Análise de padrões similar
    final similarExpenses = state.expenses
        .where((e) => e.type == expense.type && e.id != expense.id)
        .toList();

    double? averageSimilar;
    if (similarExpenses.isNotEmpty) {
      averageSimilar = similarExpenses.fold<double>(
              0, (total, e) => total + e.amount) /
          similarExpenses.length;
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

  /// Obtém despesas de alto valor
  List<ExpenseEntity> getHighValueExpenses({double? threshold}) {
    return _filtersService.getHighValueExpenses(
      state.filteredExpenses,
      threshold: threshold ?? 1000.0,
    );
  }

  /// Obtém despesas recorrentes
  List<ExpenseEntity> getRecurringExpenses({double amountTolerance = 0.1}) {
    return _filtersService.getRecurringExpenses(
      state.filteredExpenses,
      amountTolerance: amountTolerance,
    );
  }

  /// Agrupa despesas por faixa de valores
  Map<String, List<ExpenseEntity>> groupByValueRange() {
    return _filtersService.groupByValueRange(state.filteredExpenses);
  }

  /// Agrupa despesas por mês
  Map<String, List<ExpenseEntity>> groupByMonth() {
    return _filtersService.groupByMonth(state.filteredExpenses);
  }

  /// Agrupa despesas por tipo
  Map<ExpenseType, List<ExpenseEntity>> groupByType() {
    return _filtersService.groupByType(state.filteredExpenses);
  }

  /// Obtém estatísticas por período específico
  Map<String, dynamic> getStatsByPeriod(DateTime start, DateTime end) {
    return _statisticsService.calculateStatsByPeriod(state.expenses, start, end);
  }

  /// Obtém estatísticas de crescimento
  Map<String, dynamic> getGrowthStats() {
    return _statisticsService.calculateGrowthStats(state.expenses);
  }

  /// Obtém anomalias detectadas
  Map<String, dynamic> getAnomalies() {
    return _statisticsService.calculateAnomalies(state.expenses);
  }

  /// Compara períodos diferentes
  Map<String, dynamic> comparePeriods(
    DateTime period1Start,
    DateTime period1End,
    DateTime period2Start,
    DateTime period2End,
  ) {
    return _statisticsService.comparePeriods(
      state.expenses,
      period1Start,
      period1End,
      period2Start,
      period2End,
    );
  }

  // ===========================================
  // REFRESH & UTILITY
  // ===========================================

  /// Recarrega dados
  Future<void> refresh() async {
    if (state.selectedVehicleId != null) {
      await loadExpensesByVehicle(state.selectedVehicleId!);
    } else {
      await loadExpenses();
    }
  }

  /// Limpa erro atual
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ===========================================
  // PRIVATE METHODS
  // ===========================================

  /// Atualiza estado com nova lista de despesas
  void _updateStateWithExpenses(
    List<ExpenseEntity> expenses, {
    ExpenseFiltersConfig? filtersConfig,
  }) {
    final config = filtersConfig ?? state.filtersConfig;

    // Aplicar filtros usando o service
    final filteredExpenses = _filtersService.applyFilters(expenses, config);

    // Recalcular estatísticas usando o service
    final stats = _statisticsService.calculateStats(filteredExpenses);

    // Calcular análise de padrões se há veículo selecionado
    ExpensePatternAnalysis? patternAnalysis;
    if (config.vehicleId != null) {
      patternAnalysis = _calculatePatternAnalysis(config.vehicleId!);
    }

    state = state.setSuccess(
      expenses: expenses,
      filteredExpenses: filteredExpenses,
      stats: stats,
      patternAnalysis: patternAnalysis,
    );
  }

  /// Aplica filtros e recalcula estatísticas
  void _applyFiltersAndRecalculate(ExpenseFiltersConfig newConfig) {
    _updateStateWithExpenses(state.expenses, filtersConfig: newConfig);
  }

  /// Calcula análise de padrões para o veículo
  ExpensePatternAnalysis? _calculatePatternAnalysis(String vehicleId) {
    try {
      final vehicleExpenses =
          state.expenses.where((e) => e.vehicleId == vehicleId).toList();

      if (vehicleExpenses.isEmpty) return null;

      // Aqui você pode usar _validator.analyzeExpensePatterns
      // Por enquanto, retornando null (implementação completa virá depois)
      return null;
    } catch (e) {
      debugPrint('[ExpensesNotifier] Error calculating pattern analysis: $e');
      return null;
    }
  }

  /// Obtém veículo por ID (via VehiclesNotifier)
  Future<VehicleEntity?> _getVehicleById(String vehicleId) async {
    try {
      // Acessa o VehiclesNotifier via Riverpod
      final vehiclesNotifier = ref.read(vehiclesNotifierProvider.notifier);
      return await vehiclesNotifier.getVehicleById(vehicleId);
    } catch (e) {
      debugPrint('[ExpensesNotifier] Error getting vehicle: $e');
      return null;
    }
  }
}
