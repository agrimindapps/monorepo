import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/plant.dart';
import 'optimized_plant_image_widget.dart';
import 'plant_tasks_helper.dart';

class PlantCard extends ConsumerStatefulWidget {
  final Plant plant;
  final VoidCallback? onTap;

  const PlantCard({super.key, required this.plant, this.onTap});

  @override
  ConsumerState<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends ConsumerState<PlantCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.diagonal3Values(
          _isHovered ? 1.02 : 1.0,
          _isHovered ? 1.02 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFFFFFFF), // Branco puro para modo claro
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: _isHovered ? 0.4 : 0.3)
                  : const Color(0xFF000000).withValues(
                      alpha: _isHovered ? 0.15 : 0.12,
                    ), // Sombra mais forte para contraste
              offset: Offset(0, _isHovered ? 6 : 3),
              blurRadius: _isHovered ? 16 : 12,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.1)
                  : const Color(0xFF000000).withValues(alpha: 0.06),
              offset: const Offset(0, 1),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                widget.onTap ??
                () => context.push(AppRouter.plantDetailsPath(widget.plant.id)),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(child: _buildPlantAvatar()),
                  const SizedBox(height: 16),
                  Text(
                    widget.plant.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.plant.displaySpecies,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: PlantTasksHelper.buildTaskBadge(
                      ref,
                      widget.plant.id,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantAvatar() {
    const size = 80.0;

    return OptimizedPlantImageWidget(
      imageBase64: widget.plant.imageBase64,
      imageUrls: widget.plant.imageUrls,
      size: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}
