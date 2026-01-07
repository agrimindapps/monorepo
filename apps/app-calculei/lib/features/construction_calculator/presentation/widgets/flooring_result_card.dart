import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../domain/entities/flooring_calculation.dart';
import 'detail_row.dart';
import 'material_chip.dart';
import 'result_highlight.dart';

/// Result card widget for flooring calculation
class FlooringResultCard extends StatelessWidget {
  final FlooringCalculation calculation;

  const FlooringResultCard({
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
                  text: ShareFormatter.formatFlooringCalculation(
                    boxesNeeded: calculation.boxesNeeded,
                    tilesWithWaste: calculation.tilesWithWaste,
                    tilesNeeded: calculation.tilesNeeded,
                    roomArea: calculation.roomArea,
                    groutKg: calculation.groutKg,
                    mortarKg: calculation.mortarKg,
                    flooringType: calculation.flooringType,
                    wastePercentage: calculation.wastePercentage.toInt(),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Main results
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ResultHighlight(
                  label: 'Caixas',
                  value: '${calculation.boxesNeeded}',
                  icon: Icons.inventory_2,
                  color: Colors.brown,
                ),
                ResultHighlight(
                  label: 'Peças',
                  value: '${calculation.tilesWithWaste}',
                  icon: Icons.grid_view,
                  color: Colors.blue,
                ),
                ResultHighlight(
                  label: 'Área',
                  value: '${calculation.roomArea.toStringAsFixed(1)} m²',
                  icon: Icons.square_foot,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Materials
            Text(
              'Materiais Complementares',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                MaterialChip(
                  label: 'Rejunte',
                  value: '${calculation.groutKg.toStringAsFixed(1)} kg',
                  icon: Icons.format_color_fill,
                ),
                MaterialChip(
                  label: 'Argamassa',
                  value: '${calculation.mortarKg.toStringAsFixed(1)} kg',
                  icon: Icons.construction,
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
              label: 'Peças (sem perda)',
              value: '${calculation.tilesNeeded}',
            ),
            DetailRow(
              label: 'Peças (com perda)',
              value: '${calculation.tilesWithWaste}',
            ),
            DetailRow(
              label: 'Perda considerada',
              value: '${calculation.wastePercentage.toInt()}%',
            ),
            DetailRow(
              label: 'Área da peça',
              value: '${(calculation.tileArea * 10000).toStringAsFixed(0)} cm²',
            ),
            DetailRow(
              label: 'Peças por caixa',
              value: '${calculation.tilesPerBox}',
            ),
            DetailRow(
              label: 'Tipo de piso',
              value: calculation.flooringType,
            ),
          ],
        ),
      ),
    );
  }
}
