import 'dart:math' as math;
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_parameter.dart';
import '../../entities/calculation_result.dart';
import '../../entities/calculator_engine.dart';

/// Calculadora de Alimentação Animal
/// Calcula necessidades nutricionais e formulação de rações para diferentes espécies
class FeedCalculator extends CalculatorEntity {
  FeedCalculator()
      : super(
          id: 'feed_calculator',
          name: 'Calculadora de Alimentação',
          description: 'Calcula necessidades nutricionais e formulação de rações para bovinos, suínos, aves e outras espécies',
          category: CalculatorCategory.livestock,
          parameters: const [
            CalculatorParameter(
              id: 'animal_species',
              name: 'Espécie Animal',
              description: 'Espécie do animal',
              type: ParameterType.selection,
              options: ['Bovino de Leite', 'Bovino de Corte', 'Suíno', 'Frango de Corte', 'Galinha Poedeira', 'Ovino', 'Caprino', 'Equino'],
              defaultValue: 'Bovino de Leite',
            ),
            CalculatorParameter(
              id: 'animal_category',
              name: 'Categoria Animal',
              description: 'Categoria ou fase produtiva do animal',
              type: ParameterType.selection,
              options: ['Lactação', 'Gestação', 'Crescimento', 'Engorda', 'Manutenção', 'Reprodução'],
              defaultValue: 'Lactação',
            ),
            CalculatorParameter(
              id: 'live_weight',
              name: 'Peso Vivo',
              description: 'Peso vivo atual do animal (kg)',
              type: ParameterType.decimal,
              unit: ParameterUnit.quilograma,
              minValue: 10.0,
              maxValue: 1000.0,
              defaultValue: 550.0,
              validationMessage: 'Peso deve estar entre 10 e 1000 kg',
            ),
            CalculatorParameter(
              id: 'daily_gain',
              name: 'Ganho Diário',
              description: 'Ganho de peso diário desejado (kg/dia)',
              type: ParameterType.decimal,
              unit: ParameterUnit.kgdia,
              minValue: 0.0,
              maxValue: 2.5,
              defaultValue: 0.8,
              validationMessage: 'Ganho deve estar entre 0 e 2.5 kg/dia',
            ),
            CalculatorParameter(
              id: 'milk_production',
              name: 'Produção de Leite',
              description: 'Produção diária de leite (litros/dia)',
              type: ParameterType.decimal,
              unit: ParameterUnit.litrodia,
              minValue: 0.0,
              maxValue: 80.0,
              defaultValue: 25.0,
              validationMessage: 'Produção deve estar entre 0 e 80 L/dia',
            ),
            CalculatorParameter(
              id: 'milk_fat',
              name: 'Gordura do Leite',
              description: 'Teor de gordura do leite (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 2.5,
              maxValue: 6.0,
              defaultValue: 3.6,
              validationMessage: 'Gordura deve estar entre 2.5% e 6%',
            ),
            CalculatorParameter(
              id: 'pregnancy_month',
              name: 'Mês de Gestação',
              description: 'Mês de gestação (0 se não gestante)',
              type: ParameterType.integer,
              unit: ParameterUnit.mes,
              minValue: 0,
              maxValue: 12,
              defaultValue: 0,
              validationMessage: 'Gestação deve estar entre 0 e 12 meses',
            ),
            CalculatorParameter(
              id: 'environmental_temp',
              name: 'Temperatura Ambiente',
              description: 'Temperatura média ambiente (°C)',
              type: ParameterType.decimal,
              unit: ParameterUnit.celsius,
              minValue: -10.0,
              maxValue: 45.0,
              defaultValue: 22.0,
              validationMessage: 'Temperatura deve estar entre -10°C e 45°C',
            ),
            CalculatorParameter(
              id: 'activity_level',
              name: 'Nível de Atividade',
              description: 'Nível de atividade do animal',
              type: ParameterType.selection,
              options: ['Baixo (confinamento)', 'Moderado (pasto pequeno)', 'Alto (pasto extenso)', 'Muito Alto (trabalho)'],
              defaultValue: 'Moderado (pasto pequeno)',
            ),
            CalculatorParameter(
              id: 'feed_quality',
              name: 'Qualidade da Forragem',
              description: 'Qualidade da forragem base disponível',
              type: ParameterType.selection,
              options: ['Excelente', 'Boa', 'Regular', 'Ruim', 'Sem Forragem'],
              defaultValue: 'Boa',
            ),
            CalculatorParameter(
              id: 'number_animals',
              name: 'Número de Animais',
              description: 'Número total de animais no lote',
              type: ParameterType.integer,
              unit: ParameterUnit.cabecas,
              minValue: 1,
              maxValue: 10000,
              defaultValue: 50,
              validationMessage: 'Número deve estar entre 1 e 10.000 animais',
            ),
          ],
          formula: 'NDT = EM mantença + EM produção + EM ganho + EM gestação',
          references: const [
            'NRC (2001) - Nutrient Requirements of Dairy Cattle',
            'BR-CORTE (2010) - Exigências Nutricionais de Zebuínos',
            'Rostagno et al. (2017) - Tabelas Brasileiras para Aves e Suínos',
            'AFRC (1993) - Energy and Protein Requirements of Ruminants',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String animalSpecies = inputs['animal_species'].toString();
      final String animalCategory = inputs['animal_category'].toString();
      final double liveWeight = double.parse(inputs['live_weight'].toString());
      final double dailyGain = double.parse(inputs['daily_gain'].toString());
      final double milkProduction = double.parse(inputs['milk_production'].toString());
      final double milkFat = double.parse(inputs['milk_fat'].toString());
      final int pregnancyMonth = int.parse(inputs['pregnancy_month'].toString());
      final double environmentalTemp = double.parse(inputs['environmental_temp'].toString());
      final String activityLevel = inputs['activity_level'].toString();
      final String feedQuality = inputs['feed_quality'].toString();
      final int numberAnimals = int.parse(inputs['number_animals'].toString());

      // Obter parâmetros da espécie
      final Map<String, dynamic> speciesData = _getSpeciesParameters(animalSpecies);

      // Calcular necessidades energéticas
      final Map<String, dynamic> energyRequirements = _calculateEnergyRequirements(
        animalSpecies, animalCategory, liveWeight, dailyGain, milkProduction, 
        milkFat, pregnancyMonth, environmentalTemp, activityLevel, speciesData);

      // Calcular necessidades proteicas
      final Map<String, dynamic> proteinRequirements = _calculateProteinRequirements(
        animalSpecies, animalCategory, liveWeight, dailyGain, milkProduction, 
        pregnancyMonth, energyRequirements, speciesData);

      // Calcular consumo de matéria seca
      final Map<String, dynamic> dryMatterIntake = _calculateDryMatterIntake(
        animalSpecies, liveWeight, milkProduction, pregnancyMonth, 
        environmentalTemp, feedQuality, speciesData);

      // Calcular necessidades de minerais
      final Map<String, dynamic> mineralRequirements = _calculateMineralRequirements(
        animalSpecies, liveWeight, milkProduction, dailyGain, pregnancyMonth, speciesData);

      // Formulação da ração
      final Map<String, dynamic> feedFormulation = _formulateFeed(
        energyRequirements, proteinRequirements, dryMatterIntake, 
        mineralRequirements, feedQuality, animalSpecies);

      // Cronograma alimentar
      final List<Map<String, dynamic>> feedingSchedule = _generateFeedingSchedule(
        animalSpecies, animalCategory, feedFormulation);

      // Análise econômica
      final Map<String, dynamic> economicAnalysis = _calculateEconomicAnalysis(
        feedFormulation, numberAnimals, animalSpecies);

      // Indicadores zootécnicos
      final Map<String, dynamic> zootechnicalIndicators = _calculateZootechnicalIndicators(
        energyRequirements, proteinRequirements, dryMatterIntake, 
        liveWeight, milkProduction, dailyGain);

      // Recomendações nutricionais
      final List<String> recommendations = _generateNutritionalRecommendations(
        animalSpecies, animalCategory, energyRequirements, proteinRequirements,
        feedQuality, environmentalTemp, zootechnicalIndicators);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Consumo de Matéria Seca',
            value: CalculatorMath.roundTo(dryMatterIntake['total_dmi'] as double, 2),
            unit: 'kg/dia',
            description: 'Consumo total de matéria seca por animal',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'NDT Necessário',
            value: CalculatorMath.roundTo(energyRequirements['total_ndt'] as double, 2),
            unit: 'kg/dia',
            description: 'Nutrientes digestíveis totais necessários',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Proteína Bruta',
            value: CalculatorMath.roundTo(proteinRequirements['total_pb'] as double, 0),
            unit: 'g/dia',
            description: 'Proteína bruta total necessária',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Energia Metabolizável',
            value: CalculatorMath.roundTo(energyRequirements['total_em'] as double, 0),
            unit: 'Mcal/dia',
            description: 'Energia metabolizável total',
          ),
          CalculationResultValue(
            label: 'Cálcio',
            value: CalculatorMath.roundTo(mineralRequirements['calcium'] as double, 0),
            unit: 'g/dia',
            description: 'Necessidade diária de cálcio',
          ),
          CalculationResultValue(
            label: 'Fósforo',
            value: CalculatorMath.roundTo(mineralRequirements['phosphorus'] as double, 0),
            unit: 'g/dia',
            description: 'Necessidade diária de fósforo',
          ),
          CalculatorResultValue(
            label: 'Concentrado Recomendado',
            value: CalculatorMath.roundTo(feedFormulation['concentrate_kg'] as double, 2),
            unit: 'kg/dia',
            description: 'Quantidade de concentrado por animal',
          ),
          CalculationResultValue(
            label: 'Volumoso Recomendado',
            value: CalculatorMath.roundTo(feedFormulation['roughage_kg'] as double, 2),
            unit: 'kg/dia',
            description: 'Quantidade de volumoso por animal',
          ),
          CalculationResultValue(
            label: 'Custo da Ração/Animal',
            value: CalculatorMath.roundTo(economicAnalysis['daily_cost_per_animal'] as double, 2),
            unit: 'R\$/dia',
            description: 'Custo diário da alimentação por animal',
          ),
          CalculationResultValue(
            label: 'Custo Total do Lote',
            value: CalculatorMath.roundTo(economicAnalysis['daily_cost_total'] as double, 2),
            unit: 'R\$/dia',
            description: 'Custo diário total para o lote',
          ),
          CalculationResultValue(
            label: 'Eficiência Alimentar',
            value: CalculatorMath.roundTo(zootechnicalIndicators['feed_efficiency'] as double, 2),
            unit: 'kg MS/kg ganho',
            description: 'Eficiência de conversão alimentar',
          ),
          CalculationResultValue(
            label: 'Concentração Energética',
            value: CalculatorMath.roundTo(zootechnicalIndicators['energy_density'] as double, 2),
            unit: 'Mcal EM/kg MS',
            description: 'Densidade energética da dieta',
          ),
        ],
        recommendations: recommendations,
        tableData: feedingSchedule,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  Map<String, dynamic> _getSpeciesParameters(String species) {
    final Map<String, Map<String, dynamic>> speciesDatabase = {
      'Bovino de Leite': {
        'maintenance_factor': 1.4, // Fator de mantença
        'milk_energy_factor': 0.74, // Mcal EM/L leite
        'gain_energy_factor': 4.92, // Mcal EM/kg ganho
        'pregnancy_factor': 1.13, // Fator gestação (últimos 2 meses)
        'protein_maintenance': 7.2, // g PB/kg PV^0.75
        'protein_milk_factor': 78.0, // g PB/L leite
        'max_dmi_factor': 3.5, // % do PV
        'optimal_ndt': 68.0, // % NDT na dieta
      },
      'Bovino de Corte': {
        'maintenance_factor': 1.35,
        'milk_energy_factor': 0.0,
        'gain_energy_factor': 5.12,
        'pregnancy_factor': 1.20,
        'protein_maintenance': 6.8,
        'protein_milk_factor': 0.0,
        'max_dmi_factor': 2.8,
        'optimal_ndt': 65.0,
      },
      'Suíno': {
        'maintenance_factor': 1.8,
        'milk_energy_factor': 0.0,
        'gain_energy_factor': 8.8,
        'pregnancy_factor': 1.25,
        'protein_maintenance': 15.0,
        'protein_milk_factor': 0.0,
        'max_dmi_factor': 4.0,
        'optimal_ndt': 78.0,
      },
      'Frango de Corte': {
        'maintenance_factor': 3.2,
        'milk_energy_factor': 0.0,
        'gain_energy_factor': 12.5,
        'pregnancy_factor': 1.0,
        'protein_maintenance': 25.0,
        'protein_milk_factor': 0.0,
        'max_dmi_factor': 8.0,
        'optimal_ndt': 82.0,
      },
      'Galinha Poedeira': {
        'maintenance_factor': 2.8,
        'milk_energy_factor': 2.0, // Energia por ovo
        'gain_energy_factor': 10.0,
        'pregnancy_factor': 1.0,
        'protein_maintenance': 22.0,
        'protein_milk_factor': 6.0, // Proteína por ovo
        'max_dmi_factor': 10.0,
        'optimal_ndt': 80.0,
      },
      'Ovino': {
        'maintenance_factor': 1.5,
        'milk_energy_factor': 0.8,
        'gain_energy_factor': 5.5,
        'pregnancy_factor': 1.15,
        'protein_maintenance': 8.0,
        'protein_milk_factor': 85.0,
        'max_dmi_factor': 3.2,
        'optimal_ndt': 66.0,
      },
      'Caprino': {
        'maintenance_factor': 1.6,
        'milk_energy_factor': 0.78,
        'gain_energy_factor': 5.2,
        'pregnancy_factor': 1.18,
        'protein_maintenance': 8.5,
        'protein_milk_factor': 80.0,
        'max_dmi_factor': 3.8,
        'optimal_ndt': 67.0,
      },
      'Equino': {
        'maintenance_factor': 1.2,
        'milk_energy_factor': 0.0,
        'gain_energy_factor': 4.5,
        'pregnancy_factor': 1.10,
        'protein_maintenance': 6.0,
        'protein_milk_factor': 0.0,
        'max_dmi_factor': 2.5,
        'optimal_ndt': 60.0,
      },
    };

    return speciesDatabase[species] ?? speciesDatabase['Bovino de Leite']!;
  }

