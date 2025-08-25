import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/error_handler_service.dart';
import '../../domain/entities/comentario_entity.dart';
import '../../domain/usecases/add_comentario_usecase.dart';
import '../../domain/usecases/delete_comentario_usecase.dart';
import '../../domain/usecases/get_comentarios_usecase.dart';

/// Provider for managing comentarios state using Clean Architecture.
/// Handles all comentario-related operations and state management.
class ComentariosProvider extends ChangeNotifier {
  final GetComentariosUseCase _getComentariosUseCase;
  final AddComentarioUseCase _addComentarioUseCase;
  final DeleteComentarioUseCase _deleteComentarioUseCase;
  final ErrorHandlerService _errorHandler;

  ComentariosProvider({
    required GetComentariosUseCase getComentariosUseCase,
    required AddComentarioUseCase addComentarioUseCase,
    required DeleteComentarioUseCase deleteComentarioUseCase,
    ErrorHandlerService? errorHandler,
  })  : _getComentariosUseCase = getComentariosUseCase,
        _addComentarioUseCase = addComentarioUseCase,
        _deleteComentarioUseCase = deleteComentarioUseCase,
        _errorHandler = errorHandler ?? ErrorHandlerService();

  // State
  List<ComentarioEntity> _comentarios = [];
  List<ComentarioEntity> _filteredComentarios = [];
  bool _isLoading = false;
  bool _isOperating = false; // Prevents race conditions during operations
  LoadingStates _loadingStates = const LoadingStates();
  ErrorResult? _errorResult;
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, today, week, month
  String? _selectedTool;
  String? _selectedContext;
  
  // Debounce and optimization
  Timer? _filterDebounceTimer;
  List<ComentarioEntity>? _cachedFilteredResults;
  String? _lastFilterHash;

  // Getters
  List<ComentarioEntity> get comentarios => _filteredComentarios;
  List<ComentarioEntity> get allComentarios => _comentarios;
  bool get isLoading => _isLoading;
  bool get isOperating => _isOperating;
  LoadingStates get loadingStates => _loadingStates;
  
  // Convenient getters for specific loading states
  bool get isLoadingData => _loadingStates.isLoadingData;
  bool get isAdding => _loadingStates.isAdding;
  bool get isDeleting => _loadingStates.isDeleting;
  bool get isSearching => _loadingStates.isSearching;
  bool get isSyncing => _loadingStates.isSyncing;
  bool get hasAnyLoading => _loadingStates.hasAnyLoading;
  
  ErrorResult? get errorResult => _errorResult;
  String? get error => _errorResult?.userMessage;
  String? get errorTechnical => _errorResult?.technicalMessage;
  bool get canRetryAfterError => _errorResult?.canRetry ?? true;
  List<String> get errorSuggestions => _errorResult?.suggestions ?? [];
  ErrorType? get errorType => _errorResult?.errorType;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  String? get selectedTool => _selectedTool;
  String? get selectedContext => _selectedContext;
  bool get hasComentarios => _comentarios.isNotEmpty;
  int get totalCount => _comentarios.length;
  int get activeCount => _comentarios.where((c) => c.status).length;

  // Statistics
  Map<String, int> get statistics {
    final stats = <String, int>{};
    stats['total'] = _comentarios.length;
    stats['active'] = _comentarios.where((c) => c.status).length;
    stats['today'] = _comentarios.where((c) => c.ageCategory == 'today').length;
    stats['week'] = _comentarios.where((c) => c.ageCategory == 'week').length;
    stats['month'] = _comentarios.where((c) => c.ageCategory == 'month').length;
    
    // Count by tool
    final toolCounts = <String, int>{};
    for (final comentario in _comentarios.where((c) => c.status)) {
      toolCounts[comentario.ferramenta] = (toolCounts[comentario.ferramenta] ?? 0) + 1;
    }
    stats.addAll(toolCounts);
    
    return stats;
  }

  // Available filters for UI
  List<String> get availableTools {
    final tools = _comentarios
        .where((c) => c.status)
        .map((c) => c.ferramenta)
        .toSet()
        .toList();
    tools.sort();
    return tools;
  }

  /// Initialize provider and load data
  Future<void> initialize() async {
    await loadComentarios();
  }

