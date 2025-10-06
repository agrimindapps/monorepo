import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Ganho de Peso
/// Calcula ganho de peso esperado, conversão alimentar e performance animal
class WeightGainCalculator extends CalculatorEntity {
  const WeightGainCalculator()
      : super(
          id: 'weight_gain_calculator',
          name: 'Ganho de Peso Animal',
          description: 'Calcula ganho de peso esperado, conversão alimentar, performance animal e projeções de crescimento',
          category: CalculatorCategory.livestock,
          parameters: const [
            CalculatorParameter(
              id: 'animal_species',
              name: 'Espécie Animal',
              description: 'Espécie do animal',
              type: ParameterType.selection,
              options: ['Bovino de Corte', 'Bovino de Leite', 'Suíno', 'Frango de Corte', 'Ovino', 'Caprino', 'Búfalo'],
              defaultValue: 'Bovino de Corte',
            ),
            CalculatorParameter(
              id: 'animal_category',
              name: 'Categoria Animal',
              description: 'Categoria ou fase de desenvolvimento',
              type: ParameterType.selection,
              options: ['Bezerro/Leitão', 'Recria', 'Engorda', 'Reprodutor Jovem', 'Adulto em Lactação'],
              defaultValue: 'Engorda',
            ),
            CalculatorParameter(
              id: 'current_weight',
              name: 'Peso Atual',
              description: 'Peso vivo atual do animal (kg)',
              type: ParameterType.decimal,
              unit: ParameterUnit.quilograma,
              minValue: 5.0,
              maxValue: 1000.0,
              defaultValue: 350.0,
              validationMessage: 'Peso deve estar entre 5 e 1000 kg',
            ),
            CalculatorParameter(
              id: 'target_weight',
              name: 'Peso Meta',
              description: 'Peso alvo a ser atingido (kg)',
              type: ParameterType.decimal,
              unit: ParameterUnit.quilograma,
              minValue: 10.0,
              maxValue: 1200.0,
              defaultValue: 480.0,
              validationMessage: 'Peso meta deve estar entre 10 e 1200 kg',
            ),
            CalculatorParameter(
              id: 'feed_intake',
              name: 'Consumo de Ração',
              description: 'Consumo diário de ração/alimento (kg/dia)',
              type: ParameterType.decimal,
              unit: ParameterUnit.kgdia,
              minValue: 0.1,
              maxValue: 50.0,
              defaultValue: 8.5,
              validationMessage: 'Consumo deve estar entre 0.1 e 50 kg/dia',
            ),
            CalculatorParameter(
              id: 'diet_energy',
              name: 'Energia da Dieta',
              description: 'Energia metabolizável da dieta (Mcal/kg MS)',
              type: ParameterType.decimal,
              unit: ParameterUnit.mcalkg,
              minValue: 1.5,
              maxValue: 4.0,
              defaultValue: 2.6,
              validationMessage: 'Energia deve estar entre 1.5 e 4.0 Mcal/kg',
            ),
            CalculatorParameter(
              id: 'diet_protein',
              name: 'Proteína da Dieta',
              description: 'Teor de proteína bruta da dieta (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 6.0,
              maxValue: 30.0,
              defaultValue: 14.0,
              validationMessage: 'Proteína deve estar entre 6% e 30%',
            ),
            CalculatorParameter(
              id: 'feeding_system',
              name: 'Sistema de Alimentação',
              description: 'Sistema de alimentação utilizado',
              type: ParameterType.selection,
              options: ['Confinamento Total', 'Semi-Confinamento', 'Pasto + Suplemento', 'Pasto Rotacionado', 'Creep Feeding'],
              defaultValue: 'Confinamento Total',
            ),
            CalculatorParameter(
              id: 'environmental_temperature',
              name: 'Temperatura Ambiente',
              description: 'Temperatura média ambiente (°C)',
              type: ParameterType.decimal,
              unit: ParameterUnit.celsius,
              minValue: -5.0,
              maxValue: 45.0,
              defaultValue: 25.0,
              validationMessage: 'Temperatura deve estar entre -5°C e 45°C',
            ),
            CalculatorParameter(
              id: 'animal_sex',
              name: 'Sexo do Animal',
              description: 'Sexo do animal',
              type: ParameterType.selection,
              options: ['Macho Inteiro', 'Macho Castrado', 'Fêmea'],
              defaultValue: 'Macho Castrado',
            ),
            CalculatorParameter(
              id: 'genetic_potential',
              name: 'Potencial Genético',
              description: 'Potencial genético para ganho de peso',
              type: ParameterType.selection,
              options: ['Baixo', 'Médio', 'Alto', 'Superior'],
              defaultValue: 'Médio',
            ),
            CalculatorParameter(
              id: 'health_status',
              name: 'Status Sanitário',
              description: 'Condição sanitária do animal',
              type: ParameterType.selection,
              options: ['Excelente', 'Bom', 'Regular', 'Comprometido'],
              defaultValue: 'Bom',
            ),
            CalculatorParameter(
              id: 'target_days',
              name: 'Período de Avaliação',
              description: 'Período para atingir o peso meta (dias)',
              type: ParameterType.integer,
              unit: ParameterUnit.dia,
              minValue: 30,
              maxValue: 730,
              defaultValue: 120,
              validationMessage: 'Período deve estar entre 30 e 730 dias',
            ),
          ],
          formula: 'Ganho = f(Energia Líquida, Peso Metabólico, Eficiência Genética)',
          references: const [
            'NRC (2000) - Nutrient Requirements of Beef Cattle',
            'AFRC (1993) - Energy and Protein Requirements of Ruminants',
            'Owens et al. (1993) - Factors that alter the growth and development',
            'Fox et al. (2004) - The Cornell Net Carbohydrate and Protein System',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String animalSpecies = inputs['animal_species'].toString();
      final String animalCategory = inputs['animal_category'].toString();
      final double currentWeight = double.parse(inputs['current_weight'].toString());
      final double targetWeight = double.parse(inputs['target_weight'].toString());
      final double feedIntake = double.parse(inputs['feed_intake'].toString());
      final double dietEnergy = double.parse(inputs['diet_energy'].toString());
      final double dietProtein = double.parse(inputs['diet_protein'].toString());
      final String feedingSystem = inputs['feeding_system'].toString();
      final double environmentalTemperature = double.parse(inputs['environmental_temperature'].toString());
      final String animalSex = inputs['animal_sex'].toString();
      final String geneticPotential = inputs['genetic_potential'].toString();
      final String healthStatus = inputs['health_status'].toString();
      final int targetDays = int.parse(inputs['target_days'].toString());
      if (targetWeight <= currentWeight) {
        return CalculationError(
          calculatorId: id,
          errorMessage: 'Peso meta deve ser maior que o peso atual',
          inputs: inputs,
        );
      }
      final Map<String, dynamic> speciesData = _getSpeciesGrowthParameters(animalSpecies);
      final Map<String, dynamic> energyRequirements = _calculateEnergyRequirements(
        animalSpecies, currentWeight, animalCategory, environmentalTemperature, animalSex, speciesData);
      final Map<String, dynamic> availableEnergy = _calculateAvailableEnergyForGain(
        feedIntake, dietEnergy, energyRequirements);
      final Map<String, dynamic> weightGainPotential = _calculateWeightGainPotential(
        availableEnergy, currentWeight, animalCategory, geneticPotential, healthStatus, speciesData, animalSpecies);
      final Map<String, dynamic> feedConversion = _calculateFeedConversion(
        feedIntake, weightGainPotential, feedingSystem, animalSpecies);
      final Map<String, dynamic> growthProjections = _calculateGrowthProjections(
        currentWeight, targetWeight, weightGainPotential, targetDays);
      final Map<String, dynamic> nutritionalAnalysis = _analyzeNutritionalAdequacy(
        dietEnergy, dietProtein, feedIntake, animalSpecies, animalCategory, weightGainPotential);
      final Map<String, dynamic> performanceIndicators = _calculatePerformanceIndicators(
        weightGainPotential, feedConversion, growthProjections, nutritionalAnalysis);
      final List<Map<String, dynamic>> weighingSchedule = _generateWeighingSchedule(
        currentWeight, weightGainPotential, targetDays);
      final Map<String, dynamic> economicAnalysis = _calculateEconomicAnalysis(
        feedIntake, weightGainPotential, feedingSystem, animalSpecies, targetDays);
      final List<String> recommendations = _generateZootechnicalRecommendations(
        animalSpecies, animalCategory, weightGainPotential, nutritionalAnalysis,
        feedingSystem, performanceIndicators);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Ganho de Peso Diário',
            value: CalculatorMath.roundTo(weightGainPotential['daily_gain'] as double, 3),
            unit: 'kg/dia',
            description: 'Ganho de peso diário esperado',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Conversão Alimentar',
            value: CalculatorMath.roundTo(feedConversion['feed_conversion_ratio'] as double, 2),
            unit: 'kg ração/kg ganho',
            description: 'Eficiência de conversão alimentar',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Tempo para Meta',
            value: CalculatorMath.roundTo((growthProjections['days_to_target'] as int).toDouble(), 0),
            unit: 'dias',
            description: 'Dias necessários para atingir peso meta',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Ganho Total Esperado',
            value: CalculatorMath.roundTo(growthProjections['total_weight_gain'] as double, 1),
            unit: 'kg',
            description: 'Ganho total no período avaliado',
          ),
          CalculationResultValue(
            label: 'Peso Final Projetado',
            value: CalculatorMath.roundTo(growthProjections['final_weight'] as double, 1),
            unit: 'kg',
            description: 'Peso esperado ao final do período',
          ),
          CalculationResultValue(
            label: 'Eficiência Energética',
            value: CalculatorMath.roundTo(performanceIndicators['energy_efficiency'] as double, 1),
            unit: '%',
            description: 'Eficiência de utilização da energia',
          ),
          CalculationResultValue(
            label: 'Adequação Proteica',
            value: CalculatorMath.roundTo(nutritionalAnalysis['protein_adequacy'] as double, 1),
            unit: '%',
            description: 'Adequação do nível proteico da dieta',
          ),
          CalculationResultValue(
            label: 'Taxa de Crescimento',
            value: CalculatorMath.roundTo(performanceIndicators['growth_rate'] as double, 2),
            unit: '%/dia',
            description: 'Taxa de crescimento relativo diário',
          ),
          CalculationResultValue(
            label: 'Consumo Relativo',
            value: CalculatorMath.roundTo(performanceIndicators['relative_intake'] as double, 2),
            unit: '% PV',
            description: 'Consumo como % do peso vivo',
          ),
          CalculationResultValue(
            label: 'Custo da Ração/kg Ganho',
            value: CalculatorMath.roundTo(economicAnalysis['feed_cost_per_kg_gain'] as double, 2),
            unit: 'R\$/kg',
            description: 'Custo de ração por kg de ganho',
          ),
          CalculationResultValue(
            label: 'Receita Potencial',
            value: CalculatorMath.roundTo(economicAnalysis['potential_revenue'] as double, 0),
            unit: 'R\$',
            description: 'Receita potencial com ganho de peso',
          ),
          CalculationResultValue(
            label: 'Margem por Animal',
            value: CalculatorMath.roundTo(economicAnalysis['margin_per_animal'] as double, 0),
            unit: 'R\$',
            description: 'Margem bruta por animal no período',
          ),
        ],
        recommendations: recommendations,
        tableData: weighingSchedule,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  Map<String, dynamic> _getSpeciesGrowthParameters(String species) {
    final Map<String, Map<String, dynamic>> speciesDatabase = {
      'Bovino de Corte': {
        'maintenance_energy_factor': 1.37, // Mcal EM/dia por kg^0.75
        'gain_energy_efficiency': 0.59, // Eficiência de conversão EM em EL ganho
        'max_daily_gain': 2.0, // kg/dia
        'mature_weight': 500.0, // kg
        'protein_requirement_maintenance': 7.2, // g/kg^0.75
        'protein_requirement_gain': 140.0, // g/kg ganho
        'feed_conversion_base': 6.5, // kg ração/kg ganho
      },
      'Bovino de Leite': {
        'maintenance_energy_factor': 1.40,
        'gain_energy_efficiency': 0.55,
        'max_daily_gain': 1.4,
        'mature_weight': 550.0,
        'protein_requirement_maintenance': 7.5,
        'protein_requirement_gain': 150.0,
        'feed_conversion_base': 7.0,
      },
      'Suíno': {
        'maintenance_energy_factor': 1.80,
        'gain_energy_efficiency': 0.75,
        'max_daily_gain': 1.2,
        'mature_weight': 120.0,
        'protein_requirement_maintenance': 15.0,
        'protein_requirement_gain': 180.0,
        'feed_conversion_base': 2.8,
      },
      'Frango de Corte': {
        'maintenance_energy_factor': 3.20,
        'gain_energy_efficiency': 0.70,
        'max_daily_gain': 0.08,
        'mature_weight': 3.5,
        'protein_requirement_maintenance': 25.0,
        'protein_requirement_gain': 220.0,
        'feed_conversion_base': 1.8,
      },
      'Ovino': {
        'maintenance_energy_factor': 1.45,
        'gain_energy_efficiency': 0.52,
        'max_daily_gain': 0.35,
        'mature_weight': 70.0,
        'protein_requirement_maintenance': 8.0,
        'protein_requirement_gain': 145.0,
        'feed_conversion_base': 5.5,
      },
      'Caprino': {
        'maintenance_energy_factor': 1.50,
        'gain_energy_efficiency': 0.54,
        'max_daily_gain': 0.30,
        'mature_weight': 60.0,
        'protein_requirement_maintenance': 8.5,
        'protein_requirement_gain': 150.0,
        'feed_conversion_base': 5.2,
      },
      'Búfalo': {
        'maintenance_energy_factor': 1.32,
        'gain_energy_efficiency': 0.57,
        'max_daily_gain': 1.8,
        'mature_weight': 650.0,
        'protein_requirement_maintenance': 7.0,
        'protein_requirement_gain': 135.0,
        'feed_conversion_base': 7.2,
      },
    };

    return speciesDatabase[species] ?? speciesDatabase['Bovino de Corte']!;
  }

