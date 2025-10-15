import 'package:flutter/material.dart';
import '../../domain/entities/item_master_entity.dart';
import '../../domain/entities/list_item_entity.dart' as entities;

/// Tile widget displaying a ListItem in a list
/// Shows checkbox, item name, quantity, priority indicator, and swipe-to-delete
class ListItemTile extends StatelessWidget {
  final entities.ListItemEntity listItem;
  final ItemMasterEntity? itemMaster;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const ListItemTile({
    super.key,
    required this.listItem,
    required this.itemMaster,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(listItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              color: theme.colorScheme.onError,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'Remover',
              style: TextStyle(
                color: theme.colorScheme.onError,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remover item'),
            content: Text(
              'Tem certeza que deseja remover "${itemMaster?.name ?? 'este item'}" da lista?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: const Text('Remover'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        onDelete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Item "${itemMaster?.name ?? 'removido'}" removido da lista',
            ),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                // TODO: Implement undo (would need to store deleted item)
              },
            ),
          ),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Checkbox(
          value: listItem.isCompleted,
          onChanged: (_) => onToggleComplete?.call(),
        ),
        title: Text(
          itemMaster?.name ?? 'Carregando...',
          style: listItem.isCompleted
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                )
              : null,
        ),
        subtitle: _buildSubtitle(theme),
        trailing: _buildPriorityIndicator(theme),
        onTap: onToggleComplete,
      ),
    );
  }

  /// Build subtitle with quantity and notes
  Widget? _buildSubtitle(ThemeData theme) {
    final subtitleParts = <String>[];

    // Add quantity
    if (listItem.quantity.isNotEmpty && listItem.quantity != '1') {
      subtitleParts.add('Qtd: ${listItem.quantity}');
    }

    // Add notes
    if (listItem.hasNotes) {
      subtitleParts.add(listItem.notes!);
    }

    // Add item description if available
    if (itemMaster != null && itemMaster!.description.isNotEmpty) {
      subtitleParts.add(itemMaster!.description);
    }

    if (subtitleParts.isEmpty) return null;

    return Text(
      subtitleParts.join(' • '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: listItem.isCompleted
          ? TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            )
          : null,
    );
  }

  /// Build priority indicator based on priority level
  Widget _buildPriorityIndicator(ThemeData theme) {
    late Color color;
    late IconData icon;
    late String tooltip;

    switch (listItem.priority) {
      case entities.Priority.urgent:
        color = const Color(0xFFF44336); // Red
        icon = Icons.priority_high;
        tooltip = 'Urgente';
        break;
      case entities.Priority.high:
        color = const Color(0xFFFF9800); // Orange
        icon = Icons.arrow_upward;
        tooltip = 'Alta';
        break;
      case entities.Priority.normal:
        color = const Color(0xFF9E9E9E); // Grey
        icon = Icons.remove;
        tooltip = 'Normal';
        break;
      case entities.Priority.low:
        color = const Color(0xFF4CAF50); // Green
        icon = Icons.arrow_downward;
        tooltip = 'Baixa';
        break;
    }

    // Don't show indicator for completed items or normal priority
    if (listItem.isCompleted || listItem.priority == entities.Priority.normal) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}
