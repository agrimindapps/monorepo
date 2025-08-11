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
    
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () => context.push('/plants/${plant.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem da planta
            Expanded(
              flex: 3,
              child: _buildPlantImage(context),
            ),
            
            // Informações da planta
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome da planta
                    Text(
                      plant.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Espécie
                    Text(
                      plant.displaySpecies,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Status de cuidado e idade
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Indicador de cuidado
                        _buildCareIndicator(context),
                        
                        // Idade da planta
                        _buildPlantAge(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantImage(BuildContext context) {
    final theme = Theme.of(context);
    
    if (plant.hasImage) {
      try {
        final imageBytes = base64Decode(plant.imageBase64!);
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        );
      } catch (e) {
        return _buildPlaceholder(context);
      }
    }
    
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
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
        size: 48,
        color: PlantisColors.primary.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildCareIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final careStatus = _getCareStatus();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: careStatus.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: careStatus.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            careStatus.icon,
            size: 12,
            color: careStatus.color,
          ),
          const SizedBox(width: 4),
          Text(
            careStatus.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: careStatus.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantAge(BuildContext context) {
    final theme = Theme.of(context);
    final ageText = _getAgeText();
    
    return Text(
      ageText,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontWeight: FontWeight.w500,
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
    if (age == 1) return '1 dia';
    if (age < 30) return '$age dias';
    if (age < 365) return '${(age / 30).round()} meses';
    return '${(age / 365).round()} anos';
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