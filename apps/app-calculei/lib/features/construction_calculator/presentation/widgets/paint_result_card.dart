import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../domain/entities/paint_calculation.dart';
import 'detail_row.dart';

/// Result card widget for paint calculation
class PaintResultCard extends StatelessWidget {
  final PaintCalculation calculation;

  const PaintResultCard({
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
                  text: ShareFormatter.formatPaintCalculation(
                    paintLiters: calculation.paintLiters,
                    netArea: calculation.netArea,
                    paintType: calculation.paintType,
                    coats: calculation.coats,
                    recommendedOption: calculation.recommendedOption,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Main result highlight
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total de Tinta',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.paintLiters.toStringAsFixed(1)} litros',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recommended option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.thumb_up, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recomendado',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calculation.recommendedOption,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
              label: 'Área das paredes',
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
              label: 'Tipo de tinta',
              value: calculation.paintType,
            ),
            DetailRow(
              label: 'Demãos',
              value: '${calculation.coats}',
            ),
            DetailRow(
              label: 'Rendimento',
              value: '${calculation.paintYield.toStringAsFixed(0)} m²/L',
            ),

            const SizedBox(height: 16),

            // Note
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
                      'Latas disponíveis: 3,6L e 18L. O cálculo otimiza para menor desperdício.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
