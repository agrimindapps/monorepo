import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/concrete_calculation.dart';

/// Result card for concrete calculation
class ConcreteResultCard extends StatelessWidget {
  const ConcreteResultCard({
    super.key,
    required this.calculation,
  });

  final ConcreteCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final numberFormat = NumberFormat.decimalPattern('pt_BR');
    final volumeFormat = NumberFormat('0.00', 'pt_BR');

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
                  Icons.foundation,
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

            // Dimensions and Volume
            _buildResultRow(
              context,
              'Dimensões',
              '${numberFormat.format(calculation.length)} × ${numberFormat.format(calculation.width)} × ${numberFormat.format(calculation.height)} m',
              Icons.aspect_ratio,
            ),

            const SizedBox(height: 12),

            _buildResultRow(
              context,
              'Volume total',
              '${volumeFormat.format(calculation.volume)} m³',
              Icons.crop_square,
              isHighlighted: true,
            ),

            const SizedBox(height: 12),

            _buildResultRow(
              context,
              'Tipo de concreto',
              calculation.concreteType.toUpperCase(),
              Icons.build,
            ),

            const SizedBox(height: 16),

            // Materials Section
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
                    'Materiais Necessários',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow(
                    context,
                    'Cimento (sacos de 50kg)',
                    numberFormat.format(calculation.cementBags),
                    Icons.inventory,
                    isHighlighted: true,
                  ),
                  const SizedBox(height: 8),
                  _buildResultRow(
                    context,
                    'Areia',
                    '${volumeFormat.format(calculation.sandVolume)} m³',
                    Icons.grain,
                  ),
                  const SizedBox(height: 8),
                  _buildResultRow(
                    context,
                    'Brita',
                    '${volumeFormat.format(calculation.gravelVolume)} m³',
                    Icons.terrain,
                  ),
                  const SizedBox(height: 8),
                  _buildResultRow(
                    context,
                    'Água',
                    '${numberFormat.format(calculation.waterVolume)} L',
                    Icons.water_drop,
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
                      'Custo Total Estimado',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      context,
                      'Valor total dos materiais',
                      currencyFormat.format(calculation.totalCost),
                      Icons.attach_money,
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este valor inclui cimento, areia e brita. Não inclui mão de obra, transporte ou equipamentos.',
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
                    'Use cimento fresco (validade máxima de 3 meses).',
                  ),
                  _buildTipItem(
                    context,
                    'A areia deve estar limpa e sem impurezas.',
                  ),
                  _buildTipItem(
                    context,
                    'A brita deve ter granulometria adequada ao tipo de concreto.',
                  ),
                  _buildTipItem(
                    context,
                    'A água deve ser potável e limpa.',
                  ),
                  _buildTipItem(
                    context,
                    'Considere perdas de 5-10% no transporte e manuseio.',
                  ),
                  _buildTipItem(
                    context,
                    'Para grandes volumes, considere concretagem em etapas.',
                  ),
                ],
              ),
            ),

            // Standards Info
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .tertiaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cálculo baseado nas normas ABNT NBR 6118 e NBR 12655.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
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
