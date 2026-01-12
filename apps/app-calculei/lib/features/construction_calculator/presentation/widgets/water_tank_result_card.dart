import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/water_tank_calculation.dart';

/// Result card widget for water tank calculation - Dark theme
class WaterTankResultCard extends StatelessWidget {
  final WaterTankCalculation calculation;

  const WaterTankResultCard({
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
                  text: ShareFormatter.formatWaterTankCalculation(
                    numberOfPeople: calculation.numberOfPeople,
                    dailyConsumption: calculation.dailyConsumption,
                    reserveDays: calculation.reserveDays,
                    totalCapacity: calculation.totalCapacity,
                    recommendedTankSize: calculation.recommendedTankSize,
                    tankType: calculation.tankType,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Recommended tank size highlight
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
                    'Caixa d\'Água Recomendada',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatCapacity(calculation.recommendedTankSize)} L',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    calculation.tankType,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Detalhes do Cálculo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Calculation Details Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _DetailItem(
                  icon: Icons.people,
                  label: 'Pessoas',
                  value: calculation.numberOfPeople.toString(),
                  unit: calculation.numberOfPeople == 1 ? 'pessoa' : 'pessoas',
                  color: Colors.blue,
                ),
                _DetailItem(
                  icon: Icons.water_drop,
                  label: 'Consumo Diário',
                  value: calculation.dailyConsumption.toInt().toString(),
                  unit: 'L/pessoa/dia',
                  color: Colors.cyan,
                ),
                _DetailItem(
                  icon: Icons.calendar_today,
                  label: 'Dias de Reserva',
                  value: calculation.reserveDays.toString(),
                  unit: calculation.reserveDays == 1 ? 'dia' : 'dias',
                  color: Colors.orange,
                ),
                _DetailItem(
                  icon: Icons.analytics,
                  label: 'Capacidade Mínima',
                  value: _formatCapacity(calculation.totalCapacity.toInt()),
                  unit: 'litros',
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Additional Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Consumo Total Diário: ${(calculation.numberOfPeople * calculation.dailyConsumption).toInt()} litros',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      'Considere margem de segurança de 20% para variações no consumo',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
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

  /// Format capacity with thousands separator
  String _formatCapacity(int capacity) {
    if (capacity >= 1000) {
      final thousands = capacity ~/ 1000;
      final hundreds = capacity % 1000;
      if (hundreds == 0) {
        return '$thousands.000';
      }
      return '$thousands.${hundreds.toString().padLeft(3, '0')}';
    }
    return capacity.toString();
  }
}

/// Detail item widget for dark theme
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _DetailItem({
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
