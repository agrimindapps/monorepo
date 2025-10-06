import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Ciclo Reprodutivo
/// Calcula e planeja ciclos reprodutivos para diferentes espécies pecuárias
class BreedingCycleCalculator extends CalculatorEntity {
  const BreedingCycleCalculator()
      : super(
          id: 'breeding_cycle_calculator',
          name: 'Ciclo Reprodutivo',
          description: 'Calcula e planeja ciclos reprodutivos, datas de cobertura, gestação e parto para diferentes espécies',
          category: CalculatorCategory.livestock,
          parameters: const [
            CalculatorParameter(
              id: 'animal_species',
              name: 'Espécie Animal',
              description: 'Espécie do animal para reprodução',
              type: ParameterType.selection,
              options: ['Bovino', 'Suíno', 'Ovino', 'Caprino', 'Equino', 'Bubalino'],
              defaultValue: 'Bovino',
            ),
            CalculatorParameter(
              id: 'breeding_system',
              name: 'Sistema de Reprodução',
              description: 'Sistema reprodutivo utilizado',
              type: ParameterType.selection,
              options: ['Monta Natural', 'Inseminação Artificial', 'Transferência de Embriões', 'FIV', 'Monta Controlada'],
              defaultValue: 'Inseminação Artificial',
            ),
            CalculatorParameter(
              id: 'last_birth_date',
              name: 'Data do Último Parto',
              description: 'Data do último parto (dd/mm/aaaa)',
              type: ParameterType.date,
              required: false,
            ),
            CalculatorParameter(
              id: 'target_birth_date',
              name: 'Data Desejada do Próximo Parto',
              description: 'Data desejada para o próximo parto (dd/mm/aaaa)',
              type: ParameterType.date,
              required: false,
            ),
            CalculatorParameter(
              id: 'female_age_months',
              name: 'Idade da Fêmea',
              description: 'Idade da fêmea em meses',
              type: ParameterType.integer,
              unit: ParameterUnit.mes,
              minValue: 6,
              maxValue: 240,
              defaultValue: 36,
              validationMessage: 'Idade deve estar entre 6 e 240 meses',
            ),
            CalculatorParameter(
              id: 'female_weight',
              name: 'Peso da Fêmea',
              description: 'Peso atual da fêmea (kg)',
              type: ParameterType.decimal,
              unit: ParameterUnit.quilograma,
              minValue: 20.0,
              maxValue: 1000.0,
              defaultValue: 450.0,
              validationMessage: 'Peso deve estar entre 20 e 1000 kg',
            ),
            CalculatorParameter(
              id: 'body_condition_score',
              name: 'Escore Corporal',
              description: 'Escore de condição corporal (1-5)',
              type: ParameterType.decimal,
              unit: ParameterUnit.escore,
              minValue: 1.0,
              maxValue: 5.0,
              defaultValue: 3.0,
              validationMessage: 'Escore deve estar entre 1 e 5',
            ),
            CalculatorParameter(
              id: 'breeding_season',
              name: 'Estação de Monta',
              description: 'Período preferencial para reprodução',
              type: ParameterType.selection,
              options: ['Ano Todo', 'Primavera/Verão', 'Outono/Inverno', 'Seca', 'Águas'],
              defaultValue: 'Ano Todo',
            ),
            CalculatorParameter(
              id: 'number_females',
              name: 'Número de Fêmeas',
              description: 'Número total de fêmeas no rebanho',
              type: ParameterType.integer,
              unit: ParameterUnit.cabecas,
              minValue: 1,
              maxValue: 10000,
              defaultValue: 100,
              validationMessage: 'Número deve estar entre 1 e 10.000',
            ),
            CalculatorParameter(
              id: 'desired_conception_rate',
              name: 'Taxa de Concepção Desejada',
              description: 'Taxa de concepção esperada (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 60.0,
              maxValue: 95.0,
              defaultValue: 85.0,
              validationMessage: 'Taxa deve estar entre 60% e 95%',
            ),
            CalculatorParameter(
              id: 'lactation_period',
              name: 'Período de Lactação',
              description: 'Duração desejada da lactação (dias)',
              type: ParameterType.integer,
              unit: ParameterUnit.dia,
              minValue: 150,
              maxValue: 365,
              defaultValue: 305,
              validationMessage: 'Lactação deve estar entre 150 e 365 dias',
            ),
            CalculatorParameter(
              id: 'voluntary_waiting_period',
              name: 'Período de Espera Voluntária',
              description: 'Dias após parto para iniciar reprodução',
              type: ParameterType.integer,
              unit: ParameterUnit.dia,
              minValue: 30,
              maxValue: 120,
              defaultValue: 60,
              validationMessage: 'Período deve estar entre 30 e 120 dias',
            ),
          ],
          formula: 'IEP = Período de Gestação + Período de Serviço',
          references: const [
            'Hafez & Hafez (2000) - Reproduction in Farm Animals',
            'Peters & Ball (1995) - Reproduction in Cattle',
            'Gordon (2017) - Controlled Reproduction in Farm Animals',
            'Ball & Peters (2004) - Reproduction in Cattle',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String animalSpecies = inputs['animal_species'].toString();
      final String breedingSystem = inputs['breeding_system'].toString();
      final String? lastBirthDateStr = inputs['last_birth_date']?.toString();
      final String? targetBirthDateStr = inputs['target_birth_date']?.toString();
      final int femaleAgeMonths = int.parse(inputs['female_age_months'].toString());
      final double femaleWeight = double.parse(inputs['female_weight'].toString());
      final double bodyConditionScore = double.parse(inputs['body_condition_score'].toString());
      final String breedingSeason = inputs['breeding_season'].toString();
      final int numberFemales = int.parse(inputs['number_females'].toString());
      final double desiredConceptionRate = double.parse(inputs['desired_conception_rate'].toString());
      final int lactationPeriod = int.parse(inputs['lactation_period'].toString());
      final int voluntaryWaitingPeriod = int.parse(inputs['voluntary_waiting_period'].toString());
      final Map<String, dynamic> speciesData = _getSpeciesReproductiveData(animalSpecies);
      final Map<String, dynamic> reproductiveReadiness = _assessReproductiveReadiness(
        animalSpecies, femaleAgeMonths, femaleWeight, bodyConditionScore, speciesData);
      final Map<String, dynamic> breedingDates = _calculateBreedingDates(
        lastBirthDateStr, targetBirthDateStr, voluntaryWaitingPeriod, speciesData);
      final Map<String, dynamic> calvingInterval = _calculateCalvingInterval(
        voluntaryWaitingPeriod, lactationPeriod, speciesData, breedingSystem);
      final Map<String, dynamic> herdPlanning = _calculateHerdReproductivePlanning(
        numberFemales, desiredConceptionRate, speciesData, breedingSeason);
      final List<Map<String, dynamic>> reproductiveSchedule = _generateReproductiveSchedule(
        breedingDates, speciesData, breedingSystem);
      final Map<String, dynamic> reproductiveIndicators = _calculateReproductiveIndicators(
        calvingInterval, desiredConceptionRate, lactationPeriod, speciesData);
      final Map<String, dynamic> economicAnalysis = _calculateEconomicAnalysis(
        herdPlanning, reproductiveIndicators, numberFemales, animalSpecies);
      final List<String> recommendations = _generateReproductiveRecommendations(
        animalSpecies, reproductiveReadiness, breedingSystem, bodyConditionScore,
        reproductiveIndicators, breedingSeason);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Período de Gestação',
            value: CalculatorMath.roundTo((speciesData['gestation_days'] as int).toDouble(), 0),
            unit: 'dias',
            description: 'Duração média da gestação',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Intervalo Entre Partos',
            value: CalculatorMath.roundTo((calvingInterval['total_iep_days'] as int).toDouble(), 0),
            unit: 'dias',
            description: 'Intervalo total entre partos consecutivos',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Data Ideal de Cobertura',
            value: breedingDates['breeding_date'] != null ? 1.0 : 0.0,
            unit: '',
            description: breedingDates['breeding_date']?.toString() ?? 'Não calculada',
          ),
          CalculationResultValue(
            label: 'Data Prevista do Parto',
            value: breedingDates['expected_birth_date'] != null ? 1.0 : 0.0,
            unit: '',
            description: breedingDates['expected_birth_date']?.toString() ?? 'Não calculada',
          ),
          CalculationResultValue(
            label: 'Período de Serviço',
            value: CalculatorMath.roundTo((calvingInterval['service_period_days'] as int).toDouble(), 0),
            unit: 'dias',
            description: 'Dias do parto à próxima concepção',
          ),
          CalculationResultValue(
            label: 'Aptidão Reprodutiva',
            value: CalculatorMath.roundTo(reproductiveReadiness['readiness_score'] as double, 1),
            unit: 'pontos',
            description: 'Escore de aptidão (0-10)',
          ),
          CalculationResultValue(
            label: 'Nascimentos Esperados/Ano',
            value: CalculatorMath.roundTo(herdPlanning['expected_births_per_year'] as double, 0),
            unit: 'bezerros',
            description: 'Número de nascimentos esperados anualmente',
          ),
          CalculationResultValue(
            label: 'Taxa de Fertilidade Real',
            value: CalculatorMath.roundTo(reproductiveIndicators['fertility_rate'] as double, 1),
            unit: '%',
            description: 'Taxa de fertilidade baseada no IEP',
          ),
          CalculationResultValue(
            label: 'Eficiência Reprodutiva',
            value: CalculatorMath.roundTo(reproductiveIndicators['reproductive_efficiency'] as double, 1),
            unit: '%',
            description: 'Eficiência reprodutiva global',
          ),
          CalculationResultValue(
            label: 'Receita Anual Estimada',
            value: CalculatorMath.roundTo(economicAnalysis['annual_revenue'] as double, 0),
            unit: 'R\$',
            description: 'Receita anual com bezerros',
          ),
          CalculationResultValue(
            label: 'Custo Reprodutivo/Fêmea',
            value: CalculatorMath.roundTo(economicAnalysis['cost_per_female'] as double, 2),
            unit: 'R\$/ano',
            description: 'Custo reprodutivo anual por fêmea',
          ),
          CalculationResultValue(
            label: 'ROI Reprodutivo',
            value: CalculatorMath.roundTo(economicAnalysis['reproductive_roi'] as double, 1),
            unit: '%',
            description: 'Retorno sobre investimento reprodutivo',
          ),
        ],
        recommendations: recommendations,
        tableData: reproductiveSchedule,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  Map<String, dynamic> _getSpeciesReproductiveData(String species) {
    final Map<String, Map<String, dynamic>> speciesDatabase = {
      'Bovino': {
        'gestation_days': 280,
        'estrous_cycle_days': 21,
        'estrous_duration_hours': 18,
        'sexual_maturity_months': 14,
        'minimum_breeding_weight_kg': 330, // 60% peso adulto
        'optimal_breeding_age_months': 18,
        'reproductive_life_years': 12,
        'ovulation_after_estrous_hours': 28,
        'conception_rate_natural': 65.0,
        'conception_rate_ai': 55.0,
        'lactation_anoestrous_days': 45,
        'postpartum_uterine_involution_days': 40,
      },
      'Suíno': {
        'gestation_days': 114,
        'estrous_cycle_days': 21,
        'estrous_duration_hours': 48,
        'sexual_maturity_months': 6,
        'minimum_breeding_weight_kg': 100,
        'optimal_breeding_age_months': 8,
        'reproductive_life_years': 6,
        'ovulation_after_estrous_hours': 36,
        'conception_rate_natural': 85.0,
        'conception_rate_ai': 80.0,
        'lactation_anoestrous_days': 5,
        'postpartum_uterine_involution_days': 21,
      },
      'Ovino': {
        'gestation_days': 150,
        'estrous_cycle_days': 17,
        'estrous_duration_hours': 30,
        'sexual_maturity_months': 7,
        'minimum_breeding_weight_kg': 35,
        'optimal_breeding_age_months': 10,
        'reproductive_life_years': 8,
        'ovulation_after_estrous_hours': 24,
        'conception_rate_natural': 75.0,
        'conception_rate_ai': 65.0,
        'lactation_anoestrous_days': 30,
        'postpartum_uterine_involution_days': 25,
      },
      'Caprino': {
        'gestation_days': 150,
        'estrous_cycle_days': 21,
        'estrous_duration_hours': 36,
        'sexual_maturity_months': 7,
        'minimum_breeding_weight_kg': 30,
        'optimal_breeding_age_months': 10,
        'reproductive_life_years': 10,
        'ovulation_after_estrous_hours': 30,
        'conception_rate_natural': 80.0,
        'conception_rate_ai': 70.0,
        'lactation_anoestrous_days': 25,
        'postpartum_uterine_involution_days': 20,
      },
      'Equino': {
        'gestation_days': 340,
        'estrous_cycle_days': 21,
        'estrous_duration_hours': 144,
        'sexual_maturity_months': 18,
        'minimum_breeding_weight_kg': 350,
        'optimal_breeding_age_months': 36,
        'reproductive_life_years': 15,
        'ovulation_after_estrous_hours': 24,
        'conception_rate_natural': 70.0,
        'conception_rate_ai': 60.0,
        'lactation_anoestrous_days': 60,
        'postpartum_uterine_involution_days': 60,
      },
      'Bubalino': {
        'gestation_days': 310,
        'estrous_cycle_days': 21,
        'estrous_duration_hours': 20,
        'sexual_maturity_months': 18,
        'minimum_breeding_weight_kg': 300,
        'optimal_breeding_age_months': 24,
        'reproductive_life_years': 15,
        'ovulation_after_estrous_hours': 30,
        'conception_rate_natural': 60.0,
        'conception_rate_ai': 50.0,
        'lactation_anoestrous_days': 60,
        'postpartum_uterine_involution_days': 45,
      },
    };

    return speciesDatabase[species] ?? speciesDatabase['Bovino']!;
  }

