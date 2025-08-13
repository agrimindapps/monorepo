import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/plant.dart';
import '../providers/plants_provider.dart';
import '../../../../core/theme/colors.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;

  const PlantCard({
    super.key,
    required this.plant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push('/plants/${plant.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Ícone da planta
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildPlantIcon(),
            ),
            
            const SizedBox(width: 16),
            
            // Informações da planta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome da planta
                  Text(
                    plant.displayName,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Espécie + localização
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plant.displaySpecies,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (plant.location != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  plant.location!,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Badge de cuidados pendentes
                  _buildPendingTasksBadge(),
                ],
              ),
            ),
            
            // Menu de três pontos
            IconButton(
              onPressed: () => _showPlantMenu(context),
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantIcon() {
    if (plant.hasImage) {
      try {
        final imageBytes = base64Decode(plant.imageBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            errorBuilder: (context, error, stackTrace) => _buildIconPlaceholder(),
          ),
        );
      } catch (e) {
        return _buildIconPlaceholder();
      }
    }
    
    return _buildIconPlaceholder();
  }

  Widget _buildIconPlaceholder() {
    return const Icon(
      Icons.eco,
      color: Colors.black,
      size: 28,
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
        color: const Color(0xFF8B6914), // Brown/orange color like in the image
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            pendingTasks == 1 
                ? '$pendingTasks cuidado pendente'
                : '$pendingTasks cuidados pendentes',
            style: const TextStyle(
              color: Colors.white,
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
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
      builder: (context) => Container(
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
              leading: Icon(Icons.visibility, color: theme.colorScheme.secondary),
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
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
        title: Text(
          'Excluir planta',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Tem certeza que deseja excluir "${plant.displayName}"? Esta ação não pode ser desfeita.',
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
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
        return 5;
      case 'espada de são jorge':
        return 5;
      default:
        return 0;
    }
  }

}