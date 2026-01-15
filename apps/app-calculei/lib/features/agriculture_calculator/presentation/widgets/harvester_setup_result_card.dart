import 'package:flutter/material.dart';

import '../../../../shared/widgets/share_button.dart';
import '../../domain/entities/harvester_setup_calculation.dart';

/// Result card displaying harvester setup calculation results
class HarvesterSetupResultCard extends StatelessWidget {
  final HarvesterSetupCalculation calculation;

  const HarvesterSetupResultCard({
    required this.calculation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show if no calculation performed
    if (calculation.id.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: Color(0xFF4CAF50),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultado da Regulagem',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      calculation.cropType,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ShareButton(
                text: ShareFormatter.formatHarvesterSetupCalculation(
                  cropType: calculation.cropType,
                  productivity: calculation.productivity,
                  moisture: calculation.moisture,
                  harvestSpeed: calculation.harvestSpeed,
                  platformWidth: calculation.platformWidth,
                  cylinderSpeed: calculation.cylinderSpeed,
                  concaveOpening: calculation.concaveOpening,
                  fanSpeed: calculation.fanSpeed,
                  sieveOpening: calculation.sieveOpening,
                  estimatedLoss: calculation.estimatedLoss,
                  harvestCapacity: calculation.harvestCapacity,
                ),
              ),
              _buildQualityBadge(calculation.qualityStatus),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),

          // Recommended Settings Section
          _buildSectionTitle('Regulagens Recomendadas'),
          const SizedBox(height: 16),

          _buildSettingsGrid(),

          const SizedBox(height: 24),

          // Performance Metrics Section
          _buildSectionTitle('Desempenho Estimado'),
          const SizedBox(height: 16),

          _buildPerformanceGrid(),

          const SizedBox(height: 24),

          // Warning/Info messages
          _buildInfoMessages(),
        ],
      ),
    );
  }

  Widget _buildQualityBadge(String status) {
    Color badgeColor;
    IconData icon;

    switch (status) {
      case 'Excelente':
        badgeColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle;
        break;
      case 'Boa':
        badgeColor = const Color(0xFF8BC34A);
        icon = Icons.check_circle_outline;
        break;
      case 'Regular':
        badgeColor = const Color(0xFFFFC107);
        icon = Icons.warning_amber;
        break;
      case 'Necessita Ajustes':
        badgeColor = const Color(0xFFF44336);
        icon = Icons.error_outline;
        break;
      default:
        badgeColor = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 18),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: badgeColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingsGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildSettingCard(
          icon: Icons.speed,
          label: 'Velocidade do Cilindro',
          value: '${calculation.cylinderSpeed.toStringAsFixed(0)} RPM',
          range: calculation.cylinderSpeedRange,
          color: const Color(0xFF2196F3),
        ),
        _buildSettingCard(
          icon: Icons.tune,
          label: 'Abertura do Côncavo',
          value: '${calculation.concaveOpening.toStringAsFixed(1)} mm',
          range: calculation.concaveOpeningRange,
          color: const Color(0xFF9C27B0),
        ),
        _buildSettingCard(
          icon: Icons.air,
          label: 'Velocidade do Ventilador',
          value: '${calculation.fanSpeed.toStringAsFixed(0)} RPM',
          range: calculation.fanSpeedRange,
          color: const Color(0xFF00BCD4),
        ),
        _buildSettingCard(
          icon: Icons.grid_on,
          label: 'Abertura das Peneiras',
          value: '${calculation.sieveOpening.toStringAsFixed(1)} mm',
          range: calculation.sieveOpeningRange,
          color: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String label,
    required String value,
    required String range,
    required Color color,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Faixa: $range',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildMetricCard(
          icon: Icons.speed_outlined,
          label: 'Capacidade de Colheita',
          value: '${calculation.harvestCapacity.toStringAsFixed(2)} ha/h',
          color: const Color(0xFF4CAF50),
        ),
        _buildMetricCard(
          icon: Icons.warning_amber_outlined,
          label: 'Perda Estimada',
          value: '${calculation.estimatedLoss.toStringAsFixed(2)} kg/ha',
          color: _getLossColor(calculation.estimatedLoss, calculation.acceptableLoss),
        ),
        _buildMetricCard(
          icon: Icons.check_circle_outline,
          label: 'Perda Aceitável',
          value: '${(calculation.acceptableLoss * calculation.productivity * 60 / 100).toStringAsFixed(2)} kg/ha',
          color: const Color(0xFF8BC34A),
        ),
        _buildMetricCard(
          icon: Icons.water_drop_outlined,
          label: 'Umidade do Grão',
          value: '${calculation.moisture.toStringAsFixed(1)}%',
          color: const Color(0xFF2196F3),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLossColor(double estimatedLoss, double acceptableLoss) {
    final acceptableLossKgHa = acceptableLoss * calculation.productivity * 60 / 100;

    if (estimatedLoss <= acceptableLossKgHa) {
      return const Color(0xFF4CAF50); // Green - Good
    } else if (estimatedLoss <= acceptableLossKgHa * 1.5) {
      return const Color(0xFFFFC107); // Yellow - Warning
    } else {
      return const Color(0xFFF44336); // Red - Bad
    }
  }

  Widget _buildInfoMessages() {
    final messages = <Widget>[];

    // Moisture warning
    if (calculation.moisture > 16) {
      messages.add(
        _buildInfoMessage(
          icon: Icons.water_drop,
          message: 'Umidade elevada: Reduzir velocidade de colheita e ajustar regulagens',
          color: const Color(0xFFFFC107),
        ),
      );
    }

    // Speed warning
    if (calculation.harvestSpeed > 6) {
      messages.add(
        _buildInfoMessage(
          icon: Icons.speed,
          message: 'Velocidade alta: Aumenta o risco de perdas. Monitorar constantemente',
          color: const Color(0xFFFF9800),
        ),
      );
    }

    // Loss warning
    final acceptableLossKgHa = calculation.acceptableLoss * calculation.productivity * 60 / 100;
    if (calculation.estimatedLoss > acceptableLossKgHa * 1.5) {
      messages.add(
        _buildInfoMessage(
          icon: Icons.error_outline,
          message: 'Perdas acima do aceitável: Reduzir velocidade e revisar regulagens',
          color: const Color(0xFFF44336),
        ),
      );
    }

    // Capacity info
    if (calculation.harvestCapacity > 4) {
      messages.add(
        _buildInfoMessage(
          icon: Icons.thumb_up_outlined,
          message: 'Ótima capacidade de colheita: Manter configurações atuais',
          color: const Color(0xFF4CAF50),
        ),
      );
    }

    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white24, height: 1),
        const SizedBox(height: 16),
        ...messages.map((msg) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: msg,
            )),
      ],
    );
  }

  Widget _buildInfoMessage({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