  Map<String, dynamic> _calculateEnergyRequirements(
    String species,
    double currentWeight,
    String category,
    double temperature,
    String sex,
    Map<String, dynamic> speciesData,
  ) {
    final double metabolicWeight = math.pow(currentWeight, 0.75).toDouble();
    final double maintenanceFactor = speciesData['maintenance_energy_factor'] as double;
    double maintenanceEnergy = (maintenanceFactor * metabolicWeight) / 1000; // Mcal/dia
    if (temperature < 5 || temperature > 30) {
      final double tempDiff = temperature - 20;
      final double tempStress = (tempDiff < 0 ? -tempDiff : tempDiff) * 0.01;
      maintenanceEnergy *= (1 + math.min(tempStress, 0.25));
    }
    final Map<String, double> sexFactors = {
      'Macho Inteiro': 1.05,
      'Macho Castrado': 1.0,
      'Fêmea': 0.98,
    };

    final Map<String, double> categoryFactors = {
      'Bezerro/Leitão': 1.2, // Maior necessidade relativa
      'Recria': 1.1,
      'Engorda': 1.0,
      'Reprodutor Jovem': 1.15,
      'Adulto em Lactação': 1.3,
    };

    maintenanceEnergy *= (sexFactors[sex] ?? 1.0);
    maintenanceEnergy *= (categoryFactors[category] ?? 1.0);

    return {
      'maintenance_energy': maintenanceEnergy,
      'metabolic_weight': metabolicWeight,
      'temperature_stress': temperature < 5 || temperature > 30,
    };
  }

