import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../domain/entities/field_capacity_calculation.dart';

/// Result card widget for field capacity calculation - Dark theme
class FieldCapacityResultCard extends StatelessWidget {
  final FieldCapacityCalculation calculation;

  const FieldCapacityResultCard({
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
                    Icons.check_circle,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resultado - ${calculation.operationType}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ShareButton(
                  text: _formatShareText(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main capacity highlight
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
                    'Capacidade Efetiva',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.effectiveCapacity.toStringAsFixed(2)} ha/h',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${calculation.hoursPerHectare.toStringAsFixed(2)} horas por hectare',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Capacity Details
            _buildSectionTitle('Capacidades Calculadas'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Capacidade Teórica',
              '${calculation.theoreticalCapacity.toStringAsFixed(2)} ha/h',
              icon: Icons.speed,
            ),
            _buildDetailRow(
              'Capacidade Efetiva',
              '${calculation.effectiveCapacity.toStringAsFixed(2)} ha/h',
              icon: Icons.agriculture,
            ),
            _buildDetailRow(
              'Eficiência de Campo',
              '${calculation.fieldEfficiency.toStringAsFixed(1)}%',
              icon: Icons.percent,
            ),

            const SizedBox(height: 20),

            // Daily Productivity
            _buildSectionTitle('Produtividade Diária'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Jornada de 8 horas',
              '${calculation.hectaresPerDay8h.toStringAsFixed(2)} ha/dia',
              icon: Icons.wb_sunny,
            ),
            _buildDetailRow(
              'Jornada de 10 horas',
              '${calculation.hectaresPerDay10h.toStringAsFixed(2)} ha/dia',
              icon: Icons.access_time,
            ),

            const SizedBox(height: 20),

            // Machine Parameters
            _buildSectionTitle('Parâmetros da Máquina'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Largura de Trabalho',
              '${calculation.workingWidth.toStringAsFixed(2)} m',
              icon: Icons.straighten,
            ),
            _buildDetailRow(
              'Velocidade',
              '${calculation.workingSpeed.toStringAsFixed(2)} km/h',
              icon: Icons.speed,
            ),

            const SizedBox(height: 20),

            // Interpretation and Tips
            _buildInterpretationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationSection() {
    final tips = _getOperationTips();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dicas e Recomendações',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<String> _getOperationTips() {
    final tips = <String>[];

    // Operation-specific tips
    switch (calculation.operationType) {
      case 'Preparo':
        tips.add('Ajuste a velocidade conforme a profundidade e tipo de solo');
        tips.add('Solos argilosos requerem menor velocidade');
        tips.add('Verifique a calibração dos implementos regularmente');
        break;

      case 'Plantio':
        tips.add('Mantenha velocidade constante para distribuição uniforme');
        tips.add('Verifique o nível de sementes frequentemente');
        tips.add('Calibre a semeadora antes de iniciar');
        break;

      case 'Pulverização':
        tips.add('Evite aplicação com vento acima de 10 km/h');
        tips.add('Aplique em horários de menor temperatura');
        tips.add('Verifique a pressão e vazão dos bicos');
        break;

      case 'Colheita':
        tips.add('Ajuste a velocidade conforme umidade dos grãos');
        tips.add('Monitore perdas na plataforma e trilha');
        tips.add('Mantenha regulagens adequadas à cultura');
        break;
    }

    // General tips based on capacity
    if (calculation.effectiveCapacity < 1.0) {
      tips.add('Capacidade baixa: Considere aumentar largura ou velocidade');
    } else if (calculation.effectiveCapacity > 5.0) {
      tips.add('Alta capacidade: Garanta abastecimento e manutenção adequados');
    }

    // Efficiency tips
    if (calculation.fieldEfficiency < 65) {
      tips.add('Eficiência abaixo do ideal: Revise organização do trabalho');
    }

    tips
      ..add('Planeje manobras e abastecimentos para otimizar o tempo')
      ..add('Considere formato e tamanho do talhão no planejamento');

    return tips;
  }

  String _formatShareText() {
    final formatter = NumberFormat('#,##0.00', 'pt_BR');

    return '''
📊 Capacidade de Campo - ${calculation.operationType}

⚙️ PARÂMETROS:
• Largura: ${formatter.format(calculation.workingWidth)} m
• Velocidade: ${formatter.format(calculation.workingSpeed)} km/h
• Eficiência: ${formatter.format(calculation.fieldEfficiency)}%

📈 CAPACIDADES:
• Teórica: ${formatter.format(calculation.theoreticalCapacity)} ha/h
• Efetiva: ${formatter.format(calculation.effectiveCapacity)} ha/h
• Horas/ha: ${formatter.format(calculation.hoursPerHectare)} h

📅 PRODUTIVIDADE DIÁRIA:
• 8 horas: ${formatter.format(calculation.hectaresPerDay8h)} ha/dia
• 10 horas: ${formatter.format(calculation.hectaresPerDay10h)} ha/dia

Calculado em: ${DateFormat('dd/MM/yyyy HH:mm').format(calculation.calculatedAt)}
''';
  }
}
