import 'package:flutter/material.dart';
import 'comentario_card.dart';
import 'empty_comments_state.dart';
import '../../models/comentario_model.dart';
import '../../models/comentario_edit_state.dart';

class CommentsListWidget extends StatelessWidget {
  final List<ComentarioModel> comentarios;
  final Map<String, ComentarioEditState> editStates;
  final ValueChanged<ComentarioModel>? onStartEdit;
  final Function(ComentarioModel, String)? onEdit;
  final ValueChanged<ComentarioModel>? onDelete;
  final ValueChanged<String>? onCancelEdit;
  final Function(String, String)? onContentChanged;

  const CommentsListWidget({
    super.key,
    required this.comentarios,
    required this.editStates,
    this.onStartEdit,
    this.onEdit,
    this.onDelete,
    this.onCancelEdit,
    this.onContentChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (comentarios.isEmpty) {
      return const EmptyCommentsState();
    }

    return ListView.builder(
      itemCount: comentarios.length,
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemBuilder: (context, index) {
        final comentario = comentarios[index];
        final editState = editStates[comentario.id];

        return ComentarioCard(
          comentario: comentario,
          editState: editState,
          onStartEdit: () => onStartEdit?.call(comentario),
          onEdit: (content) => onEdit?.call(comentario, content),
          onDelete: () => onDelete?.call(comentario),
          onCancelEdit: () => onCancelEdit?.call(comentario.id),
          onContentChanged: (content) => onContentChanged?.call(comentario.id, content),
        );
      },
    );
  }
}