  Map<String, dynamic> _calculateAvailableEnergyForGain(
    double feedIntake,
    double dietEnergy,
    Map<String, dynamic> energyRequirements,
  ) {
    final double totalEnergyIntake = feedIntake * dietEnergy;
    final double maintenanceEnergy = energyRequirements['maintenance_energy'] as double;
    final double availableEnergyForGain = math.max(0, totalEnergyIntake - maintenanceEnergy);
    final double energyEfficiency = availableEnergyForGain > 0 
        ? (availableEnergyForGain / totalEnergyIntake) * 100
        : 0.0;

    return {
      'total_energy_intake': totalEnergyIntake,
      'available_energy_for_gain': availableEnergyForGain,
      'energy_efficiency': energyEfficiency,
      'energy_balance': totalEnergyIntake - maintenanceEnergy,
    };
  }

  Map<String, dynamic> _calculateWeightGainPotential(
    Map<String, dynamic> availableEnergy,
    double currentWeight,
    String category,
    String geneticPotential,
    String healthStatus,
    Map<String, dynamic> speciesData,
    String animalSpecies,
  ) {
    final double energyForGain = availableEnergy['available_energy_for_gain'] as double;
    final double gainEfficiency = speciesData['gain_energy_efficiency'] as double;
    final double maxDailyGain = speciesData['max_daily_gain'] as double;
    final double matureWeight = speciesData['mature_weight'] as double;
    final double netEnergyForGain = energyForGain * gainEfficiency;
    double energyBasedGain = 0.0;
    if (netEnergyForGain > 0) {
      final double energyPerKgGain = animalSpecies.contains('Bovino') ? 4.92 
          : animalSpecies.contains('Suíno') ? 6.8
          : animalSpecies.contains('Frango') ? 5.2
          : 5.0;
      energyBasedGain = netEnergyForGain / energyPerKgGain;
    }
    final double maturityFactor = 1.0 - math.pow(currentWeight / matureWeight, 2);
    energyBasedGain *= math.max(0.3, maturityFactor);
    final Map<String, double> geneticFactors = {
      'Baixo': 0.8,
      'Médio': 1.0,
      'Alto': 1.2,
      'Superior': 1.4,
    };
    energyBasedGain *= (geneticFactors[geneticPotential] ?? 1.0);
    final Map<String, double> healthFactors = {
      'Excelente': 1.0,
      'Bom': 0.95,
      'Regular': 0.85,
      'Comprometido': 0.70,
    };
    energyBasedGain *= (healthFactors[healthStatus] ?? 0.95);
    final double dailyGain = math.min(energyBasedGain, maxDailyGain);

    return {
      'daily_gain': math.max(0, dailyGain),
      'energy_based_gain': energyBasedGain,
      'maturity_factor': maturityFactor,
      'genetic_factor': geneticFactors[geneticPotential] ?? 1.0,
      'health_factor': healthFactors[healthStatus] ?? 0.95,
      'net_energy_for_gain': netEnergyForGain,
    };
  }

