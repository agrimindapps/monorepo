import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/paint_calculation.dart';

/// Result card widget for paint calculation - Adaptive theme
class PaintResultCard extends StatelessWidget {
  final PaintCalculation calculation;

  const PaintResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.construction;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Background and border colors based on theme
    final cardBgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50;
    final cardBorderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200;
    
    // Text colors
    final titleColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
    final subtitleColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;
    final valueColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;

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
            
            const SizedBox(height: 20),

            // Main result highlight
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
                    'Total de Tinta',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.paintLiters.toStringAsFixed(1)} litros',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.thumb_up, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recomendado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calculation.recommendedOption,
                          style: TextStyle(
                            color: valueColor,
                            fontSize: 15,
                          ),
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
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _DetailRow(
              label: 'Área das paredes',
              value: '${calculation.wallArea.toStringAsFixed(1)} m²',
              isDark: isDark,
            ),
            _DetailRow(
              label: 'Área de aberturas',
              value: '${calculation.openingsArea.toStringAsFixed(1)} m²',
              isDark: isDark,
            ),
            _DetailRow(
              label: 'Área líquida',
              value: '${calculation.netArea.toStringAsFixed(1)} m²',
              isDark: isDark,
            ),
            _DetailRow(
              label: 'Tipo de tinta',
              value: calculation.paintType,
              isDark: isDark,
            ),
            _DetailRow(
              label: 'Demãos',
              value: '${calculation.coats}',
              isDark: isDark,
            ),
            _DetailRow(
              label: 'Rendimento',
              value: '${calculation.paintYield.toStringAsFixed(0)} m²/L',
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // Note
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
                      'Latas disponíveis: 3,6L e 18L. O cálculo otimiza para menor desperdício.',
                      style: TextStyle(
                        color: subtitleColor,
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

/// Detail row widget for adaptive theme
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
