import 'dart:math' as math;
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_parameter.dart';
import '../../entities/calculation_result.dart';
import '../../entities/calculator_engine.dart';

/// Calculadora de Predição de Produtividade
/// Estima produtividade baseada em condições da cultura e manejo
class YieldPredictionCalculator extends CalculatorEntity {
  YieldPredictionCalculator()
      : super(
          id: 'yield_prediction_calculator',
          name: 'Predição de Produtividade',
          description: 'Estima produtividade da cultura baseada em população, condições climáticas, solo e manejo',
          category: CalculatorCategory.crops,
          parameters: const [
            CalculatorParameter(
              id: 'crop_type',
              name: 'Tipo de Cultura',
              description: 'Cultura para predição',
              type: ParameterType.selection,
              options: ['Milho', 'Soja', 'Feijão', 'Trigo', 'Arroz', 'Algodão', 'Café', 'Cana-de-açúcar'],
              defaultValue: 'Milho',
            ),
            CalculatorParameter(
              id: 'plant_population',
              name: 'População de Plantas',
              description: 'População atual de plantas (plantas/ha)',
              type: ParameterType.integer,
              unit: ParameterUnit.plantasha,
              minValue: 10000,
              maxValue: 500000,
              defaultValue: 65000,
              validationMessage: 'População deve estar entre 10.000 e 500.000 plantas/ha',
            ),
            CalculatorParameter(
              id: 'growth_stage',
              name: 'Estágio de Desenvolvimento',
              description: 'Estágio atual da cultura',
              type: ParameterType.selection,
              options: ['Emergência', 'Vegetativo Inicial', 'Vegetativo Avançado', 'Floração', 'Enchimento de Grãos', 'Maturação'],
              defaultValue: 'Floração',
            ),
            CalculatorParameter(
              id: 'soil_fertility',
              name: 'Fertilidade do Solo',
              description: 'Nível de fertilidade do solo',
              type: ParameterType.selection,
              options: ['Muito Baixa', 'Baixa', 'Média', 'Alta', 'Muito Alta'],
              defaultValue: 'Alta',
            ),
            CalculatorParameter(
              id: 'water_availability',
              name: 'Disponibilidade Hídrica',
              description: 'Condição hídrica da cultura',
              type: ParameterType.selection,
              options: ['Déficit Severo', 'Déficit Moderado', 'Adequada', 'Excessiva'],
              defaultValue: 'Adequada',
            ),
            CalculatorParameter(
              id: 'weather_conditions',
              name: 'Condições Climáticas',
              description: 'Condições climáticas gerais da safra',
              type: ParameterType.selection,
              options: ['Muito Desfavoráveis', 'Desfavoráveis', 'Normais', 'Favoráveis', 'Muito Favoráveis'],
              defaultValue: 'Favoráveis',
            ),
            CalculatorParameter(
              id: 'pest_disease_pressure',
              name: 'Pressão de Pragas/Doenças',
              description: 'Nível de ocorrência de pragas e doenças',
              type: ParameterType.selection,
              options: ['Muito Alta', 'Alta', 'Média', 'Baixa', 'Muito Baixa'],
              defaultValue: 'Baixa',
            ),
            CalculatorParameter(
              id: 'technology_level',
              name: 'Nível Tecnológico',
              description: 'Nível de tecnologia aplicado no manejo',
              type: ParameterType.selection,
              options: ['Baixo', 'Médio', 'Alto', 'Muito Alto'],
              defaultValue: 'Alto',
            ),
            CalculatorParameter(
              id: 'cultivar_potential',
              name: 'Potencial do Cultivar',
              description: 'Potencial produtivo do cultivar utilizado',
              type: ParameterType.selection,
              options: ['Baixo', 'Médio', 'Alto', 'Muito Alto'],
              defaultValue: 'Alto',
            ),
          ],
          formula: 'Produtividade = Potencial Base × Fatores Limitantes × Eficiência de Manejo',
          references: const [
            'Van Ittersum & Rabbinge (1997) - Concepts in production ecology',
            'Lobell et al. (2009) - Crop yield gaps',
            'Evans (1993) - Crop evolution, adaptation and yield',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String cropType = inputs['crop_type'].toString();
      final int plantPopulation = int.parse(inputs['plant_population'].toString());
      final String growthStage = inputs['growth_stage'].toString();
      final String soilFertility = inputs['soil_fertility'].toString();
      final String waterAvailability = inputs['water_availability'].toString();
      final String weatherConditions = inputs['weather_conditions'].toString();
      final String pestDiseasePressure = inputs['pest_disease_pressure'].toString();
      final String technologyLevel = inputs['technology_level'].toString();
      final String cultivarPotential = inputs['cultivar_potential'].toString();

      // Obter potencial base da cultura
      final Map<String, dynamic> cropData = _getCropYieldData(cropType);
      
      // Calcular fatores limitantes
      final Map<String, dynamic> limitingFactors = _calculateLimitingFactors(
        soilFertility, waterAvailability, weatherConditions, pestDiseasePressure);

      // Calcular eficiência de manejo
      final Map<String, dynamic> managementEfficiency = _calculateManagementEfficiency(
        technologyLevel, cultivarPotential, plantPopulation, cropData);

      // Ajuste por estágio de desenvolvimento
      final Map<String, dynamic> stageAdjustment = _calculateStageAdjustment(growthStage);

      // Calcular produtividade estimada
      final Map<String, dynamic> yieldPrediction = _calculateYieldPrediction(
        cropData, limitingFactors, managementEfficiency, stageAdjustment);

      // Análise de gap de produtividade
      final Map<String, dynamic> yieldGapAnalysis = _analyzeYieldGap(
        yieldPrediction, cropData, limitingFactors);

      // Cenários
      final Map<String, dynamic> scenarios = _generateScenarios(
        cropData, limitingFactors, managementEfficiency);

      // Recomendações
      final List<String> recommendations = _generateYieldRecommendations(
        yieldPrediction, yieldGapAnalysis, limitingFactors, cropType);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Produtividade Estimada',
            value: CalculatorMath.roundTo(yieldPrediction['estimated_yield'] as double, 0),
            unit: 'kg/ha',
            description: 'Produtividade estimada para as condições atuais',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Potencial Máximo',
            value: CalculatorMath.roundTo((cropData['maximum_potential'] as double), 0),
            unit: 'kg/ha',
            description: 'Potencial máximo da cultura',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Eficiência Atual',
            value: CalculatorMath.roundTo(yieldPrediction['efficiency_percentage'] as double, 1),
            unit: '%',
            description: 'Eficiência em relação ao potencial',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Gap de Produtividade',
            value: CalculatorMath.roundTo(yieldGapAnalysis['yield_gap'] as double, 0),
            unit: 'kg/ha',
            description: 'Diferença para o potencial máximo',
          ),
          CalculationResultValue(
            label: 'Fator Limitante Principal',
            value: 1.0,
            unit: '',
            description: limitingFactors['main_limiting_factor'].toString(),
          ),
          CalculationResultValue(
            label: 'Cenário Otimista',
            value: CalculatorMath.roundTo(scenarios['optimistic'] as double, 0),
            unit: 'kg/ha',
            description: 'Produtividade em cenário favorável',
          ),
          CalculationResultValue(
            label: 'Cenário Pessimista',
            value: CalculatorMath.roundTo(scenarios['pessimistic'] as double, 0),
            unit: 'kg/ha',
            description: 'Produtividade em cenário desfavorável',
          ),
          CalculationResultValue(
            label: 'Confiabilidade da Predição',
            value: CalculatorMath.roundTo(yieldPrediction['reliability'] as double, 1),
            unit: '%',
            description: 'Confiabilidade da estimativa',
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

  Map<String, dynamic> _getCropYieldData(String cropType) {
    final Map<String, Map<String, dynamic>> cropDatabase = {
      'Milho': {
        'maximum_potential': 15000.0,
        'average_yield': 8000.0,
        'optimal_population': 65000,
        'yield_per_plant': 0.23, // kg/planta
      },
      'Soja': {
        'maximum_potential': 5000.0,
        'average_yield': 3200.0,
        'optimal_population': 300000,
        'yield_per_plant': 0.017,
      },
      'Feijão': {
        'maximum_potential': 4000.0,
        'average_yield': 2500.0,
        'optimal_population': 250000,
        'yield_per_plant': 0.016,
      },
      'default': {
        'maximum_potential': 6000.0,
        'average_yield': 4000.0,
        'optimal_population': 100000,
        'yield_per_plant': 0.06,
      },
    };

    return cropDatabase[cropType] ?? cropDatabase['default']!;
  }

  Map<String, dynamic> _calculateLimitingFactors(
    String soilFertility,
    String waterAvailability,
    String weatherConditions,
    String pestDiseasePressure,
  ) {
    final Map<String, double> fertilityFactors = {
      'Muito Baixa': 0.4,
      'Baixa': 0.6,
      'Média': 0.8,
      'Alta': 0.95,
      'Muito Alta': 1.0,
    };

    final Map<String, double> waterFactors = {
      'Déficit Severo': 0.3,
      'Déficit Moderado': 0.6,
      'Adequada': 1.0,
      'Excessiva': 0.8,
    };

    final Map<String, double> weatherFactors = {
      'Muito Desfavoráveis': 0.4,
      'Desfavoráveis': 0.7,
      'Normais': 0.9,
      'Favoráveis': 1.0,
      'Muito Favoráveis': 1.1,
    };

    final Map<String, double> pestFactors = {
      'Muito Alta': 0.5,
      'Alta': 0.7,
      'Média': 0.85,
      'Baixa': 0.95,
      'Muito Baixa': 1.0,
    };

    final double fertFactor = fertilityFactors[soilFertility] ?? 0.8;
    final double waterFactor = waterFactors[waterAvailability] ?? 0.9;
    final double weatherFactor = weatherFactors[weatherConditions] ?? 0.9;
    final double pestFactor = pestFactors[pestDiseasePressure] ?? 0.9;

    final double overallFactor = fertFactor * waterFactor * weatherFactor * pestFactor;

    // Identificar fator mais limitante
    final Map<String, double> factors = {
      'Fertilidade': fertFactor,
      'Água': waterFactor,
      'Clima': weatherFactor,
      'Pragas/Doenças': pestFactor,
    };

    String mainLimitingFactor = 'Fertilidade';
    double minFactor = 1.0;
    factors.forEach((key, value) {
      if (value < minFactor) {
        minFactor = value;
        mainLimitingFactor = key;
      }
    });

    return {
      'overall_factor': overallFactor,
      'main_limiting_factor': mainLimitingFactor,
      'fertility_factor': fertFactor,
      'water_factor': waterFactor,
      'weather_factor': weatherFactor,
      'pest_factor': pestFactor,
    };
  }

  Map<String, dynamic> _calculateManagementEfficiency(
    String technologyLevel,
    String cultivarPotential,
    int plantPopulation,
    Map<String, dynamic> cropData,
  ) {
    final Map<String, double> technologyFactors = {
      'Baixo': 0.7,
      'Médio': 0.85,
      'Alto': 0.95,
      'Muito Alto': 1.0,
    };

    final Map<String, double> cultivarFactors = {
      'Baixo': 0.8,
      'Médio': 0.9,
      'Alto': 1.0,
      'Muito Alto': 1.1,
    };

    final double techFactor = technologyFactors[technologyLevel] ?? 0.85;
    final double cultivarFactor = cultivarFactors[cultivarPotential] ?? 0.9;

    // Fator de população
    final int optimalPop = cropData['optimal_population'] as int;
    final double popRatio = plantPopulation / optimalPop;
    double popFactor = 1.0;
    
    if (popRatio < 0.7) {
      popFactor = 0.8;
    } else if (popRatio > 1.3) {
      popFactor = 0.9;
    }

    final double overallEfficiency = techFactor * cultivarFactor * popFactor;

    return {
      'overall_efficiency': overallEfficiency,
      'technology_factor': techFactor,
      'cultivar_factor': cultivarFactor,
      'population_factor': popFactor,
    };
  }

  Map<String, dynamic> _calculateStageAdjustment(String growthStage) {
    final Map<String, double> stageReliability = {
      'Emergência': 0.4,
      'Vegetativo Inicial': 0.5,
      'Vegetativo Avançado': 0.7,
      'Floração': 0.85,
      'Enchimento de Grãos': 0.95,
      'Maturação': 0.98,
    };

    return {
      'reliability': stageReliability[growthStage] ?? 0.7,
      'stage': growthStage,
    };
  }

  Map<String, dynamic> _calculateYieldPrediction(
    Map<String, dynamic> cropData,
    Map<String, dynamic> limitingFactors,
    Map<String, dynamic> managementEfficiency,
    Map<String, dynamic> stageAdjustment,
  ) {
    final double maxPotential = cropData['maximum_potential'] as double;
    final double limitingFactor = limitingFactors['overall_factor'] as double;
    final double efficiency = managementEfficiency['overall_efficiency'] as double;
    final double reliability = stageAdjustment['reliability'] as double;

    final double estimatedYield = maxPotential * limitingFactor * efficiency;
    final double efficiencyPercentage = (estimatedYield / maxPotential) * 100;

    return {
      'estimated_yield': estimatedYield,
      'efficiency_percentage': efficiencyPercentage,
      'reliability': reliability * 100,
    };
  }

  Map<String, dynamic> _analyzeYieldGap(
    Map<String, dynamic> yieldPrediction,
    Map<String, dynamic> cropData,
    Map<String, dynamic> limitingFactors,
  ) {
    final double estimatedYield = yieldPrediction['estimated_yield'] as double;
    final double maxPotential = cropData['maximum_potential'] as double;
    final double yieldGap = maxPotential - estimatedYield;
    final double gapPercentage = (yieldGap / maxPotential) * 100;

    String gapClassification;
    if (gapPercentage <= 10) {
      gapClassification = 'Muito Pequeno';
    } else if (gapPercentage <= 25) {
      gapClassification = 'Pequeno';
    } else if (gapPercentage <= 50) {
      gapClassification = 'Médio';
    } else {
      gapClassification = 'Grande';
    }

    return {
      'yield_gap': yieldGap,
      'gap_percentage': gapPercentage,
      'gap_classification': gapClassification,
    };
  }

  Map<String, dynamic> _generateScenarios(
    Map<String, dynamic> cropData,
    Map<String, dynamic> limitingFactors,
    Map<String, dynamic> managementEfficiency,
  ) {
    final double baseYield = cropData['maximum_potential'] as double * 
                           limitingFactors['overall_factor'] as double * 
                           managementEfficiency['overall_efficiency'] as double;

    return {
      'optimistic': baseYield * 1.2,
      'realistic': baseYield,
      'pessimistic': baseYield * 0.8,
    };
  }

  List<String> _generateYieldRecommendations(
    Map<String, dynamic> yieldPrediction,
    Map<String, dynamic> yieldGapAnalysis,
    Map<String, dynamic> limitingFactors,
    String cropType,
  ) {
    final List<String> recommendations = [];

    final double efficiency = yieldPrediction['efficiency_percentage'] as double;
    final String mainLimitingFactor = limitingFactors['main_limiting_factor'] as String;

    if (efficiency < 70) {
      recommendations.add('Eficiência baixa - revisar manejo geral da cultura.');
    }

    switch (mainLimitingFactor) {
      case 'Fertilidade':
        recommendations.add('Fertilidade é o principal limitante - melhorar nutrição da cultura.');
        break;
      case 'Água':
        recommendations.add('Disponibilidade hídrica limitante - considerar irrigação ou manejo da água.');
        break;
      case 'Clima':
        recommendations.add('Condições climáticas desfavoráveis - adaptar práticas ao clima.');
        break;
      case 'Pragas/Doenças':
        recommendations.add('Pressão de pragas/doenças alta - intensificar controle.');
        break;
    }

    recommendations.add('Monitorar desenvolvimento para confirmar predições.');
    recommendations.add('Ajustar práticas baseado nos fatores limitantes identificados.');

    return recommendations;
  }
}