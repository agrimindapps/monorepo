import 'comentario_edit_state.dart';
import 'comentario_model.dart';

class ComentariosState {
  final List<ComentarioModel> comentarios;
  final List<ComentarioModel> comentariosFiltrados;
  final bool isLoading;
  final String searchText;
  final int quantComentarios;
  final int maxComentarios;
  final String? error;
  final Map<String, ComentarioEditState> editStates;
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
    List<ComentarioModel>? comentarios,
    List<ComentarioModel>? comentariosFiltrados,
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
      error: error,
      editStates: editStates ?? this.editStates,
      isCreatingNew: isCreatingNew ?? this.isCreatingNew,
      newCommentContent: newCommentContent ?? this.newCommentContent,
    );
  }

  ComentarioEditState? getEditState(String comentarioId) {
    return editStates[comentarioId];
  }

  bool isEditingComentario(String comentarioId) {
    return editStates[comentarioId]?.isEditing ?? false;
  }

  bool isDeletedComentario(String comentarioId) {
    return editStates[comentarioId]?.isDeleted ?? false;
  }

  bool isSavingComentario(String comentarioId) {
    return editStates[comentarioId]?.isSaving ?? false;
  }

  bool get canAddComentario => quantComentarios < maxComentarios;
  bool get hasReachedLimit => quantComentarios >= maxComentarios && maxComentarios > 0;
  bool get hasNoPermission => maxComentarios == 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComentariosState &&
        other.comentarios == comentarios &&
        other.isLoading == isLoading &&
        other.searchText == searchText &&
        other.quantComentarios == quantComentarios &&
        other.maxComentarios == maxComentarios &&
        other.error == error &&
        other.isCreatingNew == isCreatingNew;
  }

  @override
  int get hashCode {
    return comentarios.hashCode ^
        isLoading.hashCode ^
        searchText.hashCode ^
        quantComentarios.hashCode ^
        maxComentarios.hashCode ^
        error.hashCode ^
        isCreatingNew.hashCode;
  }

  @override
  String toString() {
    return 'ComentariosState(comentarios: ${comentarios.length}, isLoading: $isLoading, searchText: $searchText, canAdd: $canAddComentario)';
  }
}
