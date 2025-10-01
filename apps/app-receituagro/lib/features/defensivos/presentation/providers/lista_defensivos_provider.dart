import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../data/view_mode.dart';

/// Provider following SOLID principles for Lista Defensivos functionality
/// Implements Dependency Inversion Principle by injecting repository
/// Optimizes performance by consolidating setState calls
class ListaDefensivosProvider extends ChangeNotifier {
  final FitossanitarioHiveRepository _repository;

  // State variables
  final List<FitossanitarioHive> _allDefensivos = [];
  List<FitossanitarioHive> _filteredDefensivos = [];
  List<FitossanitarioHive> _displayedDefensivos = [];
  
  ViewMode _selectedViewMode = ViewMode.list;
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isAscending = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _searchText = '';

  // Pagination
  static const int _itemsPerPage = 50;
  int _currentPage = 0;
  Timer? _debounceTimer;

  ListaDefensivosProvider({
    required FitossanitarioHiveRepository repository,
  }) : _repository = repository;

  // Getters
  List<FitossanitarioHive> get allDefensivos => List.unmodifiable(_allDefensivos);
  List<FitossanitarioHive> get filteredDefensivos => List.unmodifiable(_filteredDefensivos);
  List<FitossanitarioHive> get displayedDefensivos => List.unmodifiable(_displayedDefensivos);
  
  ViewMode get selectedViewMode => _selectedViewMode;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isAscending => _isAscending;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String get searchText => _searchText;

  // Convenience getters
  bool get hasData => _allDefensivos.isNotEmpty;
  bool get hasFilteredData => _displayedDefensivos.isNotEmpty;
  bool get canLoadMore => _displayedDefensivos.length < _filteredDefensivos.length;

  /// Load initial data
  Future<void> loadData() async {
    try {
      _updateLoadingState(loading: true, error: null);
      
      // Load defensivos from repository
      final defensivos = await _repository.getActiveDefensivos();
      
      _allDefensivos.clear();
      _allDefensivos.addAll(defensivos);
      
      // Sort alphabetically by name
      _allDefensivos.sort((a, b) => a.displayName.compareTo(b.displayName));
      
      _filteredDefensivos = List.from(_allDefensivos);
      _currentPage = 0;
      _loadPage();
      
      _updateLoadingState(loading: false, error: null);
      
    } catch (e) {
      _updateLoadingState(loading: false, error: 'Erro ao carregar defensivos: $e');
    }
  }

  /// Perform search with debouncing
  void search(String searchText) {
    _searchText = searchText;
    _debounceTimer?.cancel();

    if (searchText.isEmpty) {
      _updateSearchState(
        isSearching: false,
        filteredData: List.from(_allDefensivos),
      );
      return;
    }

    _updateSearchState(isSearching: true);

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(searchText);
    });
  }

  /// Clear search
  void clearSearch() {
    _searchText = '';
    _debounceTimer?.cancel();
    _updateSearchState(
      isSearching: false,
      filteredData: List.from(_allDefensivos),
    );
  }

  /// Toggle sort order
  void toggleSort() {
    _isAscending = !_isAscending;
    
    // Expensive operation outside of state update
    _filteredDefensivos.sort((a, b) {
      return _isAscending
          ? a.displayName.compareTo(b.displayName)
          : b.displayName.compareTo(a.displayName);
    });

    _currentPage = 0;
    _loadPage();
    
    // Single notification after all changes
    notifyListeners();
  }

  /// Toggle view mode
  void toggleViewMode(ViewMode viewMode) {
    if (_selectedViewMode != viewMode) {
      _selectedViewMode = viewMode;
      notifyListeners();
    }
  }

  /// Load more items for pagination
  Future<void> loadMoreItems() async {
    if (_isLoadingMore || !canLoadMore) return;

    _isLoadingMore = true;
    notifyListeners();

    // Simulate delay for smooth UX
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final nextPage = _currentPage + 1;
    final startIndex = nextPage * _itemsPerPage;
    final endIndex = ((nextPage + 1) * _itemsPerPage).clamp(0, _filteredDefensivos.length);

    if (startIndex < _filteredDefensivos.length) {
      final newItems = _filteredDefensivos.sublist(startIndex, endIndex);
      _displayedDefensivos.addAll(newItems);
      _currentPage = nextPage;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Clear current error
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Get header subtitle text
  String getHeaderSubtitle() {
    final total = _allDefensivos.length;
    final filtered = _filteredDefensivos.length;

    if (_isLoading && total == 0) {
      return 'Carregando defensivos...';
    }

    if (_errorMessage != null) {
      return 'Erro no carregamento';
    }

    if (filtered < total) {
      return '$filtered de $total defensivos';
    }

    return '$total defensivos disponíveis';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Private methods

  /// Perform the actual search
  void _performSearch(String searchText) {
    final searchLower = searchText.toLowerCase();

    final filtered = _allDefensivos.where((defensivo) {
      return defensivo.displayName.toLowerCase().contains(searchLower) ||
          defensivo.displayIngredient.toLowerCase().contains(searchLower) ||
          defensivo.displayClass.toLowerCase().contains(searchLower) ||
          defensivo.displayFabricante.toLowerCase().contains(searchLower);
    }).toList();

    // Sort results outside of state update
    filtered.sort((a, b) => a.displayName.compareTo(b.displayName));

    _updateSearchState(
      isSearching: false,
      filteredData: filtered,
    );
  }

  /// Load current page items
  void _loadPage() {
    const startIndex = 0;
    final endIndex = (_itemsPerPage).clamp(0, _filteredDefensivos.length);
    _displayedDefensivos = _filteredDefensivos.sublist(startIndex, endIndex);
    _currentPage = 0;
  }

  /// Update loading state with single notification
  void _updateLoadingState({
    required bool loading,
    required String? error,
  }) {
    _isLoading = loading;
    _errorMessage = error;
    notifyListeners();
  }

  /// Update search state with single notification
  void _updateSearchState({
    required bool isSearching,
    List<FitossanitarioHive>? filteredData,
  }) {
    _isSearching = isSearching;
    
    if (filteredData != null) {
      _filteredDefensivos = filteredData;
      _currentPage = 0;
      _loadPage();
    }
    
    // Single notification consolidates all changes
    notifyListeners();
  }
}