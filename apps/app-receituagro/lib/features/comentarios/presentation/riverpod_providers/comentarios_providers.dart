import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/comentario_entity.dart';
import '../../domain/repositories/i_comentarios_repository.dart';
import '../../domain/usecases/add_comentario_usecase.dart';
import '../../domain/usecases/delete_comentario_usecase.dart';
import '../../domain/usecases/get_comentarios_usecase.dart';
import '../states/comentarios_riverpod_state.dart';

/// **RIVERPOD PROVIDERS - Comentarios Feature**
/// 
/// Clean Architecture implementation with Riverpod for Comentarios feature.
/// These providers manage state in a reactive and maintainable way following
/// the separation of concerns principle established in the app-receituagro architecture.
/// 
/// ## Architecture Overview:
/// 
/// ```
/// UI Layer (Widgets) → Riverpod Providers → Use Cases → Repositories → Data Sources
/// ```
/// 
/// ## Provider Responsibilities:
/// 
/// - **comentariosRepositoryProvider**: DI injection for repository
/// - **comentariosUseCasesProvider**: DI injection for use cases  
/// - **comentariosStateProvider**: Main state management with business logic
/// - **comentariosFilteredProvider**: Computed state for filtered comments
/// - **comentariosStatsProvider**: Computed state for statistics
/// 
/// ## State Management Philosophy:
/// 
/// - **Single Source of Truth**: All state flows through comentariosStateProvider
/// - **Computed Properties**: Derived state calculated from main state automatically
/// - **Immutable State**: State objects are immutable with copyWith pattern
/// - **Error Boundaries**: Each provider handles its own errors gracefully
/// - **Performance**: Selective rebuilds only when specific state changes

/// Repository dependency injection
final comentariosRepositoryProvider = Provider<IComentariosRepository>((ref) {
  return di.sl<IComentariosRepository>();
});

/// Use Cases dependency injection providers
final getComentariosUseCaseProvider = Provider<GetComentariosUseCase>((ref) {
  return GetComentariosUseCase(ref.read(comentariosRepositoryProvider));
});

final addComentariosUseCaseProvider = Provider<AddComentarioUseCase>((ref) {
  return AddComentarioUseCase(ref.read(comentariosRepositoryProvider));
});

final deleteComentariosUseCaseProvider = Provider<DeleteComentarioUseCase>((ref) {
  return DeleteComentarioUseCase(ref.read(comentariosRepositoryProvider));
});

/// Main comentarios state provider
/// Manages loading, comments list, filtering and operations
final comentariosStateProvider = StateNotifierProvider<ComentariosStateNotifier, ComentariosRiverpodState>((ref) {
  return ComentariosStateNotifier(
    getComentariosUseCase: ref.read(getComentariosUseCaseProvider),
    addComentariosUseCase: ref.read(addComentariosUseCaseProvider),
    deleteComentariosUseCase: ref.read(deleteComentariosUseCaseProvider),
  );
});

/// Filtered comentarios based on current context and search
final comentariosFilteredProvider = Provider<List<ComentarioEntity>>((ref) {
  final state = ref.watch(comentariosStateProvider);
  final comentarios = state.comentarios;
  final searchText = state.searchText;
  final filterContext = state.filterContext;
  final filterTool = state.filterTool;
  var filtered = comentarios;
  if (filterContext.isNotEmpty) {
    filtered = filtered.where((c) => c.pkIdentificador == filterContext).toList();
  }
  if (filterTool.isNotEmpty) {
    filtered = filtered.where((c) => c.ferramenta == filterTool).toList();
  }
  if (searchText.isNotEmpty) {
    final query = searchText.toLowerCase();
    filtered = filtered.where((c) =>
      c.titulo.toLowerCase().contains(query) ||
      c.conteudo.toLowerCase().contains(query) ||
      c.ferramenta.toLowerCase().contains(query)
    ).toList();
  }

  return filtered;
});

/// Statistics computed from current comentarios
final comentariosStatsProvider = Provider<ComentariosStats>((ref) {
  final comentarios = ref.watch(comentariosStateProvider).comentarios;
  
  final total = comentarios.length;
  final active = comentarios.where((c) => c.status).length;
  final byTool = <String, int>{};
  final byContext = <String, int>{};

  for (final comentario in comentarios) {
    byTool[comentario.ferramenta] = (byTool[comentario.ferramenta] ?? 0) + 1;
    if (comentario.pkIdentificador.isNotEmpty) {
      byContext[comentario.pkIdentificador] = (byContext[comentario.pkIdentificador] ?? 0) + 1;
    }
  }

  return ComentariosStats(
    total: total,
    active: active,
    deleted: total - active,
    byTool: byTool,
    byContext: byContext,
  );
});

/// Loading state provider for UI reactivity
final comentariosLoadingProvider = Provider<bool>((ref) {
  return ref.watch(comentariosStateProvider).isLoading;
});

/// Error state provider for UI error handling  
final comentariosErrorProvider = Provider<String?>((ref) {
  return ref.watch(comentariosStateProvider).error;
});

/// State notifier that manages comentarios business logic
class ComentariosStateNotifier extends StateNotifier<ComentariosRiverpodState> {
  final GetComentariosUseCase _getComentariosUseCase;
  final AddComentarioUseCase _addComentariosUseCase; 
  final DeleteComentarioUseCase _deleteComentariosUseCase;

