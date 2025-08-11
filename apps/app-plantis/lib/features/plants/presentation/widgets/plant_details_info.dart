import 'package:flutter/material.dart';
import '../../domain/entities/plant.dart';
import '../../../../core/theme/colors.dart';

class PlantDetailsInfo extends StatelessWidget {
  final Plant plant;

  const PlantDetailsInfo({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
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
                if (plant.spaceId != null) ...[
                  _buildInfoRow(
                    context,
                    icon: Icons.room_outlined,
                    label: 'Localização',
                    value: 'Espaço ${plant.spaceId}', // TODO: Get space name
                    color: PlantisColors.primary,
                  ),
                  const SizedBox(height: 16),
                ],
                if (plant.plantingDate != null) ...[
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
                    color: Colors.purple,
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
                    color: Colors.orange,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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

  String _formatDate(DateTime date) {
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}