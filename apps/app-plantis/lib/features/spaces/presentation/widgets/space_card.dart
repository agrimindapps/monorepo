import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../domain/entities/space.dart';

class SpaceCard extends StatelessWidget {
  final Space space;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SpaceCard({
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getSpaceTypeColor(space.type).withValues(alpha: 0.1),
              ),
              child: space.imageBase64 != null
                  ? Image.memory(
                      // Convert base64 to image
                      Uint8List.fromList(Uri.dataFromString(space.imageBase64!).data?.contentAsBytes() ?? []),
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      _getSpaceTypeIcon(space.type),
                      size: 48,
                      color: _getSpaceTypeColor(space.type),
                    ),
            ),
            
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Space Name
                    Text(
                      space.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
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
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    if (space.description != null && space.description!.isNotEmpty)
                      Expanded(
                        child: Text(
                          space.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    
                    // Config Info
                    if (space.config != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (space.config!.temperature != null) ...[
                            Icon(
                              Icons.thermostat,
                              size: 14,
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
                          if (space.config!.humidity != null) ...[
                            if (space.config!.temperature != null) 
                              const SizedBox(width: 12),
                            Icon(
                              Icons.water_drop,
                              size: 14,
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
                        ],
                      ),
                    ],
                    
                    // Actions Row
                    if (onEdit != null || onDelete != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              onPressed: onEdit,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete, size: 16),
                              onPressed: onDelete,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
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
}