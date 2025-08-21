import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/expense_form_model.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_validation_service.dart';
import '../../domain/services/expense_formatter_service.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';

/// Provider principal para gerenciar estado e operações de despesas
class ExpensesProvider extends ChangeNotifier {
  final ExpensesRepository _repository;
  final VehiclesProvider _vehiclesProvider;
  final ExpenseValidationService _validator = const ExpenseValidationService();
  final ExpenseFormatterService _formatter = ExpenseFormatterService();

  // Estado da listagem de despesas
  List<ExpenseEntity> _expenses = [];
  List<ExpenseEntity> _filteredExpenses = [];
  bool _isLoading = false;
  String? _error;
  
  // Filtros aplicados
  String? _selectedVehicleId;
  ExpenseType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  
  // Ordenação
  String _sortBy = 'date'; // 'date', 'amount', 'type', 'odometer'
  bool _sortAscending = false;
  
  // Estado de estatísticas
  Map<String, dynamic> _stats = {};
  ExpensePatternAnalysis? _patternAnalysis;

  ExpensesProvider(
    this._repository,
    this._vehiclesProvider,
  ) {
    _initialize();
  }

  // Getters públicos
  List<ExpenseEntity> get expenses => _filteredExpenses;
  List<ExpenseEntity> get allExpenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedVehicleId => _selectedVehicleId;
  ExpenseType? get selectedType => _selectedType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  Map<String, dynamic> get stats => _stats;
  ExpensePatternAnalysis? get patternAnalysis => _patternAnalysis;

  /// Inicialização do provider
  Future<void> _initialize() async {
    await loadExpenses();
  }

  /// Carrega todas as despesas
  Future<void> loadExpenses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _expenses = await _repository.getAllExpenses();
      _applyFilters();
      _calculateStats();
      
