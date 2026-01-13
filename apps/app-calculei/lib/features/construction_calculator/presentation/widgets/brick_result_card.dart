import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_spec_card.dart';
import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../domain/entities/brick_calculation.dart';
import 'detail_row.dart';

/// Result card widget for brick calculation
class BrickResultCard extends StatelessWidget {
  final BrickCalculation calculation;

  const BrickResultCard({
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
                  text: ShareFormatter.formatBrickCalculation(
                    bricksWithWaste: calculation.bricksWithWaste,
                    bricksNeeded: calculation.bricksNeeded,
                    netArea: calculation.netArea,
                    brickTypeName: calculation.brickType.displayName,
                    mortarBags: calculation.mortarBags,
                    sandCubicMeters: calculation.sandCubicMeters,
                    cementBags: calculation.cementBags,
                    wastePercentage: calculation.wastePercentage.toInt(),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Main result
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total de ${calculation.brickType.displayName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.bricksWithWaste}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    'unidades (com ${calculation.wastePercentage.toInt()}% de perda)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Materials
            Text(
              'Materiais para Argamassa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                AdaptiveSpecCard(
                  icon: Icons.inventory_2,
                  label: 'Argamassa',
                  value: '${calculation.mortarBags}',
                  unit: 'sacos (20kg)',
                  color: SemanticColors.specTeal(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.grain,
                  label: 'Areia',
                  value: calculation.sandCubicMeters.toStringAsFixed(2),
                  unit: 'm³',
                  color: SemanticColors.specOrange(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.inventory,
                  label: 'Cimento',
                  value: '${calculation.cementBags}',
                  unit: 'sacos (50kg)',
                  color: SemanticColors.specBlue(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Details
            Text(
              'Detalhes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            DetailRow(
              label: 'Área da parede',
              value: '${calculation.wallArea.toStringAsFixed(1)} m²',
            ),
            DetailRow(
              label: 'Área de aberturas',
              value: '${calculation.openingsArea.toStringAsFixed(1)} m²',
            ),
            DetailRow(
              label: 'Área líquida',
              value: '${calculation.netArea.toStringAsFixed(1)} m²',
            ),
            DetailRow(
              label: 'Tijolos (sem perda)',
              value: '${calculation.bricksNeeded}',
            ),
            DetailRow(
              label: 'Tipo de tijolo',
              value: calculation.brickType.displayName,
            ),
            DetailRow(
              label: 'Dimensões',
              value: calculation.brickType.dimensions,
            ),
            DetailRow(
              label: 'Consumo',
              value: '${calculation.brickType.unitsPerSquareMeter} un/m²',
            ),
          ],
        ),
      ),
    );
  }
}
