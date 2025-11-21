import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/error_handler_service.dart';
import '../../domain/entities/comentario_entity.dart';

part 'comentarios_state.freezed.dart';

/// Represents different types of loading operations
enum LoadingType {
  loadingData,
  adding,
  deleting,
  searching,
  syncing,
}

/// Immutable class to manage granular loading states
@freezed
class LoadingStates with _$LoadingStates {
  const LoadingStates._();

  const factory LoadingStates({
    @Default(false) bool isLoadingData,
    @Default(false) bool isAdding,
    @Default(false) bool isDeleting,
    @Default(false) bool isSearching,
    @Default(false) bool isSyncing,
  }) = _LoadingStates;

  /// Check if any loading operation is active
  bool get hasAnyLoading =>
      isLoadingData || isAdding || isDeleting || isSearching || isSyncing;
}

/// Extension to update specific loading states
extension LoadingStatesX on LoadingStates {
  /// Update a specific loading type
  LoadingStates copyWithType(LoadingType type, bool isLoading) {
    switch (type) {
      case LoadingType.loadingData:
        return copyWith(isLoadingData: isLoading);
      case LoadingType.adding:
        return copyWith(isAdding: isLoading);
      case LoadingType.deleting:
        return copyWith(isDeleting: isLoading);
      case LoadingType.searching:
        return copyWith(isSearching: isLoading);
      case LoadingType.syncing:
        return copyWith(isSyncing: isLoading);
    }
  }
}

/// State imutável para gerenciamento de comentários
///
/// Migrado para @freezed para type-safety, imutabilidade e código gerado
@freezed
class ComentariosState with _$ComentariosState {
  const ComentariosState._();

  const factory ComentariosState({
    /// Lista completa de comentários
    @Default([]) List<ComentarioEntity> comentarios,

    /// Comentários filtrados
    @Default([]) List<ComentarioEntity> filteredComentarios,

    /// Query de busca atual
    @Default('') String searchQuery,

    /// Filtro de data selecionado
    @Default('all') String selectedFilter,

    /// Ferramenta selecionada para filtro
    String? selectedTool,

    /// Contexto selecionado
    String? selectedContext,

    /// Loading state geral
    @Default(false) bool isLoading,

    /// Operação em andamento (add/delete)
    @Default(false) bool isOperating,

    /// Estados granulares de loading
    @Default(LoadingStates()) LoadingStates loadingStates,

    /// Mensagem de erro
    String? errorMessage,

    /// Tipo do erro
    ErrorType? errorType,

    /// Indica se pode tentar novamente
    @Default(true) bool canRetry,

    /// Sugestões para resolver o erro
    @Default([]) List<String> errorSuggestions,
  }) = _ComentariosState;

  /// Factory para estado inicial
  factory ComentariosState.initial() => const ComentariosState();

  // ========== Computed Properties ==========

  /// Verifica se há comentários
  bool get hasComentarios => comentarios.isNotEmpty;

  /// Total de comentários
  int get totalCount => comentarios.length;

  /// Comentários ativos
  int get activeCount => comentarios.where((c) => c.status).length;

  /// Estatísticas dos comentários
  Map<String, int> get statistics {
    final stats = <String, int>{};
    stats['total'] = comentarios.length;
    stats['active'] = comentarios.where((c) => c.status).length;
    stats['today'] = comentarios.where((c) => c.ageCategory == 'today').length;
    stats['week'] = comentarios.where((c) => c.ageCategory == 'week').length;
    stats['month'] = comentarios.where((c) => c.ageCategory == 'month').length;

    // Count by tool
    final toolCounts = <String, int>{};
    for (final comentario in comentarios.where((c) => c.status)) {
      toolCounts[comentario.ferramenta] =
          (toolCounts[comentario.ferramenta] ?? 0) + 1;
    }
    stats.addAll(toolCounts);

    return stats;
  }

  /// Ferramentas disponíveis
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

/// Extension para métodos de transformação do state
extension ComentariosStateX on ComentariosState {
  /// Limpa erro
  ComentariosState clearError() {
    return copyWith(
      errorMessage: null,
      errorType: null,
      canRetry: true,
      errorSuggestions: [],
    );
  }
}
