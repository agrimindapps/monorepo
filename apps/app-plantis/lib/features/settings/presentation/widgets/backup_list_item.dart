import 'package:flutter/material.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../../../../core/data/models/backup_model.dart';

/// Widget que representa um item da lista de backups
class BackupListItem extends StatelessWidget {
  final BackupInfo backup;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const BackupListItem({
    super.key,
    required this.backup,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com data e tamanho
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.cloud,
                    color: PlantisColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        backup.formattedSize,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu de ações
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'restore':
                        onRestore();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'restore',
                      child: Row(
                        children: [
                          Icon(
                            Icons.restore,
                            color: PlantisColors.leaf,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text('Restaurar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: theme.colorScheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text('Deletar'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Informações do backup
            Row(
              children: [
                _buildInfoChip(
                  context,
                  Icons.eco,
                  '${backup.metadata.plantsCount}',
                  'plantas',
                  PlantisColors.leaf,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  Icons.task_alt,
                  '${backup.metadata.tasksCount}',
                  'tarefas',
                  PlantisColors.secondary,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  Icons.location_on,
                  '${backup.metadata.spacesCount}',
                  'espaços',
                  PlantisColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestore,
                    icon: Icon(
                      Icons.restore,
                      size: 16,
                      color: PlantisColors.leaf,
                    ),
                    label: const Text('Restaurar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PlantisColors.leaf,
                      side: BorderSide(color: PlantisColors.leaf),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  ),
                  child: Icon(
                    Icons.delete,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um chip com informação
  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}