  Map<String, dynamic> _calculateEnergyRequirements(
    String species,
    String category,
    double weight,
    double gain,
    double milkProduction,
    double milkFat,
    int pregnancyMonth,
    double temperature,
    String activity,
    Map<String, dynamic> speciesData,
  ) {
    // Energia de mantença (EM mantença)
    final double metabolicWeight = math.pow(weight, 0.75).toDouble();
    double maintenanceEM = (speciesData['maintenance_factor'] as double) * metabolicWeight / 1000;

    // Ajuste por temperatura
    if (temperature < 5 || temperature > 30) {
      final double tempStress = math.max(0.05, math.min(0.25, math.abs(temperature - 20) * 0.01));
      maintenanceEM *= (1 + tempStress);
    }

    // Ajuste por atividade
    final Map<String, double> activityFactors = {
      'Baixo (confinamento)': 1.0,
      'Moderado (pasto pequeno)': 1.15,
      'Alto (pasto extenso)': 1.25,
      'Muito Alto (trabalho)': 1.4,
    };
    maintenanceEM *= (activityFactors[activity] ?? 1.0);

    // Energia para produção de leite
    double milkEM = 0.0;
    if (milkProduction > 0) {
      final double fatCorrectedMilk = milkProduction * (0.4 + 0.15 * milkFat);
      milkEM = fatCorrectedMilk * (speciesData['milk_energy_factor'] as double);
    }

    // Energia para ganho de peso
    double gainEM = 0.0;
    if (gain > 0) {
      gainEM = gain * (speciesData['gain_energy_factor'] as double);
    }

    // Energia para gestação
    double pregnancyEM = 0.0;
    if (pregnancyMonth >= 6) { // Últimos meses de gestação
      final double pregnancyFactor = speciesData['pregnancy_factor'] as double;
      pregnancyEM = maintenanceEM * (pregnancyFactor - 1.0);
    }

    final double totalEM = maintenanceEM + milkEM + gainEM + pregnancyEM;
    final double totalNDT = totalEM / 4.4; // Conversão EM para NDT (bovinos)

    return {
      'maintenance_em': maintenanceEM,
      'milk_em': milkEM,
      'gain_em': gainEM,
      'pregnancy_em': pregnancyEM,
      'total_em': totalEM,
      'total_ndt': totalNDT,
    };
  }

