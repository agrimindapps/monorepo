import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/comentario_entity.dart';
import '../../domain/repositories/i_comentarios_read_repository.dart';
import '../../domain/repositories/i_comentarios_repository.dart';
import '../../domain/repositories/i_comentarios_write_repository.dart';
import '../../domain/usecases/add_comentario_usecase.dart';
import '../../domain/usecases/delete_comentario_usecase.dart';
import '../../domain/usecases/get_comentarios_usecase.dart';
import '../states/comentarios_riverpod_state.dart';

part 'comentarios_providers.g.dart';

/// **COMENTARIOS PROVIDERS - Riverpod Code Generation Migration**
///
/// Migrated from StateNotifierProvider pattern to @riverpod code generation.
/// Clean Architecture implementation with Riverpod for Comentarios feature.
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
/// - **Use case providers**: DI injection for use cases
/// - **comentariosStateProvider**: Main state management with business logic
/// - **comentariosFilteredProvider**: Computed state for filtered comments
/// - **comentariosStatsProvider**: Computed state for statistics
///
/// ## State Management Philosophy:
///
/// - **Single Source of Truth**: All state flows through ComentariosState
/// - **Computed Properties**: Derived state calculated automatically
/// - **Immutable State**: State objects are immutable with copyWith pattern
/// - **Error Boundaries**: Each provider handles its own errors gracefully

// ============================================================================
// Repository & Use Cases Providers
// ============================================================================

/// Repository dependency injection
@riverpod
IComentariosRepository comentariosRepository(ComentariosRepositoryRef ref) {
  return di.sl<IComentariosRepository>();
}

@riverpod
IComentariosReadRepository comentariosReadRepository(
  ComentariosReadRepositoryRef ref,
) {
  return di.sl<IComentariosReadRepository>();
}

@riverpod
IComentariosWriteRepository comentariosWriteRepository(
  ComentariosWriteRepositoryRef ref,
) {
  return di.sl<IComentariosWriteRepository>();
}

/// Use Cases dependency injection providers
@riverpod
GetComentariosUseCase getComentariosUseCase(GetComentariosUseCaseRef ref) {
  return GetComentariosUseCase(ref.watch(comentariosReadRepositoryProvider));
}

@riverpod
AddComentarioUseCase addComentariosUseCase(AddComentariosUseCaseRef ref) {
  return AddComentarioUseCase(
    ref.watch(comentariosReadRepositoryProvider),
    ref.watch(comentariosWriteRepositoryProvider),
  );
}

@riverpod
DeleteComentarioUseCase deleteComentariosUseCase(
  DeleteComentariosUseCaseRef ref,
) {
  return DeleteComentarioUseCase(
    ref.watch(comentariosReadRepositoryProvider),
    ref.watch(comentariosWriteRepositoryProvider),
  );
}

// ============================================================================
// Main Comentarios State Notifier
// ============================================================================

/// Main comentarios state provider
/// Manages loading, comments list, filtering and operations
@riverpod
class ComentariosState extends _$ComentariosState {
  @override
  ComentariosRiverpodState build() {
    return const ComentariosRiverpodState();
  }

