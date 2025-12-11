import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entities/plant.dart';

class PlantDetailsInfo extends StatelessWidget {
  final Plant plant;

  const PlantDetailsInfo({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações Gerais',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: theme.brightness == Brightness.dark ? 8 : 12,
                offset: const Offset(0, 4),
                spreadRadius: theme.brightness == Brightness.dark ? 0 : 2,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(
                context,
                icon: Icons.label_outline,
                label: 'Nome',
                value: plant.displayName,
                color: PlantisColors.primary,
              ),
              const SizedBox(height: 16),
              if (plant.species != null && plant.species!.isNotEmpty) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.eco,
                  label: 'Nome Científico',
                  value: plant.species!,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
              ],
              if (plant.spaceId != null) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.room_outlined,
                  label: 'Localização',
                  value: 'Espaço ${plant.spaceId}',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
              ],
              if (plant.plantingDate != null) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.cake_outlined,
                  label: 'Idade da Planta',
                  value: _getPlantAge(),
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  icon: Icons.event,
                  label: 'Data de Plantio',
                  value: _formatDate(plant.plantingDate!),
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
              ],
              if (plant.createdAt != null) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Adicionada em',
                  value: _formatDate(plant.createdAt!),
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
              ],
              if (plant.updatedAt != null &&
                  plant.updatedAt != plant.createdAt) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.update,
                  label: 'Última atualização',
                  value: _formatDate(plant.updatedAt!),
                  color: Colors.amber,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
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
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
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

  String _formatDate(DateTime date) {
    final months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _getPlantAge() {
    if (plant.plantingDate == null) return 'Não informado';

    final now = DateTime.now();
    final plantingDate = plant.plantingDate!;
    final difference = now.difference(plantingDate);

    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    final days = difference.inDays % 30;

    if (years > 0) {
      if (months > 0) {
        return '$years ${years == 1 ? 'ano' : 'anos'} e $months ${months == 1 ? 'mês' : 'meses'}';
      }
      return '$years ${years == 1 ? 'ano' : 'anos'}';
    } else if (months > 0) {
      if (days > 0) {
        return '$months ${months == 1 ? 'mês' : 'meses'} e $days ${days == 1 ? 'dia' : 'dias'}';
      }
      return '$months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      return '$days ${days == 1 ? 'dia' : 'dias'}';
    }
  }
}
