import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Tempo de Irrigação
/// Calcula o tempo necessário para aplicar determinada lâmina de água
class IrrigationTimeCalculator extends CalculatorEntity {
  const IrrigationTimeCalculator()
      : super(
          id: 'irrigation_time',
          name: 'Tempo de Irrigação',
          description: 'Calcula o tempo necessário para aplicar a lâmina de irrigação desejada',
          category: CalculatorCategory.irrigation,
          parameters: const [
            CalculatorParameter(
              id: 'water_depth',
              name: 'Lâmina de Irrigação',
              description: 'Lâmina de água a ser aplicada (mm)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 1.0,
              maxValue: 100.0,
              defaultValue: 15.0,
              validationMessage: 'Lâmina deve estar entre 1 e 100 mm',
            ),
            CalculatorParameter(
              id: 'flow_rate',
              name: 'Vazão do Sistema',
              description: 'Vazão total do sistema de irrigação (L/h)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 100.0,
              maxValue: 50000.0,
              defaultValue: 3000.0,
              validationMessage: 'Vazão deve estar entre 100 e 50.000 L/h',
            ),
            CalculatorParameter(
              id: 'irrigated_area',
              name: 'Área Irrigada',
              description: 'Área a ser irrigada (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.01,
              maxValue: 1000.0,
              defaultValue: 2.0,
              validationMessage: 'Área deve estar entre 0.01 e 1000 hectares',
            ),
            CalculatorParameter(
              id: 'system_efficiency',
              name: 'Eficiência do Sistema',
              description: 'Eficiência de aplicação do sistema (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 50.0,
              maxValue: 98.0,
              defaultValue: 85.0,
              validationMessage: 'Eficiência deve estar entre 50% e 98%',
            ),
            CalculatorParameter(
              id: 'uniformity',
              name: 'Uniformidade de Aplicação',
              description: 'Coeficiente de uniformidade (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 60.0,
              maxValue: 95.0,
              defaultValue: 80.0,
              validationMessage: 'Uniformidade deve estar entre 60% e 95%',
            ),
            CalculatorParameter(
              id: 'system_type',
              name: 'Tipo de Sistema',
              description: 'Tipo do sistema de irrigação',
              type: ParameterType.selection,
              options: ['Aspersão Convencional', 'Gotejamento', 'Microaspersão', 'Pivô Central', 'Aspersão Autopropelido'],
              defaultValue: 'Aspersão Convencional',
            ),
            CalculatorParameter(
              id: 'wind_speed',
              name: 'Velocidade do Vento',
              description: 'Velocidade média do vento (m/s) - opcional',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 0.0,
              maxValue: 15.0,
              defaultValue: 2.0,
              required: false,
              validationMessage: 'Velocidade do vento deve estar entre 0 e 15 m/s',
            ),
          ],
          formula: 'Tempo = (Lâmina × Área) / (Vazão × Eficiência)',
          references: const [
            'Bernardo et al. (2006) - Manual de Irrigação',
            'Mantovani et al. (2009) - Irrigação: Princípios e Métodos',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double waterDepth = double.parse(inputs['water_depth'].toString());
      final double flowRate = double.parse(inputs['flow_rate'].toString());
      final double irrigatedArea = double.parse(inputs['irrigated_area'].toString());
      final double systemEfficiency = double.parse(inputs['system_efficiency'].toString()) / 100;
      final double uniformity = double.parse(inputs['uniformity'].toString()) / 100;
      final String systemType = inputs['system_type'].toString();
      final double windSpeed = inputs['wind_speed'] != null ? 
                              double.parse(inputs['wind_speed'].toString()) : 0.0;

      // Cálculo do volume necessário
      final double areaM2 = CalculatorMath.hectareToSquareMeters(irrigatedArea);
      final double volumeNeededM3 = (waterDepth / 1000) * areaM2; // m³
      final double volumeNeededLiters = CalculatorMath.cubicToLiters(volumeNeededM3);

      // Considerando eficiência do sistema
      final double realVolumeNeeded = volumeNeededLiters / systemEfficiency;

      // Cálculo do tempo básico
      final double basicTimeHours = realVolumeNeeded / flowRate;
      // ignore: unused_local_variable
      final double basicTimeMinutes = basicTimeHours * 60; // TODO: Use in time breakdown analysis

      // Fator de correção para vento (afeta principalmente aspersão)
      final double windFactor = _calculateWindFactor(systemType, windSpeed);
      
      // Fator de correção para uniformidade
      final double uniformityFactor = _calculateUniformityFactor(uniformity);

      // Tempo corrigido
      final double correctedTimeHours = basicTimeHours * windFactor * uniformityFactor;
      final double correctedTimeMinutes = correctedTimeHours * 60;

      // Cálculos adicionais
      final double intensityApplication = flowRate / areaM2 * 1000; // mm/h
      final double applicationRate = waterDepth / correctedTimeHours; // mm/h real
      
      // Número de setores (para sistemas setorizados)
      final int numberOfSectors = _calculateOptimalSectors(systemType, irrigatedArea);
      final double sectorTime = correctedTimeHours / numberOfSectors;

      // Tempo para diferentes frações da lâmina
      // ignore: unused_local_variable
      final double time25 = correctedTimeMinutes * 0.25; // TODO: Use in partial irrigation scenarios
      final double time50 = correctedTimeMinutes * 0.50;
      // ignore: unused_local_variable
      final double time75 = correctedTimeMinutes * 0.75; // TODO: Use in stress management

      // Consumo energético estimado
      final double powerEstimated = _estimatePower(flowRate, systemType);
      final double energyConsumption = powerEstimated * correctedTimeHours;

      // Recomendações
      final List<String> recommendations = _generateRecommendations(
        systemType, windSpeed, correctedTimeHours, intensityApplication, uniformity);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Tempo de Irrigação',
            value: CalculatorMath.roundTo(correctedTimeHours, 2),
            unit: 'horas',
            description: 'Tempo total para aplicar a lâmina desejada',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Tempo em Minutos',
            value: CalculatorMath.roundTo(correctedTimeMinutes, 0),
            unit: 'minutos',
            description: 'Tempo total em minutos',
          ),
          CalculationResultValue(
            label: 'Volume Necessário',
            value: CalculatorMath.roundTo(volumeNeededLiters, 0),
            unit: 'L',
            description: 'Volume teórico necessário',
          ),
          CalculationResultValue(
            label: 'Volume Real',
            value: CalculatorMath.roundTo(realVolumeNeeded, 0),
            unit: 'L',
            description: 'Volume considerando eficiência',
          ),
          CalculationResultValue(
            label: 'Intensidade de Aplicação',
            value: CalculatorMath.roundTo(intensityApplication, 2),
            unit: 'mm/h',
            description: 'Taxa máxima de aplicação do sistema',
          ),
          CalculationResultValue(
            label: 'Taxa Real de Aplicação',
            value: CalculatorMath.roundTo(applicationRate, 2),
            unit: 'mm/h',
            description: 'Taxa real considerando tempo corrigido',
          ),
          if (numberOfSectors > 1) ...[
            CalculationResultValue(
              label: 'Número de Setores',
              value: numberOfSectors,
              unit: 'setores',
              description: 'Número recomendado de setores',
            ),
            CalculationResultValue(
              label: 'Tempo por Setor',
              value: CalculatorMath.roundTo(sectorTime, 2),
              unit: 'horas',
              description: 'Tempo de irrigação por setor',
            ),
          ],
          CalculationResultValue(
            label: 'Tempo para 50% da Lâmina',
            value: CalculatorMath.roundTo(time50, 0),
            unit: 'minutos',
            description: 'Tempo para aplicar 50% da lâmina',
          ),
          CalculationResultValue(
            label: 'Consumo Energético',
            value: CalculatorMath.roundTo(energyConsumption, 2),
            unit: 'kWh',
            description: 'Consumo energético estimado',
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

  double _calculateWindFactor(String systemType, double windSpeed) {
    // Fator de correção para vento
    switch (systemType) {
      case 'Aspersão Convencional':
      case 'Aspersão Autopropelido':
        if (windSpeed > 5.0) return 1.3; // Forte perda por deriva
        if (windSpeed > 3.0) return 1.15; // Perda moderada
        if (windSpeed > 1.0) return 1.05; // Perda leve
        return 1.0;
      case 'Microaspersão':
        if (windSpeed > 4.0) return 1.15;
        if (windSpeed > 2.0) return 1.08;
        return 1.0;
      case 'Pivô Central':
        if (windSpeed > 6.0) return 1.1;
        return 1.0;
      case 'Gotejamento':
        return 1.0; // Não afetado pelo vento
      default:
        return 1.0;
    }
  }

  double _calculateUniformityFactor(double uniformity) {
    // Fator de correção baseado na uniformidade
    if (uniformity < 0.70) return 1.25; // Baixa uniformidade
    if (uniformity < 0.80) return 1.15; // Uniformidade regular
    if (uniformity < 0.90) return 1.05; // Boa uniformidade
    return 1.0; // Excelente uniformidade
  }

  int _calculateOptimalSectors(String systemType, double area) {
    // Calcula número ótimo de setores baseado no tipo e área
    switch (systemType) {
      case 'Aspersão Convencional':
        if (area > 10) return (area / 5).ceil();
        if (area > 5) return 2;
        return 1;
      case 'Gotejamento':
        if (area > 20) return (area / 8).ceil();
        if (area > 8) return 3;
        return 1;
      case 'Microaspersão':
        if (area > 15) return (area / 6).ceil();
        if (area > 6) return 2;
        return 1;
      case 'Pivô Central':
        return 1; // Geralmente não setorizado
      default:
        return area > 5 ? (area / 5).ceil() : 1;
    }
  }

  double _estimatePower(double flowRate, String systemType) {
    // Estimativa grosseira da potência baseada na vazão
    final double flowRateM3h = flowRate / 1000;
    
    switch (systemType) {
      case 'Aspersão Convencional':
        return flowRateM3h * 1.2; // kW
      case 'Gotejamento':
        return flowRateM3h * 0.8; // kW
      case 'Microaspersão':
        return flowRateM3h * 1.0; // kW
      case 'Pivô Central':
        return flowRateM3h * 1.5; // kW
      default:
        return flowRateM3h * 1.0; // kW
    }
  }

  List<String> _generateRecommendations(
    String systemType,
    double windSpeed,
    double timeHours,
    double intensity,
    double uniformity,
  ) {
    final List<String> recommendations = [];

    // Recomendações baseadas no tempo
    if (timeHours < 0.5) {
      recommendations.add('Tempo muito curto. Verifique se a vazão não está excessiva.');
    } else if (timeHours > 12) {
      recommendations.add('Tempo muito longo. Considere aumentar a vazão ou setorizar.');
    }

    // Recomendações baseadas no vento
    if (windSpeed > 3.0 && (systemType.contains('Aspersão'))) {
      recommendations.add('Vento forte. Evite irrigar nas horas mais ventosas.');
    }

    // Recomendações baseadas na intensidade
    if (intensity > 25) {
      recommendations.add('Intensidade alta. Risco de escoamento superficial.');
    } else if (intensity < 5) {
      recommendations.add('Intensidade baixa. Boa para infiltração.');
    }

    // Recomendações baseadas na uniformidade
    if (uniformity < 0.75) {
      recommendations.add('Baixa uniformidade. Revise espaçamento e pressão dos emissores.');
    }

    // Recomendações específicas por sistema
    switch (systemType) {
      case 'Aspersão Convencional':
        recommendations.add('Monitore pressão e sobreposição dos aspersores.');
        break;
      case 'Gotejamento':
        recommendations.add('Verifique entupimento dos gotejadores regularmente.');
        break;
      case 'Pivô Central':
        recommendations.add('Monitore velocidade de deslocamento.');
        break;
    }

    return recommendations;
  }
}