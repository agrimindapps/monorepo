import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Pastejo
/// Calcula capacidade de suporte, rotação de pastagens e manejo do pastejo
class GrazingCalculator extends CalculatorEntity {
  const GrazingCalculator()
      : super(
          id: 'grazing_calculator',
          name: 'Calculadora de Pastejo',
          description: 'Calcula capacidade de suporte, rotação de pastagens, dimensionamento de piquetes e manejo do pastejo',
          category: CalculatorCategory.livestock,
          parameters: const [
            CalculatorParameter(
              id: 'pasture_area',
              name: 'Área Total da Pastagem',
              description: 'Área total disponível para pastejo (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.1,
              maxValue: 10000.0,
              defaultValue: 100.0,
              validationMessage: 'Área deve estar entre 0.1 e 10.000 ha',
            ),
            CalculatorParameter(
              id: 'grass_species',
              name: 'Espécie Forrageira',
              description: 'Principal espécie forrageira da pastagem',
              type: ParameterType.selection,
              options: [
                'Brachiaria Brizantha',
                'Brachiaria Decumbens',
                'Brachiaria Humidicola',
                'Panicum Maximum',
                'Cynodon (Tifton)',
                'Andropogon',
                'Paspalum',
                'Coastcross',
                'Tanzânia',
                'Mombaça'
              ],
              defaultValue: 'Brachiaria Brizantha',
            ),
            CalculatorParameter(
              id: 'soil_fertility',
              name: 'Fertilidade do Solo',
              description: 'Nível de fertilidade do solo',
              type: ParameterType.selection,
              options: ['Baixa', 'Média', 'Alta', 'Muito Alta'],
              defaultValue: 'Média',
            ),
            CalculatorParameter(
              id: 'animal_species',
              name: 'Espécie Animal',
              description: 'Espécie dos animais em pastejo',
              type: ParameterType.selection,
              options: ['Bovino', 'Ovino', 'Caprino', 'Equino', 'Búfalo', 'Misto (Bovino+Ovino)'],
              defaultValue: 'Bovino',
            ),
            CalculatorParameter(
              id: 'average_animal_weight',
              name: 'Peso Médio dos Animais',
              description: 'Peso vivo médio dos animais (kg)',
              type: ParameterType.decimal,
              unit: ParameterUnit.quilograma,
              minValue: 20.0,
              maxValue: 800.0,
              defaultValue: 450.0,
              validationMessage: 'Peso deve estar entre 20 e 800 kg',
            ),
            CalculatorParameter(
              id: 'number_of_animals',
              name: 'Número de Animais',
              description: 'Número total de animais no sistema',
              type: ParameterType.integer,
              unit: ParameterUnit.cabecas,
              minValue: 1,
              maxValue: 10000,
              defaultValue: 100,
              validationMessage: 'Número deve estar entre 1 e 10.000 animais',
            ),
            CalculatorParameter(
              id: 'grazing_system',
              name: 'Sistema de Pastejo',
              description: 'Sistema de manejo do pastejo utilizado',
              type: ParameterType.selection,
              options: ['Contínuo', 'Rotacionado', 'Diferido', 'Voisin', 'Strip Grazing'],
              defaultValue: 'Rotacionado',
            ),
            CalculatorParameter(
              id: 'season',
              name: 'Estação do Ano',
              description: 'Estação para cálculo da produção forrageira',
              type: ParameterType.selection,
              options: ['Verão (Águas)', 'Inverno (Seca)', 'Transição', 'Ano Todo'],
              defaultValue: 'Verão (Águas)',
            ),
            CalculatorParameter(
              id: 'desired_residue_height',
              name: 'Altura de Resíduo Desejada',
              description: 'Altura de resíduo pós-pastejo desejada (cm)',
              type: ParameterType.decimal,
              unit: ParameterUnit.centimetro,
              minValue: 5.0,
              maxValue: 40.0,
              defaultValue: 15.0,
              validationMessage: 'Altura deve estar entre 5 e 40 cm',
            ),
            CalculatorParameter(
              id: 'entry_height',
              name: 'Altura de Entrada',
              description: 'Altura da pastagem na entrada dos animais (cm)',
              type: ParameterType.decimal,
              unit: ParameterUnit.centimetro,
              minValue: 15.0,
              maxValue: 120.0,
              defaultValue: 30.0,
              validationMessage: 'Altura deve estar entre 15 e 120 cm',
            ),
            CalculatorParameter(
              id: 'rest_period',
              name: 'Período de Descanso Desejado',
              description: 'Período de descanso desejado entre pastejo (dias)',
              type: ParameterType.integer,
              unit: ParameterUnit.dia,
              minValue: 15,
              maxValue: 90,
              defaultValue: 30,
              validationMessage: 'Período deve estar entre 15 e 90 dias',
            ),
            CalculatorParameter(
              id: 'supplementation_level',
              name: 'Nível de Suplementação',
              description: 'Nível de suplementação oferecida',
              type: ParameterType.selection,
              options: ['Sem Suplementação', 'Mineral', 'Energética Leve', 'Energética Pesada', 'Proteica'],
              defaultValue: 'Mineral',
            ),
          ],
          formula: 'Capacidade Suporte = (Produção Forrageira × Eficiência) / Consumo Animal',
          references: const [
            'Hodgson (1990) - Grazing Management: Science into Practice',
            'Carvalho et al. (2009) - Manejo do pastejo rotativo',
            'Santos et al. (2010) - Fundamentos do pastejo rotacionado',
            'Da Silva & Nascimento Jr. (2007) - Avanços na pesquisa com plantas forrageiras',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double pastureArea = double.parse(inputs['pasture_area'].toString());
      final String grassSpecies = inputs['grass_species'].toString();
      final String soilFertility = inputs['soil_fertility'].toString();
      final String animalSpecies = inputs['animal_species'].toString();
      final double averageAnimalWeight = double.parse(inputs['average_animal_weight'].toString());
      final int numberOfAnimals = int.parse(inputs['number_of_animals'].toString());
      final String grazingSystem = inputs['grazing_system'].toString();
      final String season = inputs['season'].toString();
      final double desiredResidueHeight = double.parse(inputs['desired_residue_height'].toString());
      final double entryHeight = double.parse(inputs['entry_height'].toString());
      final int restPeriod = int.parse(inputs['rest_period'].toString());
      final String supplementationLevel = inputs['supplementation_level'].toString();

      // Obter dados da espécie forrageira
      final Map<String, dynamic> grassData = _getGrassSpeciesData(grassSpecies);

      // Calcular produção forrageira
      final Map<String, dynamic> forageProduction = _calculateForageProduction(
        grassSpecies, soilFertility, season, grassData);

      // Calcular consumo animal
      final Map<String, dynamic> animalConsumption = _calculateAnimalConsumption(
        animalSpecies, averageAnimalWeight, numberOfAnimals, supplementationLevel);

      // Calcular capacidade de suporte
      final Map<String, dynamic> carryingCapacity = _calculateCarryingCapacity(
        forageProduction, animalConsumption, grazingSystem, entryHeight, desiredResidueHeight);

      // Dimensionamento do sistema rotacionado
      final Map<String, dynamic> rotationSystem = _calculateRotationSystem(
        pastureArea, numberOfAnimals, restPeriod, grazingSystem, carryingCapacity);

      // Análise de adequação da carga animal atual
      final Map<String, dynamic> stockingAnalysis = _analyzeCurrentStocking(
        numberOfAnimals, pastureArea, carryingCapacity, averageAnimalWeight);

      // Cronograma de rotação
      final List<Map<String, dynamic>> rotationSchedule = _generateRotationSchedule(
        rotationSystem, grazingSystem);

      // Indicadores zootécnicos
      final Map<String, dynamic> zootechnicalIndicators = _calculateZootechnicalIndicators(
        carryingCapacity, stockingAnalysis, forageProduction, animalConsumption);

      // Recomendações de manejo
      final List<String> managementRecommendations = _generateManagementRecommendations(
        grassSpecies, grazingSystem, stockingAnalysis, season, soilFertility, 
        zootechnicalIndicators);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Capacidade de Suporte',
            value: CalculatorMath.roundTo(carryingCapacity['ua_per_ha'] as double, 2),
            unit: 'UA/ha',
            description: 'Unidades Animais suportadas por hectare',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Produção de Forragem',
            value: CalculatorMath.roundTo(forageProduction['dry_matter_production'] as double, 0),
            unit: 'kg MS/ha/ano',
            description: 'Produção anual de matéria seca',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Taxa de Lotação Atual',
            value: CalculatorMath.roundTo(stockingAnalysis['current_stocking_rate'] as double, 2),
            unit: 'UA/ha',
            description: 'Taxa de lotação atual do sistema',
          ),
          CalculationResultValue(
            label: 'Número de Piquetes',
            value: CalculatorMath.roundTo((rotationSystem['number_of_paddocks'] as int).toDouble(), 0),
            unit: 'piquetes',
            description: 'Número de piquetes recomendado',
          ),
          CalculationResultValue(
            label: 'Área por Piquete',
            value: CalculatorMath.roundTo(rotationSystem['paddock_area'] as double, 2),
            unit: 'hectares',
            description: 'Área média de cada piquete',
          ),
          CalculationResultValue(
            label: 'Período de Ocupação',
            value: CalculatorMath.roundTo((rotationSystem['occupation_period'] as int).toDouble(), 0),
            unit: 'dias',
            description: 'Dias de pastejo por piquete',
          ),
          CalculationResultValue(
            label: 'Eficiência de Pastejo',
            value: CalculatorMath.roundTo(zootechnicalIndicators['grazing_efficiency'] as double, 1),
            unit: '%',
            description: 'Eficiência de utilização da forragem',
          ),
          CalculationResultValue(
            label: 'Pressão de Pastejo',
            value: CalculatorMath.roundTo(zootechnicalIndicators['grazing_pressure'] as double, 2),
            unit: '% PV',
            description: 'Oferta de forragem (% do peso vivo)',
          ),
          CalculationResultValue(
            label: 'Ajuste na Carga Animal',
            value: CalculatorMath.roundTo(stockingAnalysis['animal_adjustment'] as double, 0),
            unit: 'cabeças',
            description: 'Ajuste necessário no número de animais',
          ),
          CalculationResultValue(
            label: 'Adequação do Sistema',
            value: CalculatorMath.roundTo(stockingAnalysis['system_adequacy'] as double, 1),
            unit: '%',
            description: 'Grau de adequação do sistema atual',
          ),
          CalculationResultValue(
            label: 'Ganho Estimado/Animal',
            value: CalculatorMath.roundTo(zootechnicalIndicators['estimated_daily_gain'] as double, 3),
            unit: 'kg/dia',
            description: 'Ganho de peso diário estimado',
          ),
          CalculationResultValue(
            label: 'Produtividade por Área',
            value: CalculatorMath.roundTo(zootechnicalIndicators['productivity_per_ha'] as double, 0),
            unit: 'kg PV/ha/ano',
            description: 'Produtividade de peso vivo por hectare/ano',
          ),
        ],
        recommendations: managementRecommendations,
        tableData: rotationSchedule,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  Map<String, dynamic> _getGrassSpeciesData(String species) {
    final Map<String, Map<String, dynamic>> grassDatabase = {
      'Brachiaria Brizantha': {
        'base_production': 12000, // kg MS/ha/ano
        'seasonal_factor': {'verão': 1.2, 'inverno': 0.4, 'transição': 0.8, 'ano_todo': 0.85},
        'fertility_response': {'baixa': 0.7, 'média': 1.0, 'alta': 1.3, 'muito_alta': 1.5},
        'optimal_entry_height': 30,
        'optimal_exit_height': 15,
        'digestibility': 58.0, // %
        'crude_protein': 8.5, // %
        'rest_period_days': 30,
      },
      'Brachiaria Decumbens': {
        'base_production': 10000,
        'seasonal_factor': {'verão': 1.3, 'inverno': 0.3, 'transição': 0.7, 'ano_todo': 0.8},
        'fertility_response': {'baixa': 0.8, 'média': 1.0, 'alta': 1.2, 'muito_alta': 1.4},
        'optimal_entry_height': 25,
        'optimal_exit_height': 10,
        'digestibility': 55.0,
        'crude_protein': 7.5,
        'rest_period_days': 28,
      },
      'Brachiaria Humidicola': {
        'base_production': 8000,
        'seasonal_factor': {'verão': 1.1, 'inverno': 0.5, 'transição': 0.8, 'ano_todo': 0.85},
        'fertility_response': {'baixa': 0.9, 'média': 1.0, 'alta': 1.1, 'muito_alta': 1.25},
        'optimal_entry_height': 20,
        'optimal_exit_height': 8,
        'digestibility': 52.0,
        'crude_protein': 6.8,
        'rest_period_days': 25,
      },
      'Panicum Maximum': {
        'base_production': 18000,
        'seasonal_factor': {'verão': 1.4, 'inverno': 0.2, 'transição': 0.6, 'ano_todo': 0.8},
        'fertility_response': {'baixa': 0.6, 'média': 1.0, 'alta': 1.4, 'muito_alta': 1.7},
        'optimal_entry_height': 70,
        'optimal_exit_height': 30,
        'digestibility': 62.0,
        'crude_protein': 11.0,
        'rest_period_days': 35,
      },
      'Cynodon (Tifton)': {
        'base_production': 15000,
        'seasonal_factor': {'verão': 1.3, 'inverno': 0.4, 'transição': 0.8, 'ano_todo': 0.85},
        'fertility_response': {'baixa': 0.7, 'média': 1.0, 'alta': 1.5, 'muito_alta': 1.8},
        'optimal_entry_height': 20,
        'optimal_exit_height': 5,
        'digestibility': 65.0,
        'crude_protein': 13.0,
        'rest_period_days': 21,
      },
      'Andropogon': {
        'base_production': 6000,
        'seasonal_factor': {'verão': 1.2, 'inverno': 0.4, 'transição': 0.8, 'ano_todo': 0.8},
        'fertility_response': {'baixa': 1.0, 'média': 1.1, 'alta': 1.2, 'muito_alta': 1.3},
        'optimal_entry_height': 40,
        'optimal_exit_height': 20,
        'digestibility': 50.0,
        'crude_protein': 6.0,
        'rest_period_days': 35,
      },
      'Paspalum': {
        'base_production': 7000,
        'seasonal_factor': {'verão': 1.1, 'inverno': 0.6, 'transição': 0.9, 'ano_todo': 0.9},
        'fertility_response': {'baixa': 0.9, 'média': 1.0, 'alta': 1.1, 'muito_alta': 1.2},
        'optimal_entry_height': 25,
        'optimal_exit_height': 12,
        'digestibility': 56.0,
        'crude_protein': 8.0,
        'rest_period_days': 28,
      },
      'Coastcross': {
        'base_production': 16000,
        'seasonal_factor': {'verão': 1.3, 'inverno': 0.3, 'transição': 0.7, 'ano_todo': 0.8},
        'fertility_response': {'baixa': 0.7, 'média': 1.0, 'alta': 1.4, 'muito_alta': 1.7},
        'optimal_entry_height': 18,
        'optimal_exit_height': 5,
        'digestibility': 67.0,
        'crude_protein': 14.0,
        'rest_period_days': 21,
      },
      'Tanzânia': {
        'base_production': 20000,
        'seasonal_factor': {'verão': 1.4, 'inverno': 0.2, 'transição': 0.6, 'ano_todo': 0.8},
        'fertility_response': {'baixa': 0.6, 'média': 1.0, 'alta': 1.4, 'muito_alta': 1.7},
        'optimal_entry_height': 70,
        'optimal_exit_height': 30,
        'digestibility': 63.0,
        'crude_protein': 11.5,
        'rest_period_days': 35,
      },
      'Mombaça': {
        'base_production': 22000,
        'seasonal_factor': {'verão': 1.5, 'inverno': 0.2, 'transição': 0.5, 'ano_todo': 0.8},
        'fertility_response': {'baixa': 0.5, 'média': 1.0, 'alta': 1.5, 'muito_alta': 1.8},
        'optimal_entry_height': 90,
        'optimal_exit_height': 35,
        'digestibility': 64.0,
        'crude_protein': 12.0,
        'rest_period_days': 35,
      },
    };

    return grassDatabase[species] ?? grassDatabase['Brachiaria Brizantha']!;
  }

