import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../domain/entities/space.dart';

class SpaceListTile extends StatelessWidget {
  final Space space;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SpaceListTile({
    super.key,
    required this.space,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getSpaceTypeColor(space.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: space.imageBase64 != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    Uint8List.fromList(Uri.dataFromString(space.imageBase64!).data?.contentAsBytes() ?? []),
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  _getSpaceTypeIcon(space.type),
                  color: _getSpaceTypeColor(space.type),
                  size: 32,
                ),
        ),
        title: Text(
          space.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            
            // Space Type
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getSpaceTypeColor(space.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                space.type.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getSpaceTypeColor(space.type),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Description
            if (space.description != null && space.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                space.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Config Info
            if (space.config != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                children: [
                  if (space.config!.temperature != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thermostat,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${space.config!.temperature}°C',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  if (space.config!.humidity != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${space.config!.humidity}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  if (space.config!.lightLevel != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getLightLevelDisplay(space.config!.lightLevel!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  if (space.config!.maxPlants != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_florist,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${space.config!.maxPlants} plantas',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
        trailing: (onEdit != null || onDelete != null)
            ? PopupMenuButton(
                itemBuilder: (context) => [
                  if (onEdit != null)
                    PopupMenuItem(
                      value: 'edit',
                      child: const Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: const Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('Excluir'),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Color _getSpaceTypeColor(SpaceType type) {
    switch (type) {
      case SpaceType.indoor:
        return Colors.blue;
      case SpaceType.outdoor:
        return Colors.green;
      case SpaceType.greenhouse:
        return Colors.teal;
      case SpaceType.balcony:
        return Colors.orange;
      case SpaceType.garden:
        return Colors.lightGreen;
      case SpaceType.room:
        return Colors.purple;
      case SpaceType.kitchen:
        return Colors.red;
      case SpaceType.bathroom:
        return Colors.cyan;
      case SpaceType.office:
        return Colors.indigo;
    }
  }

  IconData _getSpaceTypeIcon(SpaceType type) {
    switch (type) {
      case SpaceType.indoor:
        return Icons.home;
      case SpaceType.outdoor:
        return Icons.nature;
      case SpaceType.greenhouse:
        return Icons.agriculture;
      case SpaceType.balcony:
        return Icons.balcony;
      case SpaceType.garden:
        return Icons.park;
      case SpaceType.room:
        return Icons.bed;
      case SpaceType.kitchen:
        return Icons.kitchen;
      case SpaceType.bathroom:
        return Icons.bathroom;
      case SpaceType.office:
        return Icons.business;
    }
  }

  String _getLightLevelDisplay(String lightLevel) {
    switch (lightLevel.toLowerCase()) {
      case 'low':
        return 'Pouca luz';
      case 'medium':
        return 'Luz média';
      case 'high':
        return 'Muita luz';
      default:
        return lightLevel;
    }
  }
}