  Map<String, dynamic> _assessReproductiveReadiness(
    String species,
    int ageMonths,
    double weight,
    double bodyCondition,
    Map<String, dynamic> speciesData,
  ) {
    double readinessScore = 10.0;
    final List<String> limitations = [];
    final int optimalAge = speciesData['optimal_breeding_age_months'] as int;
    final int minAge = speciesData['sexual_maturity_months'] as int;
    
    if (ageMonths < minAge) {
      readinessScore -= 4.0;
      limitations.add('Idade inferior à maturidade sexual');
    } else if (ageMonths < optimalAge) {
      readinessScore -= 1.5;
      limitations.add('Idade abaixo da ideal para primeira cobertura');
    }
    final double minWeight = speciesData['minimum_breeding_weight_kg'] as double;
    if (weight < minWeight) {
      readinessScore -= 3.0;
      limitations.add('Peso abaixo do mínimo recomendado');
    } else if (weight < minWeight * 1.1) {
      readinessScore -= 1.0;
      limitations.add('Peso próximo ao mínimo - monitorar');
    }
    if (bodyCondition < 2.5) {
      readinessScore -= 2.5;
      limitations.add('Condição corporal inadequada (muito magra)');
    } else if (bodyCondition > 4.0) {
      readinessScore -= 1.5;
      limitations.add('Condição corporal excessiva (muito gorda)');
    } else if (bodyCondition >= 3.0 && bodyCondition <= 3.5) {
      readinessScore += 0.5; // Bônus por condição ideal
    }
    String classification;
    if (readinessScore >= 9.0) {
      classification = 'Excelente';
    } else if (readinessScore >= 7.0) {
      classification = 'Boa';
    } else if (readinessScore >= 5.0) {
      classification = 'Regular';
    } else {
      classification = 'Inadequada';
    }

    return {
      'readiness_score': math.max(0.0, readinessScore),
      'classification': classification,
      'limitations': limitations,
      'suitable_for_breeding': readinessScore >= 6.0,
    };
  }

