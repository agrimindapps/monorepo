import 'package:core/core.dart';

import '../../domain/entities/comentario_entity.dart';

/// **COMENTARIOS RIVERPOD STATE**
/// 
/// Immutable state class for managing comentarios feature state with Riverpod.
/// Following Clean Architecture principles and Flutter best practices for state management.
/// 
/// ## State Properties:
/// 
/// ### Data State:
/// - **comentarios**: List of all loaded comments
/// - **hasLoaded**: Flag indicating if initial load has completed
/// 
/// ### Loading State:
/// - **isLoading**: General loading state for data fetching
/// - **isOperating**: Operation-specific loading (add/delete/update)
/// 
/// ### Error State:
/// - **error**: Current error message (null if no error)
/// 
/// ### Filter State:
/// - **searchText**: Current search query
/// - **filterContext**: Context filter (pkIdentificador)
/// - **filterTool**: Tool filter (ferramenta)
/// 
/// ## State Management Philosophy:
/// 
/// - **Immutability**: State is immutable, changes create new instances
/// - **Single Source**: All UI state flows from this single state object
/// - **Granular Updates**: Only changed properties trigger rebuilds
/// - **Error Recovery**: Error state doesn't block other operations
/// 
/// ## Usage with Riverpod:
/// 
/// ```dart
/// // Watch entire state
/// final state = ref.watch(comentariosStateProvider);
/// 
/// // Watch specific properties
/// final isLoading = ref.watch(comentariosStateProvider.select((s) => s.isLoading));
/// final comentarios = ref.watch(comentariosFilteredProvider); // Computed
/// ```

class ComentariosRiverpodState extends Equatable {
  
  /// List of all loaded comentarios
  final List<ComentarioEntity> comentarios;
  
  /// Flag indicating if initial data load has completed successfully
  final bool hasLoaded;
  
  /// General loading state for data fetching operations
  final bool isLoading;
  
  /// Operation-specific loading state for add/delete/update operations
  final bool isOperating;
  
  /// Current error message, null if no error
  final String? error;
  
  /// Current search text for filtering comentarios
  final String searchText;
  
  /// Context filter - filters by pkIdentificador (empty string means no filter)
  final String filterContext;
  
  /// Tool filter - filters by ferramenta (empty string means no filter) 
  final String filterTool;

  const ComentariosRiverpodState({
    this.comentarios = const [],
    this.hasLoaded = false,
    this.isLoading = false,
    this.isOperating = false,
    this.error,
    this.searchText = '',
    this.filterContext = '',
    this.filterTool = '',
  });

  /// Creates a copy of this state with updated values
  ComentariosRiverpodState copyWith({
    List<ComentarioEntity>? comentarios,
    bool? hasLoaded,
    bool? isLoading,
    bool? isOperating,
    String? error, // Note: passing null here will NOT clear error, use clearError()
    String? searchText,
    String? filterContext,
    String? filterTool,
  }) {
    return ComentariosRiverpodState(
      comentarios: comentarios ?? this.comentarios,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isLoading: isLoading ?? this.isLoading,
      isOperating: isOperating ?? this.isOperating,
      error: error ?? this.error,
      searchText: searchText ?? this.searchText,
      filterContext: filterContext ?? this.filterContext,
      filterTool: filterTool ?? this.filterTool,
    );
  }

  /// Creates a copy with error cleared (explicit method for clarity)
  ComentariosRiverpodState clearError() {
    return copyWith().copyWithNullError();
  }

  /// Internal method to actually set error to null
  ComentariosRiverpodState copyWithNullError() {
    return ComentariosRiverpodState(
      comentarios: comentarios,
      hasLoaded: hasLoaded,
      isLoading: isLoading,
      isOperating: isOperating,
      error: null, // Explicitly set to null
      searchText: searchText,
      filterContext: filterContext,
      filterTool: filterTool,
    );
  }

  /// Check if any loading operation is in progress
  bool get hasAnyLoading => isLoading || isOperating;

  /// Check if there are no comentarios loaded
  bool get isEmpty => comentarios.isEmpty;

  /// Check if there are comentarios loaded
  bool get isNotEmpty => comentarios.isNotEmpty;

  /// Check if there's an active error state
  bool get hasError => error != null;

  /// Check if search is active
  bool get hasSearch => searchText.isNotEmpty;

  /// Check if context filter is active  
  bool get hasContextFilter => filterContext.isNotEmpty;

  /// Check if tool filter is active
  bool get hasToolFilter => filterTool.isNotEmpty;

  /// Check if any filters are active
  bool get hasAnyFilter => hasSearch || hasContextFilter || hasToolFilter;

  /// Count of active comentarios
  int get activeComentariosCount => comentarios.where((c) => c.status).length;

  /// Count of deleted/inactive comentarios
  int get deletedComentariosCount => comentarios.where((c) => !c.status).length;

  /// Total count of comentarios
  int get totalComentariosCount => comentarios.length;

  /// Get unique tools from current comentarios
  List<String> get availableTools {
    final tools = comentarios.map((c) => c.ferramenta).toSet().toList();
    tools.sort();
    return tools;
  }

  /// Get unique contexts from current comentarios (non-empty only)
  List<String> get availableContexts {
    final contexts = comentarios
        .map((c) => c.pkIdentificador)
        .where((context) => context.isNotEmpty)
        .toSet()
        .toList();
    contexts.sort();
    return contexts;
  }

  @override
  List<Object?> get props => [
    comentarios,
    hasLoaded,
    isLoading,
    isOperating,
    error,
    searchText,
    filterContext,
    filterTool,
  ];

  @override
  String toString() {
    return 'ComentariosRiverpodState(\n'
        '  comentarios: ${comentarios.length} items,\n'
        '  hasLoaded: $hasLoaded,\n'
        '  isLoading: $isLoading,\n'
        '  isOperating: $isOperating,\n'
        '  hasError: $hasError,\n'
        '  searchText: "$searchText",\n'
        '  filterContext: "$filterContext",\n'
        '  filterTool: "$filterTool"\n'
        ')';
  }

  /// Initial loading state
  static const ComentariosRiverpodState loading = ComentariosRiverpodState(
    isLoading: true,
  );

  /// Empty loaded state  
  static const ComentariosRiverpodState empty = ComentariosRiverpodState(
    hasLoaded: true,
  );

  /// Error state factory
  static ComentariosRiverpodState withError(String errorMessage) => ComentariosRiverpodState(
    error: errorMessage,
    hasLoaded: true,
  );

  /// Loaded state factory
  static ComentariosRiverpodState loaded(List<ComentarioEntity> comentarios) => ComentariosRiverpodState(
    comentarios: comentarios,
    hasLoaded: true,
  );

  /// Validate state consistency (useful for debugging)
  bool isStateValid() {
    if (isLoading && isOperating) return false;
    if (hasLoaded && isLoading && comentarios.isEmpty) return false;
    if (hasError && (isLoading || isOperating)) return false;
    
    return true;
  }

  /// Get state summary for debugging
  String getStateSummary() {
    final conditions = <String>[];
    
    if (isLoading) conditions.add('LOADING');
    if (isOperating) conditions.add('OPERATING'); 
    if (hasError) conditions.add('ERROR');
    if (hasSearch) conditions.add('SEARCHING');
    if (hasContextFilter) conditions.add('CONTEXT_FILTERED');
    if (hasToolFilter) conditions.add('TOOL_FILTERED');
    if (isEmpty && hasLoaded) conditions.add('EMPTY');
    if (isNotEmpty) conditions.add('HAS_DATA');
    
    return conditions.isEmpty ? 'IDLE' : conditions.join('|');
  }
}