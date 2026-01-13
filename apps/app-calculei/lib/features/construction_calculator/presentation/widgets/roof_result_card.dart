import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/roof_calculation.dart';

/// Result card widget for roof calculation - Dark theme
class RoofResultCard extends StatelessWidget {
  final RoofCalculation calculation;

  const RoofResultCard({
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
                  text: ShareFormatter.formatRoofCalculation(
                    roofArea: calculation.roofArea,
                    numberOfTiles: calculation.numberOfTiles,
                    ridgeTilesCount: calculation.ridgeTilesCount,
                    woodFrameMeters: calculation.woodFrameMeters,
                    roofType: calculation.roofType,
                    roofSlope: calculation.roofSlope,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Roof area highlight
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
                    'Área do Telhado',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.roofArea.toStringAsFixed(2)} m²',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inclinação: ${calculation.roofSlope.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 13,
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

            // Tiles Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.roofing,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Telhas',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Telhas ${calculation.roofType}',
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${calculation.numberOfTiles}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'unidades',
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: borderColor,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cumeeiras',
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${calculation.ridgeTilesCount}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'unidades',
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Wood Frame Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.brown.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.carpenter,
                        color: Colors.brown,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Madeiramento',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _WoodItem(
                    label: 'Ripas',
                    value: calculation.ripasMeters.toStringAsFixed(2),
                  ),
                  const SizedBox(height: 8),
                  _WoodItem(
                    label: 'Caibros',
                    value: calculation.caibrosMeters.toStringAsFixed(2),
                  ),
                  const SizedBox(height: 8),
                  _WoodItem(
                    label: 'Terças',
                    value: calculation.tercasMeters.toStringAsFixed(2),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total de Madeira',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${calculation.woodFrameMeters.toStringAsFixed(2)} m',
                          style: const TextStyle(
                            color: Colors.brown,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                      'Cálculo baseado em telhas tipo ${calculation.roofType} com inclinação de ${calculation.roofSlope.toStringAsFixed(0)}%',
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

/// Wood item widget for dark theme
class _WoodItem extends StatelessWidget {
  final String label;
  final String value;

  const _WoodItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;
    final valueColor = isDark ? Colors.brown.shade300 : Colors.brown.shade700;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
          ),
        ),
        Text(
          '$value m',
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
