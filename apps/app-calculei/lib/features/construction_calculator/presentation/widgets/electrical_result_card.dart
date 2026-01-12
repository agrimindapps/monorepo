import 'package:flutter/material.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/electrical_calculation.dart';

/// Result card widget for electrical calculation - Dark theme
class ElectricalResultCard extends StatelessWidget {
  final ElectricalCalculation calculation;

  const ElectricalResultCard({
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
                  text: ShareFormatter.formatElectricalCalculation(
                    totalPower: calculation.totalPower,
                    voltage: calculation.voltage,
                    circuitType: calculation.circuitType,
                    totalCurrent: calculation.totalCurrent,
                    wireGauge: calculation.wireGauge,
                    breakerSize: calculation.recommendedBreakerSize,
                    cableLength: calculation.estimatedCableLength,
                    numberOfCircuits: calculation.numberOfCircuits,
                    voltageDrop: calculation.voltageDrop,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Current highlight
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
                    'Corrente Total',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.totalCurrent.toStringAsFixed(2)} A',
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
              'Especificações Recomendadas',
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
                _SpecificationItem(
                  icon: Icons.cable,
                  label: 'Bitola do Cabo',
                  value: '${calculation.wireGauge.toStringAsFixed(1)}',
                  unit: 'mm²',
                  color: Colors.orange,
                ),
                _SpecificationItem(
                  icon: Icons.power,
                  label: 'Disjuntor',
                  value: '${calculation.recommendedBreakerSize}',
                  unit: 'A',
                  color: Colors.red,
                ),
                _SpecificationItem(
                  icon: Icons.straighten,
                  label: 'Comprimento',
                  value:
                      calculation.estimatedCableLength.toStringAsFixed(1),
                  unit: 'm',
                  color: Colors.blue,
                ),
                _SpecificationItem(
                  icon: Icons.account_tree,
                  label: 'Circuitos',
                  value: '${calculation.numberOfCircuits}',
                  unit: calculation.numberOfCircuits == 1
                      ? 'circuito'
                      : 'circuitos',
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Circuit Info
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
                      'Circuito ${calculation.circuitType} - ${calculation.voltage.toInt()}V',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Voltage Drop Warning (if > 4%)
            if (calculation.voltageDrop != null &&
                calculation.voltageDrop! > 4) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      size: 20,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Queda de tensão: ${calculation.voltageDrop!.toStringAsFixed(2)}% - Acima do recomendado (máx. 4%)',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Technical Details
            _buildTechnicalDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes Técnicos',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Potência Total',
            value: '${calculation.totalPower.toStringAsFixed(0)} W',
          ),
          _DetailRow(
            label: 'Tensão',
            value: '${calculation.voltage.toInt()} V',
          ),
          _DetailRow(
            label: 'Tipo de Circuito',
            value: calculation.circuitType,
          ),
          if (calculation.voltageDrop != null)
            _DetailRow(
              label: 'Queda de Tensão',
              value: '${calculation.voltageDrop!.toStringAsFixed(2)}%',
            ),
        ],
      ),
    );
  }
}

/// Specification item widget for dark theme
class _SpecificationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SpecificationItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
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

/// Detail row for technical details
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
