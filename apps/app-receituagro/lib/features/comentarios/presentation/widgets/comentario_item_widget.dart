import 'package:flutter/material.dart';

import '../../domain/entities/comentario_entity.dart';
import '../../utils/comentarios_date_formatter.dart';

/// **COMENTARIO ITEM WIDGET**
/// 
/// Individual comentario card widget with modern design.
/// Displays comentario information in a structured, accessible format.
/// 
/// ## Features:
/// 
/// - **Modern Card Design**: Elevated card with consistent shadows
/// - **Contextual Information**: Shows origin, timestamp, and content
/// - **Interactive Actions**: Tap to view, menu for delete
/// - **Status Awareness**: Different styling for active/inactive comentarios
/// - **Responsive Layout**: Adapts to different screen sizes and orientations

class ComentarioItemWidget extends StatelessWidget {
  final ComentarioEntity comentario;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ComentarioItemWidget({
    super.key,
    required this.comentario,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark),
            _buildContent(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _buildOriginIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: _buildHeaderText(isDark),
          ),
          _buildTimestamp(isDark),
          const SizedBox(width: 8),
          _buildActionMenu(isDark),
        ],
      ),
    );
  }

  Widget _buildOriginIcon() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        _getOriginIcon(),
        size: 16,
        color: const Color(0xFF4CAF50),
      ),
    );
  }

  IconData _getOriginIcon() {
    switch (comentario.ferramenta.toLowerCase()) {
      case 'defensivos':
        return Icons.shield_outlined;
      case 'pragas':
        return Icons.bug_report_outlined;
      case 'diagnóstico':
      case 'diagnósticos':
        return Icons.medical_services_outlined;
      case 'comentários':
      case 'comentário direto':
        return Icons.comment_outlined;
      default:
        return Icons.note_outlined;
    }
  }

  Widget _buildHeaderText(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comentario.ferramenta,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4CAF50),
          ),
        ),
        if (comentario.pkIdentificador.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            'ID: ${comentario.pkIdentificador}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimestamp(bool isDark) {
    return Text(
      ComentariosDateFormatter.formatRelativeDate(comentario.createdAt),
      style: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildActionMenu(bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 18,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Excluir',
                style: TextStyle(
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comentario.titulo.isNotEmpty && comentario.titulo != 'Comentário') ...[
            Text(
              comentario.titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            comentario.conteudo,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: isDark ? Colors.grey.shade200 : Colors.black87,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Factory constructor for preview mode (simplified display)
  static ComentarioItemWidget preview({
    required ComentarioEntity comentario,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return ComentarioItemWidget(
      comentario: comentario,
      onTap: onTap,
      onDelete: onDelete,
    );
  }

  /// Factory constructor for compact mode (reduced padding)
  static Widget compact({
    required ComentarioEntity comentario,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ComentarioItemWidget(
        comentario: comentario,
        onTap: onTap,
        onDelete: onDelete,
      ),
    );
  }
}