  Map<String, dynamic> _calculateForageProduction(
    String grassSpecies,
    String soilFertility,
    String season,
    Map<String, dynamic> grassData,
  ) {
    final int baseProduction = grassData['base_production'] as int;
    final Map<String, dynamic> seasonalFactors = grassData['seasonal_factor'] as Map<String, dynamic>;
    final Map<String, dynamic> fertilityFactors = grassData['fertility_response'] as Map<String, dynamic>;

    // Ajuste por estação
    String seasonKey = season.toLowerCase().contains('verão') || season.toLowerCase().contains('águas') 
        ? 'verão'
        : season.toLowerCase().contains('inverno') || season.toLowerCase().contains('seca')
        ? 'inverno'
        : season.toLowerCase().contains('transição')
        ? 'transição'
        : 'ano_todo';

    final double seasonalFactor = (seasonalFactors[seasonKey] as num?)?.toDouble() ?? 0.85;

    // Ajuste por fertilidade
    String fertilityKey = soilFertility.toLowerCase().replaceAll(' ', '_');
    final double fertilityFactor = (fertilityFactors[fertilityKey] as num?)?.toDouble() ?? 1.0;

    // Produção total ajustada
    final double adjustedProduction = baseProduction * seasonalFactor * fertilityFactor;

    // Forragem disponível para pastejo (85% da produção - perdas)
    final double availableForage = adjustedProduction * 0.85;

    return {
      'dry_matter_production': adjustedProduction,
      'available_forage': availableForage,
      'seasonal_factor': seasonalFactor,
      'fertility_factor': fertilityFactor,
      'digestibility': grassData['digestibility'] as double,
      'crude_protein': grassData['crude_protein'] as double,
    };
  }