  Map<String, dynamic> _calculateBreedingDates(
    String? lastBirthDateStr,
    String? targetBirthDateStr,
    int voluntaryWaitingPeriod,
    Map<String, dynamic> speciesData,
  ) {
    DateTime? lastBirthDate;
    DateTime? targetBirthDate;
    DateTime? breedingDate;
    DateTime? expectedBirthDate;

    final int gestationDays = speciesData['gestation_days'] as int;
    if (lastBirthDateStr != null && lastBirthDateStr.isNotEmpty) {
      try {
        final parts = lastBirthDateStr.split('/');
        if (parts.length == 3) {
          lastBirthDate = DateTime(
            int.parse(parts[2]), // ano
            int.parse(parts[1]), // mês
            int.parse(parts[0]), // dia
          );
        }
      } catch (e) {
      }
    }

    if (targetBirthDateStr != null && targetBirthDateStr.isNotEmpty) {
      try {
        final parts = targetBirthDateStr.split('/');
        if (parts.length == 3) {
          targetBirthDate = DateTime(
            int.parse(parts[2]), // ano
            int.parse(parts[1]), // mês
            int.parse(parts[0]), // dia
          );
        }
      } catch (e) {
      }
    }
    if (targetBirthDate != null) {
      breedingDate = targetBirthDate.subtract(Duration(days: gestationDays));
      expectedBirthDate = targetBirthDate;
    } else if (lastBirthDate != null) {
      breedingDate = lastBirthDate.add(Duration(days: voluntaryWaitingPeriod));
      expectedBirthDate = breedingDate.add(Duration(days: gestationDays));
    }
    int? daysToBreeding;
    if (breedingDate != null) {
      daysToBreeding = breedingDate.difference(DateTime.now()).inDays;
    }

    return {
      'last_birth_date': lastBirthDate,
      'target_birth_date': targetBirthDate,
      'breeding_date': breedingDate?.toString().split(' ')[0],
      'expected_birth_date': expectedBirthDate?.toString().split(' ')[0],
      'days_to_breeding': daysToBreeding,
      'voluntary_waiting_period': voluntaryWaitingPeriod,
    };
  }