  /// Ensure data is loaded based on context parameters
  Future<void> ensureDataLoaded({String? context, String? tool}) async {
    if (_isOperating || _isLoading) {
      return; // Prevent concurrent initialization
    }

    try {
      if (context != null) {
        await loadComentariosByContext(context);
      } else if (tool != null) {
        await loadComentariosByTool(tool);
      } else {
        await initialize();
      }
    } catch (e) {
      _handleError(e, context: 'ensureDataLoaded', metadata: {
        'contextParam': context,
        'toolParam': tool,
      });
    }
  }

  /// Load all comentarios
  Future<void> loadComentarios() async {
    try {
      _setLoadingState(LoadingType.loadingData, true);
      _setLoading(true);
      _clearError();
      
      _comentarios = await _getComentariosUseCase();
      _clearFilterCache();
      _applyFilters(immediate: true);
      
    } catch (e) {
      _handleError(e, context: 'loadComentarios');
    } finally {
      _setLoadingState(LoadingType.loadingData, false);
      _setLoading(false);
    }
  }

  /// Load comentarios by context
  Future<void> loadComentariosByContext(String pkIdentificador) async {
    try {
      _setLoadingState(LoadingType.loadingData, true);
      _setLoading(true);
      _clearError();
      
      _comentarios = await _getComentariosUseCase.getByContext(pkIdentificador);
      _selectedContext = pkIdentificador;
      _clearFilterCache();
      _applyFilters(immediate: true);
      
    } catch (e) {
      _handleError(e, context: 'loadComentariosByContext', metadata: {
        'pkIdentificador': pkIdentificador,
      });
    } finally {
      _setLoadingState(LoadingType.loadingData, false);
      _setLoading(false);
    }
  }

  /// Load comentarios by tool
  Future<void> loadComentariosByTool(String ferramenta) async {
    try {
      _setLoadingState(LoadingType.loadingData, true);
      _setLoading(true);
      _clearError();
      
      _comentarios = await _getComentariosUseCase.getByTool(ferramenta);
      _selectedTool = ferramenta;
      _clearFilterCache();
      _applyFilters(immediate: true);
      
    } catch (e) {
      _handleError(e, context: 'loadComentariosByTool', metadata: {
        'ferramenta': ferramenta,
      });
    } finally {
      _setLoadingState(LoadingType.loadingData, false);
      _setLoading(false);
    }
  }

  /// Add a new comentario
  Future<bool> addComentario(ComentarioEntity comentario) async {
    // Prevent race conditions by checking if another operation is in progress
    if (_isOperating) {
      debugPrint('AddComentario: Operation already in progress, skipping');
      return false;
    }

    try {
      _isOperating = true;
      _setLoadingState(LoadingType.adding, true);
      _clearError();
      
      await _addComentarioUseCase(comentario);
      
      // Update local state immediately for better UX, then sync
      _comentarios.insert(0, comentario);
      _clearFilterCache();
      _applyFilters(immediate: true);
      
      // Background sync to ensure data consistency
      unawaited(_syncDataInBackground());
      
      return true;
    } catch (e) {
      _handleError(e, context: 'addComentario', metadata: {
        'comentarioId': comentario.id,
        'titulo': comentario.titulo,
        'ferramenta': comentario.ferramenta,
      });
      return false;
    } finally {
      _setLoadingState(LoadingType.adding, false);
      _isOperating = false;
    }
  }

  /// Background sync to ensure data consistency
  Future<void> _syncDataInBackground() async {
    try {
      _setLoadingState(LoadingType.syncing, true);
      final freshData = await _getComentariosUseCase();
      _comentarios = freshData;
      _clearFilterCache();
      _applyFilters(immediate: true);
    } catch (e) {
      // Silently handle background sync errors without affecting UI
      _errorHandler.handleError(
        e,
        context: 'backgroundSync',
        shouldLog: true,
        shouldReport: false,
      );
      // Local state is preserved
    } finally {
      _setLoadingState(LoadingType.syncing, false);
    }
  }