  Map<String, dynamic> _calculateAnimalConsumption(
    String animalSpecies,
    double averageWeight,
    int numberOfAnimals,
    String supplementationLevel,
  ) {
    // Consumo base como % do peso vivo
    final Map<String, double> consumptionRates = {
      'Bovino': 2.5,
      'Ovino': 3.5,
      'Caprino': 3.8,
      'Equino': 2.2,
      'Búfalo': 2.4,
      'Misto (Bovino+Ovino)': 2.8,
    };

    final double baseConsumptionRate = consumptionRates[animalSpecies] ?? 2.5;

    // Ajuste por suplementação
    final Map<String, double> supplementationFactors = {
      'Sem Suplementação': 1.0,
      'Mineral': 1.0,
      'Energética Leve': 0.95,
      'Energética Pesada': 0.85,
      'Proteica': 0.92,
    };

    final double supplementationFactor = supplementationFactors[supplementationLevel] ?? 1.0;

    // Consumo diário por animal (kg MS/dia)
    final double dailyConsumptionPerAnimal = (averageWeight * baseConsumptionRate / 100) * supplementationFactor;

    // Consumo total do rebanho
    final double totalDailyConsumption = dailyConsumptionPerAnimal * numberOfAnimals;
    final double totalAnnualConsumption = totalDailyConsumption * 365;

    // Conversão para UA (Unidade Animal = 450 kg)
    final double totalUA = (numberOfAnimals * averageWeight) / 450;

    return {
      'daily_consumption_per_animal': dailyConsumptionPerAnimal,
      'total_daily_consumption': totalDailyConsumption,
      'total_annual_consumption': totalAnnualConsumption,
      'total_ua': totalUA,
      'consumption_rate_percent': baseConsumptionRate * supplementationFactor,
    };
  }

