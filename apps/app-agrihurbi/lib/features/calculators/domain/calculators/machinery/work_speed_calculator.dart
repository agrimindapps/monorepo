import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Velocidade de Trabalho
/// Calcula a velocidade necessária para atingir determinado rendimento operacional
class WorkSpeedCalculator extends CalculatorEntity {
  const WorkSpeedCalculator()
      : super(
          id: 'work_speed',
          name: 'Velocidade de Trabalho',
          description:
              'Calcula a velocidade de trabalho necessária para atingir determinado rendimento operacional ou vice-versa',
          category: CalculatorCategory.machinery,
          parameters: const [
            CalculatorParameter(
              id: 'implement_width',
              name: 'Largura do Implemento',
              description: 'Largura efetiva de trabalho do implemento em metros',
              type: ParameterType.decimal,
              unit: ParameterUnit.metro,
              minValue: 0.5,
              maxValue: 50.0,
              defaultValue: 6.0,
              validationMessage: 'Largura deve estar entre 0.5 e 50 m',
            ),
            CalculatorParameter(
              id: 'operational_yield',
              name: 'Rendimento Operacional',
              description: 'Rendimento operacional desejado em hectares por hora',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.1,
              maxValue: 100.0,
              defaultValue: 3.0,
              validationMessage: 'Rendimento deve estar entre 0.1 e 100 ha/h',
            ),
            CalculatorParameter(
              id: 'field_efficiency',
              name: 'Eficiência de Campo',
              description: 'Percentual de eficiência considerando manobras e paradas (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 50.0,
              maxValue: 95.0,
              defaultValue: 75.0,
              validationMessage: 'Eficiência deve estar entre 50% e 95%',
            ),
            CalculatorParameter(
              id: 'operation_type',
              name: 'Tipo de Operação',
              description: 'Tipo de operação agrícola realizada',
              type: ParameterType.selection,
              options: [
                'Preparo de solo',
                'Plantio/Semeadura',
                'Pulverização',
                'Adubação',
                'Colheita',
                'Roçagem',
                'Gradagem',
                'Subsolagem',
              ],
              defaultValue: 'Pulverização',
            ),
            CalculatorParameter(
              id: 'terrain_type',
              name: 'Tipo de Terreno',
              description: 'Condição do terreno de trabalho',
              type: ParameterType.selection,
              options: [
                'Plano (<5% declive)',
                'Suave ondulado (5-10%)',
                'Ondulado (10-20%)',
                'Acidentado (>20%)',
              ],
              defaultValue: 'Plano (<5% declive)',
            ),
          ],
          formula: 'Velocidade = (Rendimento × 10) / (Largura × Eficiência)',
          references: const [
            'ASABE Standards - Agricultural Machinery Management',
            'Mialhe (1974) - Máquinas Agrícolas: Ensaios e Certificação',
            'EMBRAPA - Manual de Mecanização Agrícola',
          ],
          tags: const ['velocidade', 'maquinário', 'rendimento', 'operação'],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double implementWidth = double.parse(inputs['implement_width'].toString());
      final double operationalYield = double.parse(inputs['operational_yield'].toString());
      final double fieldEfficiency = double.parse(inputs['field_efficiency'].toString()) / 100;
      final String operationType = inputs['operation_type'].toString();
      final String terrainType = inputs['terrain_type'].toString();

      // Fator de correção por tipo de terreno
      final double terrainFactor = _getTerrainFactor(terrainType);
      
      // Velocidade calculada (km/h)
      // Fórmula: V = (R × 10) / (L × E)
      // Onde: V = velocidade (km/h), R = rendimento (ha/h), L = largura (m), E = eficiência
      final double calculatedSpeed = (operationalYield * 10) / (implementWidth * fieldEfficiency);
      
      // Velocidade ajustada pelo terreno
      final double adjustedSpeed = calculatedSpeed / terrainFactor;
      
      // Faixas de velocidade recomendadas por operação
      final Map<String, dynamic> speedLimits = _getSpeedLimits(operationType);
      final double minSpeed = speedLimits['min'] as double;
      final double maxSpeed = speedLimits['max'] as double;
      final double optimalSpeed = speedLimits['optimal'] as double;
      
      // Verificar se velocidade está na faixa adequada
      final bool isSpeedOk = adjustedSpeed >= minSpeed && adjustedSpeed <= maxSpeed;
      
      // Rendimento real considerando velocidade ótima
      final double realYieldOptimal = (optimalSpeed * implementWidth * fieldEfficiency) / 10;
      
      // Consumo estimado de combustível (L/h)
      final double fuelConsumption = _estimateFuelConsumption(operationType, adjustedSpeed);
      
      // Horas de trabalho por dia (jornada de 10h com eficiência)
      final double effectiveHoursPerDay = 10 * fieldEfficiency;
      final double areaPerDay = operationalYield * effectiveHoursPerDay;

      // Recomendações
      final List<String> recommendations = _generateRecommendations(
        adjustedSpeed,
        minSpeed,
        maxSpeed,
        optimalSpeed,
        operationType,
        terrainType,
        isSpeedOk,
      );

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Velocidade Calculada',
            value: CalculatorMath.roundTo(adjustedSpeed, 2),
            unit: 'km/h',
            description: 'Velocidade necessária para atingir o rendimento',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Velocidade Mínima Recomendada',
            value: CalculatorMath.roundTo(minSpeed, 1),
            unit: 'km/h',
            description: 'Velocidade mínima para a operação',
          ),
          CalculationResultValue(
            label: 'Velocidade Máxima Recomendada',
            value: CalculatorMath.roundTo(maxSpeed, 1),
            unit: 'km/h',
            description: 'Velocidade máxima para a operação',
          ),
          CalculationResultValue(
            label: 'Velocidade Ótima',
            value: CalculatorMath.roundTo(optimalSpeed, 1),
            unit: 'km/h',
            description: 'Velocidade ideal para qualidade da operação',
          ),
          CalculationResultValue(
            label: 'Rendimento com Vel. Ótima',
            value: CalculatorMath.roundTo(realYieldOptimal, 2),
            unit: 'ha/h',
            description: 'Rendimento usando velocidade ótima',
          ),
          CalculationResultValue(
            label: 'Área por Dia (10h)',
            value: CalculatorMath.roundTo(areaPerDay, 1),
            unit: 'ha/dia',
            description: 'Área trabalhada em uma jornada',
          ),
          CalculationResultValue(
            label: 'Consumo Estimado',
            value: CalculatorMath.roundTo(fuelConsumption, 1),
            unit: 'L/h',
            description: 'Consumo estimado de combustível',
          ),
          CalculationResultValue(
            label: 'Fator de Terreno',
            value: CalculatorMath.roundTo(terrainFactor, 2),
            unit: '',
            description: 'Fator de correção pelo tipo de terreno',
          ),
          CalculationResultValue(
            label: 'Status da Velocidade',
            value: isSpeedOk ? 'Adequada' : 'Fora da Faixa',
            unit: '',
            description: 'Indica se a velocidade está na faixa recomendada',
          ),
        ],
        recommendations: recommendations,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  double _getTerrainFactor(String terrainType) {
    switch (terrainType) {
      case 'Plano (<5% declive)':
        return 1.0;
      case 'Suave ondulado (5-10%)':
        return 1.1;
      case 'Ondulado (10-20%)':
        return 1.25;
      case 'Acidentado (>20%)':
        return 1.5;
      default:
        return 1.0;
    }
  }

  Map<String, dynamic> _getSpeedLimits(String operationType) {
    final Map<String, Map<String, double>> limits = {
      'Preparo de solo': {'min': 4.0, 'max': 8.0, 'optimal': 6.0},
      'Plantio/Semeadura': {'min': 4.0, 'max': 10.0, 'optimal': 6.0},
      'Pulverização': {'min': 5.0, 'max': 15.0, 'optimal': 8.0},
      'Adubação': {'min': 5.0, 'max': 12.0, 'optimal': 8.0},
      'Colheita': {'min': 3.0, 'max': 8.0, 'optimal': 5.0},
      'Roçagem': {'min': 3.0, 'max': 8.0, 'optimal': 5.0},
      'Gradagem': {'min': 5.0, 'max': 10.0, 'optimal': 7.0},
      'Subsolagem': {'min': 3.0, 'max': 6.0, 'optimal': 4.5},
    };

    return limits[operationType] ?? {'min': 4.0, 'max': 10.0, 'optimal': 7.0};
  }

  double _estimateFuelConsumption(String operationType, double speed) {
    // Consumo base em L/h por tipo de operação
    final Map<String, double> baseConsumption = {
      'Preparo de solo': 18.0,
      'Plantio/Semeadura': 12.0,
      'Pulverização': 8.0,
      'Adubação': 10.0,
      'Colheita': 25.0,
      'Roçagem': 10.0,
      'Gradagem': 15.0,
      'Subsolagem': 22.0,
    };

    final double baseRate = baseConsumption[operationType] ?? 12.0;
    // Ajuste por velocidade (consumo aumenta com velocidade)
    return baseRate * (1 + (speed - 5) * 0.05);
  }

  List<String> _generateRecommendations(
    double calculatedSpeed,
    double minSpeed,
    double maxSpeed,
    double optimalSpeed,
    String operationType,
    String terrainType,
    bool isSpeedOk,
  ) {
    final List<String> recommendations = [];

    if (!isSpeedOk) {
      if (calculatedSpeed < minSpeed) {
        recommendations.add(
          '⚠️ Velocidade abaixo do recomendado. Aumente a velocidade para ${minSpeed.toStringAsFixed(1)} km/h ou mais.',
        );
        recommendations.add(
          'Considere reduzir o rendimento operacional esperado para valores mais realistas.',
        );
      } else {
        recommendations.add(
          '⚠️ Velocidade acima do recomendado. Reduzir a velocidade para no máximo ${maxSpeed.toStringAsFixed(1)} km/h.',
        );
        recommendations.add(
          'Velocidades muito altas comprometem a qualidade da operação.',
        );
      }
    } else {
      recommendations.add(
        '✓ Velocidade dentro da faixa recomendada para $operationType.',
      );
    }

    // Recomendações por operação
    switch (operationType) {
      case 'Pulverização':
        recommendations.add(
          'Para pulverização, mantenha velocidade constante para uniformidade de aplicação.',
        );
        recommendations.add(
          'Verifique a pressão do sistema de acordo com a velocidade utilizada.',
        );
        break;
      case 'Plantio/Semeadura':
        recommendations.add(
          'Velocidades altas no plantio podem comprometer a profundidade e espaçamento.',
        );
        break;
      case 'Colheita':
        recommendations.add(
          'Ajuste a velocidade de acordo com a produtividade e umidade do grão.',
        );
        break;
      case 'Preparo de solo':
      case 'Subsolagem':
        recommendations.add(
          'Operações de solo pesado requerem velocidades menores para eficiência energética.',
        );
        break;
    }

    // Recomendações por terreno
    if (terrainType.contains('Acidentado') || terrainType.contains('Ondulado')) {
      recommendations.add(
        'Em terrenos $terrainType, reduza a velocidade nas cabeceiras e curvas.',
      );
      recommendations.add(
        'Maior atenção à segurança em declividades acentuadas.',
      );
    }

    recommendations.add(
      'A velocidade ótima de ${optimalSpeed.toStringAsFixed(1)} km/h equilibra produtividade e qualidade.',
    );

    return recommendations;
  }
}
