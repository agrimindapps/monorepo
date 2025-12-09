import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

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
import '../providers/expenses_providers.dart';
import '../state/expenses_state.dart';

part 'expenses_notifier.g.dart';

/// Notifier principal para gerenciar estado de despesas
@riverpod
class ExpensesNotifier extends _$ExpensesNotifier {
  final _validator = const ExpenseValidationService();
  final _statisticsService = ExpenseStatisticsService();
  final _filtersService = ExpenseFiltersService();
  late final GetAllExpensesUseCase _getAllExpensesUseCase;
  late final GetExpensesByVehicleUseCase _getExpensesByVehicleUseCase;
  late final AddExpenseUseCase _addExpenseUseCase;
  late final UpdateExpenseUseCase _updateExpenseUseCase;
  late final DeleteExpenseUseCase _deleteExpenseUseCase;

  @override
  ExpensesState build() {
    _getAllExpensesUseCase = ref.watch(getAllExpensesProvider);
    _getExpensesByVehicleUseCase = ref.watch(getExpensesByVehicleProvider);
    _addExpenseUseCase = ref.watch(addExpenseProvider);
    _updateExpenseUseCase = ref.watch(updateExpenseProvider);
    _deleteExpenseUseCase = ref.watch(deleteExpenseProvider);
    Future.microtask(() => _loadInitialData());

    return ExpensesState.initial();
  }

  /// Carrega dados iniciais
  Future<void> _loadInitialData() async {
    await loadExpenses();
  }

  /// Carrega todas as despesas
  Future<void> loadExpenses() async {
    state = state.setLoading();

    final result = await _getAllExpensesUseCase(const NoParams());

    result.fold(
      (failure) {
        debugPrint(
            '[ExpensesNotifier] Error loading expenses: ${failure.message}');
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
        debugPrint(
            '[ExpensesNotifier] Error loading expenses by vehicle: ${failure.message}');
        state = state.setError(failure.message);
      },
      (expenses) {
        final newFiltersConfig =
            state.filtersConfig.copyWith(vehicleId: vehicleId);
        _updateStateWithExpenses(expenses, filtersConfig: newFiltersConfig);
      },
    );
  }

  /// Adiciona nova despesa
  Future<bool> addExpense(ExpenseFormModel formModel) async {
    final validationErrors = formModel.validate();
    if (validationErrors.isNotEmpty) {
      final errorMessage = 'Dados inválidos: ${validationErrors.values.first}';
      debugPrint('[ExpensesNotifier] Validation error: $errorMessage');
      state = state.setError(errorMessage);
      return false;
    }

    final expense = formModel.toExpenseEntity();
    final vehicle = await _getVehicleById(expense.vehicleId);
    if (vehicle != null) {
      final validationResult = _validator.validateExpenseRecord(
        expense,
        vehicle,
        state.expenses.where((e) => e.vehicleId == expense.vehicleId).toList(),
      );

      if (!validationResult.isValid) {
        final errorMessage = validationResult.errors.values.first;
        debugPrint(
            '[ExpensesNotifier] Contextual validation error: $errorMessage');
        state = state.setError(errorMessage);
        return false;
      }
    }
    state = state.setLoading();

    final result = await _addExpenseUseCase(expense);

    return result.fold(
      (failure) {
        debugPrint(
            '[ExpensesNotifier] Error adding expense: ${failure.message}');
        state = state.setError(failure.message);
        return false;
      },
      (savedExpense) {
        final updatedExpenses = List<ExpenseEntity>.from(state.expenses)
          ..add(savedExpense!);
        _updateStateWithExpenses(updatedExpenses);

        debugPrint(
            '[ExpensesNotifier] Expense added successfully: ${savedExpense.id}');
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
    final validationErrors = formModel.validate();
    if (validationErrors.isNotEmpty) {
      final errorMessage = 'Dados inválidos: ${validationErrors.values.first}';
      debugPrint('[ExpensesNotifier] Validation error: $errorMessage');
      state = state.setError(errorMessage);
      return false;
    }

    final expense = formModel.toExpenseEntity();
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
        debugPrint(
            '[ExpensesNotifier] Contextual validation error: $errorMessage');
        state = state.setError(errorMessage);
        return false;
      }
    }
    state = state.setLoading();

    final result = await _updateExpenseUseCase(expense);

    return result.fold(
      (failure) {
        debugPrint(
            '[ExpensesNotifier] Error updating expense: ${failure.message}');
        state = state.setError(failure.message);
        return false;
      },
      (updatedExpense) {
        final updatedExpenses = List<ExpenseEntity>.from(
          state.expenses.map((e) {
            if (e.id == expense.id) {
              return updatedExpense!;
            }
            return e;
          }),
        );
        _updateStateWithExpenses(updatedExpenses);

        debugPrint(
            '[ExpensesNotifier] Expense updated successfully: ${updatedExpense!.id}');
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
        debugPrint(
            '[ExpensesNotifier] Error deleting expense: ${failure.message}');
        state = state.setError(failure.message);
        return false;
      },
      (deleted) {
        if (deleted) {
          final updatedExpenses =
              state.expenses.where((e) => e.id != expenseId).toList();
          _updateStateWithExpenses(updatedExpenses);

          debugPrint(
              '[ExpensesNotifier] Expense deleted successfully: $expenseId');
          return true;
        }

        state = state.setError('Erro ao deletar despesa');
        return false;
      },
    );
  }

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