  Map<String, dynamic> _calculateCarryingCapacity(
    Map<String, dynamic> forageProduction,
    Map<String, dynamic> animalConsumption,
    String grazingSystem,
    double entryHeight,
    double exitHeight,
  ) {
    final double availableForage = forageProduction['available_forage'] as double;
    const double dailyConsumptionUA = 450 * 0.025; // 450 kg × 2.5% = 11.25 kg MS/dia

    // Eficiência de pastejo por sistema
    final Map<String, double> grazingEfficiency = {
      'Contínuo': 0.45,
      'Rotacionado': 0.65,
      'Diferido': 0.50,
      'Voisin': 0.70,
      'Strip Grazing': 0.75,
    };

    final double efficiency = grazingEfficiency[grazingSystem] ?? 0.60;

    // Ajuste por altura de manejo
    double heightFactor = 1.0;
    final double utilizationRate = (entryHeight - exitHeight) / entryHeight;
    if (utilizationRate > 0.7) {
      heightFactor = 0.9; // Pastejo muito intenso
    } else if (utilizationRate < 0.4) {
      heightFactor = 0.8; // Subutilização
    }

    // Forragem efetivamente utilizada
    final double utilizedForage = availableForage * efficiency * heightFactor;

    // Capacidade de suporte
    final double uaPerHa = utilizedForage / (dailyConsumptionUA * 365);

    return {
      'ua_per_ha': uaPerHa,
      'utilized_forage': utilizedForage,
      'grazing_efficiency': efficiency * 100,
      'height_factor': heightFactor,
      'utilization_rate': utilizationRate * 100,
    };
  }