  Map<String, dynamic> _calculateCalvingInterval(
    int voluntaryWaitingPeriod,
    int lactationPeriod,
    Map<String, dynamic> speciesData,
    String breedingSystem,
  ) {
    final int gestationDays = speciesData['gestation_days'] as int;
    double averageConceptionRate = breedingSystem == 'Monta Natural' 
        ? speciesData['conception_rate_natural'] as double
        : speciesData['conception_rate_ai'] as double;
    final double averageServices = 100.0 / averageConceptionRate;
    final int estrousCycleDays = speciesData['estrous_cycle_days'] as int;
    final int servicePeriodDays = voluntaryWaitingPeriod + 
        ((averageServices - 1) * estrousCycleDays).round();
    final int totalIEPDays = gestationDays + servicePeriodDays;
    final double birthsPerYear = 365.0 / totalIEPDays;

    return {
      'service_period_days': servicePeriodDays,
      'total_iep_days': totalIEPDays,
      'births_per_year': birthsPerYear,
      'average_services': averageServices,
      'conception_rate_used': averageConceptionRate,
    };
  }

  Map<String, dynamic> _calculateHerdReproductivePlanning(
    int numberFemales,
    double desiredConceptionRate,
    Map<String, dynamic> speciesData,
    String breedingSeason,
  ) {
    final int gestationDays = speciesData['gestation_days'] as int;
    final int breedingFemales = (numberFemales * 0.85).round();
    final double expectedBirthsPerYear = breedingFemales * (365.0 / (gestationDays + 85));
    final double adjustedBirths = expectedBirthsPerYear * (desiredConceptionRate / 100);
    Map<String, double> seasonalDistribution = {};
    switch (breedingSeason) {
      case 'Primavera/Verão':
        seasonalDistribution = {
          'Primavera': adjustedBirths * 0.4,
          'Verão': adjustedBirths * 0.4,
          'Outono': adjustedBirths * 0.15,
          'Inverno': adjustedBirths * 0.05,
        };
        break;
      case 'Outono/Inverno':
        seasonalDistribution = {
          'Outono': adjustedBirths * 0.4,
          'Inverno': adjustedBirths * 0.4,
          'Primavera': adjustedBirths * 0.15,
          'Verão': adjustedBirths * 0.05,
        };
        break;
      default:
        seasonalDistribution = {
          'Primavera': adjustedBirths * 0.25,
          'Verão': adjustedBirths * 0.25,
          'Outono': adjustedBirths * 0.25,
          'Inverno': adjustedBirths * 0.25,
        };
    }

    return {
      'breeding_females': breedingFemales,
      'expected_births_per_year': adjustedBirths,
      'seasonal_distribution': seasonalDistribution,
      'replacement_rate': adjustedBirths * 0.15, // 15% para reposição
    };
  }

