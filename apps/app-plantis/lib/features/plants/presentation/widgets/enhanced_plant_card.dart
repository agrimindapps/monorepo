import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entities/plant.dart';

/// Enhanced Plant Card siguiendo principios SOLID
/// S - Responsabilidad única: Solo renderiza información de una planta
/// O - Abierto/cerrado: Extensible para nuevos tipos de tarjetas
/// L - Liskov: Implementa la interfaz común de widgets
/// I - Segregación de interfaces: Interfaces específicas para acciones
/// D - Inversión de dependencias: Depende de abstracciones

abstract class IPlantCardActions {
  void onTap(Plant plant);
  void onEdit(Plant plant);
  void onRemove(Plant plant);
}

abstract class ITaskDataProvider {
  Future<List<TaskInfo>> getPendingTasks(String plantId);
}

class TaskInfo {
  final String type;
  final DateTime dueDate;
  final bool isOverdue;

  const TaskInfo({
    required this.type,
    required this.dueDate,
    required this.isOverdue,
  });
}

class EnhancedPlantCard extends StatelessWidget {
  final Plant plant;
  final IPlantCardActions actions;
  final ITaskDataProvider taskProvider;
  final bool isGridView;

  const EnhancedPlantCard({
    super.key,
    required this.plant,
    required this.actions,
    required this.taskProvider,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return isGridView
        ? _PlantGridCard(
          plant: plant,
          actions: actions,
          taskProvider: taskProvider,
        )
        : _PlantListCard(
          plant: plant,
          actions: actions,
          taskProvider: taskProvider,
        );
  }
}

class _PlantListCard extends StatelessWidget {
  final Plant plant;
  final IPlantCardActions actions;
  final ITaskDataProvider taskProvider;