  Map<String, dynamic> _calculateRotationSystem(
    double pastureArea,
    int numberOfAnimals,
    int restPeriod,
    String grazingSystem,
    Map<String, dynamic> carryingCapacity,
  ) {
    if (grazingSystem == 'Contínuo') {
      return {
        'number_of_paddocks': 1,
        'paddock_area': pastureArea,
        'occupation_period': 365,
        'rest_period': 0,
        'cycle_length': 365,
      };
    }

    // Para sistemas rotacionados
    int occupationPeriod;
    switch (grazingSystem) {
      case 'Voisin':
        occupationPeriod = 1; // 1 dia por piquete
        break;
      case 'Strip Grazing':
        occupationPeriod = 1; // 1 dia por piquete
        break;
      default:
        occupationPeriod = math.max(1, math.min(7, restPeriod ~/ 5)); // Entre 1 e 7 dias
    }

    final int cycleLength = restPeriod + occupationPeriod;
    final int numberOfPaddocks = math.max(2, (cycleLength / occupationPeriod).ceil());
    final double paddockArea = pastureArea / numberOfPaddocks;

    return {
      'number_of_paddocks': numberOfPaddocks,
      'paddock_area': paddockArea,
      'occupation_period': occupationPeriod,
      'rest_period': restPeriod,
      'cycle_length': cycleLength,
    };
  }

