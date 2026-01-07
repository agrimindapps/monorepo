import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../domain/entities/concrete_calculation.dart';
import 'material_item.dart';

/// Result card widget for concrete calculation
class ConcreteResultCard extends StatelessWidget {
  final ConcreteCalculation calculation;

  const ConcreteResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resultado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ShareButton(
                  text: ShareFormatter.formatConcreteCalculation(
                    volume: calculation.volume,
                    cementBags: calculation.cementBags,
                    sandCubicMeters: calculation.sandCubicMeters,
                    gravelCubicMeters: calculation.gravelCubicMeters,
                    waterLiters: calculation.waterLiters.toInt(),
                    concreteType: calculation.concreteType,
                    concreteStrength: calculation.concreteStrength,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Volume highlight
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Volume Total',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.volume.toStringAsFixed(2)} m³',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Materiais Necessários',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Materials Grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                MaterialItem(
                  icon: Icons.inventory_2,
                  label: 'Cimento',
                  value: '${calculation.cementBags}',
                  unit: 'sacos (50kg)',
                  color: Colors.grey,
                ),
                MaterialItem(
                  icon: Icons.grain,
                  label: 'Areia',
                  value: calculation.sandCubicMeters.toStringAsFixed(2),
                  unit: 'm³',
                  color: Colors.amber,
                ),
                MaterialItem(
                  icon: Icons.circle,
                  label: 'Brita',
                  value: calculation.gravelCubicMeters.toStringAsFixed(2),
                  unit: 'm³',
                  color: Colors.blueGrey,
                ),
                MaterialItem(
                  icon: Icons.water_drop,
                  label: 'Água',
                  value: calculation.waterLiters.toStringAsFixed(0),
                  unit: 'litros',
                  color: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Concreto ${calculation.concreteType} - ${calculation.concreteStrength}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
