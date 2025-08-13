// Project imports:
import '../../../models/comentarios_models.dart';

/// Estado individual de edição de um comentário
class ComentarioEditState {
  final String comentarioId;
  final bool isEditing;
  final String currentContent;
  final bool isDeleted;

  const ComentarioEditState({
    required this.comentarioId,
    this.isEditing = false,
    this.currentContent = '',
    this.isDeleted = false,
  });

  ComentarioEditState copyWith({
    String? comentarioId,
    bool? isEditing,
    String? currentContent,
    bool? isDeleted,
  }) {
    return ComentarioEditState(
      comentarioId: comentarioId ?? this.comentarioId,
      isEditing: isEditing ?? this.isEditing,
      currentContent: currentContent ?? this.currentContent,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class ComentariosState {
  final List<Comentarios> comentarios;
  final List<Comentarios> comentariosFiltrados;
  final bool isLoading;
  final String searchText;
  final int quantComentarios;
  final int maxComentarios;
  final String? error;
  
  /// Estados de edição individuais para cada comentário
  final Map<String, ComentarioEditState> editStates;
  
  /// Estado de criação de novo comentário
  final bool isCreatingNew;
  final String newCommentContent;

  const ComentariosState({
    this.comentarios = const [],
    this.comentariosFiltrados = const [],
    this.isLoading = false,
    this.searchText = '',
    this.quantComentarios = 0,
    this.maxComentarios = 0,
    this.error,
    this.editStates = const {},
    this.isCreatingNew = false,
    this.newCommentContent = '',
  });

  ComentariosState copyWith({
    List<Comentarios>? comentarios,
    List<Comentarios>? comentariosFiltrados,
    bool? isLoading,
    String? searchText,
    int? quantComentarios,
    int? maxComentarios,
    String? error,
    Map<String, ComentarioEditState>? editStates,
    bool? isCreatingNew,
    String? newCommentContent,
  }) {
    return ComentariosState(
      comentarios: comentarios ?? this.comentarios,
      comentariosFiltrados: comentariosFiltrados ?? this.comentariosFiltrados,
      isLoading: isLoading ?? this.isLoading,
      searchText: searchText ?? this.searchText,
      quantComentarios: quantComentarios ?? this.quantComentarios,
      maxComentarios: maxComentarios ?? this.maxComentarios,
      error: error ?? this.error,
      editStates: editStates ?? this.editStates,
      isCreatingNew: isCreatingNew ?? this.isCreatingNew,
      newCommentContent: newCommentContent ?? this.newCommentContent,
    );
  }
  
  /// Retorna o estado de edição de um comentário específico
  ComentarioEditState? getEditState(String comentarioId) {
    return editStates[comentarioId];
  }
  
  /// Verifica se um comentário está em modo de edição
  bool isEditingComentario(String comentarioId) {
    return editStates[comentarioId]?.isEditing ?? false;
  }
  
  /// Verifica se um comentário foi deletado
  bool isDeletedComentario(String comentarioId) {
    return editStates[comentarioId]?.isDeleted ?? false;
  }
}
