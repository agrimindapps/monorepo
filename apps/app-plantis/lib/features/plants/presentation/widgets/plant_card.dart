import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/plant.dart';
import 'optimized_plant_image_widget.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;

  const PlantCard({super.key, required this.plant, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: isDark ? 8 : 12,
            offset: const Offset(0, 4),
            spreadRadius: isDark ? 0 : 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.push(AppRouter.plantDetailsPath(plant.id)),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Avatar da planta centralizado
                Center(child: _buildPlantAvatar()),

                const SizedBox(height: 16),

                // Nome da planta
                Text(
                  plant.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                // Espécie
                Text(
                  plant.displaySpecies,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Badge de cuidados pendentes
                Center(child: _buildPendingTasksBadge(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantAvatar() {
    const size = 80.0;

    return OptimizedPlantImageWidget(
      imageBase64: plant.imageBase64,
      imageUrls: plant.imageUrls,
      size: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  Widget _buildPendingTasksBadge(BuildContext context) {
    final theme = Theme.of(context);
    final pendingTasks = _getPendingTasksCount();

    // Determinar cor, ícone e texto baseado no número de tarefas
    final Color badgeColor;
    final Color backgroundColor;
    final IconData icon;
    final String text;

    if (pendingTasks == 0) {
      badgeColor = theme.colorScheme.primary;
      backgroundColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.15);
      icon = Icons.check_circle;
      text = 'Sem tarefas';
    } else {
      badgeColor = theme.colorScheme.error;
      backgroundColor = theme.colorScheme.errorContainer.withValues(alpha: 0.15);
      icon = Icons.schedule;
      text = '$pendingTasks pendentes';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  int _getPendingTasksCount() {
    // TODO: Integrar com TasksProvider para contar tarefas reais pendentes
    // Por enquanto, retornar 0 até a integração com o sistema de tarefas ser implementada
    return 0;
    
    // Implementação futura:
    // final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    // return tasksProvider.getPendingTasksCountForPlant(plant.id);
  }
}