  Map<String, dynamic> _calculateProteinRequirements(
    String species,
    String category,
    double weight,
    double gain,
    double milkProduction,
    int pregnancyMonth,
    Map<String, dynamic> energyReq,
    Map<String, dynamic> speciesData,
  ) {
    // Proteína de mantença
    final double metabolicWeight = math.pow(weight, 0.75).toDouble();
    final double maintenancePB = (speciesData['protein_maintenance'] as double) * metabolicWeight;

    // Proteína para produção de leite
    double milkPB = 0.0;
    if (milkProduction > 0) {
      milkPB = milkProduction * (speciesData['protein_milk_factor'] as double);
    }

    // Proteína para ganho de peso
    double gainPB = 0.0;
    if (gain > 0) {
      final double proteinDeposition = gain * 140; // g proteína/kg ganho (bovinos)
      gainPB = proteinDeposition / 0.59; // Eficiência de utilização da proteína
    }

    // Proteína para gestação
    double pregnancyPB = 0.0;
    if (pregnancyMonth >= 6) {
      pregnancyPB = maintenancePB * 0.15; // 15% adicional
    }

    final double totalPB = maintenancePB + milkPB + gainPB + pregnancyPB;

    return {
      'maintenance_pb': maintenancePB,
      'milk_pb': milkPB,
      'gain_pb': gainPB,
      'pregnancy_pb': pregnancyPB,
      'total_pb': totalPB,
    };
  }

