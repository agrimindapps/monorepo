import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../domain/entities/tractor_ballast_calculation.dart';

/// Result card widget for tractor ballast calculation - Dark theme
class TractorBallastResultCard extends StatelessWidget {
  final TractorBallastCalculation calculation;

  const TractorBallastResultCard({
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
                        'Lastro do Trator',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${calculation.tractorType} - ${calculation.operationType}',
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

            // Total ballast needed highlight
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
                    'Lastro Total Necessário',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${NumberFormat('#,##0', 'pt_BR').format(calculation.totalBallastNeeded)} kg',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${calculation.numberOfFrontWeights + calculation.numberOfRearWeights} pesos de 40kg',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Front ballast section
            _buildBallastSection(
              title: 'Lastro Dianteiro',
              icon: Icons.arrow_upward,
              ballastNeeded: calculation.frontBallastNeeded,
              numberOfWeights: calculation.numberOfFrontWeights,
              idealWeight: calculation.idealFrontWeight,
              weightPercent: calculation.frontWeightPercent,
            ),

            const SizedBox(height: 12),

            // Rear ballast section
            _buildBallastSection(
              title: 'Lastro Traseiro',
              icon: Icons.arrow_downward,
              ballastNeeded: calculation.rearBallastNeeded,
              numberOfWeights: calculation.numberOfRearWeights,
              idealWeight: calculation.idealRearWeight,
              weightPercent: calculation.rearWeightPercent,
            ),

            const SizedBox(height: 20),

            // Weight distribution details
            _buildDetailsSection(),

            const SizedBox(height: 20),

            // Safety recommendations
            _buildRecommendationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBallastSection({
    required String title,
    required IconData icon,
    required double ballastNeeded,
    required int numberOfWeights,
    required double idealWeight,
    required double weightPercent,
  }) {
    const accentColor = Color(0xFF4CAF50);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
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
                    'Lastro Necessário',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat('#,##0', 'pt_BR').format(ballastNeeded)} kg',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Pesos de 40kg',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$numberOfWeights unidades',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                label: 'Peso Ideal',
                value: '${NumberFormat('#,##0', 'pt_BR').format(idealWeight)} kg',
              ),
              _buildInfoItem(
                label: 'Distribuição',
                value: '${weightPercent.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_weight,
                color: Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Detalhes do Conjunto',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  label: 'Peso do Trator',
                  value: '${NumberFormat('#,##0', 'pt_BR').format(calculation.tractorWeight)} kg',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  label: 'Peso do Implemento',
                  value: '${NumberFormat('#,##0', 'pt_BR').format(calculation.implementWeight)} kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  label: 'Peso Total com Lastro',
                  value: '${NumberFormat('#,##0', 'pt_BR').format(calculation.totalWeight)} kg',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  label: 'Total de Pesos',
                  value: '${calculation.numberOfFrontWeights + calculation.numberOfRearWeights} × 40kg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    const accentColor = Color(0xFF4CAF50);
    
    final recommendations = _getRecommendations();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recomendações de Segurança',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rec,
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

  Widget _buildInfoItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[
      'Sempre distribua os pesos de forma equilibrada em cada lado do trator',
      'Verifique a calibragem dos pneus após adicionar lastro',
      'Ajuste o lastro de acordo com as condições do solo e tipo de operação',
    ];

    if (calculation.totalBallastNeeded > 1000) {
      recommendations.add(
        'Alta quantidade de lastro necessária - considere pesos líquidos ou lastros adicionais nos pneus',
      );
    }

    if (calculation.operationType == 'Preparo Pesado') {
      recommendations.add(
        'Em preparo pesado, mantenha velocidade adequada para evitar patinação excessiva',
      );
    }

    return recommendations;
  }

  String _formatShareText() {
    final buffer = StringBuffer()
      ..writeln('🚜 CÁLCULO DE LASTRO DO TRATOR')
      ..writeln('')
      ..writeln('Tipo: ${calculation.tractorType}')
      ..writeln('Operação: ${calculation.operationType}')
      ..writeln('')
      ..writeln('PESOS:')
      ..writeln(
        'Trator: ${NumberFormat('#,##0', 'pt_BR').format(calculation.tractorWeight)} kg',
      )
      ..writeln(
        'Implemento: ${NumberFormat('#,##0', 'pt_BR').format(calculation.implementWeight)} kg',
      )
      ..writeln('')
      ..writeln('LASTRO NECESSÁRIO:')
      ..writeln(
        'Dianteiro: ${NumberFormat('#,##0', 'pt_BR').format(calculation.frontBallastNeeded)} kg (${calculation.numberOfFrontWeights} pesos)',
      )
      ..writeln(
        'Traseiro: ${NumberFormat('#,##0', 'pt_BR').format(calculation.rearBallastNeeded)} kg (${calculation.numberOfRearWeights} pesos)',
      )
      ..writeln(
        'TOTAL: ${NumberFormat('#,##0', 'pt_BR').format(calculation.totalBallastNeeded)} kg',
      )
      ..writeln('')
      ..writeln('DISTRIBUIÇÃO FINAL:')
      ..writeln('Frente: ${calculation.frontWeightPercent.toStringAsFixed(1)}%')
      ..writeln('Traseira: ${calculation.rearWeightPercent.toStringAsFixed(1)}%')
      ..writeln('')
      ..writeln('Calculado em: app-calculei');

    return buffer.toString();
  }
}
