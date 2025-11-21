import 'package:flutter/material.dart';

import '../constants/comentarios_design_tokens.dart';
import 'comentarios_helpers.dart';

/// Dialog para adicionar comentário
///
/// Responsabilidades:
/// - Form de comentário com validação
/// - Contador de caracteres
/// - Info de origem e contexto
/// - Ações de salvar/cancelar
class AddCommentDialogWidget extends StatefulWidget {
  final String? origem;
  final String? itemName;
  final String? pkIdentificador;
  final String? ferramenta;
  final Future<void> Function(String content)? onSave;
  final VoidCallback? onCancel;

  const AddCommentDialogWidget({
    super.key,
    this.origem,
    this.itemName,
    this.pkIdentificador,
    this.ferramenta,
    this.onSave,
    this.onCancel,
  });

  @override
  State<AddCommentDialogWidget> createState() => _AddCommentDialogWidgetState();
}

class _AddCommentDialogWidgetState extends State<AddCommentDialogWidget> {
  final TextEditingController _commentController = TextEditingController();
  final ValueNotifier<String> _contentNotifier = ValueNotifier<String>('');
  static const int _maxLength = ComentariosDesignTokens.maxCommentLength;
  static const int _minLength = ComentariosDesignTokens.minCommentLength;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (mounted) {
      _contentNotifier.value = _commentController.text;
    }
  }

  @override
  void dispose() {
    _commentController.removeListener(_onContentChanged);
    _commentController.dispose();
    _contentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ComentariosDesignTokens.dialogBorderRadius),
      ),
      insetPadding: ComentariosDesignTokens.defaultPadding,
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: ComentariosDesignTokens.maxDialogHeight),
        decoration: BoxDecoration(
          color: isDark ? ComentariosDesignTokens.dialogBackgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(ComentariosDesignTokens.dialogBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, theme, isDark),
            if (widget.origem != null || widget.itemName != null)
              _buildOriginInfo(context, theme, isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: _buildCommentForm(theme, isDark),
              ),
            ),
            _buildActions(context, theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 12, top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? ComentariosDesignTokens.dialogHeaderDark : ComentariosDesignTokens.dialogHeaderLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ComentariosDesignTokens.dialogBorderRadius),
          topRight: Radius.circular(ComentariosDesignTokens.dialogBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ComentariosDesignTokens.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add,
              color: ComentariosDesignTokens.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Adicionar Comentário',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildOriginInfo(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.origem != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  ComentariosHelpers.getOriginIcon(widget.origem!),
                  size: 16,
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.origem!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          if (widget.itemName != null) ...[
            if (widget.origem != null) const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.label_outline,
                  size: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.itemName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentForm(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Comentário',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Semantics(
            label: 'Campo de texto para comentário',
            hint: 'Digite seu comentário aqui, mínimo $_minLength caracteres, máximo $_maxLength caracteres',
            textField: true,
            child: TextField(
              controller: _commentController,
              maxLines: null,
              expands: true,
              maxLength: _maxLength,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Digite seu comentário aqui...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4CAF50),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(8.0),
                counterText: '',
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: _contentNotifier,
          builder: (context, content, child) {
            return Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${content.length}/$_maxLength',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: content.length > _maxLength
                      ? Colors.red
                      : isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: ValueListenableBuilder<String>(
        valueListenable: _contentNotifier,
        builder: (context, content, child) {
          final trimmedContent = content.trim();
          final canSave = trimmedContent.length >= _minLength &&
                         trimmedContent.length <= _maxLength;

          return Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Botão cancelar',
                  hint: 'Cancela a criação do comentário e fecha o diálogo',
                  button: true,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                    ),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      side: BorderSide(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Semantics(
                  label: 'Botão salvar comentário',
                  hint: canSave
                      ? 'Salva o comentário e fecha o diálogo'
                      : 'Comentário deve ter entre $_minLength e $_maxLength caracteres',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: canSave ? () => _saveComment(context, trimmedContent) : null,
                    icon: const Icon(
                      Icons.check,
                      size: 18,
                    ),
                    label: const Text(
                      'Salvar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      disabledForegroundColor: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveComment(BuildContext context, String content) async {
    if (widget.onSave != null) {
      String contentToSave = content;
      if (content.length < _minLength) {
        contentToSave = content.padRight(_minLength, ' ');
      }

      try {
        await widget.onSave!(contentToSave);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar comentário: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