  Map<String, dynamic> _calculateDryMatterIntake(
    String species,
    double weight,
    double milkProduction,
    int pregnancyMonth,
    double temperature,
    String feedQuality,
    Map<String, dynamic> speciesData,
  ) {
    // Consumo base como % do peso vivo
    double baseDMI = weight * (speciesData['max_dmi_factor'] as double) / 100;

    // Ajuste por produção de leite (bovinos)
    if (species.contains('Bovino') && milkProduction > 0) {
      baseDMI += milkProduction * 0.1; // 0.1 kg MS/L leite adicional
    }

    // Ajuste por temperatura
    if (temperature > 30) {
      final double heatStress = (temperature - 30) * 0.02;
      baseDMI *= (1 - math.min(heatStress, 0.15));
    } else if (temperature < 5) {
      baseDMI *= 1.05; // Ligeiro aumento em frio
    }

    // Ajuste por qualidade da forragem
    final Map<String, double> qualityFactors = {
      'Excelente': 1.0,
      'Boa': 0.95,
      'Regular': 0.85,
      'Ruim': 0.75,
      'Sem Forragem': 1.0, // Ração completa
    };
    baseDMI *= (qualityFactors[feedQuality] ?? 0.9);

    // Ajuste por gestação (redução no final)
    if (pregnancyMonth >= 8) {
      baseDMI *= 0.9; // Redução de 10%
    }

    return {
      'total_dmi': baseDMI,
      'dmi_per_kg_weight': (baseDMI / weight) * 100,
    };
  }

