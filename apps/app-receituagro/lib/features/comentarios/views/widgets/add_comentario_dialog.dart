import 'package:flutter/material.dart';
import '../../constants/comentarios_design_tokens.dart';

class AddComentarioDialog extends StatefulWidget {
  final ValueChanged<String>? onSave;
  final String initialContent;

  const AddComentarioDialog({
    super.key,
    this.onSave,
    this.initialContent = '',
  });

  @override
  State<AddComentarioDialog> createState() => _AddComentarioDialogState();
}

class _AddComentarioDialogState extends State<AddComentarioDialog> {
  late TextEditingController _contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Novo Comentário'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ComentariosDesignTokens.maxDialogWidth,
          minHeight: 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digite seu comentário ou anotação:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Digite aqui sua anotação...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: ComentariosDesignTokens.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Mínimo de ${ComentariosDesignTokens.minCommentLength} caracteres',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: ComentariosDesignTokens.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  void _handleSave() async {
    final content = _contentController.text.trim();
    
    if (content.length < ComentariosDesignTokens.minCommentLength) {
      _showError(ComentariosDesignTokens.shortCommentError);
      return;
    }

    setState(() => _isSaving = true);

    try {
      widget.onSave?.call(content);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro ao salvar comentário');
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ComentariosDesignTokens.errorColor,
      ),
    );
  }
}