import 'dart:async';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/error/app_error.dart';
import '../models/expense_form_model.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_validation_service.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';

/// Enhanced ExpensesProvider with consistent error handling
class ExpensesProviderEnhanced extends BaseProvider with PaginatedProviderMixin<ExpenseEntity> {
  final ExpensesRepository _repository;
  final VehiclesProvider _vehiclesProvider;
  final ExpenseValidationService _validator = const ExpenseValidationService();

  // Filtered and sorted data
  List<ExpenseEntity> _allExpenses = [];
  List<ExpenseEntity> _filteredExpenses = [];
  
  // Filters
  String? _selectedVehicleId;
  ExpenseType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  
  // Sorting
  String _sortBy = 'date';
  bool _sortAscending = false;
  
  // Statistics and analysis
  Map<String, dynamic> _stats = {};
  ExpensePatternAnalysis? _patternAnalysis;

  ExpensesProviderEnhanced(
    this._repository,
    this._vehiclesProvider,
  ) {
    _initialize();
  }

  // Getters
  @override
  List<ExpenseEntity> get items => _filteredExpenses;
  List<ExpenseEntity> get allExpenses => _allExpenses;
  String? get selectedVehicleId => _selectedVehicleId;
  ExpenseType? get selectedType => _selectedType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  Map<String, dynamic> get stats => _stats;
  ExpensePatternAnalysis? get patternAnalysis => _patternAnalysis;

  /// Initialize the provider
  Future<void> _initialize() async {
    await loadAllExpenses();
  }

  /// Load all expenses
  Future<void> loadAllExpenses() async {
    await executeListOperation(
      () => _repository.getAllExpenses(),
      operationName: 'loadAllExpenses',
      onSuccess: (expenses) {
        _allExpenses = expenses;
        _applyFilters();
        _calculateStats();
        _updatePatternAnalysis();
      },
    );
  }

  /// Load expenses by vehicle
  Future<void> loadExpensesByVehicle(String vehicleId) async {
    _selectedVehicleId = vehicleId;
    
    await executeListOperation(
      () => _repository.getExpensesByVehicle(vehicleId),
      operationName: 'loadExpensesByVehicle',
      parameters: {'vehicleId': vehicleId},
      onSuccess: (expenses) {
        _allExpenses = expenses;
        _applyFilters();
        _calculateStats();
        _updatePatternAnalysis();
      },
    );
  }