  Map<String, dynamic> _analyzeCurrentStocking(
    int numberOfAnimals,
    double pastureArea,
    Map<String, dynamic> carryingCapacity,
    double averageWeight,
  ) {
    final double currentUA = (numberOfAnimals * averageWeight) / 450;
    final double currentStockingRate = currentUA / pastureArea;
    final double recommendedStockingRate = carryingCapacity['ua_per_ha'] as double;

    final double adequacyPercent = (currentStockingRate / recommendedStockingRate) * 100;
    final double idealAnimals = (recommendedStockingRate * pastureArea * 450) / averageWeight;
    final double animalAdjustment = idealAnimals - numberOfAnimals;

    String adequacyClassification;
    if (adequacyPercent <= 85) {
      adequacyClassification = 'Sublotado';
    } else if (adequacyPercent <= 115) {
      adequacyClassification = 'Adequado';
    } else if (adequacyPercent <= 130) {
      adequacyClassification = 'Levemente Sobrelotado';
    } else {
      adequacyClassification = 'Sobrelotado';
    }

    return {
      'current_stocking_rate': currentStockingRate,
      'recommended_stocking_rate': recommendedStockingRate,
      'system_adequacy': math.min(100.0, adequacyPercent),
      'adequacy_classification': adequacyClassification,
      'animal_adjustment': animalAdjustment,
      'ideal_number_animals': idealAnimals,
    };
  }

  List<Map<String, dynamic>> _generateRotationSchedule(
    Map<String, dynamic> rotationSystem,
    String grazingSystem,
  ) {
    final List<Map<String, dynamic>> schedule = [];

    if (grazingSystem == 'Contínuo') {
      schedule.add({
        'piquete': 'Único',
        'periodo_ocupacao': 'Permanente',
        'observacao': 'Pastejo contínuo durante todo o ano'
      });
      return schedule;
    }

    final int numberOfPaddocks = rotationSystem['number_of_paddocks'] as int;
    final int occupationPeriod = rotationSystem['occupation_period'] as int;
    final int restPeriod = rotationSystem['rest_period'] as int;

    for (int i = 1; i <= numberOfPaddocks; i++) {
      int dayStart = ((i - 1) * occupationPeriod) + 1;
      int dayEnd = i * occupationPeriod;
      
      schedule.add({
        'piquete': 'Piquete $i',
        'periodo_ocupacao': '$occupationPeriod dias (dias $dayStart-$dayEnd)',
        'periodo_descanso': '$restPeriod dias',
        'observacao': 'Rotação a cada ${occupationPeriod + restPeriod} dias'
      });
    }

    return schedule;
  }