  /// Delete a comentario
  Future<bool> deleteComentario(String id) async {
    // Prevent race conditions
    if (_isOperating) {
      debugPrint('DeleteComentario: Operation already in progress, skipping');
      return false;
    }

    try {
      _isOperating = true;
      _setLoadingState(LoadingType.deleting, true);
      _clearError();
      
      await _deleteComentarioUseCase(id);
      
      // Update local state immediately for better UX
      _comentarios.removeWhere((c) => c.id == id);
      _clearFilterCache();
      _applyFilters(immediate: true);
      
      return true;
    } catch (e) {
      _handleError(e, context: 'deleteComentario', metadata: {
        'comentarioId': id,
      });
      return false;
    } finally {
      _setLoadingState(LoadingType.deleting, false);
      _isOperating = false;
    }
  }

  /// Search comentarios
  Future<void> searchComentarios(String query) async {
    try {
      _setLoadingState(LoadingType.searching, true);
      _setLoading(true);
      _clearError();
      _searchQuery = query;
      
      if (query.trim().isEmpty) {
        await loadComentarios();
        return;
      }
      
      _comentarios = await _getComentariosUseCase.search(query);
      _clearFilterCache();
      _applyFilters(immediate: true);
      
    } catch (e) {
      _handleError(e, context: 'searchComentarios', metadata: {
        'searchQuery': query,
      });
    } finally {
      _setLoadingState(LoadingType.searching, false);
      _setLoading(false);
    }
  }