  /// Load all comentarios
  Future<void> loadComentarios() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getComentariosUseCaseProvider);
      final comentarios = await useCase();
      state = state.copyWith(
        comentarios: comentarios,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  /// Load comentarios by context
  Future<void> loadComentariosByContext(String pkIdentificador) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getComentariosUseCaseProvider);
      final comentarios = await useCase.getByContext(pkIdentificador);
      state = state.copyWith(
        comentarios: comentarios,
        filterContext: pkIdentificador,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  /// Load comentarios by tool
  Future<void> loadComentariosByTool(String ferramenta) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getComentariosUseCaseProvider);
      final comentarios = await useCase.getByTool(ferramenta);
      state = state.copyWith(
        comentarios: comentarios,
        filterTool: ferramenta,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  /// Load comentarios with filters
  Future<void> loadComentariosWithFilters({
    String? pkIdentificador,
    String? ferramenta,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getComentariosUseCaseProvider);
      List<ComentarioEntity> comentarios;

      if (pkIdentificador != null && ferramenta != null) {
        final allComentarios = await useCase();
        comentarios = allComentarios
            .where(
              (c) =>
                  c.pkIdentificador == pkIdentificador &&
                  c.ferramenta == ferramenta,
            )
            .toList();
      } else if (pkIdentificador != null) {
        comentarios = await useCase.getByContext(pkIdentificador);
      } else if (ferramenta != null) {
        comentarios = await useCase.getByTool(ferramenta);
      } else {
        comentarios = await useCase();
      }

      state = state.copyWith(
        comentarios: comentarios,
        filterContext: pkIdentificador ?? '',
        filterTool: ferramenta ?? '',
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  /// Add new comentario
  Future<void> addComentario(ComentarioEntity comentario) async {
    if (state.isOperating) return;

    state = state.copyWith(isOperating: true, error: null);

    try {
      final useCase = ref.read(addComentariosUseCaseProvider);
      await useCase(comentario);
      final updatedList = [...state.comentarios, comentario];
      state = state.copyWith(comentarios: updatedList, isOperating: false);
      await _refreshComentarios();
    } catch (e) {
      state = state.copyWith(isOperating: false, error: _formatError(e));
    }
  }

  /// Delete comentario
  Future<void> deleteComentario(String comentarioId) async {
    if (state.isOperating) return;

    state = state.copyWith(isOperating: true, error: null);

    try {
      final useCase = ref.read(deleteComentariosUseCaseProvider);
      await useCase(comentarioId);
      final updatedList = state.comentarios
          .where((c) => c.id != comentarioId)
          .toList();

      state = state.copyWith(comentarios: updatedList, isOperating: false);
      await _refreshComentarios();
    } catch (e) {
      state = state.copyWith(isOperating: false, error: _formatError(e));
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
    state = state.copyWith(searchText: '', filterContext: '', filterTool: '');
  }

  /// Refresh comentarios
  Future<void> _refreshComentarios() async {
    try {
      final useCase = ref.read(getComentariosUseCaseProvider);
      final comentarios = await useCase();
      state = state.copyWith(comentarios: comentarios);
    } catch (e) {
      // Silent fail on refresh
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith().copyWithNullError();
  }

  /// Initialize
  Future<void> initialize({String? pkIdentificador, String? ferramenta}) async {
    if (state.hasLoaded) return;

    await loadComentariosWithFilters(
      pkIdentificador: pkIdentificador,
      ferramenta: ferramenta,
    );
  }

  /// Reset state
  void reset() {
    state = const ComentariosRiverpodState();
  }

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
}

// ============================================================================
// Derived Providers (Computed State)
// ============================================================================

/// Filtered comentarios based on current context and search
@riverpod
List<ComentarioEntity> comentariosFiltered(ComentariosFilteredRef ref) {
  final state = ref.watch(comentariosStateProvider);
  final comentarios = state.comentarios;
  final searchText = state.searchText;
  final filterContext = state.filterContext;
  final filterTool = state.filterTool;

  var filtered = comentarios;

  if (filterContext.isNotEmpty) {
    filtered = filtered
        .where((c) => c.pkIdentificador == filterContext)
        .toList();
  }

  if (filterTool.isNotEmpty) {
    filtered = filtered.where((c) => c.ferramenta == filterTool).toList();
  }

  if (searchText.isNotEmpty) {
    final query = searchText.toLowerCase();
    filtered = filtered
        .where(
          (c) =>
              c.titulo.toLowerCase().contains(query) ||
              c.conteudo.toLowerCase().contains(query) ||
              c.ferramenta.toLowerCase().contains(query),
        )
        .toList();
  }

  return filtered;
}

/// Statistics computed from current comentarios
@riverpod
ComentariosStats comentariosStats(ComentariosStatsRef ref) {
  final comentarios = ref.watch(comentariosStateProvider).comentarios;

  final total = comentarios.length;
  final active = comentarios.where((c) => c.status).length;
  final byTool = <String, int>{};
  final byContext = <String, int>{};

  for (final comentario in comentarios) {
    byTool[comentario.ferramenta] = (byTool[comentario.ferramenta] ?? 0) + 1;
    if (comentario.pkIdentificador.isNotEmpty) {
      byContext[comentario.pkIdentificador] =
          (byContext[comentario.pkIdentificador] ?? 0) + 1;
    }
  }

  return ComentariosStats(
    total: total,
    active: active,
    deleted: total - active,
    byTool: byTool,
    byContext: byContext,
  );
}

/// Loading state provider for UI reactivity
@riverpod
bool comentariosLoading(ComentariosLoadingRef ref) {
  return ref.watch(comentariosStateProvider).isLoading;
}

/// Error state provider for UI error handling
@riverpod
String? comentariosError(ComentariosErrorRef ref) {
  return ref.watch(comentariosStateProvider).error;
}

// ============================================================================
// Statistics Data Class
// ============================================================================

/// Statistics data class for comentarios metrics
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
  String toString() =>
      'ComentariosStats(total: $total, active: $active, deleted: $deleted)';
}
