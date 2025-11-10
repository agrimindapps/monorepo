import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/spaces_providers.dart';
import '../../domain/usecases/spaces_usecases.dart';

class SpaceHeaderWidget extends ConsumerStatefulWidget {
  final String? spaceId;
  final String spaceName;
  final int plantCount;
  final VoidCallback? onEdit;

  const SpaceHeaderWidget({
    super.key,
    this.spaceId,
    required this.spaceName,
    required this.plantCount,
    this.onEdit,
  });

  @override
  ConsumerState<SpaceHeaderWidget> createState() => _SpaceHeaderWidgetState();
}

class _SpaceHeaderWidgetState extends ConsumerState<SpaceHeaderWidget> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.spaceName);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8, top: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getSpaceIcon(widget.spaceName),
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),
          Expanded(
            child:
                _isEditing
                    ? _buildEditingField(theme)
                    : _buildDisplayName(theme),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.plantCount}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.spaceId != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isEditing ? _saveEdit : _startEditing,
              icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 18),
              tooltip: _isEditing ? 'Salvar' : 'Editar nome',
              visualDensity: VisualDensity.compact,
            ),
            if (_isEditing)
              IconButton(
                onPressed: _cancelEdit,
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Cancelar',
                visualDensity: VisualDensity.compact,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDisplayName(ThemeData theme) {
    return GestureDetector(
      onTap: widget.spaceId != null ? _startEditing : null,
      child: Text(
        widget.spaceName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildEditingField(ThemeData theme) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
      onFieldSubmitted: (_) => _saveEdit(),
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _controller.text = widget.spaceName;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _controller.text = widget.spaceName;
    });
  }

  Future<void> _saveEdit() async {
    final newName = _controller.text.trim();

    if (newName.isEmpty) {
      _showError('Nome não pode estar vazio');
      return;
    }

    if (newName == widget.spaceName) {
      _cancelEdit();
      return;
    }

    if (widget.spaceId == null) {
      _cancelEdit();
      return;
    }

    try {
      final spacesNotifier = ref.read(spacesNotifierProvider.notifier);
      final spacesState = ref.read(spacesNotifierProvider);
      final existingSpace = spacesState.maybeWhen(
        data: (state) => state.findSpaceByName(newName),
        orElse: () => null,
      );

      if (existingSpace != null && existingSpace.id != widget.spaceId) {
        _showError('Já existe um espaço com esse nome');
        return;
      }

      final success = await spacesNotifier.updateSpace(
        UpdateSpaceParams(id: widget.spaceId!, name: newName),
      );

      if (success && mounted) {
        setState(() => _isEditing = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nome do espaço atualizado para "$newName"'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onEdit?.call();
      } else if (mounted) {
        _showError('Erro ao atualizar nome do espaço');
      }
    } catch (e) {
      _showError('Erro inesperado: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  IconData _getSpaceIcon(String spaceName) {
    final name = spaceName.toLowerCase();

    if (name.contains('jardim') || name.contains('garden')) {
      return Icons.yard;
    } else if (name.contains('varanda') || name.contains('balcon')) {
      return Icons.balcony;
    } else if (name.contains('sala') || name.contains('living')) {
      return Icons.weekend;
    } else if (name.contains('quarto') || name.contains('bedroom')) {
      return Icons.bed;
    } else if (name.contains('cozinha') || name.contains('kitchen')) {
      return Icons.kitchen;
    } else if (name.contains('banheiro') || name.contains('bathroom')) {
      return Icons.bathroom;
    } else if (name.contains('escritório') || name.contains('office')) {
      return Icons.desk;
    } else if (name.contains('externa') ||
        name.contains('outside') ||
        name.contains('outdoor')) {
      return Icons.nature;
    } else {
      return Icons.location_on;
    }
  }
}