  /// Apply date filter
  void setDateFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      _applyFilters(); // Use debounce for filter changes
    }
  }

  /// Apply tool filter
  void setToolFilter(String? tool) {
    if (_selectedTool != tool) {
      _selectedTool = tool;
      _applyFilters(); // Use debounce for filter changes
    }
  }

  /// Update search query with debounce optimization
  void updateSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters(); // Use debounce for search queries
    }
  }

  /// Clear all filters
  void clearFilters() {
    final hasChanges = _selectedFilter != 'all' ||
                      _selectedTool != null ||
                      _selectedContext != null ||
                      _searchQuery.isNotEmpty;

    if (hasChanges) {
      _selectedFilter = 'all';
      _selectedTool = null;
      _selectedContext = null;
      _searchQuery = '';
      _clearFilterCache();
      _applyFilters(immediate: true); // Immediate for clear action
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadComentarios();
  }

  /// Apply current filters to comentarios list with debounce and optimization
  void _applyFilters({bool immediate = false}) {
    // Cancel previous debounce timer
    _filterDebounceTimer?.cancel();
    
    if (immediate) {
      _performFiltering();
    } else {
      // Use debounce to prevent excessive filtering operations
      _filterDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        _performFiltering();
      });
    }
  }

  /// Perform the actual filtering with caching optimization
  void _performFiltering() {
    // Generate hash for current filter state
    final currentFilterHash = _generateFilterHash();
    
    // Use cached results if filter state hasn't changed
    if (_lastFilterHash == currentFilterHash && _cachedFilteredResults != null) {
      _filteredComentarios = _cachedFilteredResults!;
      notifyListeners();
      return;
    }

    // Perform filtering with optimized algorithm
    List<ComentarioEntity> filtered = _comentarios;

    // Apply date filter first (usually most selective)
    if (_selectedFilter != 'all') {
      filtered = filtered.where((c) => c.ageCategory == _selectedFilter).toList();
    }

    // Apply tool filter
    if (_selectedTool != null) {
      filtered = filtered.where((c) => c.ferramenta == _selectedTool).toList();
    }

    // Apply search query with optimized string matching
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = _performOptimizedSearch(filtered, query);
    }

    // Cache results and update state
    _cachedFilteredResults = filtered;
    _lastFilterHash = currentFilterHash;
    _filteredComentarios = filtered;
    notifyListeners();
  }

  /// Generate a hash for current filter state to enable caching
  String _generateFilterHash() {
    return '${_selectedFilter}_${_selectedTool ?? 'null'}_${_searchQuery}_${_comentarios.length}';
  }

  /// Perform optimized search with early termination and better string matching
  List<ComentarioEntity> _performOptimizedSearch(List<ComentarioEntity> items, String query) {
    if (query.isEmpty) return items;

    // Pre-compile search terms for better performance
    final searchTerms = query.split(' ').where((term) => term.isNotEmpty).map((term) => term.toLowerCase()).toList();
    
    return items.where((comentario) {
      // Create searchable text once per item
      final searchableText = '${comentario.titulo} ${comentario.conteudo} ${comentario.ferramenta}'.toLowerCase();
      
      // All search terms must be present (AND logic)
      return searchTerms.every((term) => searchableText.contains(term));
    }).toList();
  }

  /// Clear filter cache when data changes
  void _clearFilterCache() {
    _cachedFilteredResults = null;
    _lastFilterHash = null;
    _filterDebounceTimer?.cancel();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Handle error using centralized error handler
  void _handleError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    final errorResult = _errorHandler.handleError(
      error,
      context: context,
      metadata: metadata,
      shouldLog: true,
      shouldReport: !kDebugMode, // Report in production
    );
    
    _setError(errorResult);
  }

  /// Set error state with ErrorResult
  void _setError(ErrorResult? errorResult) {
    if (_errorResult != errorResult) {
      _errorResult = errorResult;
      notifyListeners();
    }
  }

  /// Clear error
  void _clearError() {
    _setError(null);
  }

  /// Clear error (public method)
  void clearError() {
    _clearError();
  }

  /// Get comentario by ID
  ComentarioEntity? getComentarioById(String id) {
    try {
      return _comentarios.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if comentario can be edited
  bool canEditComentario(String id) {
    final comentario = getComentarioById(id);
    return comentario?.canBeEdited ?? false;
  }

  /// Set specific loading state
  void _setLoadingState(LoadingType type, bool isLoading) {
    final newStates = _loadingStates.copyWith(type, isLoading);
    if (_loadingStates != newStates) {
      _loadingStates = newStates;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _filterDebounceTimer?.cancel();
    _comentarios.clear();
    _filteredComentarios.clear();
    _cachedFilteredResults?.clear();
    super.dispose();
  }
}

/// Represents different types of loading operations
enum LoadingType {
  loadingData,
  adding,
  deleting,
  searching,
  syncing,
}

/// Immutable class to manage granular loading states
class LoadingStates {
  final bool isLoadingData;
  final bool isAdding;
  final bool isDeleting;
  final bool isSearching;
  final bool isSyncing;

  const LoadingStates({
    this.isLoadingData = false,
    this.isAdding = false,
    this.isDeleting = false,
    this.isSearching = false,
    this.isSyncing = false,
  });

  /// Check if any loading operation is active
  bool get hasAnyLoading =>
      isLoadingData || isAdding || isDeleting || isSearching || isSyncing;

  /// Create a copy with specific loading state updated
  LoadingStates copyWith(LoadingType type, bool isLoading) {
    switch (type) {
      case LoadingType.loadingData:
        return LoadingStates(
          isLoadingData: isLoading,
          isAdding: isAdding,
          isDeleting: isDeleting,
          isSearching: isSearching,
          isSyncing: isSyncing,
        );
      case LoadingType.adding:
        return LoadingStates(
          isLoadingData: isLoadingData,
          isAdding: isLoading,
          isDeleting: isDeleting,
          isSearching: isSearching,
          isSyncing: isSyncing,
        );
      case LoadingType.deleting:
        return LoadingStates(
          isLoadingData: isLoadingData,
          isAdding: isAdding,
          isDeleting: isLoading,
          isSearching: isSearching,
          isSyncing: isSyncing,
        );
      case LoadingType.searching:
        return LoadingStates(
          isLoadingData: isLoadingData,
          isAdding: isAdding,
          isDeleting: isDeleting,
          isSearching: isLoading,
          isSyncing: isSyncing,
        );
      case LoadingType.syncing:
        return LoadingStates(
          isLoadingData: isLoadingData,
          isAdding: isAdding,
          isDeleting: isDeleting,
          isSearching: isSearching,
          isSyncing: isLoading,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingStates &&
          runtimeType == other.runtimeType &&
          isLoadingData == other.isLoadingData &&
          isAdding == other.isAdding &&
          isDeleting == other.isDeleting &&
          isSearching == other.isSearching &&
          isSyncing == other.isSyncing;

  @override
  int get hashCode =>
      isLoadingData.hashCode ^
      isAdding.hashCode ^
      isDeleting.hashCode ^
      isSearching.hashCode ^
      isSyncing.hashCode;

  @override
  String toString() =>
      'LoadingStates(data: $isLoadingData, adding: $isAdding, deleting: $isDeleting, searching: $isSearching, syncing: $isSyncing)';
}