import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/share_button.dart';
import '../../domain/entities/operational_cost_calculation.dart';

/// Result card widget for operational cost calculation - Dark theme
class OperationalCostResultCard extends StatelessWidget {
  final OperationalCostCalculation calculation;

  const OperationalCostResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF4CAF50); // Green for agriculture
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

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

            // Total Cost Highlight
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
                    'Custo Total da Operação',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(calculation.totalCost),
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${calculation.areaWorked.toStringAsFixed(2)} hectares trabalhados',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cost per Hectare
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custo por Hectare',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${currencyFormat.format(calculation.totalCostPerHa)}/ha',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cost Breakdown
            _buildSectionTitle('Detalhamento de Custos por Hectare'),
            const SizedBox(height: 12),
            
            _buildCostBreakdownBar(),
            
            const SizedBox(height: 16),

            _buildCostDetailRow(
              'Combustível',
              calculation.fuelCostPerHa,
              calculation.totalCostPerHa,
              Icons.local_gas_station,
              const Color(0xFFFF9800), // Orange
            ),
            _buildCostDetailRow(
              'Mão de Obra',
              calculation.laborCostPerHa,
              calculation.totalCostPerHa,
              Icons.person,
              const Color(0xFF2196F3), // Blue
            ),
            _buildCostDetailRow(
              'Maquinário',
              calculation.machineryCostPerHa,
              calculation.totalCostPerHa,
              Icons.precision_manufacturing,
              const Color(0xFF9C27B0), // Purple
            ),

            const SizedBox(height: 20),

            // Input Parameters
            _buildSectionTitle('Parâmetros Utilizados'),
            const SizedBox(height: 12),

            // Fuel Parameters
            _buildParameterGroup(
              'Combustível',
              Icons.local_gas_station,
              [
                _buildParameter(
                  'Consumo',
                  '${calculation.fuelConsumption.toStringAsFixed(2)} L/ha',
                ),
                _buildParameter(
                  'Preço',
                  '${currencyFormat.format(calculation.fuelPrice)}/L',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Labor Parameters
            _buildParameterGroup(
              'Mão de Obra',
              Icons.person,
              [
                _buildParameter(
                  'Horas',
                  '${calculation.laborHours.toStringAsFixed(2)} h/ha',
                ),
                _buildParameter(
                  'Custo Horário',
                  '${currencyFormat.format(calculation.laborCost)}/h',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Machinery Parameters
            _buildParameterGroup(
              'Maquinário',
              Icons.precision_manufacturing,
              [
                _buildParameter(
                  'Valor',
                  currencyFormat.format(calculation.machineryValue),
                ),
                _buildParameter(
                  'Vida Útil',
                  '${calculation.usefulLife.toStringAsFixed(0)} horas',
                ),
                _buildParameter(
                  'Manutenção',
                  '${calculation.maintenanceFactor.toStringAsFixed(1)}%',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recommendations
            _buildRecommendationsSection(),
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

  Widget _buildCostBreakdownBar() {
    final total = calculation.totalCostPerHa;
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final fuelPercent = (calculation.fuelCostPerHa / total) * 100;
    final laborPercent = (calculation.laborCostPerHa / total) * 100;
    final machineryPercent = (calculation.machineryCostPerHa / total) * 100;

    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (fuelPercent > 0)
                  Flexible(
                    flex: fuelPercent.round(),
                    child: Container(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.7),
                      alignment: Alignment.center,
                      child: fuelPercent > 15
                          ? Text(
                              '${fuelPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                if (laborPercent > 0)
                  Flexible(
                    flex: laborPercent.round(),
                    child: Container(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.7),
                      alignment: Alignment.center,
                      child: laborPercent > 15
                          ? Text(
                              '${laborPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                if (machineryPercent > 0)
                  Flexible(
                    flex: machineryPercent.round(),
                    child: Container(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.7),
                      alignment: Alignment.center,
                      child: machineryPercent > 15
                          ? Text(
                              '${machineryPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostDetailRow(
    String label,
    double value,
    double total,
    IconData icon,
    Color color,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final percentage = total > 0 ? (value / total) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% do total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${currencyFormat.format(value)}/ha',
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

  Widget _buildParameterGroup(
    String title,
    IconData icon,
    List<Widget> parameters,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                icon,
                color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...parameters,
        ],
      ),
    );
  }

  Widget _buildParameter(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = _getRecommendations();

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
                'Recomendações',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
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

  List<String> _getRecommendations() {
    final recommendations = <String>[];
    final total = calculation.totalCostPerHa;

    // Calculate cost percentages
    final fuelPercent = total > 0 ? (calculation.fuelCostPerHa / total) * 100 : 0;
    final laborPercent = total > 0 ? (calculation.laborCostPerHa / total) * 100 : 0;
    final machineryPercent = total > 0 ? (calculation.machineryCostPerHa / total) * 100 : 0;

    // Fuel-based recommendations
    if (fuelPercent > 50) {
      recommendations.add(
        'Combustível representa ${fuelPercent.toStringAsFixed(0)}% do custo. '
        'Considere otimizar rotas e verificar regulagens do motor.',
      );
    }

    if (calculation.fuelConsumption > 15) {
      recommendations.add(
        'Consumo de combustível elevado. Revise manutenção e calibração do motor.',
      );
    }

    // Labor-based recommendations
    if (laborPercent > 40) {
      recommendations.add(
        'Mão de obra representa ${laborPercent.toStringAsFixed(0)}% do custo. '
        'Avalie automação ou aumento de produtividade.',
      );
    }

    // Machinery-based recommendations
    if (machineryPercent > 50) {
      recommendations.add(
        'Custo de maquinário elevado (${machineryPercent.toStringAsFixed(0)}%). '
        'Considere maior utilização anual ou terceirização.',
      );
    }

    // Operation-specific recommendations
    switch (calculation.operationType) {
      case 'Preparo':
        recommendations.add(
          'Para preparo de solo, considere práticas conservacionistas como plantio direto.',
        );
        break;
      case 'Plantio':
        recommendations.add(
          'Otimize a regulagem da plantadeira para reduzir retrabalho e desperdício.',
        );
        break;
      case 'Pulverização':
        recommendations.add(
          'Monitore condições climáticas para evitar deriva e reaplica ções.',
        );
        break;
      case 'Colheita':
        recommendations.add(
          'Minimize perdas e mantenha velocidade adequada para qualidade do trabalho.',
        );
        break;
    }

    // General recommendations
    recommendations
      ..add('Faça manutenção preventiva regular para reduzir custos inesperados')
      ..add('Registre custos por operação para comparação e otimização futura');

    return recommendations;
  }

  String _formatShareText() {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return '''
💰 Custo Operacional - ${calculation.operationType}

📊 RESUMO:
• Custo Total: ${currencyFormat.format(calculation.totalCost)}
• Área: ${calculation.areaWorked.toStringAsFixed(2)} ha
• Custo/ha: ${currencyFormat.format(calculation.totalCostPerHa)}

💵 DETALHAMENTO POR HECTARE:
• Combustível: ${currencyFormat.format(calculation.fuelCostPerHa)}/ha
• Mão de Obra: ${currencyFormat.format(calculation.laborCostPerHa)}/ha
• Maquinário: ${currencyFormat.format(calculation.machineryCostPerHa)}/ha

⚙️ PARÂMETROS:
Combustível:
  • ${calculation.fuelConsumption.toStringAsFixed(2)} L/ha × ${currencyFormat.format(calculation.fuelPrice)}/L

Mão de Obra:
  • ${calculation.laborHours.toStringAsFixed(2)} h/ha × ${currencyFormat.format(calculation.laborCost)}/h

Maquinário:
  • Valor: ${currencyFormat.format(calculation.machineryValue)}
  • Vida Útil: ${calculation.usefulLife.toStringAsFixed(0)} horas
  • Manutenção: ${calculation.maintenanceFactor.toStringAsFixed(1)}%

Calculado em: ${DateFormat('dd/MM/yyyy HH:mm').format(calculation.calculatedAt)}
''';
  }
}
