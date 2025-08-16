import 'package:flutter/material.dart';
import '../../domain/entities/plant.dart';

class PlantDetailsConfig extends StatelessWidget {
  final Plant plant;

  const PlantDetailsConfig({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = plant.config;
    
    if (config == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma configuração definida',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure os cuidados da planta para receber lembretes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações',
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
                if (config.lightRequirement != null) ...[
                  _buildConfigRow(
                    context,
                    icon: Icons.wb_sunny,
                    label: 'Luminosidade',
                    value: _getLightRequirementText(config.lightRequirement!),
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                ],
                if (config.waterAmount != null) ...[
                  _buildConfigRow(
                    context,
                    icon: Icons.water_drop,
                    label: 'Quantidade de água',
                    value: config.waterAmount!,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                ],
                if (config.soilType != null) ...[
                  _buildConfigRow(
                    context,
                    icon: Icons.grass,
                    label: 'Tipo de solo',
                    value: config.soilType!,
                    color: Colors.brown,
                  ),
                  const SizedBox(height: 16),
                ],
                if (config.idealTemperature != null) ...[
                  _buildConfigRow(
                    context,
                    icon: Icons.thermostat,
                    label: 'Temperatura ideal',
                    value: '${config.idealTemperature!.toStringAsFixed(0)}°C',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                ],
                if (config.idealHumidity != null) ...[
                  _buildConfigRow(
                    context,
                    icon: Icons.opacity,
                    label: 'Umidade ideal',
                    value: '${config.idealHumidity!.toStringAsFixed(0)}%',
                    color: Colors.lightBlue,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLightRequirementText(String lightRequirement) {
    switch (lightRequirement.toLowerCase()) {
      case 'full_sun':
      case 'pleno_sol':
        return 'Pleno sol';
      case 'partial_sun':
      case 'sol_parcial':
        return 'Sol parcial';
      case 'shade':
      case 'sombra':
        return 'Sombra';
      case 'partial_shade':
      case 'meia_sombra':
        return 'Meia sombra';
      default:
        return lightRequirement;
    }
  }
}