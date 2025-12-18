import 'package:flutter/material.dart';
import '../../domain/entities/list_entity.dart';

/// Card widget displaying a list
/// Shows list name, description, completion progress, and actions
class ListCard extends StatelessWidget {
  final ListEntity list;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onSetReminder;

  const ListCard({
    super.key,
    required this.list,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
    this.onSetReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with favorite icon
            Container(
              padding: const EdgeInsets.all(12),
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      list.isFavorite ? Icons.star : Icons.star_border,
                      color: list.isFavorite ? Colors.amber : null,
                    ),
                    onPressed: onToggleFavorite,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    if (list.description.isNotEmpty)
                      Text(
                        list.description,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const Spacer(),

                    // Stats
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${list.completedCount}/${list.itemCount}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: list.itemCount > 0
                            ? list.completedCount / list.itemCount
                            : 0,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            OverflowBar(
              alignment: MainAxisAlignment.start,
              children: [
                if (onSetReminder != null)
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: onSetReminder,
                    tooltip: 'Definir Lembrete',
                    iconSize: 20,
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  tooltip: 'Arquivar',
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