  const _PlantListCard({
    required this.plant,
    required this.actions,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => actions.onTap(plant),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlantHeader(plant: plant, actions: actions, theme: theme),
                const SizedBox(height: 12),
                _TaskStatusSection(
                  plant: plant,
                  taskProvider: taskProvider,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantGridCard extends StatelessWidget {
  final Plant plant;
  final IPlantCardActions actions;
  final ITaskDataProvider taskProvider;

  const _PlantGridCard({
    required this.plant,
    required this.actions,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => actions.onTap(plant),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Plant illustration
              Expanded(
                child: Center(
                  child: _PlantIllustration(plant: plant, size: 60),
                ),
              ),

              const SizedBox(height: 8),

              // Plant name
              Text(
                plant.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              if (plant.species?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  plant.species!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 8),

              // Compact task status
              Center(
                child: _CompactTaskStatus(
                  plant: plant,
                  taskProvider: taskProvider,
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantHeader extends StatelessWidget {
  final Plant plant;
  final IPlantCardActions actions;
  final ThemeData theme;

  const _PlantHeader({
    required this.plant,
    required this.actions,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlantIllustration(plant: plant, size: 50),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plant.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (plant.species?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  plant.species!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (plant.spaceId?.isNotEmpty == true) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Espaço ${plant.spaceId!}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PlantIllustration extends StatelessWidget {
  final Plant plant;
  final double size;

  const _PlantIllustration({required this.plant, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: PlantisColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: PlantisColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child:
          plant.primaryImageUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(size / 2),
                child: Image.network(
                  plant.primaryImageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _DefaultPlantIcon(size: size);
                  },
                ),
              )
              : _DefaultPlantIcon(size: size),
    );
  }
}

class _DefaultPlantIcon extends StatelessWidget {
  final double size;

  const _DefaultPlantIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: PlantIllustrationPainter(
        leafColor: PlantisColors.primary.withValues(alpha: 0.7),
        stemColor: PlantisColors.primary,
      ),
    );
  }
}


class _TaskStatusSection extends StatelessWidget {
  final Plant plant;
  final ITaskDataProvider taskProvider;
  final ThemeData theme;

  const _TaskStatusSection({
    required this.plant,
    required this.taskProvider,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TaskInfo>>(
      future: taskProvider.getPendingTasks(plant.id),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return _StatusBadge(
            icon: Icons.check_circle,
            text: 'Em dia',
            color: Colors.green,
            backgroundColor: Colors.green.withValues(alpha: 0.1),
          );
        }

        final overdueTasks = tasks.where((t) => t.isOverdue).length;
        final pendingTasks = tasks.length - overdueTasks;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overdueTasks > 0)
              _StatusBadge(
                icon: Icons.warning,
                text: '$overdueTasks em atraso',
                color: Colors.red,
                backgroundColor: Colors.red.withValues(alpha: 0.1),
              ),
            if (pendingTasks > 0) ...[
              if (overdueTasks > 0) const SizedBox(height: 8),
              _StatusBadge(
                icon: Icons.schedule,
                text: '$pendingTasks pendentes',
                color: Colors.orange,
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CompactTaskStatus extends StatelessWidget {
  final Plant plant;
  final ITaskDataProvider taskProvider;
  final ThemeData theme;

  const _CompactTaskStatus({
    required this.plant,
    required this.taskProvider,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TaskInfo>>(
      future: taskProvider.getPendingTasks(plant.id),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return _StatusBadge(
            icon: Icons.check_circle,
            text: 'Em dia',
            color: Colors.green,
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            isCompact: true,
          );
        }

        return _StatusBadge(
          icon: Icons.schedule,
          text: '${tasks.length}',
          color: Colors.orange,
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          isCompact: true,
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color backgroundColor;
  final bool isCompact;

  const _StatusBadge({
    required this.icon,
    required this.text,
    required this.color,
    required this.backgroundColor,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isCompact ? 14 : 16),
          SizedBox(width: isCompact ? 4 : 6),
          Text(
            text,
            style: (isCompact
                    ? theme.textTheme.bodySmall
                    : theme.textTheme.bodyMedium)
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for plant illustration
class PlantIllustrationPainter extends CustomPainter {
  final Color leafColor;
  final Color stemColor;

  PlantIllustrationPainter({required this.leafColor, required this.stemColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw stem
    paint.color = stemColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 8),
          width: 3,
          height: 16,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Draw leaves
    paint.color = leafColor;

    // Left leaf
    final leftLeafPath = Path();
    leftLeafPath.moveTo(center.dx - 2, center.dy - 2);
    leftLeafPath.quadraticBezierTo(
      center.dx - 12,
      center.dy - 8,
      center.dx - 8,
      center.dy - 16,
    );
    leftLeafPath.quadraticBezierTo(
      center.dx - 4,
      center.dy - 12,
      center.dx - 2,
      center.dy - 2,
    );
    canvas.drawPath(leftLeafPath, paint);

    // Right leaf
    final rightLeafPath = Path();
    rightLeafPath.moveTo(center.dx + 2, center.dy - 2);
    rightLeafPath.quadraticBezierTo(
      center.dx + 12,
      center.dy - 8,
      center.dx + 8,
      center.dy - 16,
    );
    rightLeafPath.quadraticBezierTo(
      center.dx + 4,
      center.dy - 12,
      center.dx + 2,
      center.dy - 2,
    );
    canvas.drawPath(rightLeafPath, paint);

    // Center leaf
    final centerLeafPath = Path();
    centerLeafPath.moveTo(center.dx, center.dy - 4);
    centerLeafPath.quadraticBezierTo(
      center.dx - 6,
      center.dy - 12,
      center.dx,
      center.dy - 18,
    );
    centerLeafPath.quadraticBezierTo(
      center.dx + 6,
      center.dy - 12,
      center.dx,
      center.dy - 4,
    );
    canvas.drawPath(centerLeafPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! PlantIllustrationPainter ||
        oldDelegate.leafColor != leafColor ||
        oldDelegate.stemColor != stemColor;
  }
}
