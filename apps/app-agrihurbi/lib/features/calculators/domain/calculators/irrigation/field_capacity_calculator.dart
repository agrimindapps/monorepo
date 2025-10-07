import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Capacidade de Campo
/// Calcula a capacidade de retenção de água do solo e parâmetros hídricos
class FieldCapacityCalculator extends CalculatorEntity {
  const FieldCapacityCalculator()
    : super(
        id: 'field_capacity',
        name: 'Capacidade de Campo',
        description:
            'Calcula a capacidade de retenção de água do solo e parâmetros para manejo da irrigação',
        category: CalculatorCategory.irrigation,
        parameters: const [
          CalculatorParameter(
            id: 'soil_type',
            name: 'Tipo de Solo',
            description: 'Classificação textural do solo',
            type: ParameterType.selection,
            options: [
              'Arenoso',
              'Franco-Arenoso',
              'Franco',
              'Franco-Argiloso',
              'Argiloso',
            ],
            defaultValue: 'Franco',
          ),
          CalculatorParameter(
            id: 'clay_content',
            name: 'Teor de Argila',
            description: 'Percentual de argila no solo (%)',
            type: ParameterType.percentage,
            unit: ParameterUnit.percentual,
            minValue: 5.0,
            maxValue: 80.0,
            defaultValue: 25.0,
            validationMessage: 'Teor de argila deve estar entre 5% e 80%',
          ),
          CalculatorParameter(
            id: 'sand_content',
            name: 'Teor de Areia',
            description: 'Percentual de areia no solo (%)',
            type: ParameterType.percentage,
            unit: ParameterUnit.percentual,
            minValue: 10.0,
            maxValue: 90.0,
            defaultValue: 45.0,
            validationMessage: 'Teor de areia deve estar entre 10% e 90%',
          ),
          CalculatorParameter(
            id: 'organic_matter',
            name: 'Matéria Orgânica',
            description: 'Percentual de matéria orgânica (%)',
            type: ParameterType.percentage,
            unit: ParameterUnit.percentual,
            minValue: 0.5,
            maxValue: 10.0,
            defaultValue: 3.0,
            validationMessage: 'Matéria orgânica deve estar entre 0.5% e 10%',
          ),
          CalculatorParameter(
            id: 'bulk_density',
            name: 'Densidade do Solo',
            description: 'Densidade aparente do solo (g/cm³)',
            type: ParameterType.decimal,
            unit: ParameterUnit.none,
            minValue: 1.0,
            maxValue: 2.0,
            defaultValue: 1.3,
            validationMessage: 'Densidade deve estar entre 1.0 e 2.0 g/cm³',
          ),
          CalculatorParameter(
            id: 'root_depth',
            name: 'Profundidade das Raízes',
            description: 'Profundidade efetiva do sistema radicular (cm)',
            type: ParameterType.decimal,
            unit: ParameterUnit.centimetro,
            minValue: 10.0,
            maxValue: 200.0,
            defaultValue: 60.0,
            validationMessage: 'Profundidade deve estar entre 10 e 200 cm',
          ),
          CalculatorParameter(
            id: 'area',
            name: 'Área do Campo',
            description: 'Área total do campo (hectares)',
            type: ParameterType.decimal,
            unit: ParameterUnit.hectare,
            minValue: 0.01,
            maxValue: 10000.0,
            defaultValue: 1.0,
            validationMessage: 'Área deve ser maior que 0.01 ha',
          ),
        ],
        formula: 'CC = a + b×Argila + c×MO + d×DS; AD = CC - PMP',
        references: const [
          'Saxton & Rawls (2006) - Soil water characteristic estimates',
          'Van Genuchten (1980) - Closed-form equation',
        ],
      );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String soilType = inputs['soil_type'].toString();
      final double clayContent = double.parse(
        inputs['clay_content'].toString(),
      );
      final double sandContent = double.parse(
        inputs['sand_content'].toString(),
      );
      final double organicMatter = double.parse(
        inputs['organic_matter'].toString(),
      );
      final double bulkDensity = double.parse(
        inputs['bulk_density'].toString(),
      );
      final double rootDepth = double.parse(inputs['root_depth'].toString());
      final double area = double.parse(inputs['area'].toString());
      final double siltContent = 100 - clayContent - sandContent;
      if (siltContent < 0 || siltContent > 85) {
        return CalculationError(
          calculatorId: id,
          errorMessage: 'Soma de argila e areia não pode exceder 100%',
          inputs: inputs,
        );
      }
      final double thetaS = _calculateSaturatedMoisture(
        clayContent,
        sandContent,
        organicMatter,
      );
      final double theta_33 = _calculateFieldCapacity(
        clayContent,
        sandContent,
        organicMatter,
      );
      final double theta_1500 = _calculateWiltingPoint(
        clayContent,
        sandContent,
        organicMatter,
      );
      final double availableWater = theta_33 - theta_1500;
      final double availableWaterMm = availableWater * rootDepth * 10; // mm
      final double totalVolumeM3 =
          availableWaterMm * CalculatorMath.hectareToSquareMeters(area) / 1000;
      final double totalVolumeLiters = CalculatorMath.cubicToLiters(
        totalVolumeM3,
      );
      final double totalPorosity = 1 - (bulkDensity / 2.65);
      final double macroporosity = totalPorosity - thetaS;
      final double lamina50 = availableWaterMm * 0.50;
      const double etMedia = 5.0;
      final double diasEsgotamento = availableWaterMm / etMedia;
      final int frequenciaIrrigacao = _calculateIrrigationFrequency(
        availableWaterMm,
        soilType,
      );
      final String qualidadeFisica = _classifySoilPhysicalQuality(
        totalPorosity,
        macroporosity,
        availableWater,
      );
      final List<String> recommendations = _generateRecommendations(
        soilType,
        availableWater,
        bulkDensity,
        organicMatter,
        frequenciaIrrigacao,
      );

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Capacidade de Campo',
            value: CalculatorMath.roundTo(theta_33 * 100, 1),
            unit: '%',
            description: 'Umidade na capacidade de campo',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Ponto de Murcha',
            value: CalculatorMath.roundTo(theta_1500 * 100, 1),
            unit: '%',
            description: 'Umidade no ponto de murcha permanente',
          ),
          CalculationResultValue(
            label: 'Água Disponível',
            value: CalculatorMath.roundTo(availableWater * 100, 1),
            unit: '%',
            description: 'Água disponível para as plantas',
          ),
          CalculationResultValue(
            label: 'Lâmina de Água Disponível',
            value: CalculatorMath.roundTo(availableWaterMm, 1),
            unit: 'mm',
            description: 'Lâmina total de água disponível',
          ),
          CalculationResultValue(
            label: 'Volume Total Disponível',
            value: CalculatorMath.roundTo(totalVolumeLiters, 0),
            unit: 'L',
            description: 'Volume total de água disponível na área',
          ),
          CalculationResultValue(
            label: 'Porosidade Total',
            value: CalculatorMath.roundTo(totalPorosity * 100, 1),
            unit: '%',
            description: 'Porosidade total do solo',
          ),
          CalculationResultValue(
            label: 'Macroporosidade',
            value: CalculatorMath.roundTo(macroporosity * 100, 1),
            unit: '%',
            description: 'Porosidade para aeração',
          ),
          CalculationResultValue(
            label: 'Lâmina 50% AD',
            value: CalculatorMath.roundTo(lamina50, 1),
            unit: 'mm',
            description: 'Lâmina para irrigação aos 50% da AD',
          ),
          CalculationResultValue(
            label: 'Dias para Esgotamento',
            value: CalculatorMath.roundTo(diasEsgotamento, 1),
            unit: 'dias',
            description: 'Tempo para esgotar água disponível',
          ),
          CalculationResultValue(
            label: 'Frequência Recomendada',
            value: frequenciaIrrigacao,
            unit: 'dias',
            description: 'Intervalo recomendado entre irrigações',
          ),
          CalculationResultValue(
            label: 'Qualidade Física',
            value: qualidadeFisica,
            unit: '',
            description: 'Classificação da qualidade física do solo',
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

  double _calculateSaturatedMoisture(double clay, double sand, double om) {
    final double thetaS =
        0.332 - 7.251e-4 * sand + 0.1276 * (math.log(clay) / math.ln10);
    return math.min(0.7, math.max(0.3, thetaS + 0.02 * om));
  }

  double _calculateFieldCapacity(double clay, double sand, double om) {
    final double theta33T =
        0.299 - 2.92e-4 * sand + 0.1004 * (math.log(clay) / math.ln10);
    return math.min(0.6, math.max(0.1, theta33T + 0.015 * om));
  }

  double _calculateWiltingPoint(double clay, double sand, double om) {
    final double theta1500T =
        0.157 - 1.83e-4 * sand + 0.0663 * (math.log(clay) / math.ln10);
    return math.min(0.4, math.max(0.02, theta1500T + 0.01 * om));
  }

  int _calculateIrrigationFrequency(double availableWater, String soilType) {
    switch (soilType) {
      case 'Arenoso':
        return availableWater > 20 ? 3 : 2;
      case 'Franco-Arenoso':
        return availableWater > 30 ? 4 : 3;
      case 'Franco':
        return availableWater > 40 ? 6 : 4;
      case 'Franco-Argiloso':
        return availableWater > 50 ? 8 : 6;
      case 'Argiloso':
        return availableWater > 60 ? 10 : 8;
      default:
        return 5;
    }
  }

  String _classifySoilPhysicalQuality(
    double totalPorosity,
    double macroporosity,
    double availableWater,
  ) {
    if (totalPorosity > 0.55 && macroporosity > 0.15 && availableWater > 0.15) {
      return 'Excelente';
    } else if (totalPorosity > 0.50 &&
        macroporosity > 0.10 &&
        availableWater > 0.12) {
      return 'Boa';
    } else if (totalPorosity > 0.45 &&
        macroporosity > 0.08 &&
        availableWater > 0.10) {
      return 'Regular';
    } else {
      return 'Ruim';
    }
  }

  List<String> _generateRecommendations(
    String soilType,
    double availableWater,
    double bulkDensity,
    double organicMatter,
    int frequency,
  ) {
    final List<String> recommendations = [];
    switch (soilType) {
      case 'Arenoso':
        recommendations.add(
          'Solo arenoso: irrigações mais frequentes e menores volumes.',
        );
        break;
      case 'Argiloso':
        recommendations.add(
          'Solo argiloso: irrigações menos frequentes e maiores volumes.',
        );
        break;
    }
    if (availableWater < 0.08) {
      recommendations.add(
        'Baixa capacidade de retenção. Considere melhorar estrutura do solo.',
      );
    } else if (availableWater > 0.20) {
      recommendations.add(
        'Boa capacidade de retenção. Solo adequado para irrigação.',
      );
    }
    if (bulkDensity > 1.6) {
      recommendations.add('Solo compactado. Considere descompactação.');
    } else if (bulkDensity < 1.1) {
      recommendations.add('Solo com boa estrutura física.');
    }
    if (organicMatter < 2.0) {
      recommendations.add(
        'Baixo teor de MO. Adicione matéria orgânica para melhorar retenção.',
      );
    } else if (organicMatter > 5.0) {
      recommendations.add('Excelente teor de matéria orgânica.');
    }
    recommendations.add('Irrigue quando atingir 50-70% da água disponível.');
    recommendations.add('Frequência recomendada: a cada $frequency dias.');

    return recommendations;
  }
}
