// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/pluviometros_models.dart';
import '../error_handling/error_handler.dart';
import '../models/filter_models.dart';
import '../services/filter_service.dart';

/// Estados possíveis da lista de pluviômetros
enum PluviometrosViewState {
  initial,
  loading,
  loaded,
  error,
  refreshing,
}

/// Notificador reativo para o estado dos pluviômetros
class PluviometrosStateNotifier extends ChangeNotifier {
  // Estado privado
  PluviometrosViewState _state = PluviometrosViewState.initial;
  List<Pluviometro> _allPluviometros = [];
  List<Pluviometro> _filteredPluviometros = [];
  String? _errorMessage;
  bool _hasInitialized = false;

  // Filtros e ordenação
  late FilterService _filterService;

  // Paginação
  int _currentPage = 1;
  int _itemsPerPage = 20;

  // Estatísticas
  Map<String, int> _statistics = {};

  PluviometrosStateNotifier() {
    _filterService = FilterService();
    _filterService.addListener(_onFiltersChanged);
  }

  // Getters públicos
  PluviometrosViewState get state => _state;
  List<Pluviometro> get allPluviometros => List.unmodifiable(_allPluviometros);
  List<Pluviometro> get filteredPluviometros =>
      List.unmodifiable(_filteredPluviometros);
  List<Pluviometro> get paginatedPluviometros => _getPaginatedItems();
  String? get errorMessage => _errorMessage;
  bool get hasInitialized => _hasInitialized;
  bool get isLoading => _state == PluviometrosViewState.loading;
  bool get isRefreshing => _state == PluviometrosViewState.refreshing;
  bool get hasError => _state == PluviometrosViewState.error;
  bool get hasData => _allPluviometros.isNotEmpty;
  bool get isEmpty =>
      _allPluviometros.isEmpty && _state == PluviometrosViewState.loaded;

  // Filtros
  FilterService get filterService => _filterService;
  FilterSet get activeFilters => _filterService.filterSet;
  bool get hasActiveFilters => _filterService.hasActiveFilters;

  // Paginação
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _filteredPluviometros.length;
  int get totalPages => (totalItems / _itemsPerPage).ceil();
  bool get canGoToPreviousPage => _currentPage > 1;
  bool get canGoToNextPage => _currentPage < totalPages;
  bool get hasPagination => totalPages > 1;

  // Estatísticas
  Map<String, int> get statistics => Map.unmodifiable(_statistics);
  int get totalPluviometros => _allPluviometros.length;
  int get filteredCount => _filteredPluviometros.length;
  double get averageQuantidade => _calculateAverageQuantidade();
  List<Pluviometro> get highQuantityPluviometros =>
      _allPluviometros.where((p) => p.getQuantidadeAsDouble() > 50).toList();

  /// Carrega dados iniciais
  Future<void> initialize() async {
    if (_hasInitialized) return;

    await loadPluviometros();
    _hasInitialized = true;
  }

  /// Carrega lista de pluviômetros
  Future<void> loadPluviometros() async {
    _updateState(PluviometrosViewState.loading);

    try {
      // Simular carregamento - em produção seria uma chamada de API
      await Future.delayed(const Duration(milliseconds: 500));

      // Por enquanto, usar dados mockados ou existentes
      final pluviometros = <Pluviometro>[];

      _allPluviometros = pluviometros;
      _applyFiltersAndUpdate();
      _calculateStatistics();
      _updateState(PluviometrosViewState.loaded);
    } catch (error, stackTrace) {
      final errorResponse =
          PluviometroErrorHandler.instance.handleError(error, stackTrace);
      _errorMessage = errorResponse.userMessage;
      _updateState(PluviometrosViewState.error);
    }
  }

  /// Atualiza lista (pull-to-refresh)
  Future<void> refresh() async {
    if (_state == PluviometrosViewState.loading) return;

    _updateState(PluviometrosViewState.refreshing);

    try {
      // Simular refresh
      await Future.delayed(const Duration(milliseconds: 800));

      // Recarregar dados
      await loadPluviometros();
    } catch (error, stackTrace) {
      final errorResponse =
          PluviometroErrorHandler.instance.handleError(error, stackTrace);
      _errorMessage = errorResponse.userMessage;
      _updateState(PluviometrosViewState.error);
    }
  }