  /// Add new expense
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
        _allExpenses.where((e) => e.vehicleId == expense.vehicleId).toList(),
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
      () => _repository.saveExpense(expense),
      operationName: 'addExpense',
      parameters: {
        'vehicleId': expense.vehicleId,
        'type': expense.type.name,
        'amount': expense.amount,
      },
      showLoading: false,
    );

    if (savedExpense != null) {
      _allExpenses.add(savedExpense);
      _applyFilters();
      _calculateStats();
      _updatePatternAnalysis();
      notifyListeners();
      
      logInfo('Expense added successfully', metadata: {
        'expenseId': savedExpense.id,
        'vehicleId': savedExpense.vehicleId,
        'amount': savedExpense.amount,
      });
      
      return true;
    }

    return false;
  }

  /// Update existing expense
  Future<bool> updateExpense(ExpenseFormModel formModel) async {
    if (!formModel.isEditing) {
      final error = BusinessLogicError(
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
      final otherExpenses = _allExpenses
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
      () => _repository.updateExpense(expense),
      operationName: 'updateExpense',
      parameters: {
        'expenseId': expense.id,
        'vehicleId': expense.vehicleId,
        'amount': expense.amount,
      },
      showLoading: false,
    );

    if (updatedExpense != null) {
      final index = _allExpenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _allExpenses[index] = updatedExpense;
        _applyFilters();
        _calculateStats();
        _updatePatternAnalysis();
        notifyListeners();
        
        logInfo('Expense updated successfully', metadata: {
          'expenseId': updatedExpense.id,
          'vehicleId': updatedExpense.vehicleId,
        });
        
        return true;
      }
    }

    return false;
  }

  /// Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    final expense = _allExpenses.where((e) => e.id == expenseId).firstOrNull;
    if (expense == null) {
      final error = ExpenseNotFoundError(
        technicalDetails: 'Expense ID: $expenseId',
      );
      logError(error);
      setState(ProviderState.error, error: error);
      return false;
    }

    final success = await executeDataOperation(
      () => _repository.deleteExpense(expenseId),
      operationName: 'deleteExpense',
      parameters: {'expenseId': expenseId},
      showLoading: false,
    );

    if (success == true) {
      _allExpenses.removeWhere((e) => e.id == expenseId);
      _applyFilters();
      _calculateStats();
      _updatePatternAnalysis();
      notifyListeners();
      
      logInfo('Expense deleted successfully', metadata: {
        'expenseId': expenseId,
        'vehicleId': expense.vehicleId,
      });
      
      return true;
    }

    return false;
  }

  /// Get expense by ID
  ExpenseEntity? getExpenseById(String expenseId) {
    try {
      return _allExpenses.firstWhere((e) => e.id == expenseId);
    } catch (e) {
      return null;
    }
  }

  /// Apply filters to expenses
  void applyFilters({
    String? vehicleId,
    ExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    _selectedVehicleId = vehicleId;
    _selectedType = type;
    _startDate = startDate;
    _endDate = endDate;
    _searchQuery = searchQuery ?? '';

    _applyFilters();
    _calculateStats();
    notifyListeners();
  }

  /// Clear all filters
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

  /// Sort expenses
  void sortExpenses(String sortBy, bool ascending) {
    _sortBy = sortBy;
    _sortAscending = ascending;

    _applySorting();
    notifyListeners();
  }

  /// Refresh all data
  @override
  Future<void> refresh() async {
    clearError();
    
    if (_selectedVehicleId != null) {
      await loadExpensesByVehicle(_selectedVehicleId!);
    } else {
      await loadAllExpenses();
    }
  }

  // Private methods

  void _applyFilters() {
    _filteredExpenses = _allExpenses.where((expense) {
      // Vehicle filter
      if (_selectedVehicleId != null && expense.vehicleId != _selectedVehicleId) {
        return false;
      }

      // Type filter
      if (_selectedType != null && expense.type != _selectedType) {
        return false;
      }

      // Date range filter
      if (_startDate != null && expense.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && expense.date.isAfter(_endDate!)) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesDescription = expense.description.toLowerCase().contains(query);
        final matchesLocation = expense.location?.toLowerCase().contains(query) ?? false;
        final matchesNotes = expense.notes?.toLowerCase().contains(query) ?? false;
        
        if (!matchesDescription && !matchesLocation && !matchesNotes) {
          return false;
        }
      }

      return true;
    }).toList();

    _applySorting();
  }

  void _applySorting() {
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
          comparison = a.type.name.compareTo(b.type.name);
          break;
        case 'odometer':
          comparison = a.odometer.compareTo(b.odometer);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  void _calculateStats() {
    if (_filteredExpenses.isEmpty) {
      _stats = {};
      return;
    }

    final total = _filteredExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    final byType = <ExpenseType, double>{};
    final byMonth = <String, double>{};

    for (final expense in _filteredExpenses) {
      // By type
      byType[expense.type] = (byType[expense.type] ?? 0.0) + expense.amount;

      // By month
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      byMonth[monthKey] = (byMonth[monthKey] ?? 0.0) + expense.amount;
    }

    _stats = {
      'total': total,
      'count': _filteredExpenses.length,
      'average': total / _filteredExpenses.length,
      'byType': byType,
      'byMonth': byMonth,
      'dateRange': {
        'start': _filteredExpenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b),
        'end': _filteredExpenses.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b),
      },
    };
  }

  void _updatePatternAnalysis() {
    if (_selectedVehicleId != null) {
      _vehiclesProvider.getVehicleById(_selectedVehicleId!).then((vehicle) {
        if (vehicle != null) {
          _patternAnalysis = _validator.analyzeExpensePatterns(
            _allExpenses.where((e) => e.vehicleId == _selectedVehicleId).toList(),
            vehicle,
          );
          notifyListeners();
        }
      });
    }
  }

  // Pagination implementation
  @override
  Future<List<ExpenseEntity>> fetchPage(int page) async {
    final pageSize = getPageSize();
    final startIndex = page * pageSize;
    
    if (startIndex >= _filteredExpenses.length) {
      return [];
    }
    
    final endIndex = (startIndex + pageSize).clamp(0, _filteredExpenses.length);
    return _filteredExpenses.sublist(startIndex, endIndex);
  }

  @override
  int getPageSize() => 20;

  @override
  void onRetry() {
    refresh();
  }
}