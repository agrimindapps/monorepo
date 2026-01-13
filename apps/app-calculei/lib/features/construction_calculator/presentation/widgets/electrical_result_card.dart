import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_spec_card.dart';
import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/electrical_calculation.dart';

/// Result card widget for electrical calculation - Adaptive theme
class ElectricalResultCard extends StatelessWidget {
  final ElectricalCalculation calculation;

  const ElectricalResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.construction;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme colors
    final cardBgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50;
    final cardBorderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200;
    
    // Text colors
    final titleColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
    final subtitleColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;
    final detailLabelColor = isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54;
    final detailValueColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardBorderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resultado',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ShareButton(
                  text: ShareFormatter.formatElectricalCalculation(
                    totalPower: calculation.totalPower,
                    voltage: calculation.voltage,
                    circuitType: calculation.circuitType,
                    totalCurrent: calculation.totalCurrent,
                    wireGauge: calculation.wireGauge,
                    breakerSize: calculation.recommendedBreakerSize,
                    cableLength: calculation.estimatedCableLength,
                    numberOfCircuits: calculation.numberOfCircuits,
                    voltageDrop: calculation.voltageDrop,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Current highlight
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.2),
                    accentColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Corrente Total',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.totalCurrent.toStringAsFixed(2)} A',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Especificações Recomendadas',
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Specifications Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AdaptiveSpecCard(
                  icon: Icons.cable,
                  label: 'Bitola do Cabo',
                  value: calculation.wireGauge.toStringAsFixed(1),
                  unit: 'mm²',
                  color: SemanticColors.specOrange(context),
                  width: 160,
                ),
                AdaptiveSpecCard(
                  icon: Icons.power,
                  label: 'Disjuntor',
                  value: '${calculation.recommendedBreakerSize}',
                  unit: 'A',
                  color: SemanticColors.danger(context),
                  width: 160,
                ),
                AdaptiveSpecCard(
                  icon: Icons.straighten,
                  label: 'Comprimento',
                  value:
                      calculation.estimatedCableLength.toStringAsFixed(1),
                  unit: 'm',
                  color: SemanticColors.specBlue(context),
                  width: 160,
                ),
                AdaptiveSpecCard(
                  icon: Icons.account_tree,
                  label: 'Circuitos',
                  value: '${calculation.numberOfCircuits}',
                  unit: calculation.numberOfCircuits == 1
                      ? 'circuito'
                      : 'circuitos',
                  color: SemanticColors.specPurple(context),
                  width: 160,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Circuit Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: subtitleColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Circuito ${calculation.circuitType} - ${calculation.voltage.toInt()}V',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Voltage Drop Warning (if > 4%)
            if (calculation.voltageDrop != null &&
                calculation.voltageDrop! > 4) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      size: 20,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Queda de tensão: ${calculation.voltageDrop!.toStringAsFixed(2)}% - Acima do recomendado (máx. 4%)',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Technical Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes Técnicos',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Potência Total',
                    value: '${calculation.totalPower.toStringAsFixed(0)} W',
                    labelColor: detailLabelColor,
                    valueColor: detailValueColor,
                  ),
                  _DetailRow(
                    label: 'Tensão',
                    value: '${calculation.voltage.toInt()} V',
                    labelColor: detailLabelColor,
                    valueColor: detailValueColor,
                  ),
                  _DetailRow(
                    label: 'Tipo de Circuito',
                    value: calculation.circuitType,
                    labelColor: detailLabelColor,
                    valueColor: detailValueColor,
                  ),
                  if (calculation.voltageDrop != null)
                    _DetailRow(
                      label: 'Queda de Tensão',
                      value: '${calculation.voltageDrop!.toStringAsFixed(2)}%',
                      labelColor: detailLabelColor,
                      valueColor: detailValueColor,
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

/// Detail row for technical details
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
