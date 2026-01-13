import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_spec_card.dart';
import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/rebar_calculation.dart';

/// Result card widget for rebar calculation - Dark theme
class RebarResultCard extends StatelessWidget {
  final RebarCalculation calculation;

  const RebarResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.construction;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
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
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ShareButton(
                  text: ShareFormatter.formatRebarCalculation(
                    structureType: calculation.structureType,
                    concreteVolume: calculation.concreteVolume,
                    rebarDiameter: calculation.rebarDiameter,
                    totalWeight: calculation.totalWeight,
                    totalLength: calculation.totalLength,
                    numberOfBars: calculation.numberOfBars,
                    steelRate: calculation.steelRate,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Total Weight highlight
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
                    'Peso Total de Aço',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.totalWeight.toStringAsFixed(1)} kg',
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
              'Detalhes da Ferragem',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Details Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AdaptiveSpecCard(
                  icon: Icons.straighten,
                  label: 'Comprimento Total',
                  value: calculation.totalLength.toStringAsFixed(1),
                  unit: 'metros',
                  color: SemanticColors.specOrange(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.hardware,
                  label: 'Barras de 12m',
                  value: '${calculation.numberOfBars}',
                  unit: 'unidades',
                  color: SemanticColors.specOrange(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.donut_small,
                  label: 'Diâmetro',
                  value: calculation.rebarDiameter,
                  unit: '(${calculation.weightPerMeter.toStringAsFixed(3)} kg/m)',
                  color: SemanticColors.specOrange(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.analytics,
                  label: 'Taxa de Aço',
                  value: calculation.steelRate.toStringAsFixed(0),
                  unit: 'kg/m³',
                  color: SemanticColors.specBlue(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Structure info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Estrutura: ${calculation.structureType} | Volume: ${calculation.concreteVolume.toStringAsFixed(2)} m³',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Additional info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    size: 18,
                    color: Colors.amber.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Considere 5-10% de perda no corte e amarração',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
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