  Map<String, dynamic> _calculateFeedConversion(
    double feedIntake,
    Map<String, dynamic> weightGain,
    String feedingSystem,
    String species,
  ) {
    final double dailyGain = weightGain['daily_gain'] as double;
    double feedConversionRatio = dailyGain > 0 ? feedIntake / dailyGain : 0.0;
    final Map<String, double> systemFactors = {
      'Confinamento Total': 1.0,
      'Semi-Confinamento': 1.1,
      'Pasto + Suplemento': 1.3,
      'Pasto Rotacionado': 1.4,
      'Creep Feeding': 0.9,
    };
    feedConversionRatio *= (systemFactors[feedingSystem] ?? 1.0);
    String conversionClassification;
    final double speciesBaseFCR = species.contains('Frango') ? 1.8
        : species.contains('Suíno') ? 2.8
        : species.contains('Bovino') ? 6.5
        : 5.5;

    if (feedConversionRatio <= speciesBaseFCR * 0.9) {
      conversionClassification = 'Excelente';
    } else if (feedConversionRatio <= speciesBaseFCR * 1.1) {
      conversionClassification = 'Boa';
    } else if (feedConversionRatio <= speciesBaseFCR * 1.3) {
      conversionClassification = 'Regular';
    } else {
      conversionClassification = 'Ruim';
    }

    return {
      'feed_conversion_ratio': feedConversionRatio,
      'classification': conversionClassification,
      'system_factor': systemFactors[feedingSystem] ?? 1.0,
      'efficiency_index': speciesBaseFCR / feedConversionRatio * 100,
    };
  }

