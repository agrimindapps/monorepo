import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/plant.dart';
import '../providers/plants_provider.dart';
import '../../../../core/theme/colors.dart';

class PlantListTile extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;

  const PlantListTile({
    super.key,
    required this.plant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: ListTile(
        onTap: onTap ?? () => context.push('/plants/${plant.id}'),
        contentPadding: const EdgeInsets.all(12),
        
        // Avatar/Imagem da planta
        leading: _buildPlantAvatar(context),
        
        // Título e subtítulo
        title: Text(
          plant.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              plant.displaySpecies,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            _buildPlantInfo(context),
          ],
        ),
        
        // Indicador de cuidado
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCareIndicator(context),
            const SizedBox(height: 4),
            Text(
              _getAgeText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
        
        isThreeLine: true,
      ),
    );
  }

  Widget _buildPlantAvatar(BuildContext context) {
    const size = 56.0;
    
    if (plant.hasImage) {
      try {
        final imageBytes = base64Decode(plant.imageBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size),
          ),
        );
      } catch (e) {
        return _buildPlaceholder(size);
      }
    }
    
    return _buildPlaceholder(size);
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary.withValues(alpha: 0.1),
            PlantisColors.primary.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Icon(
        Icons.eco,
        size: 28,
        color: PlantisColors.primary.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildPlantInfo(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[];
    
    // Espaço/localização
    if (plant.spaceId != null) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              'Espaço', // TODO: Resolver nome do espaço
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }
    
    // Última rega (se tiver configuração)
    if (plant.config?.wateringIntervalDays != null) {
      final lastWatering = plant.updatedAt ?? plant.createdAt;
      if (lastWatering != null) {
        final daysSinceWatering = DateTime.now().difference(lastWatering).inDays;
        items.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.water_drop,
                size: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                daysSinceWatering == 0 
                    ? 'Hoje' 
                    : daysSinceWatering == 1
                        ? 'Ontem'
                        : '$daysSinceWatering dias',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }
    }
    
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: 12,
      children: items,
    );
  }

  Widget _buildCareIndicator(BuildContext context) {
    final careStatus = _getCareStatus();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: careStatus.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: careStatus.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        careStatus.icon,
        size: 16,
        color: careStatus.color,
      ),
    );
  }

  CareStatusInfo _getCareStatus() {
    if (plant.config?.wateringIntervalDays == null) {
      return CareStatusInfo(
        status: CareStatus.unknown,
        label: 'Config',
        icon: Icons.settings,
        color: Colors.grey,
      );
    }

    final now = DateTime.now();
    final lastWatering = plant.updatedAt ?? plant.createdAt ?? now;
    final nextWatering = lastWatering.add(
      Duration(days: plant.config!.wateringIntervalDays!),
    );
    final daysDifference = nextWatering.difference(now).inDays;

    if (daysDifference <= 0) {
      return CareStatusInfo(
        status: CareStatus.needsWater,
        label: 'Regar',
        icon: Icons.water_drop,
        color: Colors.red,
      );
    } else if (daysDifference <= 2) {
      return CareStatusInfo(
        status: CareStatus.soonWater,
        label: 'Em breve',
        icon: Icons.schedule,
        color: Colors.orange,
      );
    } else {
      return CareStatusInfo(
        status: CareStatus.good,
        label: 'Ok',
        icon: Icons.check_circle,
        color: Colors.green,
      );
    }
  }

  String _getAgeText() {
    final age = plant.ageInDays;
    if (age == 0) return 'Nova';
    if (age == 1) return '1d';
    if (age < 30) return '${age}d';
    if (age < 365) return '${(age / 30).round()}m';
    return '${(age / 365).round()}a';
  }
}

class CareStatusInfo {
  final CareStatus status;
  final String label;
  final IconData icon;
  final Color color;

  const CareStatusInfo({
    required this.status,
    required this.label,
    required this.icon,
    required this.color,
  });
}