  /// Seleciona mês para filtro
  void selectMonth(DateTime month) {
    final newFiltersConfig = state.filtersConfig.copyWith(selectedMonth: month);
    _applyFiltersAndRecalculate(newFiltersConfig);
  }

  /// Limpa filtro de mês
  void clearMonthFilter() {
    final newFiltersConfig = state.filtersConfig.copyWith(clearMonth: true);
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
    final otherExpenses = state.expenses
        .where((e) => e.vehicleId == expense.vehicleId && e.id != expense.id)
        .toList();

    final validationResult = _validator.validateExpenseRecord(
      expense,
      vehicle,
      otherExpenses,
    );
    final similarExpenses = state.expenses
        .where((e) => e.type == expense.type && e.id != expense.id)
        .toList();

    double? averageSimilar;
    if (similarExpenses.isNotEmpty) {
      averageSimilar =
          similarExpenses.fold<double>(0, (total, e) => total + e.amount) /
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
    return _statisticsService.calculateStatsByPeriod(
        state.expenses, start, end);
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

  // Cache para restauração de itens excluídos
  final Map<String, ExpenseEntity> _deletedCache = {};

  /// Remove despesa de forma otimista (para SwipeToDelete)
  /// O item é removido imediatamente da UI e pode ser restaurado
  Future<void> deleteOptimistic(String expenseId) async {
    final expense = getExpenseById(expenseId);
    if (expense == null) return;

    // Guarda no cache para possível restauração
    _deletedCache[expenseId] = expense;

    // Remove otimisticamente da lista
    final updatedExpenses = state.expenses.where((e) => e.id != expenseId).toList();
    _updateStateWithExpenses(updatedExpenses);

    // Executa a deleção real em background
    final result = await _deleteExpenseUseCase(expenseId);
    result.fold(
      (failure) {
        // Se falhar, restaura o item
        debugPrint('[ExpensesNotifier] Delete failed, restoring: ${failure.message}');
        _restoreFromCache(expenseId);
      },
      (success) {
        // Sucesso - remove do cache após um tempo
        Future.delayed(const Duration(seconds: 10), () {
          _deletedCache.remove(expenseId);
        });
      },
    );
  }

  /// Restaura despesa excluída (para undo do SwipeToDelete)
  Future<void> restoreDeleted(String expenseId) async {
    _restoreFromCache(expenseId);
  }

  void _restoreFromCache(String expenseId) {
    final expense = _deletedCache[expenseId];
    if (expense == null) return;

    // Restaura na lista
    final updatedExpenses = List<ExpenseEntity>.from(state.expenses)..add(expense);
    _updateStateWithExpenses(updatedExpenses);
    _deletedCache.remove(expenseId);
  }

  /// Atualiza estado com nova lista de despesas
  void _updateStateWithExpenses(
    List<ExpenseEntity> expenses, {
    ExpenseFiltersConfig? filtersConfig,
  }) {
    final config = filtersConfig ?? state.filtersConfig;
    final filteredExpenses = _filtersService.applyFilters(expenses, config);
    final stats = _statisticsService.calculateStats(filteredExpenses);
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
      return null;
    } catch (e) {
      debugPrint('[ExpensesNotifier] Error calculating pattern analysis: $e');
      return null;
    }
  }

  /// Obtém veículo por ID (via VehiclesNotifier)
  Future<VehicleEntity?> _getVehicleById(String vehicleId) async {
    try {
      final vehiclesNotifier = ref.read(vehiclesProvider.notifier);
      return await vehiclesNotifier.getVehicleById(vehicleId);
    } catch (e) {
      debugPrint('[ExpensesNotifier] Error getting vehicle: $e');
      return null;
    }
  }
}
