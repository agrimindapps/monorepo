import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entities/plant.dart';

class PlantDetailsCare extends StatelessWidget {
  final Plant plant;

  const PlantDetailsCare({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuidados',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildCareCard(
                context,
                icon: Icons.water_drop,
                title: 'Rega',
                interval: plant.config?.wateringIntervalDays,
                unit: 'dias',
                color: PlantisColors.primary,
                nextDate: _calculateNextWatering(),
              ),
              if (plant.config?.fertilizingIntervalDays != null) ...[
                const SizedBox(height: 16),
                _buildCareCard(
                  context,
                  icon: Icons.eco,
                  title: 'Fertilização',
                  interval: plant.config!.fertilizingIntervalDays,
                  unit: 'dias',
                  color: PlantisColors.primary,
                  nextDate: _calculateNextFertilizing(),
                ),
              ],
              if (plant.config?.pruningIntervalDays != null) ...[
                const SizedBox(height: 16),
                _buildCareCard(
                  context,
                  icon: Icons.content_cut,
                  title: 'Poda',
                  interval: plant.config!.pruningIntervalDays,
                  unit: 'dias',
                  color: PlantisColors.primary,
                  nextDate: _calculateNextPruning(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCareCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int? interval,
    required String unit,
    required Color color,
    DateTime? nextDate,
  }) {
    final theme = Theme.of(context);

    if (interval == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Não configurado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final daysUntilNext = nextDate?.difference(DateTime.now()).inDays;

    final isOverdue = daysUntilNext != null && daysUntilNext < 0;
    final isToday = daysUntilNext == 0;
    final isSoon =
        daysUntilNext != null && daysUntilNext <= 2 && daysUntilNext > 0;

    Color statusColor = color;
    String statusText = '';

    if (isOverdue) {
      statusColor = Colors.red;
      statusText = '${(-daysUntilNext)} dias atrás';
    } else if (isToday) {
      statusColor = Colors.orange;
      statusText = 'Hoje';
    } else if (isSoon) {
      statusColor = Colors.orange;
      statusText = 'Em $daysUntilNext dias';
    } else if (daysUntilNext != null) {
      statusColor = Colors.green;
      statusText = 'Em $daysUntilNext dias';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A cada $interval $unit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (statusText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                statusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  DateTime? _calculateNextWatering() {
    if (plant.config?.wateringIntervalDays == null ||
        plant.plantingDate == null) {
      return null;
    }

    final interval = plant.config!.wateringIntervalDays!;
    final daysSincePlanting =
        DateTime.now().difference(plant.plantingDate!).inDays;
    final cyclesSincePlanting = (daysSincePlanting / interval).floor();

    return plant.plantingDate!.add(
      Duration(days: (cyclesSincePlanting + 1) * interval),
    );
  }

  DateTime? _calculateNextFertilizing() {
    if (plant.config?.fertilizingIntervalDays == null ||
        plant.plantingDate == null) {
      return null;
    }

    final interval = plant.config!.fertilizingIntervalDays!;
    final daysSincePlanting =
        DateTime.now().difference(plant.plantingDate!).inDays;
    final cyclesSincePlanting = (daysSincePlanting / interval).floor();

    return plant.plantingDate!.add(
      Duration(days: (cyclesSincePlanting + 1) * interval),
    );
  }

  DateTime? _calculateNextPruning() {
    if (plant.config?.pruningIntervalDays == null ||
        plant.plantingDate == null) {
      return null;
    }

    final interval = plant.config!.pruningIntervalDays!;
    final daysSincePlanting =
        DateTime.now().difference(plant.plantingDate!).inDays;
    final cyclesSincePlanting = (daysSincePlanting / interval).floor();

    return plant.plantingDate!.add(
      Duration(days: (cyclesSincePlanting + 1) * interval),
    );
  }
}