  ComentariosStateNotifier({
    required GetComentariosUseCase getComentariosUseCase,
    required AddComentarioUseCase addComentariosUseCase,
    required DeleteComentarioUseCase deleteComentariosUseCase,
  }) : _getComentariosUseCase = getComentariosUseCase,
       _addComentariosUseCase = addComentariosUseCase,
       _deleteComentariosUseCase = deleteComentariosUseCase,
       super(const ComentariosRiverpodState());

  /// Load all comentarios
  Future<void> loadComentarios() async {
    if (state.isLoading) return; // Prevent concurrent loads

    state = state.copyWith(isLoading: true, error: null);

    try {
      final comentarios = await _getComentariosUseCase();
      state = state.copyWith(
        comentarios: comentarios,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _formatError(e),
      );
    }
  }

  /// Load comentarios by context
  Future<void> loadComentariosByContext(String pkIdentificador) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final comentarios = await _getComentariosUseCase.getByContext(pkIdentificador);
      state = state.copyWith(
        comentarios: comentarios,
        filterContext: pkIdentificador,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _formatError(e),
      );
    }
  }

  /// Load comentarios by tool
  Future<void> loadComentariosByTool(String ferramenta) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final comentarios = await _getComentariosUseCase.getByTool(ferramenta);
      state = state.copyWith(
        comentarios: comentarios,
        filterTool: ferramenta,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _formatError(e),
      );
    }
  }

  /// Load comentarios with both context and tool filters
  Future<void> loadComentariosWithFilters({
    String? pkIdentificador,
    String? ferramenta,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<ComentarioEntity> comentarios;

      if (pkIdentificador != null && ferramenta != null) {
        final allComentarios = await _getComentariosUseCase();
        comentarios = allComentarios.where((c) =>
          c.pkIdentificador == pkIdentificador && c.ferramenta == ferramenta
        ).toList();
      } else if (pkIdentificador != null) {
        comentarios = await _getComentariosUseCase.getByContext(pkIdentificador);
      } else if (ferramenta != null) {
        comentarios = await _getComentariosUseCase.getByTool(ferramenta);
      } else {
        comentarios = await _getComentariosUseCase();
      }

      state = state.copyWith(
        comentarios: comentarios,
        filterContext: pkIdentificador ?? '',
        filterTool: ferramenta ?? '',
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _formatError(e),
      );
    }
  }

  /// Add new comentario
  Future<void> addComentario(ComentarioEntity comentario) async {
    if (state.isOperating) return; // Prevent concurrent operations

    state = state.copyWith(isOperating: true, error: null);

    try {
      await _addComentariosUseCase(comentario);
      final updatedList = [...state.comentarios, comentario];
      state = state.copyWith(
        comentarios: updatedList,
        isOperating: false,
      );
      await _refreshComentarios();
    } catch (e) {
      state = state.copyWith(
        isOperating: false,
        error: _formatError(e),
      );
    }
  }

  /// Delete comentario
  Future<void> deleteComentario(String comentarioId) async {
    if (state.isOperating) return;

    state = state.copyWith(isOperating: true, error: null);

    try {
      await _deleteComentariosUseCase(comentarioId);
      final updatedList = state.comentarios
          .where((c) => c.id != comentarioId)
          .toList();
      
      state = state.copyWith(
        comentarios: updatedList,
        isOperating: false,
      );
      await _refreshComentarios();
    } catch (e) {
      state = state.copyWith(
        isOperating: false,
        error: _formatError(e),
      );
    }
  }

  /// Update search text
  void updateSearchText(String searchText) {
    state = state.copyWith(searchText: searchText);
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(searchText: '');
  }

  /// Set context filter
  void setContextFilter(String context) {
    state = state.copyWith(filterContext: context);
  }

  /// Set tool filter
  void setToolFilter(String tool) {
    state = state.copyWith(filterTool: tool);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      searchText: '',
      filterContext: '',
      filterTool: '',
    );
  }

  /// Refresh comentarios from repository
  Future<void> _refreshComentarios() async {
    try {
      final comentarios = await _getComentariosUseCase();
      state = state.copyWith(comentarios: comentarios);
    } catch (e) {
    }
  }

  /// Clear all errors
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Format error messages for user consumption
  String _formatError(dynamic error) {
    if (error is InvalidComentarioException ||
        error is DuplicateComentarioException ||
        error is CommentLimitExceededException ||
        error is ComentarioNotFoundException ||
        error is DeletionNotAllowedException) {
      return error.toString().replaceFirst('${error.runtimeType}: ', '');
    }
    
    return 'Erro inesperado: ${error.toString()}';
  }

  /// Initialize with context and tool if provided
  Future<void> initialize({
    String? pkIdentificador,
    String? ferramenta,
  }) async {
    if (state.hasLoaded) return;

    await loadComentariosWithFilters(
      pkIdentificador: pkIdentificador,
      ferramenta: ferramenta,
    );
  }

  /// Reset state to initial state
  void reset() {
    state = const ComentariosRiverpodState();
  }
}

/// Statistics data class
class ComentariosStats {
  final int total;
  final int active;
  final int deleted;
  final Map<String, int> byTool;
  final Map<String, int> byContext;

  const ComentariosStats({
    required this.total,
    required this.active,
    required this.deleted,
    required this.byTool,
    required this.byContext,
  });

  @override
  String toString() => 'ComentariosStats(total: $total, active: $active, deleted: $deleted)';
}
