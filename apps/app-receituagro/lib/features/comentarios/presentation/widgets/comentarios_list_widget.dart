import 'package:flutter/material.dart';

import '../../domain/entities/comentario_entity.dart';
import 'comentario_item_widget.dart';

/// **COMENTARIOS LIST WIDGET**
/// 
/// Displays a scrollable list of comentarios with optimized performance.
/// Handles the rendering of individual comentario cards in a ListView.
/// 
/// ## Features:
/// 
/// - **Performance Optimized**: Uses ListView.builder for large lists
/// - **Custom Spacing**: Consistent spacing between items
/// - **Delegate Pattern**: Delegates item interactions to parent
/// - **Accessibility**: Proper semantic structure for screen readers
/// - **Responsive Design**: Adapts to different screen sizes

class ComentariosListWidget extends StatelessWidget {
  final List<ComentarioEntity> comentarios;
  final Function(ComentarioEntity) onComentarioTap;
  final Function(ComentarioEntity) onComentarioDelete;
  final ScrollController? scrollController;
  final EdgeInsets? padding;

  const ComentariosListWidget({
    super.key,
    required this.comentarios,
    required this.onComentarioTap,
    required this.onComentarioDelete,
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (comentarios.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: scrollController,
      padding: padding ?? const EdgeInsets.all(16.0),
      itemCount: comentarios.length,
      itemBuilder: (context, index) => _buildComentarioItem(context, index),
    );
  }

  Widget _buildComentarioItem(BuildContext context, int index) {
    final comentario = comentarios[index];
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: index < comentarios.length - 1 ? 12.0 : 0.0,
      ),
      child: ComentarioItemWidget(
        comentario: comentario,
        onTap: () => onComentarioTap(comentario),
        onDelete: () => onComentarioDelete(comentario),
      ),
    );
  }

  /// Factory constructor for optimized performance
  static ComentariosListWidget optimized({
    required List<ComentarioEntity> comentarios,
    required Function(ComentarioEntity) onComentarioTap,
    required Function(ComentarioEntity) onComentarioDelete,
    ScrollController? scrollController,
  }) {
    return ComentariosListWidget(
      comentarios: comentarios,
      onComentarioTap: onComentarioTap,
      onComentarioDelete: onComentarioDelete,
      scrollController: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }

  /// Factory constructor for compact display
  static ComentariosListWidget compact({
    required List<ComentarioEntity> comentarios,
    required Function(ComentarioEntity) onComentarioTap,
    required Function(ComentarioEntity) onComentarioDelete,
  }) {
    return ComentariosListWidget(
      comentarios: comentarios,
      onComentarioTap: onComentarioTap,
      onComentarioDelete: onComentarioDelete,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    );
  }
}
