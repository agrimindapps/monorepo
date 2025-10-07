import 'package:flutter/material.dart';

import '../../constants/comentarios_design_tokens.dart';

/// **ADD COMENTARIO DIALOG**
///
/// Modal dialog for creating new comentarios with comprehensive validation.
/// Follows Material Design guidelines and app-receituagro design system.
///
/// ## Features:
///
/// - **Smart Validation**: Real-time content validation
/// - **Character Limits**: Visual feedback for min/max limits
/// - **Context Display**: Shows origin information when available
/// - **Responsive Design**: Adapts to different screen sizes
/// - **Accessibility**: Full accessibility support

class AddComentarioDialog extends StatefulWidget {
  final String? origem;
  final String? itemName;
  final String? pkIdentificador;
  final String? ferramenta;
  final Future<void> Function(String content) onSave;
  final VoidCallback? onCancel;

  const AddComentarioDialog({
    super.key,
    this.origem,
    this.itemName,
    this.pkIdentificador,
    this.ferramenta,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<AddComentarioDialog> createState() => _AddComentarioDialogState();
}

class _AddComentarioDialogState extends State<AddComentarioDialog> {
  final TextEditingController _commentController = TextEditingController();
  final ValueNotifier<String> _contentNotifier = ValueNotifier<String>('');
  bool _isSaving = false;

  static const int _maxLength = ComentariosDesignTokens.maxCommentLength;
  static const int _minLength = ComentariosDesignTokens.minCommentLength;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _commentController.removeListener(_onContentChanged);
    _commentController.dispose();
    _contentNotifier.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (mounted) {
      _contentNotifier.value = _commentController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ComentariosDesignTokens.dialogBorderRadius,
        ),
      ),
      insetPadding: ComentariosDesignTokens.defaultPadding,
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(
          maxHeight: ComentariosDesignTokens.maxDialogHeight,
        ),
        decoration: BoxDecoration(
          color:
              isDark
                  ? ComentariosDesignTokens.dialogBackgroundDark
                  : Colors.white,
          borderRadius: BorderRadius.circular(
            ComentariosDesignTokens.dialogBorderRadius,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(theme, isDark),
            if (_hasOriginInfo()) _buildOriginInfo(theme, isDark),
            Expanded(child: _buildContentSection(theme, isDark)),
            _buildActionButtons(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 12, top: 12, bottom: 8),
      decoration: BoxDecoration(
        color:
            isDark
                ? ComentariosDesignTokens.dialogHeaderDark
                : ComentariosDesignTokens.dialogHeaderLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ComentariosDesignTokens.dialogBorderRadius),
          topRight: Radius.circular(ComentariosDesignTokens.dialogBorderRadius),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderIcon(),
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
          _buildCloseButton(isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
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
    );
  }

  Widget _buildCloseButton(bool isDark) {
    return IconButton(
      onPressed: _handleCancel,
      icon: Icon(
        Icons.close,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      tooltip: 'Fechar',
    );
  }

  Widget _buildOriginInfo(ThemeData theme, bool isDark) {
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
          if (widget.origem != null) _buildOriginRow(theme),
          if (widget.itemName != null) _buildItemNameRow(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildOriginRow(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_getOriginIcon(), size: 16, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 6),
        Text(
          widget.origem!,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildItemNameRow(ThemeData theme, bool isDark) {
    return Padding(
      padding:
          widget.origem != null
              ? const EdgeInsets.only(top: 4)
              : EdgeInsets.zero,
      child: Row(
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
    );
  }

  Widget _buildContentSection(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentLabel(theme, isDark),
          const SizedBox(height: 16),
          Expanded(child: _buildTextField(isDark)),
          const SizedBox(height: 8),
          _buildCharacterCounter(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildContentLabel(ThemeData theme, bool isDark) {
    return Text(
      'Comentário',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField(bool isDark) {
    return TextField(
      controller: _commentController,
      maxLines: null,
      expands: true,
      maxLength: _maxLength,
      autofocus: true,
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
        border: _buildInputBorder(isDark, false),
        enabledBorder: _buildInputBorder(isDark, false),
        focusedBorder: _buildInputBorder(isDark, true),
        contentPadding: const EdgeInsets.all(16.0),
        counterText: '', // Hide default counter
      ),
    );
  }

  OutlineInputBorder _buildInputBorder(bool isDark, bool isFocused) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color:
            isFocused
                ? const Color(0xFF4CAF50)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        width: isFocused ? 2 : 1,
      ),
    );
  }

  Widget _buildCharacterCounter(ThemeData theme, bool isDark) {
    return ValueListenableBuilder<String>(
      valueListenable: _contentNotifier,
      builder: (context, content, child) {
        final length = content.length;
        final isOverLimit = length > _maxLength;

        return Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$length/$_maxLength',
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  isOverLimit
                      ? Colors.red
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: ValueListenableBuilder<String>(
        valueListenable: _contentNotifier,
        builder: (context, content, child) {
          final trimmedContent = content.trim();
          final canSave =
              trimmedContent.length >= _minLength &&
              trimmedContent.length <= _maxLength &&
              !_isSaving;

          return Row(
            children: [
              Expanded(child: _buildCancelButton(isDark)),
              const SizedBox(width: 16),
              Expanded(child: _buildSaveButton(canSave, trimmedContent)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCancelButton(bool isDark) {
    return OutlinedButton.icon(
      onPressed: _isSaving ? null : _handleCancel,
      icon: const Icon(Icons.close, size: 18),
      label: const Text(
        'Cancelar',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        side: BorderSide(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSaveButton(bool canSave, String trimmedContent) {
    return ElevatedButton.icon(
      onPressed: canSave ? () => _handleSave(trimmedContent) : null,
      icon:
          _isSaving
              ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.check, size: 18),
      label: Text(
        _isSaving ? 'Salvando...' : 'Salvar',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        disabledForegroundColor: Colors.grey.shade600,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  void _handleCancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  Future<void> _handleSave(String content) async {
    setState(() => _isSaving = true);

    try {
      await widget.onSave(content);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar comentário: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _hasOriginInfo() {
    return widget.origem != null || widget.itemName != null;
  }

  IconData _getOriginIcon() {
    if (widget.origem == null) return Icons.comment_outlined;

    switch (widget.origem!.toLowerCase()) {
      case 'defensivos':
        return Icons.shield_outlined;
      case 'pragas':
        return Icons.bug_report_outlined;
      case 'diagnóstico':
      case 'diagnósticos':
        return Icons.medical_services_outlined;
      case 'comentários':
        return Icons.comment_outlined;
      default:
        return Icons.comment_outlined;
    }
  }
}