  List<Map<String, dynamic>> _generateReproductiveSchedule(
    Map<String, dynamic> breedingDates,
    Map<String, dynamic> speciesData,
    String breedingSystem,
  ) {
    final List<Map<String, dynamic>> schedule = [];

    final int gestationDays = speciesData['gestation_days'] as int;
    final String? breedingDateStr = breedingDates['breeding_date'] as String?;

    if (breedingDateStr != null) {
      final DateTime breedingDate = DateTime.parse(breedingDateStr);
      schedule.addAll([
        {
          'evento': 'Cobertura/IA',
          'data': breedingDateStr,
          'dias': 0,
          'observacao': 'Monta ou inseminação artificial'
        },
        {
          'evento': 'Diagnóstico de Gestação',
          'data': breedingDate.add(const Duration(days: 30)).toString().split(' ')[0],
          'dias': 30,
          'observacao': 'Primeiro diagnóstico (ultrassom/palpação)'
        },
        {
          'evento': 'Confirmação de Gestação',
          'data': breedingDate.add(const Duration(days: 60)).toString().split(' ')[0],
          'dias': 60,
          'observacao': 'Confirmação da gestação'
        },
        {
          'evento': 'Vacinação Pré-Parto',
          'data': breedingDate.add(Duration(days: gestationDays - 30)).toString().split(' ')[0],
          'dias': gestationDays - 30,
          'observacao': 'Vacinas para transferência de imunidade'
        },
        {
          'evento': 'Preparação do Parto',
          'data': breedingDate.add(Duration(days: gestationDays - 7)).toString().split(' ')[0],
          'dias': gestationDays - 7,
          'observacao': 'Preparar maternidade/piquete'
        },
        {
          'evento': 'Parto Previsto',
          'data': breedingDate.add(Duration(days: gestationDays)).toString().split(' ')[0],
          'dias': gestationDays,
          'observacao': 'Data prevista do parto'
        },
      ]);
    }

    return schedule;
  }

