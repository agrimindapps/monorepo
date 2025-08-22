import 'dart:math' as math;
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_parameter.dart';
import '../../entities/calculation_result.dart';
import '../../entities/calculator_engine.dart';

/// Calculadora de Drenagem
/// Calcula sistemas de drenagem agrícola e escoamento
class DrainageCalculator extends CalculatorEntity {
  DrainageCalculator()
      : super(
          id: 'drainage_calculator',
          name: 'Calculadora de Drenagem',
          description: 'Calcula sistemas de drenagem agrícola, escoamento superficial e dimensionamento de drenos',
          category: CalculatorCategory.crops, // Ajustado para crops pois não temos categoria soil
          parameters: const [
            CalculatorParameter(
              id: 'field_area',
              name: 'Área do Campo',
              description: 'Área total a ser drenada (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.1,
              maxValue: 1000.0,
              defaultValue: 25.0,
              validationMessage: 'Área deve estar entre 0.1 e 1000 ha',
            ),
            CalculatorParameter(
              id: 'soil_type',
              name: 'Tipo de Solo',
              description: 'Classificação textural do solo',
              type: ParameterType.selection,
              options: ['Arenoso', 'Franco-arenoso', 'Franco', 'Franco-argiloso', 'Argiloso', 'Orgânico'],
              defaultValue: 'Franco',
            ),
            CalculatorParameter(
              id: 'slope_percentage',
              name: 'Declividade',
              description: 'Declividade média do terreno (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.1,
              maxValue: 20.0,
              defaultValue: 2.5,
              validationMessage: 'Declividade deve estar entre 0.1% e 20%',
            ),
            CalculatorParameter(
              id: 'annual_rainfall',
              name: 'Precipitação Anual',
              description: 'Precipitação média anual (mm)',
              type: ParameterType.decimal,
              unit: ParameterUnit.milimetro,
              minValue: 500.0,
              maxValue: 3000.0,
              defaultValue: 1200.0,
              validationMessage: 'Precipitação deve estar entre 500 e 3000 mm',
            ),
            CalculatorParameter(
              id: 'design_storm',
              name: 'Chuva de Projeto',
              description: 'Intensidade da chuva de projeto (mm/h)',
              type: ParameterType.decimal,
              unit: ParameterUnit.mmh,
              minValue: 10.0,
              maxValue: 150.0,
              defaultValue: 50.0,
              validationMessage: 'Intensidade deve estar entre 10 e 150 mm/h',
            ),
            CalculatorParameter(
              id: 'return_period',
              name: 'Período de Retorno',
              description: 'Período de retorno para dimensionamento (anos)',
              type: ParameterType.selection,
              options: ['5 anos', '10 anos', '15 anos', '25 anos', '50 anos'],
              defaultValue: '10 anos',
            ),
            CalculatorParameter(
              id: 'drainage_coefficient',
              name: 'Coeficiente de Drenagem',
              description: 'Lâmina a ser drenada em 24h (mm)',
              type: ParameterType.decimal,
              unit: ParameterUnit.milimetro,
              minValue: 5.0,
              maxValue: 50.0,
              defaultValue: 15.0,
              validationMessage: 'Coeficiente deve estar entre 5 e 50 mm',
            ),
            CalculatorParameter(
              id: 'crop_type',
              name: 'Tipo de Cultura',
              description: 'Cultura principal da área',
              type: ParameterType.selection,
              options: ['Arroz', 'Milho', 'Soja', 'Pastagem', 'Hortaliças', 'Fruticultura'],
              defaultValue: 'Milho',
            ),
            CalculatorParameter(
              id: 'drainage_method',
              name: 'Método de Drenagem',
              description: 'Sistema de drenagem a ser utilizado',
              type: ParameterType.selection,
              options: ['Drenos Subterrâneos', 'Canais Superficiais', 'Sistema Misto', 'Terraços'],
              defaultValue: 'Sistema Misto',
            ),
          ],
          formula: 'Q = C × I × A (Método Racional) + Cálculo de Drenos',
          references: const [
            'Cruciani (1987) - A drenagem na agricultura',
            'Pizarro (1978) - Drenaje agrícola y recuperación de suelos salinos',
            'USDA (2001) - Agricultural drainage criteria',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double fieldArea = double.parse(inputs['field_area'].toString());
      final String soilType = inputs['soil_type'].toString();
      final double slopePercentage = double.parse(inputs['slope_percentage'].toString());
      final double annualRainfall = double.parse(inputs['annual_rainfall'].toString());
      final double designStorm = double.parse(inputs['design_storm'].toString());
      final String returnPeriod = inputs['return_period'].toString();
      final double drainageCoefficient = double.parse(inputs['drainage_coefficient'].toString());
      final String cropType = inputs['crop_type'].toString();
      final String drainageMethod = inputs['drainage_method'].toString();

      // Obter parâmetros do solo
      final Map<String, dynamic> soilParameters = _getSoilParameters(soilType);

      // Calcular coeficiente de escoamento
      final Map<String, dynamic> runoffAnalysis = _calculateRunoffCoefficient(
        soilType, slopePercentage, cropType, annualRainfall);

      // Calcular vazão de projeto
      final Map<String, dynamic> designFlow = _calculateDesignFlow(
        fieldArea, designStorm, runoffAnalysis, returnPeriod);

      // Dimensionar sistema de drenagem
      final Map<String, dynamic> drainageSystem = _designDrainageSystem(
        fieldArea, drainageCoefficient, drainageMethod, soilParameters);

      // Calcular espaçamento de drenos
      final Map<String, dynamic> drainSpacing = _calculateDrainSpacing(
        soilParameters, drainageCoefficient, slopePercentage);

      // Análise econômica
      final Map<String, dynamic> economicAnalysis = _calculateDrainageCosts(
        fieldArea, drainageSystem, drainageMethod);

      // Recomendações
      final List<String> recommendations = _generateDrainageRecommendations(
        soilType, drainageMethod, runoffAnalysis, drainageSystem);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Vazão de Projeto',
            value: CalculatorMath.roundTo(designFlow['peak_flow'] as double, 2),
            unit: 'm³/s',
            description: 'Vazão máxima a ser drenada',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Coeficiente de Escoamento',
            value: CalculatorMath.roundTo(runoffAnalysis['runoff_coefficient'] as double, 3),
            unit: '',
            description: 'Fração da chuva que escoa superficialmente',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Espaçamento de Drenos',
            value: CalculatorMath.roundTo(drainSpacing['drain_spacing'] as double, 1),
            unit: 'metros',
            description: 'Distância recomendada entre drenos',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Comprimento Total de Drenos',
            value: CalculatorMath.roundTo(drainageSystem['total_drain_length'] as double, 0),
            unit: 'metros',
            description: 'Extensão total do sistema de drenagem',
          ),
          CalculationResultValue(
            label: 'Profundidade dos Drenos',
            value: CalculatorMath.roundTo(drainSpacing['drain_depth'] as double, 2),
            unit: 'metros',
            description: 'Profundidade recomendada dos drenos',
          ),
          CalculationResultValue(
            label: 'Tempo de Concentração',
            value: CalculatorMath.roundTo(designFlow['time_of_concentration'] as double, 1),
            unit: 'minutos',
            description: 'Tempo para a água atingir o exutório',
          ),
          CalculationResultValue(
            label: 'Infiltração Base',
            value: CalculatorMath.roundTo(soilParameters['infiltration_rate'] as double, 1),
            unit: 'mm/h',
            description: 'Taxa de infiltração do solo',
          ),
          CalculationResultValue(
            label: 'Custo Total do Sistema',
            value: CalculatorMath.roundTo(economicAnalysis['total_cost'] as double, 0),
            unit: 'R\$',
            description: 'Custo estimado de implantação',
          ),
        ],
        recommendations: recommendations,
        tableData: [],
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  Map<String, dynamic> _getSoilParameters(String soilType) {
    final Map<String, Map<String, dynamic>> soilDatabase = {
      'Arenoso': {
        'infiltration_rate': 25.0, // mm/h
        'permeability': 0.5, // m/dia
        'porosity': 0.4,
        'field_capacity': 0.15,
        'drainage_category': 'Excessiva',
      },
      'Franco-arenoso': {
        'infiltration_rate': 15.0,
        'permeability': 0.3,
        'porosity': 0.45,
        'field_capacity': 0.20,
        'drainage_category': 'Boa',
      },
      'Franco': {
        'infiltration_rate': 8.0,
        'permeability': 0.15,
        'porosity': 0.48,
        'field_capacity': 0.25,
        'drainage_category': 'Moderada',
      },
      'Franco-argiloso': {
        'infiltration_rate': 4.0,
        'permeability': 0.08,
        'porosity': 0.50,
        'field_capacity': 0.30,
        'drainage_category': 'Lenta',
      },
      'Argiloso': {
        'infiltration_rate': 1.5,
        'permeability': 0.03,
        'porosity': 0.52,
        'field_capacity': 0.35,
        'drainage_category': 'Muito Lenta',
      },
      'Orgânico': {
        'infiltration_rate': 12.0,
        'permeability': 0.20,
        'porosity': 0.60,
        'field_capacity': 0.40,
        'drainage_category': 'Variável',
      },
    };

    return soilDatabase[soilType] ?? soilDatabase['Franco']!;
  }

