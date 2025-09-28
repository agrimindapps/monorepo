import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/plant.dart';
import 'plant_tasks_helper.dart';

class PlantListTile extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;

  const PlantListTile({super.key, required this.plant, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : theme.colorScheme.surface,
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
            child: Row(
              children: [
                // Avatar/Imagem da planta
                _buildPlantAvatar(context),

                const SizedBox(width: 16),

                // Conteúdo principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header com nome e menu
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              plant.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? Colors.white
                                        : theme.colorScheme.onSurface,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showPlantMenu(context),
                            icon: Icon(
                              Icons.more_vert,
                              color:
                                  isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                              size: 20,
                            ),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Subtítulo com espécie e localização
                      Row(
                        children: [
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
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color:
                                isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Sala de Estar', // TODO: Resolver nome do espaço
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Badge de cuidados pendentes
                      PlantTasksHelper.buildTaskBadge(
                        context,
                        plant.id,
                        hideWhenEmpty: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantAvatar(BuildContext context) {
    const size = 60.0;

    if (plant.hasImage) {
      try {
        final imageBytes = base64Decode(plant.imageBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => _buildPlaceholder(size),
          ),
        );
      } catch (e) {
        return _buildPlaceholder(size);
      }
    }

    return _buildPlaceholder(size);
  }

  Widget _buildPlaceholder(double size) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                isDark
                    ? const Color(0xFF2C2C2E)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
            border: isDark ? Border.all(color: const Color(0xFF3A3A3C)) : null,
          ),
          child: Icon(
            Icons.eco,
            size: 28,
            color: isDark ? const Color(0xFF55D85A) : theme.colorScheme.primary,
          ),
        );
      },
    );
  }

  void _showPlantMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar planta'),
                onTap: () {
                  Navigator.pop(context);
                  // Edit functionality not implemented
                },
              ),
              ListTile(
                leading: const Icon(Icons.water_drop),
                title: const Text('Registrar rega'),
                onTap: () {
                  Navigator.pop(context);
                  // Water logging not implemented
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
                  // Delete functionality not implemented
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
