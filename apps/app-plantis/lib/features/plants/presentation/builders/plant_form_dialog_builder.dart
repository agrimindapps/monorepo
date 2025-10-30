import 'package:flutter/material.dart';

/// Builds UI components for plant form dialogs
class PlantFormDialogBuilder {
  /// Build discard changes confirmation dialog
  static Widget buildDiscardDialog({
    required List<String> changes,
    required VoidCallback onDiscard,
    required VoidCallback onCancel,
  }) {
    return AlertDialog(
      title: const Text('Descartar alterações?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Você tem alterações não salvas que serão perdidas:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ..._buildChangesList(changes),
            const SizedBox(height: 16),
            const Text(
              'Deseja realmente sair sem salvar?',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        TextButton(
          onPressed: onDiscard,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Descartar'),
        ),
      ],
    );
  }

  /// Build list of changes
  static List<Widget> _buildChangesList(List<String> changes) {
    final displayChanges = changes.take(4).toList();
    final remainingCount = changes.length - displayChanges.length;
    final theme = ThemeData.light();

    final widgets = <Widget>[];

    for (final change in displayChanges) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  change,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (remainingCount > 0) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.more_horiz,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'e mais $remainingCount configuração${remainingCount > 1 ? 'ões' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }
}
