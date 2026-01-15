import 'package:flutter/material.dart';

import '../../../../shared/widgets/share_button.dart';
import '../../domain/entities/nozzle_flow_calculation.dart';

/// Card de resultado do cálculo de vazão de bicos
class NozzleFlowResultCard extends StatelessWidget {
  final NozzleFlowCalculation calculation;

  const NozzleFlowResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BC34A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Color(0xFF8BC34A),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Resultado do Cálculo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ShareButton(
                  text: ShareFormatter.formatNozzleFlowCalculation(
                    applicationRate: calculation.applicationRate,
                    workingSpeed: calculation.workingSpeed,
                    nozzleSpacing: calculation.nozzleSpacing,
                    pressure: calculation.pressure,
                    nozzleType: calculation.nozzleType.name,
                    numberOfNozzles: calculation.numberOfNozzles,
                    requiredFlow: calculation.requiredFlow,
                    totalFlow: calculation.totalFlow,
                    workingWidth: calculation.workingWidth,
                    recommendedNozzle: calculation.recommendedNozzle?.displayName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Vazão requerida - DESTAQUE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Vazão por Bico',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.requiredFlow.toStringAsFixed(2)} L/min',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bico recomendado
            if (calculation.recommendedNozzle != null) ...[
              _buildRecommendedNozzle(context),
              const SizedBox(height: 20),
            ],

            // Informações adicionais
            _buildInfoRow(
              icon: Icons.speed,
              label: 'Vazão Total da Barra',
              value: '${calculation.totalFlow.toStringAsFixed(1)} L/min',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.straighten,
              label: 'Largura de Trabalho',
              value: '${calculation.workingWidth.toStringAsFixed(2)} m',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.opacity,
              label: 'Taxa Confirmada',
              value: '${calculation.confirmedApplicationRate.toStringAsFixed(1)} L/ha',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.category,
              label: 'Tipo de Bico',
              value: calculation.nozzleType.displayName,
            ),

            // Dicas de calibração
            if (calculation.calibrationTips.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dicas de Calibração',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...calculation.calibrationTips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Color(0xFF8BC34A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedNozzle(BuildContext context) {
    final nozzle = calculation.recommendedNozzle!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(nozzle.colorValue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(nozzle.colorValue).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Círculo com a cor
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(nozzle.colorValue),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(nozzle.colorValue).withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bico Recomendado',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nozzle.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Faixa: ${nozzle.minFlow.toStringAsFixed(1)}-${nozzle.maxFlow.toStringAsFixed(1)} L/min',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
