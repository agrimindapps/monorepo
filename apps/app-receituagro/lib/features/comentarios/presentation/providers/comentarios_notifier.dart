import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/error_handler_service.dart';
import '../../domain/entities/comentario_entity.dart';
import '../../domain/usecases/add_comentario_usecase.dart';
import '../../domain/usecases/delete_comentario_usecase.dart';
import '../../domain/usecases/get_comentarios_usecase.dart';

part 'comentarios_notifier.g.dart';

/// Comentarios state
class ComentariosState {
  final List<ComentarioEntity> comentarios;
  final List<ComentarioEntity> filteredComentarios;
  final String searchQuery;
  final String selectedFilter;
  final String? selectedTool;
  final String? selectedContext;
  final bool isLoading;
  final bool isOperating;
  final LoadingStates loadingStates;
  final String? errorMessage;
  final ErrorType? errorType;
  final bool canRetry;
  final List<String> errorSuggestions;

  const ComentariosState({
    required this.comentarios,
    required this.filteredComentarios,
    required this.searchQuery,
    required this.selectedFilter,
    this.selectedTool,
    this.selectedContext,
    required this.isLoading,
    required this.isOperating,
    required this.loadingStates,
    this.errorMessage,
    this.errorType,
    required this.canRetry,
    required this.errorSuggestions,
  });

  factory ComentariosState.initial() {
    return const ComentariosState(
      comentarios: [],
      filteredComentarios: [],
      searchQuery: '',
      selectedFilter: 'all',
      selectedTool: null,
      selectedContext: null,
      isLoading: false,
      isOperating: false,
      loadingStates: LoadingStates(),
      errorMessage: null,
      errorType: null,
      canRetry: true,
      errorSuggestions: [],
    );
  }

  ComentariosState copyWith({
    List<ComentarioEntity>? comentarios,
    List<ComentarioEntity>? filteredComentarios,
    String? searchQuery,
    String? selectedFilter,
    String? selectedTool,
    String? selectedContext,
    bool? isLoading,
    bool? isOperating,
    LoadingStates? loadingStates,
    String? errorMessage,
    ErrorType? errorType,
    bool? canRetry,
    List<String>? errorSuggestions,
  }) {
    return ComentariosState(
      comentarios: comentarios ?? this.comentarios,
      filteredComentarios: filteredComentarios ?? this.filteredComentarios,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedContext: selectedContext ?? this.selectedContext,
      isLoading: isLoading ?? this.isLoading,
      isOperating: isOperating ?? this.isOperating,
      loadingStates: loadingStates ?? this.loadingStates,
      errorMessage: errorMessage ?? this.errorMessage,
      errorType: errorType ?? this.errorType,
      canRetry: canRetry ?? this.canRetry,
      errorSuggestions: errorSuggestions ?? this.errorSuggestions,
    );
  }

  ComentariosState clearError() {
    return copyWith(
      errorMessage: null,
      errorType: null,
      canRetry: true,
      errorSuggestions: [],
    );
  }
  bool get hasComentarios => comentarios.isNotEmpty;
  int get totalCount => comentarios.length;
  int get activeCount => comentarios.where((c) => c.status).length;
  Map<String, int> get statistics {
    final stats = <String, int>{};
    stats['total'] = comentarios.length;
    stats['active'] = comentarios.where((c) => c.status).length;
    stats['today'] = comentarios.where((c) => c.ageCategory == 'today').length;
    stats['week'] = comentarios.where((c) => c.ageCategory == 'week').length;
    stats['month'] = comentarios.where((c) => c.ageCategory == 'month').length;
    final toolCounts = <String, int>{};
    for (final comentario in comentarios.where((c) => c.status)) {
      toolCounts[comentario.ferramenta] = (toolCounts[comentario.ferramenta] ?? 0) + 1;
    }
    stats.addAll(toolCounts);

    return stats;
  }
  List<String> get availableTools {
    final tools = comentarios
        .where((c) => c.status)
        .map((c) => c.ferramenta)
        .toSet()
        .toList();
    tools.sort();
    return tools;
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

  bool get hasAnyLoading =>
      isLoadingData || isAdding || isDeleting || isSearching || isSyncing;

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
}

/// Notifier para gerenciar estado dos comentários (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@riverpod
class ComentariosNotifier extends _$ComentariosNotifier {
  late final GetComentariosUseCase _getComentariosUseCase;
  late final AddComentarioUseCase _addComentarioUseCase;
  late final DeleteComentarioUseCase _deleteComentarioUseCase;
  late final ErrorHandlerService _errorHandler;