  /// Adiciona novo pluviômetro
  void addPluviometro(Pluviometro pluviometro) {
    _allPluviometros.add(pluviometro);
    _applyFiltersAndUpdate();
    _calculateStatistics();
    notifyListeners();
  }

  /// Atualiza pluviômetro existente
  void updatePluviometro(Pluviometro updated) {
    final index = _allPluviometros.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _allPluviometros[index] = updated;
      _applyFiltersAndUpdate();
      _calculateStatistics();
      notifyListeners();
    }
  }

  /// Remove pluviômetro
  void removePluviometro(String id) {
    _allPluviometros.removeWhere((p) => p.id == id);
    _applyFiltersAndUpdate();
    _calculateStatistics();
    notifyListeners();
  }

  /// Navega para página específica
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages && page != _currentPage) {
      _currentPage = page;
      notifyListeners();
    }
  }

  /// Vai para página anterior
  void goToPreviousPage() {
    if (canGoToPreviousPage) {
      goToPage(_currentPage - 1);
    }
  }

  /// Vai para próxima página
  void goToNextPage() {
    if (canGoToNextPage) {
      goToPage(_currentPage + 1);
    }
  }

  /// Altera quantidade de itens por página
  void changeItemsPerPage(int items) {
    if (items != _itemsPerPage && items > 0) {
      _itemsPerPage = items;
      _currentPage = 1; // Reset to first page
      notifyListeners();
    }
  }

  /// Limpa erro
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Recarrega após erro
  Future<void> retryAfterError() async {
    if (_state == PluviometrosViewState.error) {
      clearError();
      await loadPluviometros();
    }
  }

  // Métodos privados

  void _updateState(PluviometrosViewState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _onFiltersChanged() {
    _applyFiltersAndUpdate();
    _currentPage = 1; // Reset pagination when filters change
    notifyListeners();
  }

  void _applyFiltersAndUpdate() {
    _filteredPluviometros =
        _filterService.applyFiltersAndSort(_allPluviometros);
  }

  List<Pluviometro> _getPaginatedItems() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, _filteredPluviometros.length);

    if (startIndex >= _filteredPluviometros.length) {
      return [];
    }

    return _filteredPluviometros.sublist(startIndex, endIndex);
  }

  void _calculateStatistics() {
    _statistics = {
      'total': _allPluviometros.length,
      'high_quantity':
          _allPluviometros.where((p) => p.getQuantidadeAsDouble() > 50).length,
      'medium_quantity': _allPluviometros.where((p) {
        final qty = p.getQuantidadeAsDouble();
        return qty >= 20 && qty <= 50;
      }).length,
      'low_quantity':
          _allPluviometros.where((p) => p.getQuantidadeAsDouble() < 20).length,
      'with_coordinates': _allPluviometros
          .where((p) =>
              p.latitude != null &&
              p.latitude!.isNotEmpty &&
              p.longitude != null &&
              p.longitude!.isNotEmpty)
          .length,
      'without_coordinates': _allPluviometros
          .where((p) =>
              p.latitude == null ||
              p.latitude!.isEmpty ||
              p.longitude == null ||
              p.longitude!.isEmpty)
          .length,
    };
  }

  double _calculateAverageQuantidade() {
    if (_allPluviometros.isEmpty) return 0;

    final total = _allPluviometros.fold<double>(
        0, (sum, p) => sum + p.getQuantidadeAsDouble());

    return total / _allPluviometros.length;
  }

  @override
  void dispose() {
    _filterService.removeListener(_onFiltersChanged);
    _filterService.dispose();
    super.dispose();
  }
}

/// Provider para acessar o estado dos pluviômetros
class PluviometrosStateProvider
    extends InheritedNotifier<PluviometrosStateNotifier> {
  const PluviometrosStateProvider({
    super.key,
    required PluviometrosStateNotifier super.notifier,
    required super.child,
  });

  static PluviometrosStateNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<PluviometrosStateProvider>();
    assert(provider != null, 'PluviometrosStateProvider not found in context');
    return provider!.notifier!;
  }

  static PluviometrosStateNotifier? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<PluviometrosStateProvider>();
    return provider?.notifier;
  }
}
