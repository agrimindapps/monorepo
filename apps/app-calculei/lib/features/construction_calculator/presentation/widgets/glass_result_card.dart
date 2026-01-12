import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
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
                  text: ShareFormatter.formatGlassCalculation(
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
                      color: Colors.white.withValues(alpha: 0.7),
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
                color: Colors.white.withValues(alpha: 0.9),
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
                _SpecItem(
                  icon: Icons.straighten,
                  label: 'Dimensões',
                  value: '${calculation.width.toStringAsFixed(2)} × ${calculation.height.toStringAsFixed(2)}',
                  unit: 'm',
                  color: Colors.blue,
                ),
                _SpecItem(
                  icon: Icons.inventory_2,
                  label: 'Painéis',
                  value: '${calculation.numberOfPanels}',
                  unit: 'unidades',
                  color: Colors.purple,
                ),
                _SpecItem(
                  icon: Icons.line_weight,
                  label: 'Peso Total',
                  value: calculation.estimatedWeight.toStringAsFixed(1),
                  unit: 'kg',
                  color: Colors.orange,
                ),
                _SpecItem(
                  icon: Icons.layers,
                  label: 'Espessura',
                  value: '${calculation.glassThickness}',
                  unit: 'mm',
                  color: Colors.teal,
                ),
              ],
            ),

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
                      'Vidro ${calculation.glassType} - ${calculation.glassThickness}mm',
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
                        color: Colors.white.withValues(alpha: 0.8),
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

/// Specification item widget for dark theme
class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