  Map<String, dynamic> _calculateRunoffCoefficient(
    String soilType,
    double slope,
    String cropType,
    double rainfall,
  ) {
    // Coeficiente base por tipo de solo
    final Map<String, double> baseCoefficients = {
      'Arenoso': 0.15,
      'Franco-arenoso': 0.25,
      'Franco': 0.35,
      'Franco-argiloso': 0.45,
      'Argiloso': 0.55,
      'Orgânico': 0.20,
    };

    double runoffCoefficient = baseCoefficients[soilType] ?? 0.35;

    // Ajuste por declividade
    if (slope > 5.0) {
      runoffCoefficient += 0.1;
    } else if (slope < 1.0) {
      runoffCoefficient -= 0.05;
    }

    // Ajuste por cultura
    final Map<String, double> cropFactors = {
      'Arroz': 0.8, // Cultura inundada
      'Milho': 1.0,
      'Soja': 0.9,
      'Pastagem': 0.7,
      'Hortaliças': 1.1,
      'Fruticultura': 0.8,
    };

    runoffCoefficient *= (cropFactors[cropType] ?? 1.0);

    // Limitar valores
    runoffCoefficient = math.max(0.1, math.min(0.9, runoffCoefficient));

    return {
      'runoff_coefficient': runoffCoefficient,
      'infiltration_percentage': (1 - runoffCoefficient) * 100,
    };
  }