  Map<String, dynamic> _calculateMineralRequirements(
    String species,
    double weight,
    double milkProduction,
    double gain,
    int pregnancyMonth,
    Map<String, dynamic> speciesData,
  ) {
    // Necessidades básicas de minerais (g/dia)
    double calcium = weight * 0.05; // Base: 0.05g Ca/kg PV
    double phosphorus = weight * 0.04; // Base: 0.04g P/kg PV
    double sodium = weight * 0.02;
    double magnesium = weight * 0.015;

    // Adicionais para produção de leite
    if (milkProduction > 0) {
      calcium += milkProduction * 1.2; // 1.2g Ca/L leite
      phosphorus += milkProduction * 0.9; // 0.9g P/L leite
    }

    // Adicionais para ganho de peso
    if (gain > 0) {
      calcium += gain * 8.0; // 8g Ca/kg ganho
      phosphorus += gain * 4.5; // 4.5g P/kg ganho
    }

    // Adicionais para gestação
    if (pregnancyMonth >= 6) {
      calcium *= 1.2;
      phosphorus *= 1.15;
    }

    return {
      'calcium': calcium,
      'phosphorus': phosphorus,
      'sodium': sodium,
      'magnesium': magnesium,
      'ca_p_ratio': calcium / phosphorus,
    };
  }

