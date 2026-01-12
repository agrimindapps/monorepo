import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
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
                      color: Colors.white.withValues(alpha: 0.7),
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
                _MaterialItem(
                  icon: Icons.grid_on,
                  label: 'Placas',
                  value: '${calculation.numberOfPanels}',
                  unit: 'placas (1.20×2.40m)',
                  color: Colors.blueGrey,
                ),
                _MaterialItem(
                  icon: Icons.straighten,
                  label: 'Montantes',
                  value: calculation.montantesMeters.toStringAsFixed(1),
                  unit: 'metros',
                  color: Colors.orange,
                ),
                _MaterialItem(
                  icon: Icons.horizontal_rule,
                  label: 'Guias',
                  value: calculation.guiasMeters.toStringAsFixed(1),
                  unit: 'metros',
                  color: Colors.deepOrange,
                ),
                _MaterialItem(
                  icon: Icons.build,
                  label: 'Parafusos',
                  value: '${calculation.screwsCount}',
                  unit: 'unidades',
                  color: Colors.grey,
                ),
                _MaterialItem(
                  icon: Icons.line_style,
                  label: 'Fita de Junção',
                  value: calculation.jointTapeMeters.toStringAsFixed(1),
                  unit: 'metros',
                  color: Colors.white,
                ),
                _MaterialItem(
                  icon: Icons.format_paint,
                  label: 'Massa Corrida',
                  value: calculation.jointCompoundKg.toStringAsFixed(1),
                  unit: 'kg',
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
                      'Parede ${calculation.wallType} - ${calculation.length.toStringAsFixed(2)}m × ${calculation.height.toStringAsFixed(2)}m',
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

/// Material item widget for dark theme
class _MaterialItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MaterialItem({
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
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
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
