import 'package:flutter/foundation.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_filters_service.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../../../core/widgets/paginated_list_view.dart';

/// Provider de despesas com suporte a paginação e lazy loading
class ExpensesPaginatedProvider extends ChangeNotifier with PaginatedProvider<ExpenseEntity> {
  final ExpensesRepository _repository;
  final ExpenseFiltersService _filtersService = ExpenseFiltersService();

  // Configuração de filtros
  ExpenseFiltersConfig _filtersConfig = const ExpenseFiltersConfig();
  
  // Estado
  bool _isLoading = false;
  String? _error;

  ExpensesPaginatedProvider(this._repository);

  // Getters
  ExpenseFiltersConfig get filtersConfig => _filtersConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveFilters => _filtersConfig.hasActiveFilters;

  /// Implementação do método abstrato para carregar páginas
  @override
  Future<List<ExpenseEntity>> fetchPage(int page, int pageSize) async {
    try {
      _setLoading(true);
      _clearError();

      // Carregar todas as despesas (necessário para filtros locais)
      // Em um cenário real, isso seria otimizado no backend
      List<ExpenseEntity> allExpenses;
      
      if (_filtersConfig.vehicleId != null) {
        allExpenses = await _repository.getExpensesByVehicle(_filtersConfig.vehicleId!);
      } else {
        allExpenses = await _repository.getAllExpenses();
      }

      // Aplicar filtros
      final filteredExpenses = _filtersService.applyFilters(allExpenses, _filtersConfig);

      // Simular paginação local
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, filteredExpenses.length);
      
      if (startIndex >= filteredExpenses.length) {
        return []; // Não há mais dados
      }

      return filteredExpenses.sublist(startIndex, endIndex);
      
    } catch (e) {
      _setError('Erro ao carregar despesas: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega página específica com filtros
  Future<List<ExpenseEntity>> loadPageWithFilters(
    int page, 
    int pageSize, 
    ExpenseFiltersConfig filters,
  ) async {
    // Atualizar filtros se mudaram
    if (_filtersConfig != filters) {
      _filtersConfig = filters;
      clearPageCache(); // Limpar cache quando filtros mudam
    }

    return loadPage(page, pageSize);
  }

  // ===========================================
  // FILTROS
  // ===========================================

  /// Aplica filtro por veículo
  void filterByVehicle(String? vehicleId) {
    final newConfig = _filtersConfig.copyWith(
      vehicleId: vehicleId,
      clearVehicleId: vehicleId == null,
    );
    
    if (newConfig != _filtersConfig) {
      _filtersConfig = newConfig;
      clearPageCache();
      notifyListeners();
    }
  }

  /// Aplica filtro por tipo
  void filterByType(ExpenseType? type) {
    final newConfig = _filtersConfig.copyWith(
      type: type,
      clearType: type == null,
    );
    
    if (newConfig != _filtersConfig) {
      _filtersConfig = newConfig;
      clearPageCache();
      notifyListeners();
    }
  }

  /// Aplica filtro por período
  void filterByPeriod(DateTime? start, DateTime? end) {
    final newConfig = _filtersConfig.copyWith(
      startDate: start,
      endDate: end,
      clearDates: start == null && end == null,
    );
    
    if (newConfig != _filtersConfig) {
      _filtersConfig = newConfig;
      clearPageCache();
      notifyListeners();
    }
  }

  /// Aplica busca por texto
  void search(String query) {
    final newConfig = _filtersConfig.copyWith(searchQuery: query);
    
    if (newConfig != _filtersConfig) {
      _filtersConfig = newConfig;
      clearPageCache();
      notifyListeners();
    }
  }

  /// Define ordenação
  void setSortBy(String field, {bool? ascending}) {
    final newConfig = _filtersConfig.copyWith(
      sortBy: field,
      sortAscending: ascending ?? 
          (_filtersConfig.sortBy == field ? !_filtersConfig.sortAscending : false),
    );
    
    if (newConfig != _filtersConfig) {
      _filtersConfig = newConfig;
      clearPageCache();
      notifyListeners();
    }
  }

  /// Limpa todos os filtros
  void clearFilters() {
    final newConfig = _filtersConfig.cleared();
    
    if (newConfig != _filtersConfig) {
      _filtersConfig = newConfig;
      clearPageCache();
      notifyListeners();
    }
  }

  // ===========================================
  // OPERAÇÕES ESPECÍFICAS
  // ===========================================

  /// Busca despesa por ID nas páginas carregadas
  ExpenseEntity? findExpenseById(String expenseId) {
    try {
      return allItems.firstWhere((e) => e.id == expenseId);
    } catch (e) {
      return null;
    }
  }

  /// Obtém despesas carregadas por tipo
  List<ExpenseEntity> getLoadedExpensesByType(ExpenseType type) {
    return allItems.where((e) => e.type == type).toList();
  }

  /// Obtém despesas carregadas de alto valor
  List<ExpenseEntity> getLoadedHighValueExpenses({double threshold = 1000.0}) {
    return allItems.where((e) => e.amount >= threshold).toList();
  }

  /// Força recarregamento de todas as páginas
  Future<void> refresh() async {
    clearPageCache();
    notifyListeners();
  }

  /// Adiciona nova despesa ao cache local (otimização)
  void addExpenseToCache(ExpenseEntity expense) {
    // Filtrar para verificar se corresponde aos filtros atuais
    final filteredExpense = _filtersService.applyFilters([expense], _filtersConfig);
    if (filteredExpense.isNotEmpty) {
      // Limpar cache para forçar recarregamento com novo item
      clearPageCache();
      notifyListeners();
    }
  }

  /// Remove despesa do cache local (otimização)
  void removeExpenseFromCache(String expenseId) {
    // Limpar cache para forçar recarregamento sem o item removido
    clearPageCache();
    notifyListeners();
  }

  /// Atualiza despesa no cache local (otimização)
  void updateExpenseInCache(ExpenseEntity updatedExpense) {
    // Limpar cache para forçar recarregamento com item atualizado
    clearPageCache();
    notifyListeners();
  }

  // ===========================================
  // MÉTODOS AUXILIARES
  // ===========================================

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

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

  /// Obtém estatísticas de performance
  Map<String, dynamic> getPerformanceStats() {
    return {
      'cacheStats': getCacheStats(),
      'filtersActive': hasActiveFilters,
      'currentFilters': {
        'vehicleId': _filtersConfig.vehicleId,
        'type': _filtersConfig.type?.name,
        'searchQuery': _filtersConfig.searchQuery,
        'sortBy': _filtersConfig.sortBy,
        'sortAscending': _filtersConfig.sortAscending,
        'hasDateFilter': _filtersConfig.startDate != null || _filtersConfig.endDate != null,
      },
    };
  }
}