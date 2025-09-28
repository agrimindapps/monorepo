import 'package:flutter/material.dart';

import '../../../../../core/theme/plantis_colors.dart';
import '../../../domain/entities/plant.dart';

/// Widget responsável por exibir as informações de cuidados da planta
class PlantCareSection extends StatelessWidget {
  final Plant plant;

  const PlantCareSection({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    if (plant.config == null) {
      return _buildEmptyCareState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCareSchedule(context),
        const SizedBox(height: 24),
        _buildCareRequirements(context),
      ],
    );
  }

  Widget _buildEmptyCareState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.spa_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Configurações de cuidado não definidas',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure os intervalos de rega, adubação e outros cuidados para esta planta.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCareSchedule(BuildContext context) {
    final theme = Theme.of(context);
    final config = plant.config!;

    final careItems = <Map<String, dynamic>>[
      if (config.hasWateringSchedule)
        {
          'icon': Icons.water_drop,
          'title': 'Rega',
          'interval': '${config.wateringIntervalDays} dias',
          'color': PlantisColors.primary,
          'description': 'Regue a planta regularmente',
        },
      if (config.hasFertilizingSchedule)
        {
          'icon': Icons.grass,
          'title': 'Adubação',
          'interval': '${config.fertilizingIntervalDays} dias',
          'color': PlantisColors.primary,
          'description': 'Aplique fertilizante',
        },
      if (config.hasPruningSchedule)
        {
          'icon': Icons.content_cut,
          'title': 'Poda',
          'interval': '${config.pruningIntervalDays} dias',
          'color': PlantisColors.primary,
          'description': 'Pode folhas e galhos',
        },
      if (config.hasSunlightCheckSchedule)
        {
          'icon': Icons.wb_sunny,
          'title': 'Verificar luz',
          'interval': '${config.sunlightCheckIntervalDays} dias',
          'color': PlantisColors.primary,
          'description': 'Verifique a exposição à luz',
        },
      if (config.hasPestInspectionSchedule)
        {
          'icon': Icons.bug_report,
          'title': 'Inspeção de pragas',
          'interval': '${config.pestInspectionIntervalDays} dias',
          'color': PlantisColors.primary,
          'description': 'Inspecione por pragas e doenças',
        },
      if (config.hasReplantingSchedule)
        {
          'icon': Icons.change_circle,
          'title': 'Replantio',
          'interval': '${config.replantingIntervalDays} dias',
          'color': PlantisColors.primary,
          'description': 'Replante em vaso maior',
        },
    ];

    if (careItems.isEmpty) {
      return _buildEmptyCareState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cronograma de cuidados',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...careItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCareItem(context, item),
          ),
        ),
      ],
    );
  }

  Widget _buildCareItem(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final color = item['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item['icon'] as IconData, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item['interval'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareRequirements(BuildContext context) {
    final theme = Theme.of(context);
    final config = plant.config!;

    final requirements = <Map<String, dynamic>>[
      if (config.lightRequirement != null)
        {
          'icon': Icons.wb_sunny_outlined,
          'title': 'Necessidade de luz',
          'value': _getLightRequirementText(config.lightRequirement),
          'color': PlantisColors.primary,
        },
      if (config.waterAmount != null)
        {
          'icon': Icons.water_drop_outlined,
          'title': 'Quantidade de água',
          'value': _getWaterAmountText(config.waterAmount),
          'color': PlantisColors.primary,
        },
      if (config.soilType != null)
        {
          'icon': Icons.landscape_outlined,
          'title': 'Tipo de solo',
          'value': config.soilType,
          'color': PlantisColors.primary,
        },
      if (config.idealTemperature != null)
        {
          'icon': Icons.thermostat_outlined,
          'title': 'Temperatura ideal',
          'value': '${config.idealTemperature}°C',
          'color': PlantisColors.primary,
        },
      if (config.idealHumidity != null)
        {
          'icon': Icons.opacity_outlined,
          'title': 'Umidade ideal',
          'value': '${config.idealHumidity}%',
          'color': PlantisColors.primary,
        },
    ];

    if (requirements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requisitos ambientais',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              requirements
                  .map((req) => _buildRequirementChip(context, req))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildRequirementChip(BuildContext context, Map<String, dynamic> req) {
    final theme = Theme.of(context);
    final color = req['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(req['icon'] as IconData, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                req['title'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                req['value'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLightRequirementText(String? lightRequirement) {
    switch (lightRequirement?.toLowerCase()) {
      case 'low':
        return 'Pouca luz';
      case 'medium':
        return 'Luz moderada';
      case 'high':
        return 'Muita luz';
      default:
        return 'Não definido';
    }
  }

  String _getWaterAmountText(String? waterAmount) {
    switch (waterAmount?.toLowerCase()) {
      case 'little':
        return 'Pouca água';
      case 'moderate':
        return 'Água moderada';
      case 'plenty':
        return 'Muita água';
      default:
        return 'Não definido';
    }
  }
}
