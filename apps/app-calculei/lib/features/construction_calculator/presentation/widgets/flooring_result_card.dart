import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/flooring_calculation.dart';

/// Result card for flooring calculation
class FlooringResultCard extends StatelessWidget {
  const FlooringResultCard({
    super.key,
    required this.calculation,
  });

  final FlooringCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final numberFormat = NumberFormat.decimalPattern('pt_BR');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.grid_view,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Resultado do Cálculo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Main Results
            _buildResultRow(
              context,
              'Área total',
              '${numberFormat.format(calculation.area)} m²',
              Icons.square_foot,
            ),

            const SizedBox(height: 12),

            _buildResultRow(
              context,
              'Dimensões da peça',
              '${numberFormat.format(calculation.tileWidth)} x ${numberFormat.format(calculation.tileLength)} cm',
              Icons.aspect_ratio,
            ),

            const SizedBox(height: 12),

            _buildResultRow(
              context,
              'Área por peça',
              '${numberFormat.format(calculation.areaPerTile)} m²',
              Icons.crop_square,
            ),

            const SizedBox(height: 16),

            // Tiles Calculation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantidade de Peças',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow(
                    context,
                    'Peças necessárias (sem perda)',
                    numberFormat.format(calculation.tilesNeeded),
                    Icons.format_list_numbered,
                  ),
                  const SizedBox(height: 8),
                  _buildResultRow(
                    context,
                    'Percentual de perda',
                    '${calculation.wastePercentage.toInt()}%',
                    Icons.percent,
                  ),
                  const SizedBox(height: 8),
                  _buildResultRow(
                    context,
                    'Peças com perda',
                    numberFormat.format(calculation.tilesWithWaste),
                    Icons.add_circle,
                    isHighlighted: true,
                  ),
                ],
              ),
            ),

            // Cost Section (if provided)
            if (calculation.totalCost != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custo Total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      context,
                      'Valor total estimado',
                      currencyFormat.format(calculation.totalCost),
                      Icons.attach_money,
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este valor inclui o percentual de perda.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Tips Section
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dicas Importantes',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildTipItem(
                    context,
                    'Compre sempre um pouco mais de material para imprevistos.',
                  ),
                  _buildTipItem(
                    context,
                    'Considere a dilatação térmica ao instalar pisos cerâmicos.',
                  ),
                  _buildTipItem(
                    context,
                    'Verifique se há rejunte suficiente (cerca de 2-3mm entre peças).',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlighted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
