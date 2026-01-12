import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../domain/entities/planter_setup_calculation.dart';

/// Result card widget for planter setup calculation - Dark theme
class PlanterSetupResultCard extends StatelessWidget {
  final PlanterSetupCalculation calculation;

  const PlanterSetupResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF4CAF50); // Green for agriculture

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
                    Icons.agriculture,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Regulagem da Plantadeira',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        calculation.cropType,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ShareButton(
                  text: _formatShareText(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Seeds per meter highlight
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
                    'Sementes por Metro',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    calculation.seedsPerMeter.toStringAsFixed(1),
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'sementes/m',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Key metrics grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'População Alvo',
                  value: _formatNumber(calculation.targetPopulation),
                  unit: 'plantas/ha',
                  icon: Icons.grass,
                  accentColor: accentColor,
                ),
                _MetricCard(
                  label: 'Espaçamento',
                  value: calculation.rowSpacing.toStringAsFixed(0),
                  unit: 'cm',
                  icon: Icons.straighten,
                  accentColor: accentColor,
                ),
                _MetricCard(
                  label: 'Germinação',
                  value: calculation.germination.toStringAsFixed(0),
                  unit: '%',
                  icon: Icons.eco,
                  accentColor: accentColor,
                ),
                _MetricCard(
                  label: 'Sementes/ha',
                  value: _formatNumber(calculation.seedsPerHectare),
                  unit: 'sementes',
                  icon: Icons.grid_on,
                  accentColor: accentColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Calibration section
            _buildCalibrationSection(accentColor),

            const SizedBox(height: 20),

            // Seed weight section
            _buildSeedWeightSection(accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationSection(Color accentColor) {
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
          Row(
            children: [
              Icon(
                Icons.settings,
                color: accentColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Teste de Calibração',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Disco de Plantio',
            value: '${calculation.discHoles} furos',
            accentColor: accentColor,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Voltas da Roda',
            value: calculation.wheelTurns.toStringAsFixed(0),
            accentColor: accentColor,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: accentColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gire a roda ${calculation.wheelTurns.toStringAsFixed(0)} voltas e conte as sementes. '
                    'Devem cair ~${(calculation.seedsPerMeter * 2).toStringAsFixed(0)} sementes.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeedWeightSection(Color accentColor) {
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
          Row(
            children: [
              Icon(
                Icons.scale,
                color: accentColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Peso de Sementes',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'PMG (Peso Mil Grãos)',
            value: '${calculation.thousandSeedWeight.toStringAsFixed(0)}g',
            accentColor: accentColor,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Consumo por Hectare',
            value: '${calculation.seedWeight.toStringAsFixed(2)} kg/ha',
            accentColor: accentColor,
            highlight: true,
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    return formatter.format(value.round());
  }

  String _formatShareText() {
    return '''
🌾 REGULAGEM DA PLANTADEIRA - ${calculation.cropType}

📊 Configuração:
• População: ${_formatNumber(calculation.targetPopulation)} plantas/ha
• Espaçamento: ${calculation.rowSpacing.toStringAsFixed(0)} cm
• Germinação: ${calculation.germination.toStringAsFixed(0)}%

🎯 Resultados:
• Sementes/metro: ${calculation.seedsPerMeter.toStringAsFixed(1)}
• Sementes/ha: ${_formatNumber(calculation.seedsPerHectare)}

⚙️ Calibração:
• Disco: ${calculation.discHoles} furos
• Voltas: ${calculation.wheelTurns.toStringAsFixed(0)}

📦 Consumo:
• Peso/ha: ${calculation.seedWeight.toStringAsFixed(2)} kg
• PMG: ${calculation.thousandSeedWeight.toStringAsFixed(0)}g

Calculado com app-calculei
''';
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
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
          Icon(
            icon,
            color: accentColor.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final bool highlight;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.accentColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight
                ? accentColor
                : Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
