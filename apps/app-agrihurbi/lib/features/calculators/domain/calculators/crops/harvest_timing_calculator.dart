import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Época de Colheita
/// Calcula o momento ideal para colheita baseado em maturidade e condições
class HarvestTimingCalculator extends CalculatorEntity {
  const HarvestTimingCalculator()
      : super(
          id: 'harvest_timing_calculator',
          name: 'Época de Colheita',
          description: 'Determina o momento ideal para colheita baseado em ciclo da cultura, maturação e condições climáticas',
          category: CalculatorCategory.crops,
          parameters: const [
            CalculatorParameter(
              id: 'crop_type',
              name: 'Tipo de Cultura',
              description: 'Cultura a ser colhida',
              type: ParameterType.selection,
              options: ['Milho', 'Soja', 'Feijão', 'Trigo', 'Arroz', 'Algodão', 'Café', 'Tomate', 'Batata'],
              defaultValue: 'Milho',
            ),
            CalculatorParameter(
              id: 'planting_date',
              name: 'Data do Plantio',
              description: 'Data em que foi realizado o plantio (dd/mm/aaaa)',
              type: ParameterType.date,
            ),
            CalculatorParameter(
              id: 'cultivar_cycle',
              name: 'Ciclo do Cultivar',
              description: 'Ciclo de desenvolvimento do cultivar',
              type: ParameterType.selection,
              options: ['Super Precoce (90-110 dias)', 'Precoce (110-125 dias)', 'Médio (125-140 dias)', 'Tardio (140-160 dias)'],
              defaultValue: 'Médio (125-140 dias)',
            ),
            CalculatorParameter(
              id: 'current_moisture',
              name: 'Umidade Atual dos Grãos',
              description: 'Umidade atual medida nos grãos (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 10.0,
              maxValue: 35.0,
              defaultValue: 22.0,
              validationMessage: 'Umidade deve estar entre 10% e 35%',
            ),
            CalculatorParameter(
              id: 'target_moisture',
              name: 'Umidade Ideal para Colheita',
              description: 'Umidade desejada para colheita (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 12.0,
              maxValue: 25.0,
              defaultValue: 18.0,
              validationMessage: 'Umidade ideal deve estar entre 12% e 25%',
            ),
            CalculatorParameter(
              id: 'weather_forecast',
              name: 'Previsão do Tempo',
              description: 'Condição climática prevista para os próximos dias',
              type: ParameterType.selection,
              options: ['Seco e Ensolarado', 'Parcialmente Nublado', 'Chuva Leve', 'Chuva Forte', 'Instável'],
              defaultValue: 'Seco e Ensolarado',
            ),
            CalculatorParameter(
              id: 'field_accessibility',
              name: 'Condições do Campo',
              description: 'Condições de acesso e trafegabilidade do campo',
              type: ParameterType.selection,
              options: ['Ótimas', 'Boas', 'Regulares', 'Ruins', 'Intrafegável'],
              defaultValue: 'Boas',
            ),
            CalculatorParameter(
              id: 'harvest_purpose',
              name: 'Finalidade da Colheita',
              description: 'Destino da produção colhida',
              type: ParameterType.selection,
              options: ['Comercialização Imediata', 'Armazenamento', 'Consumo Próprio', 'Sementes', 'Silagem'],
              defaultValue: 'Comercialização Imediata',
            ),
            CalculatorParameter(
              id: 'machinery_availability',
              name: 'Disponibilidade de Máquinas',
              description: 'Disponibilidade de equipamentos para colheita',
              type: ParameterType.selection,
              options: ['Imediata', 'Em 2-3 dias', 'Em uma semana', 'Terceirizada', 'Manual'],
              defaultValue: 'Imediata',
            ),
            CalculatorParameter(
              id: 'field_size',
              name: 'Tamanho da Área',
              description: 'Área total a ser colhida (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.1,
              maxValue: 5000.0,
              defaultValue: 25.0,
              validationMessage: 'Área deve estar entre 0.1 e 5000 ha',
            ),
          ],
          formula: 'Ponto Ótimo = Maturidade Fisiológica + Condições Climáticas + Logística',
          references: const [
            'Embrapa (2015) - Ponto de colheita de grãos',
            'Peske & Villela (2003) - Secagem e armazenamento',
            'Silva et al. (2009) - Qualidade na colheita',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String cropType = inputs['crop_type'].toString();
      final String plantingDateStr = inputs['planting_date'].toString();
      final String cultivarCycle = inputs['cultivar_cycle'].toString();
      final double currentMoisture = double.parse(inputs['current_moisture'].toString());
      final double targetMoisture = double.parse(inputs['target_moisture'].toString());
      final String weatherForecast = inputs['weather_forecast'].toString();
      final String fieldAccessibility = inputs['field_accessibility'].toString();
      final String harvestPurpose = inputs['harvest_purpose'].toString();
      final String machineryAvailability = inputs['machinery_availability'].toString();
      final double fieldSize = double.parse(inputs['field_size'].toString());
      final DateTime plantingDate = _parseDate(plantingDateStr);
      final Map<String, dynamic> cropData = _getCropHarvestData(cropType);
      final Map<String, dynamic> maturityDates = _calculateMaturityDates(
        plantingDate, cultivarCycle, cropData);
      final Map<String, dynamic> maturityAnalysis = _analyzeCurrentMaturity(
        currentMoisture, targetMoisture, cropType, harvestPurpose);
      final Map<String, dynamic> weatherImpact = _analyzeWeatherImpact(
        weatherForecast, fieldAccessibility, harvestPurpose);
      final Map<String, dynamic> timingRecommendation = _calculateOptimalTiming(
        maturityDates, maturityAnalysis, weatherImpact, machineryAvailability);
      final List<Map<String, dynamic>> harvestSchedule = _generateHarvestSchedule(
        timingRecommendation, fieldSize, machineryAvailability);
      final Map<String, dynamic> qualityAnalysis = _analyzeHarvestQuality(
        currentMoisture, targetMoisture, weatherForecast, cropType);
      final List<String> recommendations = _generateHarvestRecommendations(
        timingRecommendation, qualityAnalysis, weatherImpact, cropType);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Data Ideal de Colheita',
            value: 1.0,
            unit: '',
            description: timingRecommendation['optimal_date'].toString(),
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Status de Maturidade',
            value: CalculatorMath.roundTo(maturityAnalysis['maturity_percentage'] as double, 1),
            unit: '%',
            description: 'Percentual de maturação atual',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Dias para Colheita',
            value: CalculatorMath.roundTo((timingRecommendation['days_to_harvest'] as int).toDouble(), 0),
            unit: 'dias',
            description: 'Dias restantes até o ponto ideal',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Janela Ideal de Colheita',
            value: CalculatorMath.roundTo((timingRecommendation['harvest_window_days'] as int).toDouble(), 0),
            unit: 'dias',
            description: 'Período ótimo para realizar a colheita',
          ),
          CalculationResultValue(
            label: 'Índice de Qualidade',
            value: CalculatorMath.roundTo(qualityAnalysis['quality_index'] as double, 1),
            unit: 'pontos',
            description: 'Índice de qualidade esperada (0-100)',
          ),
          CalculationResultValue(
            label: 'Risco Climático',
            value: CalculatorMath.roundTo(weatherImpact['risk_level'] as double, 1),
            unit: 'pontos',
            description: 'Nível de risco climático (0-100)',
          ),
          CalculationResultValue(
            label: 'Tempo de Colheita',
            value: CalculatorMath.roundTo(harvestSchedule.isNotEmpty ? 
                (harvestSchedule.last['tempo_acumulado'] as double) : 0.0, 1),
            unit: 'horas',
            description: 'Tempo estimado para colheita total',
          ),
          CalculationResultValue(
            label: 'Perda por Atraso',
            value: CalculatorMath.roundTo(timingRecommendation['delay_loss_percentage'] as double, 2),
            unit: '%/dia',
            description: 'Perda estimada por dia de atraso',
          ),
        ],
        recommendations: recommendations,
        tableData: harvestSchedule,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      return DateTime(
        int.parse(parts[2]), // ano
        int.parse(parts[1]), // mês
        int.parse(parts[0]), // dia
      );
    } catch (e) {
      return DateTime.now().subtract(const Duration(days: 120)); // Default 120 dias atrás
    }
  }

  Map<String, dynamic> _getCropHarvestData(String cropType) {
    final Map<String, Map<String, dynamic>> cropDatabase = {
      'Milho': {
        'optimal_moisture': 18.0,
        'storage_moisture': 14.0,
        'loss_rate_per_day': 0.3,
        'quality_window_days': 15,
        'maturity_indicators': ['Linha negra', 'Umidade dos grãos', 'Dureza dos grãos'],
      },
      'Soja': {
        'optimal_moisture': 15.0,
        'storage_moisture': 12.0,
        'loss_rate_per_day': 0.5,
        'quality_window_days': 10,
        'maturity_indicators': ['Amarelecimento das vagens', 'Ruído das vagens', 'Umidade'],
      },
      'Feijão': {
        'optimal_moisture': 16.0,
        'storage_moisture': 13.0,
        'loss_rate_per_day': 0.4,
        'quality_window_days': 8,
        'maturity_indicators': ['Amarelecimento das vagens', 'Secagem das plantas'],
      },
      'default': {
        'optimal_moisture': 16.0,
        'storage_moisture': 13.0,
        'loss_rate_per_day': 0.3,
        'quality_window_days': 12,
        'maturity_indicators': ['Maturação visual', 'Teste de umidade'],
      },
    };

    return cropDatabase[cropType] ?? cropDatabase['default']!;
  }

  Map<String, dynamic> _calculateMaturityDates(
    DateTime plantingDate,
    String cultivarCycle,
    Map<String, dynamic> cropData,
  ) {
    final RegExp regex = RegExp(r'(\d+)-(\d+)');
    final match = regex.firstMatch(cultivarCycle);
    
    int minDays = 120;
    int maxDays = 140;
    
    if (match != null) {
      minDays = int.parse(match.group(1)!);
      maxDays = int.parse(match.group(2)!);
    }

    final int avgDays = ((minDays + maxDays) / 2).round();
    
    final DateTime maturityDate = plantingDate.add(Duration(days: avgDays));
    final DateTime earliestHarvest = plantingDate.add(Duration(days: minDays));
    final DateTime latestHarvest = plantingDate.add(Duration(days: maxDays + 10));

    return {
      'physiological_maturity': maturityDate,
      'earliest_harvest': earliestHarvest,
      'latest_harvest': latestHarvest,
      'cycle_days': avgDays,
    };
  }

  Map<String, dynamic> _analyzeCurrentMaturity(
    double currentMoisture,
    double targetMoisture,
    String cropType,
    String harvestPurpose,
  ) {
    final Map<String, dynamic> cropData = _getCropHarvestData(cropType);
    final double optimalMoisture = cropData['optimal_moisture'] as double;
    double maturityPercentage = 100.0;
    if (currentMoisture > optimalMoisture) {
      maturityPercentage = math.max(70, 100 - (currentMoisture - optimalMoisture) * 3);
    }
    final double moistureDeviation = (currentMoisture - targetMoisture).abs();
    String maturityStatus;
    
    if (moistureDeviation <= 1.0) {
      maturityStatus = 'Ideal';
    } else if (moistureDeviation <= 3.0) {
      maturityStatus = 'Adequada';
    } else if (currentMoisture > targetMoisture) {
      maturityStatus = 'Ainda Verde';
    } else {
      maturityStatus = 'Passada';
    }

    return {
      'maturity_percentage': maturityPercentage,
      'moisture_status': maturityStatus,
      'moisture_deviation': moistureDeviation,
      'ready_for_harvest': moistureDeviation <= 3.0,
    };
  }

  Map<String, dynamic> _analyzeWeatherImpact(
    String weatherForecast,
    String fieldAccessibility,
    String harvestPurpose,
  ) {
    final Map<String, double> weatherRisk = {
      'Seco e Ensolarado': 10.0,
      'Parcialmente Nublado': 25.0,
      'Chuva Leve': 60.0,
      'Chuva Forte': 90.0,
      'Instável': 75.0,
    };

    final Map<String, double> accessibilityFactor = {
      'Ótimas': 1.0,
      'Boas': 1.1,
      'Regulares': 1.3,
      'Ruins': 1.6,
      'Intrafegável': 2.0,
    };

    final double riskLevel = weatherRisk[weatherForecast] ?? 50.0;
    final double accessFactor = accessibilityFactor[fieldAccessibility] ?? 1.2;
    
    final double finalRisk = math.min(100, riskLevel * accessFactor);

    String recommendation;
    if (finalRisk <= 30) {
      recommendation = 'Condições ideais para colheita';
    } else if (finalRisk <= 60) {
      recommendation = 'Condições aceitáveis - proceder com cautela';
    } else {
      recommendation = 'Aguardar melhores condições climáticas';
    }

    return {
      'risk_level': finalRisk,
      'weather_recommendation': recommendation,
      'access_factor': accessFactor,
    };
  }

  Map<String, dynamic> _calculateOptimalTiming(
    Map<String, dynamic> maturityDates,
    Map<String, dynamic> maturityAnalysis,
    Map<String, dynamic> weatherImpact,
    String machineryAvailability,
  ) {
    final DateTime today = DateTime.now();
    final DateTime physiologicalMaturity = maturityDates['physiological_maturity'] as DateTime;
    final Map<String, int> machineryDelay = {
      'Imediata': 0,
      'Em 2-3 dias': 2,
      'Em uma semana': 7,
      'Terceirizada': 5,
      'Manual': 0,
    };

    final int delay = machineryDelay[machineryAvailability] ?? 3;
    final DateTime optimalDate = physiologicalMaturity.add(Duration(days: delay));

    final int daysToHarvest = optimalDate.difference(today).inDays;
    final double riskLevel = (weatherImpact['risk_level'] as double) / 10;
    final int harvestWindowDays = math.max(5, 15 - riskLevel.round());
    final double delayLossPercentage = daysToHarvest > 0 ? 0.0 : daysToHarvest.toDouble().abs() * 0.3;

    return {
      'optimal_date': optimalDate.toString().split(' ')[0],
      'days_to_harvest': math.max(0, daysToHarvest),
      'harvest_window_days': harvestWindowDays,
      'delay_loss_percentage': delayLossPercentage,
      'urgency_level': daysToHarvest < 0 ? 'Urgente' : daysToHarvest <= 3 ? 'Alta' : 'Normal',
    };
  }

  Map<String, dynamic> _analyzeHarvestQuality(
    double currentMoisture,
    double targetMoisture,
    String weatherForecast,
    String cropType,
  ) {
    double qualityIndex = 100.0;
    final double moistureDeviation = (currentMoisture - targetMoisture).abs();
    qualityIndex -= moistureDeviation * 5;
    final Map<String, double> weatherQualityImpact = {
      'Seco e Ensolarado': 0.0,
      'Parcialmente Nublado': -5.0,
      'Chuva Leve': -15.0,
      'Chuva Forte': -30.0,
      'Instável': -20.0,
    };

    qualityIndex += (weatherQualityImpact[weatherForecast] ?? -10.0);
    qualityIndex = math.max(0, math.min(100, qualityIndex));

    String qualityClassification;
    if (qualityIndex >= 90) {
      qualityClassification = 'Excelente';
    } else if (qualityIndex >= 75) {
      qualityClassification = 'Boa';
    } else if (qualityIndex >= 60) {
      qualityClassification = 'Regular';
    } else {
      qualityClassification = 'Comprometida';
    }

    return {
      'quality_index': qualityIndex,
      'quality_classification': qualityClassification,
      'moisture_impact': moistureDeviation * 5,
      'weather_impact': weatherQualityImpact[weatherForecast] ?? -10.0,
    };
  }

  List<Map<String, dynamic>> _generateHarvestSchedule(
    Map<String, dynamic> timingRecommendation,
    double fieldSize,
    String machineryAvailability,
  ) {
    final List<Map<String, dynamic>> schedule = [];
    final Map<String, double> dailyCapacity = {
      'Manual': 0.5,
      'Imediata': 8.0,
      'Em 2-3 dias': 8.0,
      'Em uma semana': 8.0,
      'Terceirizada': 12.0,
    };

    final double capacity = dailyCapacity[machineryAvailability] ?? 8.0;
    final int harvestDays = (fieldSize / capacity).ceil();

    for (int day = 1; day <= harvestDays; day++) {
      final double dailyArea = math.min(capacity, fieldSize - (capacity * (day - 1)));
      
      schedule.add({
        'dia': day,
        'area_dia': CalculatorMath.roundTo(dailyArea, 1),
        'area_acumulada': CalculatorMath.roundTo(capacity * day, 1),
        'tempo_acumulado': day * 8.0, // 8 horas/dia
        'observacao': day == 1 ? 'Início da colheita' : day == harvestDays ? 'Finalização' : 'Continuação',
      });
    }

    return schedule;
  }

  List<String> _generateHarvestRecommendations(
    Map<String, dynamic> timingRecommendation,
    Map<String, dynamic> qualityAnalysis,
    Map<String, dynamic> weatherImpact,
    String cropType,
  ) {
    final List<String> recommendations = [];

    final String urgencyLevel = timingRecommendation['urgency_level'] as String;
    final double qualityIndex = qualityAnalysis['quality_index'] as double;
    final double riskLevel = weatherImpact['risk_level'] as double;
    if (urgencyLevel == 'Urgente') {
      recommendations.add('URGENTE: Colheita deve ser iniciada imediatamente para evitar perdas.');
    } else if (urgencyLevel == 'Alta') {
      recommendations.add('Priorizar início da colheita nos próximos dias.');
    }
    if (qualityIndex < 70) {
      recommendations.add('Qualidade comprometida - considerar estratégias de melhoria pós-colheita.');
    }
    if (riskLevel > 70) {
      recommendations.add('Alto risco climático - aguardar janela de tempo favorável.');
    }
    switch (cropType) {
      case 'Milho':
        recommendations.add('Milho: verificar linha negra nos grãos como indicador de maturidade.');
        break;
      case 'Soja':
        recommendations.add('Soja: realizar colheita preferencialmente no período da manhã.');
        break;
      case 'Feijão':
        recommendations.add('Feijão: evitar colheita com orvalho para reduzir umidade.');
        break;
    }
    recommendations.add('Verificar calibração da colheitadeira antes do início.');
    recommendations.add('Monitorar umidade dos grãos durante a colheita.');
    recommendations.add('Preparar sistema de secagem se necessário.');
    recommendations.add('Acompanhar previsão do tempo diariamente.');

    return recommendations;
  }
}