  Map<String, dynamic> _calculateReproductiveIndicators(
    Map<String, dynamic> calvingInterval,
    double desiredConceptionRate,
    int lactationPeriod,
    Map<String, dynamic> speciesData,
  ) {
    final int totalIEP = calvingInterval['total_iep_days'] as int;
    final int gestationDays = speciesData['gestation_days'] as int;
    final double fertilityRate = (365.0 / totalIEP) * 100;
    final double reproductiveEfficiency = (gestationDays / totalIEP) * 100;
    final int servicePeriod = calvingInterval['service_period_days'] as int;
    final int dryPeriod = math.max(60, 365 - lactationPeriod); // Mínimo 60 dias
    final int nonproductiveDays = servicePeriod + dryPeriod;
    final double annualProductivity = (lactationPeriod / 365.0) * 100;

    return {
      'fertility_rate': fertilityRate,
      'reproductive_efficiency': reproductiveEfficiency,
      'nonproductive_days': nonproductiveDays,
      'annual_productivity': annualProductivity,
      'optimal_iep_days': gestationDays + 85, // IEP ideal
      'iep_classification': _classifyIEP(totalIEP, gestationDays),
    };
  }

  String _classifyIEP(int iepDays, int gestationDays) {
    final int idealIEP = gestationDays + 85;
    
    if (iepDays <= idealIEP) {
      return 'Excelente';
    } else if (iepDays <= idealIEP + 30) {
      return 'Bom';
    } else if (iepDays <= idealIEP + 60) {
      return 'Regular';
    } else {
      return 'Ruim';
    }
  }

