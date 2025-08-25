import 'package:flutter/material.dart';

import '../../constants/comentarios_design_tokens.dart';
import '../../constants/comentarios_strings.dart';
import '../../models/comentario_edit_state.dart';
import '../../models/comentario_model.dart';

class ComentarioCard extends StatefulWidget {
  final ComentarioModel comentario;
  final ComentarioEditState? editState;
  final ValueChanged<String>? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStartEdit;
  final VoidCallback? onCancelEdit;
  final ValueChanged<String>? onContentChanged;

  const ComentarioCard({
    super.key,
    required this.comentario,
    this.editState,
    this.onEdit,
    this.onDelete,
    this.onStartEdit,
    this.onCancelEdit,
    this.onContentChanged,
  });

  @override
  State<ComentarioCard> createState() => _ComentarioCardState();
}

class _ComentarioCardState extends State<ComentarioCard> {
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(
      text: widget.editState?.currentContent ?? widget.comentario.conteudo,
    );
  }

  @override
  void didUpdateWidget(ComentarioCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editState != oldWidget.editState) {
      _editController.text = widget.editState?.currentContent ?? widget.comentario.conteudo;
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.editState?.isEditing ?? false;
    final isSaving = widget.editState?.isSaving ?? false;
    final formattedDate = _formatDate(widget.comentario.createdAt);

    return Semantics(
      label: ComentariosStrings.a11yCommentCard(widget.comentario.ferramenta, formattedDate),
      hint: ComentariosStrings.a11yCommentCardHint,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: ComentariosDesignTokens.getCardDecoration(context),
        child: Padding(
          padding: ComentariosDesignTokens.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 12),
              _buildContent(theme, isEditing),
              if (isEditing) ...[
                const SizedBox(height: 12),
                _buildEditActions(isSaving),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Semantics(
          label: ComentariosStrings.a11yToolBadge(widget.comentario.ferramenta),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ComentariosDesignTokens.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.comentario.ferramenta,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ComentariosDesignTokens.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const Spacer(),
        Semantics(
          label: ComentariosStrings.a11yCreationDate(_formatDateForAccessibility(widget.comentario.createdAt)),
          child: Text(
            _formatDate(widget.comentario.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildActionMenu(),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, bool isEditing) {
    if (isEditing) {
      return Semantics(
        label: ComentariosStrings.a11yEditField,
        hint: ComentariosStrings.a11yEditFieldHint,
        child: TextField(
          controller: _editController,
          onChanged: widget.onContentChanged,
          maxLines: null,
          decoration: InputDecoration(
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
            labelText: ComentariosStrings.fieldLabelContent,
          ),
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Semantics(
      label: ComentariosStrings.a11yContent,
      child: Text(
        widget.comentario.conteudo,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildEditActions(bool isSaving) {
    return Semantics(
      label: 'Ações de edição do comentário',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Semantics(
            label: ComentariosStrings.a11yCancelButton,
            hint: ComentariosStrings.a11yCancelButtonHint,
            child: TextButton.icon(
              onPressed: isSaving ? null : widget.onCancelEdit,
              icon: const Icon(ComentariosDesignTokens.cancelIcon),
              label: const Text(ComentariosStrings.buttonCancel),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: isSaving ? ComentariosStrings.statusSaving : ComentariosStrings.a11ySaveButton,
            hint: ComentariosStrings.a11ySaveButtonHint,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : () {
                widget.onEdit?.call(_editController.text);
              },
              icon: isSaving 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(ComentariosDesignTokens.saveIcon),
              label: Text(isSaving ? ComentariosStrings.statusSaving : ComentariosStrings.buttonSave),
              style: ElevatedButton.styleFrom(
                backgroundColor: ComentariosDesignTokens.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu() {
    return Semantics(
      label: ComentariosStrings.a11yActionsMenu,
      hint: ComentariosStrings.a11yActionsMenuHint,
      child: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              widget.onStartEdit?.call();
              break;
            case 'delete':
              widget.onDelete?.call();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Semantics(
              label: ComentariosStrings.a11yEditAction,
              hint: ComentariosStrings.a11yEditActionHint,
              child: const Row(
                children: [
                  Icon(ComentariosDesignTokens.editIcon),
                  SizedBox(width: 8),
                  Text(ComentariosStrings.buttonEdit),
                ],
              ),
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Semantics(
              label: ComentariosStrings.a11yDeleteAction,
              hint: ComentariosStrings.a11yDeleteActionHint,
              child: const Row(
                children: [
                  Icon(ComentariosDesignTokens.deleteIcon, color: Colors.red),
                  SizedBox(width: 8),
                  Text(ComentariosStrings.buttonDelete, style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min atrás';
    } else {
      return ComentariosStrings.timeNow;
    }
  }

  String _formatDateForAccessibility(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      return days == 1 ? ComentariosStrings.timeDayAgo : ComentariosStrings.timeDaysAgo(days);
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      return hours == 1 ? ComentariosStrings.timeHourAgo : ComentariosStrings.timeHoursAgo(hours);
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return minutes == 1 ? ComentariosStrings.timeMinuteAgo : ComentariosStrings.timeMinutesAgo(minutes);
    } else {
      return ComentariosStrings.timeNow;
    }
  }
}