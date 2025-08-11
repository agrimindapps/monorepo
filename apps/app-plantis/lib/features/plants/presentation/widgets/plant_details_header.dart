import 'package:flutter/material.dart';
import '../../domain/entities/plant.dart';
import '../../../../core/theme/colors.dart';

class PlantDetailsHeader extends StatelessWidget {
  final Plant plant;

  const PlantDetailsHeader({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (plant.species != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        plant.species!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: PlantisColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildCareStatus(context),
            ],
          ),
          if (plant.plantingDate != null) ...[
            const SizedBox(height: 16),
            _buildPlantAge(context),
          ],
          if (plant.notes != null && plant.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotes(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCareStatus(BuildContext context) {
    final theme = Theme.of(context);
    final careStatus = _getCareStatus();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: careStatus.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
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
            size: 16,
            color: careStatus.color,
          ),
          const SizedBox(width: 8),
          Text(
            careStatus.label,
            style: theme.textTheme.bodyMedium?.copyWith(
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
    final age = DateTime.now().difference(plant.plantingDate!);
    final ageText = _formatAge(age);
    
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          'Plantada há $ageText',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNotes(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Observações',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          plant.notes!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  ({Color color, IconData icon, String label}) _getCareStatus() {
    if (plant.config?.wateringIntervalDays == null) {
      return (
        color: Colors.grey,
        icon: Icons.help_outline,
        label: 'Sem info',
      );
    }

    final daysSincePlanting = plant.plantingDate != null
        ? DateTime.now().difference(plant.plantingDate!).inDays
        : 0;

    final wateringInterval = plant.config!.wateringIntervalDays!;
    final daysSinceLastWatering = daysSincePlanting % wateringInterval;
    
    if (daysSinceLastWatering >= wateringInterval) {
      return (
        color: Colors.red,
        icon: Icons.water_drop,
        label: 'Regar agora',
      );
    } else if (daysSinceLastWatering >= (wateringInterval * 0.8).round()) {
      return (
        color: Colors.orange,
        icon: Icons.water_drop_outlined,
        label: 'Regar em breve',
      );
    } else {
      return (
        color: Colors.green,
        icon: Icons.check_circle,
        label: 'Em dia',
      );
    }
  }

  String _formatAge(Duration age) {
    final days = age.inDays;
    
    if (days < 30) {
      return '$days dias';
    } else if (days < 365) {
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      if (remainingDays == 0) {
        return '$months ${months == 1 ? 'mês' : 'meses'}';
      } else {
        return '$months ${months == 1 ? 'mês' : 'meses'} e $remainingDays dias';
      }
    } else {
      final years = (days / 365).floor();
      final remainingDays = days % 365;
      final months = (remainingDays / 30).floor();
      
      if (months == 0) {
        return '$years ${years == 1 ? 'ano' : 'anos'}';
      } else {
        return '$years ${years == 1 ? 'ano' : 'anos'} e $months ${months == 1 ? 'mês' : 'meses'}';
      }
    }
  }
}