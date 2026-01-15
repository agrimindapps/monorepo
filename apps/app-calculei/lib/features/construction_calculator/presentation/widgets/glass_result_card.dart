import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_spec_card.dart';
import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/glass_calculation.dart';

/// Result card widget for glass calculation - Dark theme
class GlassResultCard extends StatelessWidget {
  final GlassCalculation calculation;

  const GlassResultCard({
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
    final infoBgColor = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100;
    final infoBorderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300;

    
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
                  text: ShareFormatter.formatGlassCalculation(
                    width: calculation.width,
                    height: calculation.height,
                    totalArea: calculation.totalArea,
                    estimatedWeight: calculation.estimatedWeight,
                    glassType: calculation.glassType,
                    glassThickness: calculation.glassThickness,
                    numberOfPanels: calculation.numberOfPanels,
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
                    'Área Total',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.totalArea.toStringAsFixed(2)} m²',
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
              'Especificações',
              style: TextStyle(
                color: textColor,
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
                  icon: Icons.straighten,
                  label: 'Dimensões',
                  value: '${calculation.width.toStringAsFixed(2)} × ${calculation.height.toStringAsFixed(2)}',
                  unit: 'm',
                  color: SemanticColors.specBlue(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.inventory_2,
                  label: 'Painéis',
                  value: '${calculation.numberOfPanels}',
                  unit: 'unidades',
                  color: SemanticColors.specPurple(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.line_weight,
                  label: 'Peso Total',
                  value: calculation.estimatedWeight.toStringAsFixed(1),
                  unit: 'kg',
                  color: SemanticColors.specOrange(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.layers,
                  label: 'Espessura',
                  value: '${calculation.glassThickness}',
                  unit: 'mm',
                  color: SemanticColors.specTeal(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: infoBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: infoBorderColor,
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
                      'Vidro ${calculation.glassType} - ${calculation.glassThickness}mm',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Weight Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.scale,
                    size: 20,
                    color: Colors.orange.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Peso calculado: ${(calculation.estimatedWeight / calculation.numberOfPanels).toStringAsFixed(1)} kg por painel',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
                        fontSize: 13,
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
}