  Map<String, dynamic> _formulateFeed(
    Map<String, dynamic> energyReq,
    Map<String, dynamic> proteinReq,
    Map<String, dynamic> dmiReq,
    Map<String, dynamic> mineralReq,
    String feedQuality,
    String species,
  ) {
    final double totalDMI = dmiReq['total_dmi'] as double;
    final double totalNDT = energyReq['total_ndt'] as double;
    final double totalPB = proteinReq['total_pb'] as double;

    // Características dos volumosos baseado na qualidade
    final Map<String, Map<String, double>> roughageData = {
      'Excelente': {'ndt': 68.0, 'pb': 14.0, 'proportion': 0.6},
      'Boa': {'ndt': 60.0, 'pb': 12.0, 'proportion': 0.65},
      'Regular': {'ndt': 52.0, 'pb': 8.0, 'proportion': 0.7},
      'Ruim': {'ndt': 45.0, 'pb': 6.0, 'proportion': 0.75},
      'Sem Forragem': {'ndt': 0.0, 'pb': 0.0, 'proportion': 0.0},
    };

    final roughageSpecs = roughageData[feedQuality] ?? roughageData['Boa']!;
    
    // Proporção de volumoso e concentrado
    double roughageProportion = roughageSpecs['proportion']!;
    double concentrateProportion = 1.0 - roughageProportion;

    // Ajustar proporções baseado nas necessidades
    final double requiredNDT = (totalNDT / totalDMI) * 100; // % NDT necessário
    if (requiredNDT > 65) {
      // Aumentar concentrado para dietas de alta energia
      concentrateProportion = math.min(0.6, concentrateProportion + 0.1);
      roughageProportion = 1.0 - concentrateProportion;
    }

    final double roughageKg = totalDMI * roughageProportion;
    final double concentrateKg = totalDMI * concentrateProportion;

    // NDT fornecido pelo volumoso
    final double roughageNDT = roughageKg * (roughageSpecs['ndt']! / 100);
    
    // NDT necessário do concentrado
    final double concentrateNDTNeeded = totalNDT - roughageNDT;
    final double concentrateNDTPercent = concentrateKg > 0 
        ? math.min(85.0, (concentrateNDTNeeded / concentrateKg) * 100)
        : 75.0;

    // Proteína fornecida pelo volumoso
    final double roughagePB = roughageKg * (roughageSpecs['pb']! / 100) * 1000; // em gramas
    
    // Proteína necessária do concentrado
    final double concentratePBNeeded = totalPB - roughagePB;
    final double concentratePBPercent = concentrateKg > 0 
        ? math.min(25.0, (concentratePBNeeded / (concentrateKg * 1000)) * 100)
        : 18.0;

    return {
      'roughage_kg': roughageKg,
      'concentrate_kg': concentrateKg,
      'roughage_proportion': roughageProportion * 100,
      'concentrate_proportion': concentrateProportion * 100,
      'concentrate_ndt_percent': concentrateNDTPercent,
      'concentrate_pb_percent': concentratePBPercent,
      'total_ndt_percent': (totalNDT / totalDMI) * 100,
      'total_pb_percent': (totalPB / (totalDMI * 1000)) * 100,
    };
  }

