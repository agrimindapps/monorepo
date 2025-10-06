import 'package:flutter/material.dart';

import '../../../../core/data/models/backup_model.dart';
import '../../../../core/services/backup_restore_service.dart'
    show RestoreOptions, RestoreMergeStrategy;
import '../../../../core/theme/plantis_colors.dart';

/// Dialog para escolher opções de restauração do backup
class RestoreOptionsDialog extends StatefulWidget {
  final BackupInfo backup;
  final Function(RestoreOptions) onRestore;

  const RestoreOptionsDialog({
    super.key,
    required this.backup,
    required this.onRestore,
  });

  @override
  State<RestoreOptionsDialog> createState() => _RestoreOptionsDialogState();
}

class _RestoreOptionsDialogState extends State<RestoreOptionsDialog> {
  RestoreOptions options = const RestoreOptions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: PlantisColors.leaf.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.restore,
              color: PlantisColors.leaf,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text('Restaurar Backup'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.backup.formattedDate,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.backup.metadata.totalItems} itens • ${widget.backup.formattedSize}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoBadge(
                        Icons.eco,
                        widget.backup.metadata.plantsCount.toString(),
                        'plantas',
                        PlantisColors.leaf,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoBadge(
                        Icons.task_alt,
                        widget.backup.metadata.tasksCount.toString(),
                        'tarefas',
                        PlantisColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'O que deseja restaurar?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.backup.metadata.plantsCount > 0)
              _buildRestoreOption(
                icon: Icons.eco,
                title: 'Plantas',
                subtitle:
                    '${widget.backup.metadata.plantsCount} plantas serão restauradas',
                value: options.restorePlants,
                onChanged:
                    (value) => setState(() {
                      options = options.copyWith(restorePlants: value ?? false);
                    }),
                color: PlantisColors.leaf,
              ),

            if (widget.backup.metadata.tasksCount > 0)
              _buildRestoreOption(
                icon: Icons.task_alt,
                title: 'Tarefas',
                subtitle:
                    '${widget.backup.metadata.tasksCount} tarefas serão restauradas',
                value: options.restoreTasks,
                onChanged:
                    (value) => setState(() {
                      options = options.copyWith(restoreTasks: value);
                    }),
                color: PlantisColors.secondary,
              ),

            if (widget.backup.metadata.spacesCount > 0)
              _buildRestoreOption(
                icon: Icons.location_on,
                title: 'Espaços',
                subtitle:
                    '${widget.backup.metadata.spacesCount} espaços serão restaurados',
                value: options.restoreSpaces,
                onChanged:
                    (value) => setState(() {
                      options = options.copyWith(restoreSpaces: value);
                    }),
                color: PlantisColors.accent,
              ),

            _buildRestoreOption(
              icon: Icons.settings,
              title: 'Configurações',
              subtitle: 'Preferências e configurações do app',
              value: options.restoreSettings,
              onChanged:
                  (value) => setState(() {
                    options = options.copyWith(restoreSettings: value);
                  }),
              color: PlantisColors.primary,
            ),

            const SizedBox(height: 16),
            Text(
              'Como lidar com dados existentes?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            ...RestoreMergeStrategy.values.map(
              (strategy) => RadioListTile<RestoreMergeStrategy>(
                title: Text(_getStrategyTitle(strategy)),
                subtitle: Text(
                  _getStrategyDescription(strategy),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: strategy,
                groupValue: options.mergeStrategy,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      options = options.copyWith(mergeStrategy: value);
                    });
                  }
                },
                activeColor: PlantisColors.primary,
                contentPadding: EdgeInsets.zero,
                focusNode: FocusNode(skipTraversal: true),
              ),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A restauração pode demorar alguns minutos dependendo da quantidade de dados.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed:
              _hasSelectedOptions()
                  ? () {
                    widget.onRestore(options);
                  }
                  : null,
          icon: const Icon(Icons.restore),
          label: const Text('Restaurar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: PlantisColors.leaf,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Constrói um badge de informação
  Widget _buildInfoBadge(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói uma opção de restauração
  Widget _buildRestoreOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Color color,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      activeColor: color,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      focusNode: FocusNode(skipTraversal: true),
    );
  }

  /// Retorna o título da estratégia
  String _getStrategyTitle(RestoreMergeStrategy strategy) {
    switch (strategy) {
      case RestoreMergeStrategy.replace:
        return 'Substituir';
      case RestoreMergeStrategy.merge:
        return 'Combinar';
      case RestoreMergeStrategy.skip:
        return 'Pular Existentes';
    }
  }

  /// Retorna a descrição da estratégia
  String _getStrategyDescription(RestoreMergeStrategy strategy) {
    switch (strategy) {
      case RestoreMergeStrategy.replace:
        return 'Remove dados existentes e substitui pelos do backup';
      case RestoreMergeStrategy.merge:
        return 'Mantém dados existentes e adiciona os do backup';
      case RestoreMergeStrategy.skip:
        return 'Pula dados que já existem';
    }
  }

  /// Verifica se pelo menos uma opção foi selecionada
  bool _hasSelectedOptions() {
    return options.restorePlants ||
        options.restoreTasks ||
        options.restoreSpaces ||
        options.restoreSettings;
  }
}
