import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
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
                      color: Colors.white.withValues(alpha: 0.7),
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
                  icon: Icons.inventory_2,
                  label: 'Cimento',
                  value: '${calculation.cementBags}',
                  unit: 'sacos (50kg)',
                  color: Colors.grey,
                ),
                _MaterialItem(
                  icon: Icons.grain,
                  label: 'Areia',
                  value: calculation.sandCubicMeters.toStringAsFixed(2),
                  unit: 'm³',
                  color: Colors.amber,
                ),
                _MaterialItem(
                  icon: Icons.circle,
                  label: 'Brita',
                  value: calculation.gravelCubicMeters.toStringAsFixed(2),
                  unit: 'm³',
                  color: Colors.blueGrey,
                ),
                _MaterialItem(
                  icon: Icons.water_drop,
                  label: 'Água',
                  value: calculation.waterLiters.toStringAsFixed(0),
                  unit: 'litros',
                  color: Colors.blue,
                ),
                _MaterialItem(
                  icon: Icons.architecture,
                  label: 'Aço/Ferro',
                  value: calculation.steelWeight.toStringAsFixed(0),
                  unit: 'kg',
                  color: Colors.orange,
                ),
                if (calculation.numberOfBlocks > 0)
                  _MaterialItem(
                    icon: Icons.dashboard,
                    label: 'Blocos',
                    value: '${calculation.numberOfBlocks}',
                    unit: 'unidades',
                    color: Colors.brown,
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
                      'Laje ${calculation.slabType} - ${calculation.thickness.toStringAsFixed(0)} cm de espessura',
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
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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