  List<Map<String, dynamic>> _generateFeedingSchedule(
    String species,
    String category,
    Map<String, dynamic> formulation,
  ) {
    final List<Map<String, dynamic>> schedule = [];

    if (species.contains('Bovino')) {
      // Bovinos - 2-3 refeições por dia
      schedule.addAll([
        {
          'horario': '06:00',
          'volumoso': CalculatorMath.roundTo((formulation['roughage_kg'] as double) * 0.4, 1),
          'concentrado': CalculatorMath.roundTo((formulation['concentrate_kg'] as double) * 0.5, 1),
          'observacao': 'Refeição matinal - maior concentrado'
        },
        {
          'horario': '14:00',
          'volumoso': CalculatorMath.roundTo((formulation['roughage_kg'] as double) * 0.4, 1),
          'concentrado': CalculatorMath.roundTo((formulation['concentrate_kg'] as double) * 0.5, 1),
          'observacao': 'Refeição vespertina'
        },
        {
          'horario': '20:00',
          'volumoso': CalculatorMath.roundTo((formulation['roughage_kg'] as double) * 0.2, 1),
          'concentrado': 0.0,
          'observacao': 'Volumoso noturno'
        },
      ]);
    } else if (species == 'Suíno') {
      // Suínos - 3-4 refeições por dia
      final double totalFeed = (formulation['concentrate_kg'] as double);
      schedule.addAll([
        {
          'horario': '07:00',
          'racao': CalculatorMath.roundTo(totalFeed * 0.3, 1),
          'observacao': 'Primeira refeição'
        },
        {
          'horario': '12:00',
          'racao': CalculatorMath.roundTo(totalFeed * 0.3, 1),
          'observacao': 'Refeição do meio-dia'
        },
        {
          'horario': '17:00',
          'racao': CalculatorMath.roundTo(totalFeed * 0.4, 1),
          'observacao': 'Última refeição - maior quantidade'
        },
      ]);
    } else {
      // Outros animais - esquema genérico
      schedule.addAll([
        {
          'horario': '07:00',
          'alimento': CalculatorMath.roundTo((formulation['concentrate_kg'] as double) * 0.6, 1),
          'observacao': 'Refeição principal'
        },
        {
          'horario': '16:00',
          'alimento': CalculatorMath.roundTo((formulation['concentrate_kg'] as double) * 0.4, 1),
          'observacao': 'Refeição complementar'
        },
      ]);
    }

    return schedule;
  }

  Map<String, dynamic> _calculateEconomicAnalysis(
    Map<String, dynamic> formulation,
    int numberAnimals,
    String species,
  ) {
    // Preços médios dos ingredientes (R\$/kg)
    final Map<String, double> ingredientPrices = {
      'volumoso': 0.25, // Silagem, feno, pasto
      'concentrado_bovino': 1.20, // Ração concentrada bovinos
      'concentrado_suino': 1.35, // Ração suínos
      'concentrado_aves': 1.45, // Ração aves
      'concentrado_outros': 1.25, // Outros
    };

    String concentrateType = 'concentrado_outros';
    if (species.contains('Bovino')) {
      concentrateType = 'concentrado_bovino';
    } else if (species == 'Suíno') {
      concentrateType = 'concentrado_suino';
    } else if (species.contains('Frango') || species.contains('Galinha')) {
      concentrateType = 'concentrado_aves';
    }

    final double roughageCost = (formulation['roughage_kg'] as double) * 
                               (ingredientPrices['volumoso'] ?? 0.25);
    final double concentrateCost = (formulation['concentrate_kg'] as double) * 
                                  (ingredientPrices[concentrateType] ?? 1.25);

    final double dailyCostPerAnimal = roughageCost + concentrateCost;
    final double dailyCostTotal = dailyCostPerAnimal * numberAnimals;
    final double monthlyCostTotal = dailyCostTotal * 30;
    final double annualCostTotal = dailyCostTotal * 365;

    return {
      'roughage_cost': roughageCost,
      'concentrate_cost': concentrateCost,
      'daily_cost_per_animal': dailyCostPerAnimal,
      'daily_cost_total': dailyCostTotal,
      'monthly_cost_total': monthlyCostTotal,
      'annual_cost_total': annualCostTotal,
    };
  }

