import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            isDark
                ? Border.all(color: Colors.grey.withValues(alpha: 0.1))
                : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
            blurRadius: isDark ? 8 : 12,
            offset: const Offset(0, 4),
            spreadRadius: isDark ? 0 : 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.push('/plants/${plant.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showPlantMenu(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.more_vert,
                          color:
                              isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

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
                Center(child: _buildPendingTasksBadge()),
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

  Widget _buildPendingTasksBadge() {
    final pendingTasks = _getPendingTasksCount();

    if (pendingTasks == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9500).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF9500).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, color: const Color(0xFFFF9500), size: 14),
          const SizedBox(width: 6),
          Text(
            '$pendingTasks pendentes',
            style: TextStyle(
              color: const Color(0xFFFF9500),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlantMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit, color: theme.colorScheme.secondary),
                  title: Text(
                    'Editar planta',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/plants/${plant.id}/edit');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.visibility,
                    color: theme.colorScheme.secondary,
                  ),
                  title: Text(
                    'Ver detalhes',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/plants/${plant.id}');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Excluir planta',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
            title: Text(
              'Excluir planta',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            content: Text(
              'Tem certeza que deseja excluir "${plant.displayName}"? Esta ação não pode ser desfeita.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: theme.colorScheme.secondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement delete functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Função de exclusão será implementada'),
                    ),
                  );
                },
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  int _getPendingTasksCount() {
    // TODO: Integrate with actual tasks system
    // For now, return a mock value based on plant name for demonstration
    switch (plant.displayName.toLowerCase()) {
      case 'teste':
        return 6;
      case 'monstera deliciosa':
        return 10;
      case 'espada de são jorge':
        return 10;
      case 'suculenta echeveria':
        return 10;
      default:
        return 6;
    }
  }
}
