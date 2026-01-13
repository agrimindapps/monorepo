import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_spec_card.dart';
import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/mortar_calculation.dart';

/// Result card widget for mortar calculation - Dark theme
class MortarResultCard extends StatelessWidget {
  final MortarCalculation calculation;

  const MortarResultCard({
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
                  text: ShareFormatter.formatMortarCalculation(
                    area: calculation.area,
                    thickness: calculation.thickness,
                    volume: calculation.mortarVolume,
                    cementBags: calculation.cementBags,
                    sandCubicMeters: calculation.sandCubicMeters,
                    waterLiters: calculation.waterLiters.toInt(),
                    mortarType: calculation.mortarType,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Volume highlight
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
                    'Volume de Argamassa',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.mortarVolume.toStringAsFixed(2)} m³',
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
                  icon: Icons.inventory_2,
                  label: 'Cimento',
                  value: '${calculation.cementBags}',
                  unit: 'sacos (50kg)',
                  color: SemanticColors.specBlue(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.grain,
                  label: 'Areia',
                  value: calculation.sandCubicMeters.toStringAsFixed(2),
                  unit: 'm³',
                  color: SemanticColors.specPurple(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.water_drop,
                  label: 'Água',
                  value: calculation.waterLiters.toStringAsFixed(0),
                  unit: 'litros',
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
                      'Argamassa para ${calculation.mortarType} - ${calculation.area.toStringAsFixed(1)} m² x ${calculation.thickness.toStringAsFixed(1)} cm',
                      style: TextStyle(
                        color: labelColor,
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