  Map<String, dynamic> _calculateZootechnicalIndicators(
    Map<String, dynamic> energyReq,
    Map<String, dynamic> proteinReq,
    Map<String, dynamic> dmiReq,
    double weight,
    double milkProduction,
    double dailyGain,
  ) {
    final double totalDMI = dmiReq['total_dmi'] as double;
    final double totalEM = energyReq['total_em'] as double;
    final double totalPB = proteinReq['total_pb'] as double;

    // Eficiência alimentar
    final double feedEfficiency = dailyGain > 0 ? totalDMI / dailyGain : 0.0;

    // Densidade energética da dieta
    final double energyDensity = totalEM / totalDMI;

    // Concentração proteica da dieta
    final double proteinConcentration = (totalPB / (totalDMI * 1000)) * 100;

    // Consumo relativo (% peso vivo)
    final double relativeDMI = (totalDMI / weight) * 100;

    // Eficiência de produção de leite
    final double milkEfficiency = milkProduction > 0 ? totalDMI / milkProduction : 0.0;

    return {
      'feed_efficiency': feedEfficiency,
      'energy_density': energyDensity,
      'protein_concentration': proteinConcentration,
      'relative_dmi': relativeDMI,
      'milk_efficiency': milkEfficiency,
    };
  }

  List<String> _generateNutritionalRecommendations(
    String species,
    String category,
    Map<String, dynamic> energyReq,
    Map<String, dynamic> proteinReq,
    String feedQuality,
    double temperature,
    Map<String, dynamic> indicators,
  ) {
    final List<String> recommendations = [];

    // Recomendações por densidade energética
    final double energyDensity = indicators['energy_density'] as double;
    if (energyDensity > 2.8) {
      recommendations.add('Dieta de alta energia - monitorar acidose ruminal.');
    } else if (energyDensity < 2.2) {
      recommendations.add('Dieta de baixa energia - pode limitar produção.');
    }

    // Recomendações por concentração proteica
    final double proteinConc = indicators['protein_concentration'] as double;
    if (proteinConc > 18) {
      recommendations.add('Alta proteína - verificar eficiência de utilização.');
    } else if (proteinConc < 12) {
      recommendations.add('Baixa proteína - pode limitar crescimento/produção.');
    }

    // Recomendações por qualidade da forragem
    if (feedQuality == 'Ruim') {
      recommendations.add('Forragem de baixa qualidade - aumentar concentrado.');
    } else if (feedQuality == 'Excelente') {
      recommendations.add('Forragem excelente - otimizar custo com menos concentrado.');
    }

    // Recomendações por temperatura
    if (temperature > 30) {
      recommendations.add('Calor - fornecer água fresca e sombra.');
      recommendations.add('Considerar eletrólitos na água.');
    } else if (temperature < 5) {
      recommendations.add('Frio - aumentar energia da dieta.');
    }

    // Recomendações específicas por espécie
    if (species.contains('Bovino de Leite')) {
      recommendations.add('Monitorar gordura e proteína do leite.');
      recommendations.add('Ajustar cálcio e fósforo para prevenção de doenças metabólicas.');
    } else if (species == 'Suíno') {
      recommendations.add('Atenção ao aminoácidos essenciais (lisina, metionina).');
    } else if (species.contains('Frango')) {
      recommendations.add('Monitorar conversão alimentar diariamente.');
    }

    // Recomendações gerais
    recommendations.add('Fornecer água limpa e fresca à vontade.');
    recommendations.add('Dividir concentrado em 2-3 refeições diárias.');
    recommendations.add('Monitorar escore corporal regularmente.');
    recommendations.add('Ajustar dieta conforme mudanças produtivas.');

    return recommendations;
  }
}