  Map<String, dynamic> _calculateGrowthProjections(
    double currentWeight,
    double targetWeight,
    Map<String, dynamic> weightGain,
    int targetDays,
  ) {
    final double dailyGain = weightGain['daily_gain'] as double;
    final double totalWeightGain = dailyGain * targetDays;
    final double finalWeight = currentWeight + totalWeightGain;
    final int daysToTarget = dailyGain > 0 
        ? ((targetWeight - currentWeight) / dailyGain).ceil()
        : 999999;
    final double growthRate = (dailyGain / currentWeight) * 100;
    final List<Map<String, dynamic>> weeklyProjection = [];
    for (int week = 1; week <= math.min(52, (targetDays / 7).ceil()); week++) {
      final int days = week * 7;
      final double projectedWeight = currentWeight + (dailyGain * days);
      weeklyProjection.add({
        'semana': week,
        'dias': days,
        'peso_projetado': CalculatorMath.roundTo(projectedWeight, 1),
        'ganho_acumulado': CalculatorMath.roundTo(dailyGain * days, 1),
      });
    }

    return {
      'total_weight_gain': totalWeightGain,
      'final_weight': finalWeight,
      'days_to_target': daysToTarget,
      'growth_rate': growthRate,
      'weekly_projection': weeklyProjection,
      'will_reach_target': finalWeight >= targetWeight,
    };
  }

