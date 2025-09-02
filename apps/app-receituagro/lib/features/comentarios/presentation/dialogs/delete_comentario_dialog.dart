import 'package:flutter/material.dart';

import '../../domain/entities/comentario_entity.dart';

/// **DELETE COMENTARIO DIALOG**
/// 
/// Confirmation dialog for comentario deletion with clear messaging.
/// Ensures users understand the permanent nature of the deletion.
/// 
/// ## Features:
/// 
/// - **Clear Warning**: Explains deletion is permanent
/// - **Context Information**: Shows which comentario will be deleted
/// - **Safe Design**: Requires explicit confirmation
/// - **Visual Hierarchy**: Important actions are clearly distinguished

class DeleteComentarioDialog extends StatelessWidget {
  final ComentarioEntity comentario;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const DeleteComentarioDialog({
    super.key,
    required this.comentario,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: _buildTitle(),
      content: _buildContent(theme),
      actions: _buildActions(context),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(
          Icons.warning_outlined,
          color: Colors.red.shade600,
          size: 24,
        ),
        const SizedBox(width: 12),
        const Text(
          'Excluir Comentário',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tem certeza que deseja excluir este comentário? Esta ação não pode ser desfeita.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildComentarioPreview(theme),
      ],
    );
  }

  Widget _buildComentarioPreview(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getOriginIcon(),
                size: 16,
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 8),
              Text(
                comentario.ferramenta,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          if (comentario.titulo.isNotEmpty && comentario.titulo != 'Comentário') ...[
            const SizedBox(height: 8),
            Text(
              comentario.titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            comentario.conteudo,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => _handleCancel(context),
        child: const Text('Cancelar'),
      ),
      TextButton(
        onPressed: () => _handleConfirm(context),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
        child: const Text(
          'Excluir',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ];
  }

  // ========================================================================
  // EVENT HANDLERS
  // ========================================================================

  void _handleCancel(BuildContext context) {
    onCancel?.call();
    Navigator.of(context).pop();
  }

  void _handleConfirm(BuildContext context) {
    Navigator.of(context).pop();
    onConfirm();
  }

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

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

  // ========================================================================
  // FACTORY CONSTRUCTORS
  // ========================================================================

  /// Factory constructor with confirmation callback
  static DeleteComentarioDialog withConfirmation({
    required ComentarioEntity comentario,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return DeleteComentarioDialog(
      comentario: comentario,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Factory constructor for simple deletion
  static DeleteComentarioDialog simple({
    required ComentarioEntity comentario,
    required VoidCallback onConfirm,
  }) {
    return DeleteComentarioDialog(
      comentario: comentario,
      onConfirm: onConfirm,
    );
  }
}