import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_spec_card.dart';
import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/slab_calculation.dart';

/// Result card widget for slab calculation - Dark theme
class SlabResultCard extends StatelessWidget {
  final SlabCalculation calculation;

  const SlabResultCard({
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
                  text: ShareFormatter.formatSlabCalculation(
                    slabType: calculation.slabType,
                    concreteVolume: calculation.concreteVolume,
                    cementBags: calculation.cementBags,
                    sandCubicMeters: calculation.sandCubicMeters,
                    gravelCubicMeters: calculation.gravelCubicMeters,
                    steelWeight: calculation.steelWeight.toInt(),
                    numberOfBlocks: calculation.numberOfBlocks,
                    waterLiters: calculation.waterLiters.toInt(),
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
                    'Volume de Concreto',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.concreteVolume.toStringAsFixed(2)} m³',
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
                  icon: Icons.circle,
                  label: 'Brita',
                  value: calculation.gravelCubicMeters.toStringAsFixed(2),
                  unit: 'm³',
                  color: SemanticColors.specOrange(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.water_drop,
                  label: 'Água',
                  value: calculation.waterLiters.toStringAsFixed(0),
                  unit: 'litros',
                  color: SemanticColors.specTeal(context),
                ),
                AdaptiveSpecCard(
                  icon: Icons.architecture,
                  label: 'Aço/Ferro',
                  value: calculation.steelWeight.toStringAsFixed(0),
                  unit: 'kg',
                  color: SemanticColors.specBlue(context),
                ),
                if (calculation.numberOfBlocks > 0)
                  AdaptiveSpecCard(
                    icon: Icons.dashboard,
                    label: 'Blocos',
                    value: '${calculation.numberOfBlocks}',
                    unit: 'unidades',
                    color: SemanticColors.specPurple(context),
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
                      'Laje ${calculation.slabType} - ${calculation.thickness.toStringAsFixed(0)} cm de espessura',
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