  Map<String, dynamic> _calculateEconomicAnalysis(
    Map<String, dynamic> herdPlanning,
    Map<String, dynamic> indicators,
    int numberFemales,
    String species,
  ) {
    final Map<String, double> animalValues = {
      'Bovino': 1800.0,
      'Suíno': 400.0,
      'Ovino': 350.0,
      'Caprino': 300.0,
      'Equino': 5000.0,
      'Bubalino': 2000.0,
    };

    final double valuePerAnimal = animalValues[species] ?? 1800.0;
    final double expectedBirths = herdPlanning['expected_births_per_year'] as double;
    final double annualRevenue = expectedBirths * valuePerAnimal * 0.8; // 80% vendidos
    final double costPerFemale = species == 'Bovino' ? 300.0 : 150.0; // Anual
    final double totalReproductiveCosts = numberFemales * costPerFemale;
    final double reproductiveROI = totalReproductiveCosts > 0 
        ? ((annualRevenue - totalReproductiveCosts) / totalReproductiveCosts) * 100
        : 0.0;

    return {
      'annual_revenue': annualRevenue,
      'total_reproductive_costs': totalReproductiveCosts,
      'cost_per_female': costPerFemale,
      'reproductive_roi': reproductiveROI,
      'revenue_per_female': annualRevenue / numberFemales,
    };
  }

  List<String> _generateReproductiveRecommendations(
    String species,
    Map<String, dynamic> reproductiveReadiness,
    String breedingSystem,
    double bodyCondition,
    Map<String, dynamic> indicators,
    String breedingSeason,
  ) {
    final List<String> recommendations = [];
    final double readinessScore = reproductiveReadiness['readiness_score'] as double;
    if (readinessScore < 6.0) {
      recommendations.add('Aptidão reprodutiva inadequada - melhorar nutrição e manejo.');
      final List<String> limitations = reproductiveReadiness['limitations'] as List<String>;
      for (String limitation in limitations) {
        recommendations.add('Atenção: $limitation');
      }
    }
    if (bodyCondition < 2.5) {
      recommendations.add('Condição corporal baixa - aumentar nível nutricional.');
    } else if (bodyCondition > 4.0) {
      recommendations.add('Condição corporal excessiva - reduzir energia da dieta.');
    }
    final double efficiency = indicators['reproductive_efficiency'] as double;
    if (efficiency < 75.0) {
      recommendations.add('Eficiência reprodutiva baixa - revisar manejo reprodutivo.');
    }
    switch (breedingSystem) {
      case 'Inseminação Artificial':
        recommendations.add('IA: manter sêmen em nitrogênio líquido e detectar cio adequadamente.');
        break;
      case 'Monta Natural':
        recommendations.add('Monta natural: manter relação touro:vaca adequada (1:25-30).');
        break;
      case 'Transferência de Embriões':
        recommendations.add('TE: selecionar doadoras e receptoras com rigor.');
        break;
    }
    switch (species) {
      case 'Bovino':
        recommendations.add('Bovinos: monitorar parasitas e doenças reprodutivas (brucelose, IBR).');
        break;
      case 'Suíno':
        recommendations.add('Suínos: controlar temperatura e umidade na maternidade.');
        break;
      case 'Ovino':
      case 'Caprino':
        recommendations.add('Pequenos ruminantes: atenção ao efeito macho para indução do cio.');
        break;
    }
    if (breedingSeason != 'Ano Todo') {
      recommendations.add('Estação de monta: concentrar partos na época mais favorável.');
    }
    recommendations.add('Manter registros reprodutivos atualizados para acompanhamento.');
    recommendations.add('Realizar diagnóstico de gestação 30-45 dias após cobertura.');
    recommendations.add('Monitorar saúde reprodutiva com exames periódicos.');
    recommendations.add('Adequar nutrição conforme fase reprodutiva (gestação, lactação).');

    return recommendations;
  }
}