  Map<String, dynamic> _calculateZootechnicalIndicators(
    Map<String, dynamic> carryingCapacity,
    Map<String, dynamic> stockingAnalysis,
    Map<String, dynamic> forageProduction,
    Map<String, dynamic> animalConsumption,
  ) {
    final double grazingEfficiency = carryingCapacity['grazing_efficiency'] as double;
    final double digestibility = forageProduction['digestibility'] as double;
    final double crudeProtein = forageProduction['crude_protein'] as double;
    final double consumptionRate = animalConsumption['consumption_rate_percent'] as double;

    // Pressão de pastejo (oferta de forragem)
    final double grazingPressure = consumptionRate * 1.5; // 150% do consumo como oferta

    // Estimativa de ganho diário baseado na qualidade da forragem
    double estimatedDailyGain = 0.0;
    if (digestibility >= 65 && crudeProtein >= 12) {
      estimatedDailyGain = 0.8; // Forragem de alta qualidade
    } else if (digestibility >= 58 && crudeProtein >= 9) {
      estimatedDailyGain = 0.6; // Forragem de média qualidade
    } else if (digestibility >= 52 && crudeProtein >= 7) {
      estimatedDailyGain = 0.4; // Forragem de baixa qualidade
    } else {
      estimatedDailyGain = 0.2; // Forragem de qualidade muito baixa
    }

    // Ajuste pelo sistema de pastejo
    final double systemEfficiency = grazingEfficiency / 100;
    estimatedDailyGain *= systemEfficiency;

    // Produtividade por hectare
    final double uaPerHa = carryingCapacity['ua_per_ha'] as double;
    final double productivityPerHa = uaPerHa * 450 * estimatedDailyGain * 365;

    return {
      'grazing_efficiency': grazingEfficiency,
      'grazing_pressure': grazingPressure,
      'estimated_daily_gain': estimatedDailyGain,
      'productivity_per_ha': productivityPerHa,
      'forage_quality_index': (digestibility + crudeProtein * 2) / 3,
    };
  }

  List<String> _generateManagementRecommendations(
    String grassSpecies,
    String grazingSystem,
    Map<String, dynamic> stockingAnalysis,
    String season,
    String soilFertility,
    Map<String, dynamic> indicators,
  ) {
    final List<String> recommendations = [];

    // Recomendações por adequação do sistema
    final String adequacy = stockingAnalysis['adequacy_classification'] as String;
    switch (adequacy) {
      case 'Sublotado':
        recommendations.add('Sistema sublotado - considere aumentar carga animal ou reduzir área.');
        break;
      case 'Sobrelotado':
        recommendations.add('Sistema sobrelotado - reduza carga animal ou aumente área de pastagem.');
        break;
      case 'Levemente Sobrelotado':
        recommendations.add('Carga animal levemente alta - monitore condição da pastagem.');
        break;
    }

    // Recomendações por sistema de pastejo
    switch (grazingSystem) {
      case 'Contínuo':
        recommendations.add('Pastejo contínuo - considere divisão em piquetes para melhor eficiência.');
        break;
      case 'Rotacionado':
        recommendations.add('Pastejo rotacionado - respeite período de descanso para rebrota.');
        break;
      case 'Voisin':
        recommendations.add('Sistema Voisin - monitore ponto ótimo de pastejo diariamente.');
        break;
    }

    // Recomendações por qualidade da forragem
    final double qualityIndex = indicators['forage_quality_index'] as double;
    if (qualityIndex < 50) {
      recommendations.add('Forragem de baixa qualidade - considere suplementação proteica.');
    } else if (qualityIndex > 70) {
      recommendations.add('Forragem de boa qualidade - aproveite para categorias exigentes.');
    }

    // Recomendações por estação
    if (season.contains('Seca') || season.contains('Inverno')) {
      recommendations.add('Período seco - monitore oferta de forragem e considere suplementação.');
      recommendations.add('Considere diferimento de pastagens para o período seco.');
    }

    // Recomendações por fertilidade
    if (soilFertility == 'Baixa') {
      recommendations.add('Solo de baixa fertilidade - investir em correção e adubação.');
    } else if (soilFertility == 'Alta' || soilFertility == 'Muito Alta') {
      recommendations.add('Solo fértil - otimize carga animal para máximo aproveitamento.');
    }

    // Recomendações específicas por espécie forrageira
    if (grassSpecies.contains('Panicum') || grassSpecies.contains('Tanzânia') || grassSpecies.contains('Mombaça')) {
      recommendations.add('Capim de alta exigência - manter fertilidade do solo e manejo adequado.');
    } else if (grassSpecies.contains('Brachiaria')) {
      recommendations.add('Brachiaria - resistente mas responde bem à adubação.');
    }

    // Recomendações gerais
    recommendations.add('Monitorar altura de entrada e saída dos piquetes.');
    recommendations.add('Fazer análise de solo anualmente para adequar adubação.');
    recommendations.add('Considerar consórcio com leguminosas para fixação de nitrogênio.');
    recommendations.add('Manter disponibilidade de água em todos os piquetes.');

    return recommendations;
  }
}