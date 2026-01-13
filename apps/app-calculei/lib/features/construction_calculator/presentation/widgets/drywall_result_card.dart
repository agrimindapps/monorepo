import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_spec_card.dart';
import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/drywall_calculation.dart';

/// Result card widget for drywall calculation - Dark theme
class DrywallResultCard extends StatelessWidget {
  final DrywallCalculation calculation;

  const DrywallResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.construction;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive colors
    final bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;
    
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
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
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ShareButton(
                  text: ShareFormatter.formatDrywallCalculation(
                    wallArea: calculation.wallArea,
                    numberOfPanels: calculation.numberOfPanels,
                    profilesMeters: calculation.profilesMeters,
                    screwsCount: calculation.screwsCount,
                    jointTapeMeters: calculation.jointTapeMeters,
                    jointCompoundKg: calculation.jointCompoundKg,
                    wallType: calculation.wallType,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Area highlight
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
                    'Área Total da Parede',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.wallArea.toStringAsFixed(2)} m²',
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
              'Materiais Necessários',
              style: TextStyle(
                color: textColor,
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
                  icon: Icons.grid_on,
                  label: 'Placas',
                  value: '${calculation.numberOfPanels}',
                  unit: 'placas (1.20×2.40m)',
                  color: SemanticColors.specBlue(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.straighten,
                  label: 'Montantes',
                  value: calculation.montantesMeters.toStringAsFixed(1),
                  unit: 'metros',
                  color: SemanticColors.specOrange(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.horizontal_rule,
                  label: 'Guias',
                  value: calculation.guiasMeters.toStringAsFixed(1),
                  unit: 'metros',
                  color: SemanticColors.specOrange(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.build,
                  label: 'Parafusos',
                  value: '${calculation.screwsCount}',
                  unit: 'unidades',
                  color: SemanticColors.specPurple(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.line_style,
                  label: 'Fita de Junção',
                  value: calculation.jointTapeMeters.toStringAsFixed(1),
                  unit: 'metros',
                  color: SemanticColors.specBlue(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.format_paint,
                  label: 'Massa Corrida',
                  value: calculation.jointCompoundKg.toStringAsFixed(1),
                  unit: 'kg',
                  color: SemanticColors.specTeal(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info
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
                    color: labelColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Parede ${calculation.wallType} - ${calculation.length.toStringAsFixed(2)}m × ${calculation.height.toStringAsFixed(2)}m',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54,
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