  Map<String, dynamic> _analyzeNutritionalAdequacy(
    double dietEnergy,
    double dietProtein,
    double feedIntake,
    String species,
    String category,
    Map<String, dynamic> weightGain,
  ) {
    final double dailyGain = weightGain['daily_gain'] as double;
    final double idealEnergy = species.contains('Bovino') ? 2.6
        : species.contains('Suíno') ? 3.2
        : species.contains('Frango') ? 3.0
        : 2.4;
    final double idealProtein = category == 'Bezerro/Leitão' ? 18.0
        : category == 'Recria' ? 14.0
        : category == 'Engorda' ? 12.0
        : 14.0;
    final double energyAdequacy = (dietEnergy / idealEnergy) * 100;
    final double proteinAdequacy = (dietProtein / idealProtein) * 100;
    final double dailyProteinIntake = feedIntake * (dietProtein / 100) * 1000; // gramas
    final double proteinEfficiency = dailyProteinIntake > 0 
        ? (dailyGain * 1000) / dailyProteinIntake
        : 0.0;

    return {
      'energy_adequacy': energyAdequacy,
      'protein_adequacy': proteinAdequacy,
      'daily_protein_intake': dailyProteinIntake,
      'protein_efficiency': proteinEfficiency,
      'energy_classification': _classifyAdequacy(energyAdequacy),
      'protein_classification': _classifyAdequacy(proteinAdequacy),
    };
  }

  String _classifyAdequacy(double adequacy) {
    if (adequacy >= 95 && adequacy <= 110) {
      return 'Adequado';
    } else if (adequacy >= 85 && adequacy < 95) {
      return 'Ligeiramente Baixo';
    } else if (adequacy > 110 && adequacy <= 125) {
      return 'Ligeiramente Alto';
    } else if (adequacy < 85) {
      return 'Insuficiente';
    } else {
      return 'Excessivo';
    }
  }

  Map<String, dynamic> _calculatePerformanceIndicators(
    Map<String, dynamic> weightGain,
    Map<String, dynamic> feedConversion,
    Map<String, dynamic> growthProjections,
    Map<String, dynamic> nutritionalAnalysis,
  ) {
    final double dailyGain = weightGain['daily_gain'] as double;
    final double fcr = feedConversion['feed_conversion_ratio'] as double;
    final double growthRate = growthProjections['growth_rate'] as double;
    final double energyEfficiency = nutritionalAnalysis['energy_adequacy'] as double;
    double performanceIndex = 0.0;
    final double gainScore = math.min(100, dailyGain * 50); // Normalizado
    final double fcrScore = math.max(0, 100 - (fcr - 2) * 10); // Melhor FCR = maior score
    final double efficiencyScore = math.min(100, energyEfficiency);
    
    performanceIndex = (gainScore + fcrScore + efficiencyScore) / 3;
    const double relativeFeedIntake = 2.5; // Estimativa genérica

    return {
      'performance_index': performanceIndex,
      'gain_score': gainScore,
      'fcr_score': fcrScore,
      'efficiency_score': efficiencyScore,
      'growth_rate': growthRate,
      'energy_efficiency': energyEfficiency,
      'relative_intake': relativeFeedIntake,
    };
  }

  List<Map<String, dynamic>> _generateWeighingSchedule(
    double currentWeight,
    Map<String, dynamic> weightGain,
    int targetDays,
  ) {
    final List<Map<String, dynamic>> schedule = [];
    final double dailyGain = weightGain['daily_gain'] as double;
    for (int day = 0; day <= targetDays; day += 15) {
      if (day > targetDays) day = targetDays;
      
      final double projectedWeight = currentWeight + (dailyGain * day);
      final double cumulativeGain = dailyGain * day;
      
      schedule.add({
        'dia': day,
        'peso_projetado': CalculatorMath.roundTo(projectedWeight, 1),
        'ganho_acumulado': CalculatorMath.roundTo(cumulativeGain, 1),
        'ganho_periodo': day == 0 ? 0.0 : CalculatorMath.roundTo(dailyGain * 15, 1),
        'observacao': day == 0 ? 'Peso inicial' : 'Pesagem quinzenal'
      });
    }

    return schedule;
  }

