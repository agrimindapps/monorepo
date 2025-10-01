class ComentarioEditState {
  final String comentarioId;
  final bool isEditing;
  final String currentContent;
  final bool isDeleted;
  final bool isSaving;

  const ComentarioEditState({
    required this.comentarioId,
    this.isEditing = false,
    this.currentContent = '',
    this.isDeleted = false,
    this.isSaving = false,
  });

  ComentarioEditState copyWith({
    String? comentarioId,
    bool? isEditing,
    String? currentContent,
    bool? isDeleted,
    bool? isSaving,
  }) {
    return ComentarioEditState(
      comentarioId: comentarioId ?? this.comentarioId,
      isEditing: isEditing ?? this.isEditing,
      currentContent: currentContent ?? this.currentContent,
      isDeleted: isDeleted ?? this.isDeleted,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComentarioEditState &&
        other.comentarioId == comentarioId &&
        other.isEditing == isEditing &&
        other.currentContent == currentContent &&
        other.isDeleted == isDeleted &&
        other.isSaving == isSaving;
  }

  @override
  int get hashCode {
    return comentarioId.hashCode ^
        isEditing.hashCode ^
        currentContent.hashCode ^
        isDeleted.hashCode ^
        isSaving.hashCode;
  }

  @override
  String toString() {
    return 'ComentarioEditState(comentarioId: $comentarioId, isEditing: $isEditing, isSaving: $isSaving, isDeleted: $isDeleted)';
  }
}