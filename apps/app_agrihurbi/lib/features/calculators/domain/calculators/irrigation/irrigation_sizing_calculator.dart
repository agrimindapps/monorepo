import 'dart:math' as math;
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_parameter.dart';
import '../../entities/calculation_result.dart';
import '../../entities/calculator_engine.dart';

/// Calculadora de Dimensionamento de Sistema de Irrigação
/// Calcula componentes do sistema: bomba, tubulação e aspersores
class IrrigationSizingCalculator extends CalculatorEntity {
  IrrigationSizingCalculator()
      : super(
          id: 'irrigation_sizing',
          name: 'Dimensionamento de Irrigação',
          description: 'Dimensiona componentes do sistema de irrigação: bomba, tubulação e aspersores',
          category: CalculatorCategory.irrigation,
          parameters: const [
            CalculatorParameter(
              id: 'flow_rate',
              name: 'Vazão Necessária',
              description: 'Vazão total necessária do sistema (L/h)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 100.0,
              maxValue: 100000.0,
              defaultValue: 5000.0,
              validationMessage: 'Vazão deve estar entre 100 e 100.000 L/h',
            ),
            CalculatorParameter(
              id: 'total_head',
              name: 'Altura Manométrica Total',
              description: 'Altura manométrica total (AMT) em metros',
              type: ParameterType.decimal,
              unit: ParameterUnit.metro,
              minValue: 5.0,
              maxValue: 200.0,
              defaultValue: 30.0,
              validationMessage: 'AMT deve estar entre 5 e 200 metros',
            ),
            CalculatorParameter(
              id: 'pipe_length',
              name: 'Comprimento da Tubulação',
              description: 'Comprimento total da tubulação principal (m)',
              type: ParameterType.decimal,
              unit: ParameterUnit.metro,
              minValue: 10.0,
              maxValue: 5000.0,
              defaultValue: 200.0,
              validationMessage: 'Comprimento deve estar entre 10 e 5.000 metros',
            ),
            CalculatorParameter(
              id: 'operating_hours',
              name: 'Horas de Operação',
              description: 'Horas de operação diária do sistema',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 1.0,
              maxValue: 24.0,
              defaultValue: 8.0,
              validationMessage: 'Horas de operação deve estar entre 1 e 24',
            ),
            CalculatorParameter(
              id: 'system_type',
              name: 'Tipo de Sistema',
              description: 'Tipo do sistema de irrigação',
              type: ParameterType.selection,
              options: ['Aspersão', 'Gotejamento', 'Microaspersão', 'Pivô Central'],
              defaultValue: 'Aspersão',
            ),
          ],
          formula: 'Potência = (Q × AMT × γ) / (3600 × η); Diâmetro = √(4Q / (π × v))',
          references: const [
            'Bernardo et al. (2006) - Manual de Irrigação',
            'ABNT NBR 12218 - Projeto de rede de distribuição de água',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double flowRate = double.parse(inputs['flow_rate'].toString()); // L/h
      final double totalHead = double.parse(inputs['total_head'].toString()); // m
      final double pipeLength = double.parse(inputs['pipe_length'].toString()); // m
      final double operatingHours = double.parse(inputs['operating_hours'].toString()); // h
      final String systemType = inputs['system_type'].toString();

      // Conversões
      final double flowRateM3h = flowRate / 1000; // m³/h
      final double flowRateM3s = flowRateM3h / 3600; // m³/s

      // Cálculo da potência da bomba
      const double waterDensity = 1000; // kg/m³
      const double gravity = 9.81; // m/s²
      const double pumpEfficiency = 0.75; // 75% eficiência típica
      
      final double powerKW = (flowRateM3s * totalHead * waterDensity * gravity) / 
                            (1000 * pumpEfficiency);
      final double powerCV = powerKW / 0.736; // Conversão para CV

      // Cálculo do diâmetro da tubulação
      final double velocity = _getRecommendedVelocity(systemType);
      final double pipeDiameter = CalculatorMath.roundTo(
        2 * math.sqrt((flowRateM3s / (math.pi * velocity))), 3);
      final double pipeDiameterMm = pipeDiameter * 1000;

      // Perda de carga na tubulação (Hazen-Williams)
      final double pipeHead = _calculatePipeHeadLoss(
        flowRateM3h, pipeDiameter, pipeLength);

      // Consumo energético
      final double dailyConsumption = powerKW * operatingHours; // kWh/dia
      final double monthlyConsumption = dailyConsumption * 30; // kWh/mês

      // Dimensionamento de aspersores (se aplicável)
      final Map<String, double> sprinklerData = _calculateSprinklerSpacing(
        flowRate, systemType);

      // Recomendações
      final List<String> recommendations = _generateRecommendations(
        powerKW, velocity, systemType, pipeHead, totalHead);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Potência da Bomba',
            value: CalculatorMath.roundTo(powerKW, 2),
            unit: 'kW',
            description: 'Potência necessária da bomba',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Potência da Bomba (CV)',
            value: CalculatorMath.roundTo(powerCV, 2),
            unit: 'CV',
            description: 'Potência em cavalos-vapor',
          ),
          CalculationResultValue(
            label: 'Diâmetro da Tubulação',
            value: CalculatorMath.roundTo(pipeDiameterMm, 1),
            unit: 'mm',
            description: 'Diâmetro recomendado da tubulação principal',
          ),
          CalculationResultValue(
            label: 'Velocidade na Tubulação',
            value: CalculatorMath.roundTo(velocity, 2),
            unit: 'm/s',
            description: 'Velocidade de escoamento na tubulação',
          ),
          CalculationResultValue(
            label: 'Perda de Carga',
            value: CalculatorMath.roundTo(pipeHead, 2),
            unit: 'm',
            description: 'Perda de carga na tubulação principal',
          ),
          CalculationResultValue(
            label: 'Consumo Diário',
            value: CalculatorMath.roundTo(dailyConsumption, 2),
            unit: 'kWh/dia',
            description: 'Consumo energético diário',
          ),
          CalculationResultValue(
            label: 'Consumo Mensal',
            value: CalculatorMath.roundTo(monthlyConsumption, 1),
            unit: 'kWh/mês',
            description: 'Consumo energético mensal',
          ),
          if (sprinklerData.isNotEmpty) ...[
            CalculationResultValue(
              label: 'Espaçamento Aspersores',
              value: CalculatorMath.roundTo(sprinklerData['spacing']!, 1),
              unit: 'm',
              description: 'Espaçamento recomendado entre aspersores',
            ),
            CalculationResultValue(
              label: 'Número de Aspersores',
              value: sprinklerData['quantity']!.round(),
              unit: 'unidades',
              description: 'Quantidade estimada de aspersores',
            ),
          ],
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

  double _getRecommendedVelocity(String systemType) {
    switch (systemType) {
      case 'Aspersão':
        return 2.0; // m/s
      case 'Gotejamento':
        return 1.5; // m/s
      case 'Microaspersão':
        return 1.8; // m/s
      case 'Pivô Central':
        return 2.5; // m/s
      default:
        return 2.0; // m/s
    }
  }

  double _calculatePipeHeadLoss(double flowM3h, double diameter, double length) {
    // Fórmula de Hazen-Williams simplificada
    const double c = 130; // Coeficiente para PVC
    final double j = 10.643 * math.pow(flowM3h, 1.852) /
                    (math.pow(c, 1.852) * math.pow(diameter, 4.871));
    return j * length / 1000; // Perda em metros
  }

  Map<String, double> _calculateSprinklerSpacing(double flowRate, String systemType) {
    if (systemType != 'Aspersão' && systemType != 'Microaspersão') {
      return {};
    }

    // Valores típicos para dimensionamento
    final double sprinklerFlow = systemType == 'Aspersão' ? 600.0 : 200.0; // L/h por aspersor
    final double spacing = systemType == 'Aspersão' ? 12.0 : 6.0; // metros
    final double quantity = flowRate / sprinklerFlow;

    return {
      'spacing': spacing,
      'quantity': quantity,
    };
  }

  List<String> _generateRecommendations(
    double powerKW,
    double velocity,
    String systemType,
    double pipeHead,
    double totalHead,
  ) {
    final List<String> recommendations = [];

    // Recomendações sobre potência
    if (powerKW < 1.0) {
      recommendations.add('Sistema de baixa potência. Considere bomba monofásica.');
    } else if (powerKW > 10.0) {
      recommendations.add('Sistema de alta potência. Requer bomba trifásica.');
    }

    // Recomendações sobre velocidade
    if (velocity < 1.0) {
      recommendations.add('Velocidade baixa. Pode reduzir diâmetro da tubulação.');
    } else if (velocity > 3.0) {
      recommendations.add('Velocidade alta. Aumente diâmetro para reduzir perdas.');
    }

    // Recomendações sobre perdas
    final double lossPercentage = (pipeHead / totalHead) * 100;
    if (lossPercentage > 20) {
      recommendations.add('Perdas de carga elevadas (${lossPercentage.toStringAsFixed(1)}%). Revise dimensionamento.');
    }

    // Recomendações por tipo de sistema
    switch (systemType) {
      case 'Gotejamento':
        recommendations.add('Sistema de gotejamento: use filtros e monitore pressão.');
        break;
      case 'Aspersão':
        recommendations.add('Sistema de aspersão: verifique sobreposição dos aspersores.');
        break;
      case 'Pivô Central':
        recommendations.add('Pivô central: monitore desgaste dos pneus e estrutura.');
        break;
    }

    return recommendations;
  }
}