  Map<String, dynamic> _calculateEconomicAnalysis(
    double feedIntake,
    Map<String, dynamic> weightGain,
    String feedingSystem,
    String species,
    int targetDays,
  ) {
    final double dailyGain = weightGain['daily_gain'] as double;
    final Map<String, double> feedPrices = {
      'Confinamento Total': 1.25, // R\$/kg
      'Semi-Confinamento': 1.10,
      'Pasto + Suplemento': 1.80, // Suplemento é mais caro
      'Pasto Rotacionado': 0.30, // Apenas custos de pastagem
      'Creep Feeding': 1.50,
    };
    
    final Map<String, double> animalPrices = {
      'Bovino de Corte': 16.0, // R\$/kg PV
      'Bovino de Leite': 14.0,
      'Suíno': 7.5,
      'Frango de Corte': 6.0,
      'Ovino': 12.0,
      'Caprino': 11.0,
      'Búfalo': 15.0,
    };
    
    final double feedPrice = feedPrices[feedingSystem] ?? 1.25;
    final double animalPrice = animalPrices[species] ?? 15.0;
    final double dailyFeedCost = feedIntake * feedPrice;
    final double totalFeedCost = dailyFeedCost * targetDays;
    final double feedCostPerKgGain = dailyGain > 0 ? dailyFeedCost / dailyGain : 0.0;
    final double totalWeightGain = dailyGain * targetDays;
    final double potentialRevenue = totalWeightGain * animalPrice;
    final double marginPerAnimal = potentialRevenue - totalFeedCost;
    final double roi = totalFeedCost > 0 ? (marginPerAnimal / totalFeedCost) * 100 : 0.0;

    return {
      'daily_feed_cost': dailyFeedCost,
      'total_feed_cost': totalFeedCost,
      'feed_cost_per_kg_gain': feedCostPerKgGain,
      'potential_revenue': potentialRevenue,
      'margin_per_animal': marginPerAnimal,
      'roi_percent': roi,
    };
  }

  List<String> _generateZootechnicalRecommendations(
    String species,
    String category,
    Map<String, dynamic> weightGain,
    Map<String, dynamic> nutritionalAnalysis,
    String feedingSystem,
    Map<String, dynamic> performanceIndicators,
  ) {
    final List<String> recommendations = [];
    
    final double dailyGain = weightGain['daily_gain'] as double;
    final double energyAdequacy = nutritionalAnalysis['energy_adequacy'] as double;
    final double proteinAdequacy = nutritionalAnalysis['protein_adequacy'] as double;
    final double performanceIndex = performanceIndicators['performance_index'] as double;
    if (dailyGain < 0.3 && species.contains('Bovino')) {
      recommendations.add('Ganho baixo para bovinos - revisar nutrição e sanidade.');
    } else if (dailyGain > 1.5 && species.contains('Bovino')) {
      recommendations.add('Excelente ganho - manter protocolo atual.');
    }
    if (energyAdequacy < 90) {
      recommendations.add('Energia insuficiente - aumentar densidade energética da dieta.');
    } else if (energyAdequacy > 120) {
      recommendations.add('Excesso de energia - otimizar custos reduzindo densidade.');
    }
    if (proteinAdequacy < 85) {
      recommendations.add('Proteína insuficiente - incluir fonte proteica adicional.');
    } else if (proteinAdequacy > 130) {
      recommendations.add('Excesso de proteína - otimizar custos reduzindo inclusão.');
    }
    if (performanceIndex < 60) {
      recommendations.add('Performance abaixo do esperado - revisar manejo geral.');
    } else if (performanceIndex > 85) {
      recommendations.add('Excelente performance - manter protocolos atuais.');
    }
    switch (feedingSystem) {
      case 'Confinamento Total':
        recommendations.add('Confinamento: monitorar acidose e fornecer fibra adequada.');
        break;
      case 'Pasto + Suplemento':
        recommendations.add('Suplementação: ajustar quantidade conforme qualidade do pasto.');
        break;
      case 'Pasto Rotacionado':
        recommendations.add('Pastejo rotacionado: respeitar altura de entrada e saída.');
        break;
    }
    switch (category) {
      case 'Bezerro/Leitão':
        recommendations.add('Animais jovens: atenção especial à digestibilidade.');
        break;
      case 'Engorda':
        recommendations.add('Fase de engorda: maximizar conversão alimentar.');
        break;
    }
    recommendations.add('Realizar pesagens regulares para acompanhar performance.');
    recommendations.add('Monitorar sanidade e vacinação em dia.');
    recommendations.add('Ajustar dieta conforme mudanças de peso e categoria.');
    recommendations.add('Manter água limpa e fresca sempre disponível.');

    return recommendations;
  }
}