      // Calcular análise de padrões se há veículo selecionado
      if (_selectedVehicleId != null) {
        final vehicle = await _vehiclesProvider.getVehicleById(_selectedVehicleId!);
        if (vehicle != null) {
          _patternAnalysis = _validator.analyzeExpensePatterns(_expenses, vehicle);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar despesas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega despesas por veículo
  Future<void> loadExpensesByVehicle(String vehicleId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _expenses = await _repository.getExpensesByVehicle(vehicleId);
      _selectedVehicleId = vehicleId;
      
      _applyFilters();
      _calculateStats();
      
      // Calcular análise de padrões
      final vehicle = await _vehiclesProvider.getVehicleById(vehicleId);
      if (vehicle != null) {
        _patternAnalysis = _validator.analyzeExpensePatterns(_expenses, vehicle);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar despesas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona nova despesa
  Future<bool> addExpense(ExpenseFormModel formModel) async {
    try {
      _error = null;

      // Validar dados completos
      final validationErrors = formModel.validate();
      if (validationErrors.isNotEmpty) {
        _error = 'Dados inválidos: ${validationErrors.values.first}';
        notifyListeners();
        return false;
      }

      // Converter para entity
      final expense = formModel.toExpenseEntity();

      // Validação contextual com despesas existentes
      final vehicle = await _vehiclesProvider.getVehicleById(expense.vehicleId);
      if (vehicle != null) {
        final validationResult = _validator.validateExpenseRecord(
          expense,
          vehicle,
          _expenses.where((e) => e.vehicleId == expense.vehicleId).toList(),
        );

        if (!validationResult.isValid) {
          _error = validationResult.errors.values.first;
          notifyListeners();
          return false;
        }
      }

      // Salvar no repositório
      final saved = await _repository.saveExpense(expense);
      
      if (saved != null) {
        // Atualizar lista local
        _expenses.add(saved);
        _applyFilters();
        _calculateStats();
        
        // Recalcular análise de padrões
        if (vehicle != null) {
          _patternAnalysis = _validator.analyzeExpensePatterns(
            _expenses.where((e) => e.vehicleId == expense.vehicleId).toList(),
            vehicle,
          );
        }

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Erro ao salvar despesa: $e';
      notifyListeners();
      return false;
    }
  }

  /// Atualiza despesa existente
  Future<bool> updateExpense(ExpenseFormModel formModel) async {
    try {
      _error = null;

      if (!formModel.isEditing) {
        _error = 'Despesa não existe para edição';
        notifyListeners();
        return false;
      }

      // Validar dados
      final validationErrors = formModel.validate();
      if (validationErrors.isNotEmpty) {
        _error = 'Dados inválidos: ${validationErrors.values.first}';
        notifyListeners();
        return false;
      }

      // Converter para entity
      final expense = formModel.toExpenseEntity();

      // Validação contextual
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
          _error = validationResult.errors.values.first;
          notifyListeners();
          return false;
        }
      }

      // Atualizar no repositório
      final updated = await _repository.updateExpense(expense);
      
      if (updated != null) {
        // Atualizar lista local
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        if (index >= 0) {
          _expenses[index] = updated;
          _applyFilters();
          _calculateStats();
          
          // Recalcular análise de padrões
          if (vehicle != null) {
            _patternAnalysis = _validator.analyzeExpensePatterns(
              _expenses.where((e) => e.vehicleId == expense.vehicleId).toList(),
              vehicle,
            );
          }

          notifyListeners();
        }
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Erro ao atualizar despesa: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove despesa
  Future<bool> removeExpense(String expenseId) async {
    try {
      _error = null;

      final success = await _repository.deleteExpense(expenseId);
      
      if (success) {
        _expenses.removeWhere((e) => e.id == expenseId);
        _applyFilters();
        _calculateStats();
        
        // Recalcular análise de padrões se necessário
        if (_selectedVehicleId != null) {
          final vehicle = await _vehiclesProvider.getVehicleById(_selectedVehicleId!);
          if (vehicle != null) {
            _patternAnalysis = _validator.analyzeExpensePatterns(
              _expenses.where((e) => e.vehicleId == _selectedVehicleId!).toList(),
              vehicle,
            );
          }
        }

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Erro ao remover despesa: $e';
      notifyListeners();
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

  // Métodos de filtragem

  /// Aplica filtro por veículo
  void filterByVehicle(String? vehicleId) {
    _selectedVehicleId = vehicleId;
    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  /// Aplica filtro por tipo
  void filterByType(ExpenseType? type) {
    _selectedType = type;
    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  /// Aplica filtro por período
  void filterByPeriod(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  /// Aplica busca por texto
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _selectedVehicleId = null;
    _selectedType = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  // Métodos de ordenação

  /// Ordena por campo específico
  void setSortBy(String field, {bool? ascending}) {
    _sortBy = field;
    _sortAscending = ascending ?? (_sortBy == field ? !_sortAscending : false);
    _applySort();
    notifyListeners();
  }

  /// Aplica filtros à lista de despesas
  void _applyFilters() {
    _filteredExpenses = _expenses.where((expense) {
      // Filtro por veículo
      if (_selectedVehicleId != null && expense.vehicleId != _selectedVehicleId) {
        return false;
      }

      // Filtro por tipo
      if (_selectedType != null && expense.type != _selectedType) {
        return false;
      }

      // Filtro por período
      if (_startDate != null) {
        final startOfDay = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        if (expense.date.isBefore(startOfDay)) return false;
      }
      
      if (_endDate != null) {
        final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        if (expense.date.isAfter(endOfDay)) return false;
      }

      // Filtro por busca de texto
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!expense.description.toLowerCase().contains(query) &&
            !expense.type.displayName.toLowerCase().contains(query) &&
            (expense.location?.toLowerCase().contains(query) != true) &&
            (expense.notes?.toLowerCase().contains(query) != true)) {
          return false;
        }
      }

      return true;
    }).toList();

    _applySort();
  }

  /// Aplica ordenação à lista filtrada
  void _applySort() {
    _filteredExpenses.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'type':
          comparison = a.type.displayName.compareTo(b.type.displayName);
          break;
        case 'odometer':
          comparison = a.odometer.compareTo(b.odometer);
          break;
        case 'description':
          comparison = a.description.compareTo(b.description);
          break;
        default:
          comparison = a.date.compareTo(b.date);
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  /// Calcula estatísticas da lista filtrada
  void _calculateStats() {
    if (_filteredExpenses.isEmpty) {
      _stats = {};
      return;
    }

    final totalAmount = _filteredExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final averageAmount = totalAmount / _filteredExpenses.length;
    
    // Agrupar por tipo
    final byType = <ExpenseType, double>{};
    final countByType = <ExpenseType, int>{};
    
    for (final expense in _filteredExpenses) {
      byType[expense.type] = (byType[expense.type] ?? 0) + expense.amount;
      countByType[expense.type] = (countByType[expense.type] ?? 0) + 1;
    }

    // Encontrar tipo mais caro
    ExpenseType? mostExpensiveType;
    double maxTypeAmount = 0;
    byType.forEach((type, amount) {
      if (amount > maxTypeAmount) {
        maxTypeAmount = amount;
        mostExpensiveType = type;
      }
    });

    // Calcular médias mensais se tiver dados suficientes
    double monthlyAverage = 0;
    if (_filteredExpenses.length >= 2) {
      final sortedByDate = List<ExpenseEntity>.from(_filteredExpenses)
        ..sort((a, b) => a.date.compareTo(b.date));
      
      final firstDate = sortedByDate.first.date;
      final lastDate = sortedByDate.last.date;
      final monthsDiff = ((lastDate.year - firstDate.year) * 12 + lastDate.month - firstDate.month) + 1;
      
      if (monthsDiff > 0) {
        monthlyAverage = totalAmount / monthsDiff;
      }
    }

    _stats = {
      'totalRecords': _filteredExpenses.length,
      'totalAmount': totalAmount,
      'totalAmountFormatted': _formatter.formatAmount(totalAmount),
      'averageAmount': averageAmount,
      'averageAmountFormatted': _formatter.formatAmount(averageAmount),
      'monthlyAverage': monthlyAverage,
      'monthlyAverageFormatted': _formatter.formatAmount(monthlyAverage),
      'byType': byType.map((k, v) => MapEntry(k.displayName, v)),
      'countByType': countByType.map((k, v) => MapEntry(k.displayName, v)),
      'mostExpensiveType': mostExpensiveType?.displayName,
      'mostExpensiveTypeAmount': maxTypeAmount,
      'mostExpensiveTypeAmountFormatted': _formatter.formatAmount(maxTypeAmount),
      'highestExpense': _filteredExpenses.reduce((a, b) => a.amount > b.amount ? a : b).amount,
      'lowestExpense': _filteredExpenses.reduce((a, b) => a.amount < b.amount ? a : b).amount,
    };
  }

  /// Recarrega dados
  Future<void> refresh() async {
    await loadExpenses();
  }

  /// Limpa erro atual
  void clearError() {
    _error = null;
    notifyListeners();
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
}