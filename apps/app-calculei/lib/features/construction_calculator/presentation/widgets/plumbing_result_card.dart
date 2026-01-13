import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_spec_card.dart';
import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/plumbing_calculation.dart';

/// Result card widget for plumbing calculation - Dark theme
class PlumbingResultCard extends StatelessWidget {
  final PlumbingCalculation calculation;

  const PlumbingResultCard({
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
                  text: ShareFormatter.formatPlumbingCalculation(
                    systemType: calculation.systemType,
                    pipeDiameter: calculation.pipeDiameter,
                    totalLength: calculation.totalLength,
                    pipeCount: calculation.pipeCount,
                    glueAmount: calculation.glueAmount.toInt(),
                    numberOfElbows: calculation.numberOfElbows,
                    numberOfTees: calculation.numberOfTees,
                    numberOfCouplings: calculation.numberOfCouplings,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // System info highlight
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.plumbing,
                        color: accentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${calculation.systemType} - ${calculation.pipeDiameter}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${calculation.totalLength.toStringAsFixed(1)} metros totais',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Materiais Necessários',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Materials Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AdaptiveSpecCard(
                  icon: Icons.straighten,
                  label: 'Tubos PVC',
                  value: '${calculation.pipeCount}',
                  unit: 'unidades (6m)',
                  color: SemanticColors.specBlue(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.opacity,
                  label: 'Cola PVC',
                  value: calculation.glueAmount.toStringAsFixed(0),
                  unit: 'ml',
                  color: SemanticColors.specOrange(context),
                ),
              ],
            ),

            if (calculation.numberOfElbows > 0 ||
                calculation.numberOfTees > 0 ||
                calculation.numberOfCouplings > 0) ...[
              const SizedBox(height: 20),
              
              Text(
                'Conexões',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (calculation.numberOfElbows > 0)
                    AdaptiveSpecCard(
                      icon: Icons.turn_right,
                      label: 'Joelhos 90°',
                      value: '${calculation.numberOfElbows}',
                      unit: 'unidades',
                      color: SemanticColors.specPurple(context),
                    ),
                  if (calculation.numberOfTees > 0)
                    AdaptiveSpecCard(
                      icon: Icons.call_split,
                      label: 'Ts (Junções)',
                      value: '${calculation.numberOfTees}',
                      unit: 'unidades',
                      color: SemanticColors.specOrange(context),
                    ),
                  if (calculation.numberOfCouplings > 0)
                    AdaptiveSpecCard(
                      icon: Icons.link,
                      label: 'Luvas',
                      value: '${calculation.numberOfCouplings}',
                      unit: 'unidades',
                      color: SemanticColors.specTeal(context),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Info
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
                      'Cálculo inclui 10% de margem para desperdício',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
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