  Map<String, dynamic> _calculateDesignFlow(
    double area,
    double intensity,
    Map<String, dynamic> runoffAnalysis,
    String returnPeriod,
  ) {
    final double runoffCoeff = runoffAnalysis['runoff_coefficient'] as double;

    // Fator de ajuste por período de retorno
    final Map<String, double> returnFactors = {
      '5 anos': 1.0,
      '10 anos': 1.15,
      '15 anos': 1.25,
      '25 anos': 1.35,
      '50 anos': 1.5,
    };

    final double returnFactor = returnFactors[returnPeriod] ?? 1.15;
    
    // Vazão pelo método racional: Q = C × I × A / 360
    final double peakFlow = (runoffCoeff * intensity * area * 10000) / 3600; // m³/s

    final double adjustedFlow = peakFlow * returnFactor;

    // Tempo de concentração (estimativa)
    final double timeOfConcentration = math.pow(area, 0.3) * 10; // minutos

    return {
      'peak_flow': adjustedFlow,
      'base_flow': peakFlow,
      'time_of_concentration': timeOfConcentration,
      'return_factor': returnFactor,
    };
  }

  Map<String, dynamic> _designDrainageSystem(
    double area,
    double drainageCoeff,
    String method,
    Map<String, dynamic> soilParams,
  ) {
    double drainSpacing = 50.0; // metros
    double drainDepth = 1.2; // metros

    // Ajustar baseado no método
    switch (method) {
      case 'Drenos Subterrâneos':
        drainSpacing = 30.0;
        drainDepth = 1.5;
        break;
      case 'Canais Superficiais':
        drainSpacing = 100.0;
        drainDepth = 0.8;
        break;
      case 'Sistema Misto':
        drainSpacing = 50.0;
        drainDepth = 1.2;
        break;
      case 'Terraços':
        drainSpacing = 80.0;
        drainDepth = 0.6;
        break;
    }

    // Ajustar pela permeabilidade
    final double permeability = soilParams['permeability'] as double;
    if (permeability < 0.1) {
      drainSpacing *= 0.7; // Solo menos permeável = drenos mais próximos
    } else if (permeability > 0.3) {
      drainSpacing *= 1.3; // Solo mais permeável = drenos mais afastados
    }

    // Calcular comprimento total
    final double areaM2 = area * 10000;
    final double fieldLength = math.sqrt(areaM2);
    final int numberOfDrains = (fieldLength / drainSpacing).ceil();
    final double totalDrainLength = numberOfDrains * fieldLength;

    return {
      'drain_spacing': drainSpacing,
      'drain_depth': drainDepth,
      'number_of_drains': numberOfDrains,
      'total_drain_length': totalDrainLength,
      'drain_diameter': method.contains('Subterrâneo') ? 100.0 : 0.0, // mm
    };
  }

