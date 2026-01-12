import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../domain/entities/tire_pressure_calculation.dart';

/// Result card widget for tire pressure calculation - Dark theme
class TirePressureResultCard extends StatelessWidget {
  final TirePressureCalculation calculation;

  const TirePressureResultCard({
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

            // Main pressure highlight
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
                    'Pressão Recomendada',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        calculation.recommendedPressurePsi.toStringAsFixed(1),
                        style: const TextStyle(
                          color: accentColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PSI',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${calculation.recommendedPressureBar.toStringAsFixed(2)} bar',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pressure Range
            _buildSectionTitle('Faixa de Pressão Segura'),
            const SizedBox(height: 12),
            _buildPressureRange(),

            const SizedBox(height: 20),

            // Tire and Load Information
            _buildSectionTitle('Informações do Pneu'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Tipo de Pneu',
              calculation.tireType,
              icon: Icons.tire_repair,
            ),
            _buildDetailRow(
              'Tamanho',
              calculation.tireSize,
              icon: Icons.straighten,
            ),
            _buildDetailRow(
              'Carga no Eixo',
              '${NumberFormat('#,##0', 'pt_BR').format(calculation.axleLoad)} kg',
              icon: Icons.fitness_center,
            ),

            const SizedBox(height: 20),

            // Field Verification
            _buildSectionTitle('Verificação em Campo'),
            const SizedBox(height: 12),
            _buildFootprintSection(),

            const SizedBox(height: 20),

            // Calculation Details
            _buildSectionTitle('Detalhes do Cálculo'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Pressão Base',
              '${calculation.basePressurePsi.toStringAsFixed(1)} PSI',
              icon: Icons.speed,
            ),
            _buildDetailRow(
              'Ajuste por Tipo de Pneu',
              _formatAdjustment(calculation.tireTypeAdjustment),
              icon: Icons.settings,
            ),
            _buildDetailRow(
              'Ajuste por Operação',
              _formatAdjustment(calculation.operationAdjustment),
              icon: Icons.tune,
            ),

            const SizedBox(height: 20),

            // Tips and Recommendations
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

  Widget _buildPressureRange() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mínima',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${calculation.minPressurePsi.toStringAsFixed(1)} PSI',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${calculation.minPressureBar.toStringAsFixed(2)} bar',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ideal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${calculation.recommendedPressurePsi.toStringAsFixed(1)} PSI',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${calculation.recommendedPressureBar.toStringAsFixed(2)} bar',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Máxima',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${calculation.maxPressurePsi.toStringAsFixed(1)} PSI',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${calculation.maxPressureBar.toStringAsFixed(2)} bar',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFootprintSection() {
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
                Icons.straighten,
                color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Comprimento da Pegada Esperado',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${calculation.footprintLength.toStringAsFixed(1)} cm',
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Meça o comprimento da pegada do pneu no solo. Deve estar próximo a este valor para confirmar a pressão correta.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
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
      case 'Campo':
        tips.add(
          'Pressão reduzida em 15% para melhor tração e menor compactação do solo',
        );
        tips.add('Ideal para operações de preparo, plantio e pulverização');
        tips.add(
          'Aumenta área de contato, distribuindo melhor o peso da máquina',
        );
        break;

      case 'Estrada':
        tips.add(
          'Pressão aumentada em 15% para transporte rodoviário seguro',
        );
        tips.add('Reduz desgaste lateral e aquecimento excessivo');
        tips.add('Melhora economia de combustível no transporte');
        break;

      case 'Misto':
        tips.add('Pressão equilibrada para uso em campo e estrada');
        tips.add('Compromisso entre tração e durabilidade');
        tips.add(
          'Ideal quando não é possível ajustar pressão entre operações',
        );
        break;
    }

    // Tire type specific tips
    switch (calculation.tireType) {
      case 'Agrícola Radial':
        tips.add(
          'Pneus radiais trabalham com 10-15% menos pressão que diagonais',
        );
        tips.add('Melhor distribuição de carga e menor compactação');
        tips.add('Maior área de contato e melhor tração');
        break;

      case 'Agrícola Diagonal':
        tips.add('Pneus diagonais requerem maior pressão para mesma carga');
        tips.add('Estrutura mais rígida, menor flexibilidade lateral');
        break;

      case 'Implemento':
        tips.add('Pneus de implementos suportam cargas variáveis');
        tips.add('Ajuste a pressão conforme carga transportada');
        break;
    }

    // General tips
    tips
      ..add('Verifique a pressão com pneus frios (antes do trabalho)')
      ..add('Calibre regularmente, pelo menos uma vez por semana')
      ..add('Pressão incorreta aumenta consumo de combustível')
      ..add('Use manômetro calibrado para medições precisas');

    return tips;
  }

  String _formatAdjustment(double adjustment) {
    final percentage = ((adjustment - 1.0) * 100).abs();
    if (adjustment > 1.0) {
      return '+${percentage.toStringAsFixed(0)}%';
    } else if (adjustment < 1.0) {
      return '-${percentage.toStringAsFixed(0)}%';
    } else {
      return '0%';
    }
  }

  String _formatShareText() {
    final formatter = NumberFormat('#,##0.0', 'pt_BR');

    return '''
📊 Pressão de Pneus - ${calculation.operationType}

🔧 PNEU:
• Tipo: ${calculation.tireType}
• Tamanho: ${calculation.tireSize}
• Carga: ${NumberFormat('#,##0', 'pt_BR').format(calculation.axleLoad)} kg

💨 PRESSÃO RECOMENDADA:
• ${formatter.format(calculation.recommendedPressurePsi)} PSI
• ${formatter.format(calculation.recommendedPressureBar)} bar

📏 FAIXA SEGURA:
• Mín: ${formatter.format(calculation.minPressurePsi)} PSI (${formatter.format(calculation.minPressureBar)} bar)
• Máx: ${formatter.format(calculation.maxPressurePsi)} PSI (${formatter.format(calculation.maxPressureBar)} bar)

📐 VERIFICAÇÃO EM CAMPO:
• Comprimento da pegada: ${formatter.format(calculation.footprintLength)} cm

Calculado em: ${DateFormat('dd/MM/yyyy HH:mm').format(calculation.calculatedAt)}
''';
  }
}
