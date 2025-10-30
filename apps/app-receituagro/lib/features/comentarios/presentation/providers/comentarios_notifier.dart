import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/error_handler_service.dart';
import '../../domain/entities/comentario_entity.dart';
import '../../domain/usecases/add_comentario_usecase.dart';
import '../../domain/usecases/delete_comentario_usecase.dart';
import '../../domain/usecases/get_comentarios_usecase.dart';
import '../../services/comentarios_filter_service.dart';
import '../../services/comentarios_validation_service.dart';
import 'comentarios_state.dart';

part 'comentarios_notifier.g.dart';

/// Notifier para gerenciar estado dos comentários (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@riverpod
class ComentariosNotifier extends _$ComentariosNotifier {
  late final GetComentariosUseCase _getComentariosUseCase;
  late final AddComentarioUseCase _addComentarioUseCase;
  late final DeleteComentarioUseCase _deleteComentarioUseCase;
  late final ErrorHandlerService _errorHandler;
  late final ComentariosFilterService _filterService;
  late final ComentariosValidationService _validationService;

  Timer? _filterDebounceTimer;
  List<ComentarioEntity>? _cachedFilteredResults;
  String? _lastFilterHash;

  @override
  Future<ComentariosState> build() async {
    _getComentariosUseCase = di.sl<GetComentariosUseCase>();
    _addComentarioUseCase = di.sl<AddComentarioUseCase>();
    _deleteComentarioUseCase = di.sl<DeleteComentarioUseCase>();
    _errorHandler = ErrorHandlerService();
    _filterService = di.sl<ComentariosFilterService>();
    _validationService = di.sl<ComentariosValidationService>();

    // ✅ CORREÇÃO: Carregar comentários automaticamente no build
    // Isso garante que a página sempre tenha dados na inicialização
    final comentarios = await _getComentariosUseCase();

    return ComentariosState.initial().copyWith(
      comentarios: comentarios,
      isLoading: false,
    );
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
      _handleError(
        e,
        context: 'ensureDataLoaded',
        metadata: {'contextParam': context, 'toolParam': tool},
      );
    }
  }

  /// Load all comentarios
  Future<void> loadComentarios() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState
          .copyWith(
            loadingStates: currentState.loadingStates.copyWithType(
              LoadingType.loadingData,
              true,
            ),
            isLoading: true,
          )
          .clearError(),
    );

    try {
      final comentarios = await _getComentariosUseCase();
      _clearFilterCache();

      state = AsyncValue.data(
        currentState
            .copyWith(
              comentarios: comentarios,
              loadingStates: currentState.loadingStates.copyWithType(
                LoadingType.loadingData,
                false,
              ),
              isLoading: false,
            )
            .clearError(),
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
      currentState
          .copyWith(
            loadingStates: currentState.loadingStates.copyWithType(
              LoadingType.loadingData,
              true,
            ),
            isLoading: true,
          )
          .clearError(),
    );

    try {
      final comentarios = await _getComentariosUseCase.getByContext(
        pkIdentificador,
      );
      _clearFilterCache();

      state = AsyncValue.data(
        currentState
            .copyWith(
              comentarios: comentarios,
              selectedContext: pkIdentificador,
              loadingStates: currentState.loadingStates.copyWithType(
                LoadingType.loadingData,
                false,
              ),
              isLoading: false,
            )
            .clearError(),
      );

      _applyFilters(immediate: true);
    } catch (e) {
      _handleError(
        e,
        context: 'loadComentariosByContext',
        metadata: {'pkIdentificador': pkIdentificador},
      );
    }
  }

  /// Load comentarios by tool
  Future<void> loadComentariosByTool(String ferramenta) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState
          .copyWith(
            loadingStates: currentState.loadingStates.copyWithType(
              LoadingType.loadingData,
              true,
            ),
            isLoading: true,
          )
          .clearError(),
    );

    try {
      final comentarios = await _getComentariosUseCase.getByTool(ferramenta);
      _clearFilterCache();

      state = AsyncValue.data(
        currentState
            .copyWith(
              comentarios: comentarios,
              selectedTool: ferramenta,
              loadingStates: currentState.loadingStates.copyWithType(
                LoadingType.loadingData,
                false,
              ),
              isLoading: false,
            )
            .clearError(),
      );

      _applyFilters(immediate: true);
    } catch (e) {
      _handleError(
        e,
        context: 'loadComentariosByTool',
        metadata: {'ferramenta': ferramenta},
      );
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
      currentState
          .copyWith(
            isOperating: true,
            loadingStates: currentState.loadingStates.copyWithType(
              LoadingType.adding,
              true,
            ),
          )
          .clearError(),
    );

    try {
      await _addComentarioUseCase(comentario);
      final updatedComentarios = [comentario, ...currentState.comentarios];
      _clearFilterCache();

      state = AsyncValue.data(
        currentState
            .copyWith(
              comentarios: updatedComentarios,
              isOperating: false,
              loadingStates: currentState.loadingStates.copyWithType(
                LoadingType.adding,
                false,
              ),
            )
            .clearError(),
      );

      _applyFilters(immediate: true);
      unawaited(_syncDataInBackground());

      return true;
    } catch (e) {
      _handleError(
        e,
        context: 'addComentario',
        metadata: {
          'comentarioId': comentario.id,
          'titulo': comentario.titulo,
          'ferramenta': comentario.ferramenta,
        },
      );
      return false;
    }
  }

  /// Background sync to ensure data consistency
  Future<void> _syncDataInBackground() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        loadingStates: currentState.loadingStates.copyWithType(
          LoadingType.syncing,
          true,
        ),
      ),
    );

    try {
      final freshData = await _getComentariosUseCase();
      _clearFilterCache();

      state = AsyncValue.data(
        currentState.copyWith(
          comentarios: freshData,
          loadingStates: currentState.loadingStates.copyWithType(
            LoadingType.syncing,
            false,
          ),
        ),
      );

      _applyFilters(immediate: true);
    } catch (e) {
      final finalState = state.value;
      if (finalState != null) {
        state = AsyncValue.data(
          finalState.copyWith(
            loadingStates: finalState.loadingStates.copyWithType(
              LoadingType.syncing,
              false,
            ),
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
      currentState
          .copyWith(
            isOperating: true,
            loadingStates: currentState.loadingStates.copyWithType(
              LoadingType.deleting,
              true,
            ),
          )
          .clearError(),
    );

    try {
      await _deleteComentarioUseCase(id);
      final updatedComentarios = currentState.comentarios
          .where((c) => c.id != id)
          .toList();
      _clearFilterCache();

      state = AsyncValue.data(
        currentState
            .copyWith(
              comentarios: updatedComentarios,
              isOperating: false,
              loadingStates: currentState.loadingStates.copyWithType(
                LoadingType.deleting,
                false,
              ),
            )
            .clearError(),
      );

      _applyFilters(immediate: true);

      return true;
    } catch (e) {
      _handleError(
        e,
        context: 'deleteComentario',
        metadata: {'comentarioId': id},
      );
      return false;
    }
  }

  /// Search comentarios
  Future<void> searchComentarios(String query) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState
          .copyWith(
            loadingStates: currentState.loadingStates.copyWithType(
              LoadingType.searching,
              true,
            ),
            isLoading: true,
            searchQuery: query,
          )
          .clearError(),
    );

    try {
      if (query.trim().isEmpty) {
        await loadComentarios();
        return;
      }

      final comentarios = await _getComentariosUseCase.search(query);
      _clearFilterCache();

      state = AsyncValue.data(
        currentState
            .copyWith(
              comentarios: comentarios,
              loadingStates: currentState.loadingStates.copyWithType(
                LoadingType.searching,
                false,
              ),
              isLoading: false,
            )
            .clearError(),
      );

      _applyFilters(immediate: true);
    } catch (e) {
      _handleError(
        e,
        context: 'searchComentarios',
        metadata: {'searchQuery': query},
      );
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

    final hasChanges =
        currentState.selectedFilter != 'all' ||
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

    // Generate filter hash for caching
    final currentFilterHash = _filterService.generateFilterHash(
      comentariosCount: currentState.comentarios.length,
      category: currentState.selectedFilter,
      tool: currentState.selectedTool,
      context: currentState.selectedContext,
      searchQuery: currentState.searchQuery,
    );

    // Return cached results if filter state hasn't changed
    if (_lastFilterHash == currentFilterHash &&
        _cachedFilteredResults != null) {
      state = AsyncValue.data(
        currentState.copyWith(filteredComentarios: _cachedFilteredResults!),
      );
      return;
    }

    // Apply all filters using the service
    final filtered = _filterService.applyAllFilters(
      comentarios: currentState.comentarios,
      category: currentState.selectedFilter,
      tool: currentState.selectedTool,
      context: currentState.selectedContext,
      searchQuery: currentState.searchQuery,
    );

    // Cache results
    _cachedFilteredResults = filtered;
    _lastFilterHash = currentFilterHash;

    state = AsyncValue.data(
      currentState.copyWith(filteredComentarios: filtered),
    );
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

  /// Validation helper methods that delegate to service

  /// Validates if content is valid
  bool isValidContent(String content) {
    return _validationService.isValidContent(content);
  }

  /// Gets validation error message for content
  String getContentValidationError(String content) {
    return _validationService.getContentValidationError(content);
  }

  /// Checks if user can add more comentarios
  bool canAddComentario(int maxAllowed) {
    final currentState = state.value;
    if (currentState == null) return false;

    return _validationService.canAddComentario(
      currentState.comentarios.length,
      maxAllowed,
    );
  }

  /// Gets error message when limit is reached
  String getLimitReachedMessage(int maxAllowed) {
    return _validationService.getLimitReachedMessage(maxAllowed);
  }
}