  Map<String, dynamic> _calculateDrainSpacing(
    Map<String, dynamic> soilParams,
    double drainageCoeff,
    double slope,
  ) {
    final double permeability = soilParams['permeability'] as double;
    
    // Fórmula de Hooghoudt simplificada
    final double drainDepth = 1.2; // metros
    final double drainageRate = drainageCoeff / 1000; // m/dia
    
    // Espaçamento baseado na permeabilidade
    double spacing = math.sqrt((8 * permeability * drainDepth) / drainageRate);
    
    // Ajustar pela declividade
    if (slope > 3.0) {
      spacing *= 1.2; // Maior declividade permite maior espaçamento
    }
    
    // Limites práticos
    spacing = math.max(20, math.min(100, spacing));

    return {
      'drain_spacing': spacing,
      'drain_depth': drainDepth,
      'drainage_rate': drainageRate * 1000, // mm/dia
    };
  }

  Map<String, dynamic> _calculateDrainageCosts(
    double area,
    Map<String, dynamic> drainageSystem,
    String method,
  ) {
    final double totalLength = drainageSystem['total_drain_length'] as double;
    
    // Custos por metro linear (R\$/m)
    final Map<String, double> unitCosts = {
      'Drenos Subterrâneos': 35.0,
      'Canais Superficiais': 15.0,
      'Sistema Misto': 25.0,
      'Terraços': 8.0,
    };

    final double unitCost = unitCosts[method] ?? 25.0;
    final double totalCost = totalLength * unitCost;
    final double costPerHa = totalCost / area;

    return {
      'total_cost': totalCost,
      'cost_per_ha': costPerHa,
      'unit_cost': unitCost,
      'maintenance_cost_annual': totalCost * 0.05, // 5% ao ano
    };
  }

  List<String> _generateDrainageRecommendations(
    String soilType,
    String method,
    Map<String, dynamic> runoffAnalysis,
    Map<String, dynamic> drainageSystem,
  ) {
    final List<String> recommendations = [];

    final double runoffCoeff = runoffAnalysis['runoff_coefficient'] as double;

    // Recomendações por tipo de solo
    if (soilType.contains('Argiloso')) {
      recommendations.add('Solo argiloso: considerar drenos subterrâneos próximos para remoção do excesso.');
    } else if (soilType.contains('Arenoso')) {
      recommendations.add('Solo arenoso: atenção ao espaçamento dos drenos para não sobre-drenar.');
    }

    // Recomendações por escoamento
    if (runoffCoeff > 0.6) {
      recommendations.add('Alto escoamento superficial: implementar práticas conservacionistas.');
    }

    // Recomendações por método
    switch (method) {
      case 'Drenos Subterrâneos':
        recommendations.add('Drenos subterrâneos: manter sistema de manutenção regular.');
        break;
      case 'Sistema Misto':
        recommendations.add('Sistema misto: coordenar drenagem superficial e subsuperficial.');
        break;
    }

    recommendations.add('Monitorar nível freático e eficiência do sistema.');
    recommendations.add('Implementar práticas de conservação do solo complementares.');

    return recommendations;
  }
}