  Timer? _filterDebounceTimer;
  List<ComentarioEntity>? _cachedFilteredResults;
  String? _lastFilterHash;

  @override
  Future<ComentariosState> build() async {
    _getComentariosUseCase = di.sl<GetComentariosUseCase>();
    _addComentarioUseCase = di.sl<AddComentarioUseCase>();
    _deleteComentarioUseCase = di.sl<DeleteComentarioUseCase>();
    _errorHandler = ErrorHandlerService();

    return ComentariosState.initial();
  }

  /// Initialize provider and load data
  Future<void> initialize() async {
    await loadComentarios();
  }

  /// Ensure data is loaded based on context parameters
  Future<void> ensureDataLoaded({String? context, String? tool}) async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.isOperating || currentState.isLoading) {
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
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        loadingStates: currentState.loadingStates.copyWith(LoadingType.loadingData, true),
        isLoading: true,
      ).clearError(),
    );

    try {
      final comentarios = await _getComentariosUseCase();
      _clearFilterCache();

      state = AsyncValue.data(
        currentState.copyWith(
          comentarios: comentarios,
          loadingStates: currentState.loadingStates.copyWith(LoadingType.loadingData, false),
          isLoading: false,
        ).clearError(),
      );

      _applyFilters(immediate: true);
    } catch (e) {
      _handleError(e, context: 'loadComentarios');
    }
  }

  /// Load comentarios by context
  Future<void> loadComentariosByContext(String pkIdentificador) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        loadingStates: currentState.loadingStates.copyWith(LoadingType.loadingData, true),
        isLoading: true,
      ).clearError(),
    );

    try {
      final comentarios = await _getComentariosUseCase.getByContext(pkIdentificador);
      _clearFilterCache();

      state = AsyncValue.data(
        currentState.copyWith(
          comentarios: comentarios,
          selectedContext: pkIdentificador,
          loadingStates: currentState.loadingStates.copyWith(LoadingType.loadingData, false),
          isLoading: false,
        ).clearError(),
      );

      _applyFilters(immediate: true);
    } catch (e) {
      _handleError(e, context: 'loadComentariosByContext', metadata: {
        'pkIdentificador': pkIdentificador,
      });
    }
  }

  /// Load comentarios by tool
  Future<void> loadComentariosByTool(String ferramenta) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        loadingStates: currentState.loadingStates.copyWith(LoadingType.loadingData, true),
        isLoading: true,
      ).clearError(),
    );

    try {
      final comentarios = await _getComentariosUseCase.getByTool(ferramenta);
      _clearFilterCache();

      state = AsyncValue.data(
        currentState.copyWith(
          comentarios: comentarios,
          selectedTool: ferramenta,
          loadingStates: currentState.loadingStates.copyWith(LoadingType.loadingData, false),
          isLoading: false,
        ).clearError(),
      );

      _applyFilters(immediate: true);
    } catch (e) {
      _handleError(e, context: 'loadComentariosByTool', metadata: {
        'ferramenta': ferramenta,
      });
    }
  }

  /// Add a new comentario
  Future<bool> addComentario(ComentarioEntity comentario) async {
    final currentState = state.value;
    if (currentState == null) return false;
    if (currentState.isOperating) {
      return false;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isOperating: true,
        loadingStates: currentState.loadingStates.copyWith(LoadingType.adding, true),
      ).clearError(),
    );

    try {
      await _addComentarioUseCase(comentario);
      final updatedComentarios = [comentario, ...currentState.comentarios];
      _clearFilterCache();

      state = AsyncValue.data(
        currentState.copyWith(
          comentarios: updatedComentarios,
          isOperating: false,
          loadingStates: currentState.loadingStates.copyWith(LoadingType.adding, false),
        ).clearError(),
      );

      _applyFilters(immediate: true);
      unawaited(_syncDataInBackground());

      return true;
    } catch (e) {
      _handleError(e, context: 'addComentario', metadata: {
        'comentarioId': comentario.id,
        'titulo': comentario.titulo,
        'ferramenta': comentario.ferramenta,
      });
      return false;
    }
  }

  /// Background sync to ensure data consistency
  Future<void> _syncDataInBackground() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        loadingStates: currentState.loadingStates.copyWith(LoadingType.syncing, true),
      ),
    );

    try {
      final freshData = await _getComentariosUseCase();
      _clearFilterCache();

      state = AsyncValue.data(
        currentState.copyWith(
          comentarios: freshData,
          loadingStates: currentState.loadingStates.copyWith(LoadingType.syncing, false),
        ),
      );

      _applyFilters(immediate: true);
    } catch (e) {
      final finalState = state.value;
      if (finalState != null) {
        state = AsyncValue.data(
          finalState.copyWith(
            loadingStates: finalState.loadingStates.copyWith(LoadingType.syncing, false),
          ),
        );
      }
    }
  }

  /// Delete a comentario
  Future<bool> deleteComentario(String id) async {
    final currentState = state.value;
    if (currentState == null) return false;
    if (currentState.isOperating) {
      return false;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isOperating: true,
        loadingStates: currentState.loadingStates.copyWith(LoadingType.deleting, true),
      ).clearError(),
    );

    try {
      await _deleteComentarioUseCase(id);
      final updatedComentarios = currentState.comentarios.where((c) => c.id != id).toList();
      _clearFilterCache();

      state = AsyncValue.data(
        currentState.copyWith(
          comentarios: updatedComentarios,
          isOperating: false,
          loadingStates: currentState.loadingStates.copyWith(LoadingType.deleting, false),
        ).clearError(),
      );

      _applyFilters(immediate: true);

      return true;
    } catch (e) {
      _handleError(e, context: 'deleteComentario', metadata: {
        'comentarioId': id,
      });
      return false;
    }
  }

  /// Search comentarios
  Future<void> searchComentarios(String query) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        loadingStates: currentState.loadingStates.copyWith(LoadingType.searching, true),
        isLoading: true,
        searchQuery: query,
      ).clearError(),
    );

    try {
      if (query.trim().isEmpty) {
        await loadComentarios();
        return;
      }

      final comentarios = await _getComentariosUseCase.search(query);
      _clearFilterCache();

      state = AsyncValue.data(
        currentState.copyWith(
          comentarios: comentarios,
          loadingStates: currentState.loadingStates.copyWith(LoadingType.searching, false),
          isLoading: false,
        ).clearError(),
      );

      _applyFilters(immediate: true);
    } catch (e) {
      _handleError(e, context: 'searchComentarios', metadata: {
        'searchQuery': query,
      });
    }
  }

  /// Apply date filter
  void setDateFilter(String filter) {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.selectedFilter != filter) {
      state = AsyncValue.data(currentState.copyWith(selectedFilter: filter));
      _applyFilters();
    }
  }

  /// Apply tool filter
  void setToolFilter(String? tool) {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.selectedTool != tool) {
      state = AsyncValue.data(currentState.copyWith(selectedTool: tool));
      _applyFilters();
    }
  }

  /// Update search query with debounce optimization
  void updateSearchQuery(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.searchQuery != query) {
      state = AsyncValue.data(currentState.copyWith(searchQuery: query));
      _applyFilters();
    }
  }

  /// Clear all filters
  void clearFilters() {
    final currentState = state.value;
    if (currentState == null) return;

    final hasChanges = currentState.selectedFilter != 'all' ||
        currentState.selectedTool != null ||
        currentState.selectedContext != null ||
        currentState.searchQuery.isNotEmpty;

    if (hasChanges) {
      _clearFilterCache();
      state = AsyncValue.data(
        currentState.copyWith(
          selectedFilter: 'all',
          selectedTool: null,
          selectedContext: null,
          searchQuery: '',
        ),
      );
      _applyFilters(immediate: true);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadComentarios();
  }

  /// Apply current filters to comentarios list with debounce and optimization
  void _applyFilters({bool immediate = false}) {
    _filterDebounceTimer?.cancel();

    if (immediate) {
      _performFiltering();
    } else {
      _filterDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        _performFiltering();
      });
    }
  }

  /// Perform the actual filtering with caching optimization
  void _performFiltering() {
    final currentState = state.value;
    if (currentState == null) return;
    final currentFilterHash = _generateFilterHash(currentState);
    if (_lastFilterHash == currentFilterHash && _cachedFilteredResults != null) {
      state = AsyncValue.data(currentState.copyWith(filteredComentarios: _cachedFilteredResults));
      return;
    }
    List<ComentarioEntity> filtered = currentState.comentarios;
    if (currentState.selectedFilter != 'all') {
      filtered = filtered.where((c) => c.ageCategory == currentState.selectedFilter).toList();
    }
    if (currentState.selectedTool != null) {
      filtered = filtered.where((c) => c.ferramenta == currentState.selectedTool).toList();
    }
    if (currentState.searchQuery.isNotEmpty) {
      final query = currentState.searchQuery.toLowerCase();
      filtered = _performOptimizedSearch(filtered, query);
    }
    _cachedFilteredResults = filtered;
    _lastFilterHash = currentFilterHash;

    state = AsyncValue.data(currentState.copyWith(filteredComentarios: filtered));
  }

  /// Generate a hash for current filter state to enable caching
  String _generateFilterHash(ComentariosState currentState) {
    return '${currentState.selectedFilter}_${currentState.selectedTool ?? 'null'}_${currentState.searchQuery}_${currentState.comentarios.length}';
  }

  /// Perform optimized search with early termination and better string matching
  List<ComentarioEntity> _performOptimizedSearch(List<ComentarioEntity> items, String query) {
    if (query.isEmpty) return items;
    final searchTerms = query.split(' ').where((term) => term.isNotEmpty).map((term) => term.toLowerCase()).toList();

    return items.where((comentario) {
      final searchableText = '${comentario.titulo} ${comentario.conteudo} ${comentario.ferramenta}'.toLowerCase();
      return searchTerms.every((term) => searchableText.contains(term));
    }).toList();
  }

  /// Clear filter cache when data changes
  void _clearFilterCache() {
    _cachedFilteredResults = null;
    _lastFilterHash = null;
    _filterDebounceTimer?.cancel();
  }

  /// Handle error using centralized error handler
  void _handleError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    final currentState = state.value;
    if (currentState == null) return;

    final errorResult = _errorHandler.handleError(
      error,
      context: context,
      metadata: metadata,
      shouldLog: true,
      shouldReport: false,
    );

    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: false,
        isOperating: false,
        loadingStates: const LoadingStates(),
        errorMessage: errorResult.userMessage,
        errorType: errorResult.errorType,
        canRetry: errorResult.canRetry,
        errorSuggestions: errorResult.suggestions,
      ),
    );
  }

  /// Clear error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }

  /// Get comentario by ID
  ComentarioEntity? getComentarioById(String id) {
    final currentState = state.value;
    if (currentState == null) return null;

    try {
      return currentState.comentarios.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if comentario can be edited
  bool canEditComentario(String id) {
    final comentario = getComentarioById(id);
    return comentario?.canBeEdited ?? false;
  }
}
