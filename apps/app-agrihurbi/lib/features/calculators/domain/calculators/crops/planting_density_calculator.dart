import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Densidade de Plantio
/// Calcula densidade ótima de plantio, espaçamento e população de plantas
class PlantingDensityCalculator extends CalculatorEntity {
  const PlantingDensityCalculator()
      : super(
          id: 'planting_density_calculator',
          name: 'Densidade de Plantio',
          description: 'Calcula densidade ótima de plantio, espaçamento entre fileiras e plantas, população ideal e arranjo espacial',
          category: CalculatorCategory.crops,
          parameters: const [
            CalculatorParameter(
              id: 'crop_type',
              name: 'Tipo de Cultura',
              description: 'Cultura a ser plantada',
              type: ParameterType.selection,
              options: [
                'Milho',
                'Soja',
                'Feijão',
                'Trigo',
                'Arroz',
                'Algodão',
                'Cana-de-açúcar',
                'Girassol',
                'Sorgo',
                'Tomate',
                'Batata',
                'Cebola',
                'Cenoura',
                'Alface'
              ],
              defaultValue: 'Milho',
            ),
            CalculatorParameter(
              id: 'cultivar_cycle',
              name: 'Ciclo do Cultivar',
              description: 'Ciclo de desenvolvimento do cultivar',
              type: ParameterType.selection,
              options: ['Precoce', 'Médio', 'Tardio', 'Super Precoce'],
              defaultValue: 'Médio',
            ),
            CalculatorParameter(
              id: 'planting_objective',
              name: 'Objetivo do Plantio',
              description: 'Finalidade principal da cultura',
              type: ParameterType.selection,
              options: ['Produção de Grãos', 'Silagem', 'Consumo In Natura', 'Sementes', 'Forragem', 'Industrialização'],
              defaultValue: 'Produção de Grãos',
            ),
            CalculatorParameter(
              id: 'soil_fertility',
              name: 'Fertilidade do Solo',
              description: 'Nível de fertilidade do solo',
              type: ParameterType.selection,
              options: ['Muito Baixa', 'Baixa', 'Média', 'Alta', 'Muito Alta'],
              defaultValue: 'Média',
            ),
            CalculatorParameter(
              id: 'water_availability',
              name: 'Disponibilidade Hídrica',
              description: 'Condição hídrica da área',
              type: ParameterType.selection,
              options: ['Sequeiro', 'Irrigado', 'Várzea', 'Supplementar'],
              defaultValue: 'Sequeiro',
            ),
            CalculatorParameter(
              id: 'planting_season',
              name: 'Época de Plantio',
              description: 'Época/safra de plantio',
              type: ParameterType.selection,
              options: ['Safra Principal', 'Safrinha', 'Terceira Safra', 'Ano Todo'],
              defaultValue: 'Safra Principal',
            ),
            CalculatorParameter(
              id: 'row_spacing',
              name: 'Espaçamento entre Fileiras',
              description: 'Espaçamento desejado entre fileiras (cm)',
              type: ParameterType.decimal,
              unit: ParameterUnit.centimetro,
              minValue: 10.0,
              maxValue: 150.0,
              defaultValue: 50.0,
              validationMessage: 'Espaçamento deve estar entre 10 e 150 cm',
            ),
            CalculatorParameter(
              id: 'target_population',
              name: 'População Alvo',
              description: 'População de plantas desejada (plantas/ha)',
              type: ParameterType.integer,
              unit: ParameterUnit.plantasha,
              minValue: 1000,
              maxValue: 500000,
              defaultValue: 65000,
              validationMessage: 'População deve estar entre 1.000 e 500.000 plantas/ha',
              required: false,
            ),
            CalculatorParameter(
              id: 'field_area',
              name: 'Área do Talhão',
              description: 'Área total a ser plantada (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.1,
              maxValue: 10000.0,
              defaultValue: 10.0,
              validationMessage: 'Área deve estar entre 0.1 e 10.000 ha',
            ),
            CalculatorParameter(
              id: 'machinery_type',
              name: 'Tipo de Maquinário',
              description: 'Tipo de plantadeira/semeadora',
              type: ParameterType.selection,
              options: ['Manual', 'Tração Animal', 'Plantadeira de Precisão', 'Semeadora Pneumática', 'Transplantadora'],
              defaultValue: 'Plantadeira de Precisão',
            ),
            CalculatorParameter(
              id: 'seed_germination',
              name: 'Taxa de Germinação',
              description: 'Taxa de germinação das sementes (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 60.0,
              maxValue: 100.0,
              defaultValue: 85.0,
              validationMessage: 'Germinação deve estar entre 60% e 100%',
            ),
            CalculatorParameter(
              id: 'expected_losses',
              name: 'Perdas Esperadas',
              description: 'Perdas esperadas no campo (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.0,
              maxValue: 30.0,
              defaultValue: 10.0,
              validationMessage: 'Perdas devem estar entre 0% e 30%',
            ),
          ],
          formula: 'Densidade = População / (10.000 m² × Eficiência de Estabelecimento)',
          references: const [
            'Sangoi et al. (2002) - Arranjo espacial de plantas em milho',
            'Embrapa (2013) - Tecnologias de produção de soja',
            'Fornasieri Filho (2007) - Manual da cultura do milho',
            'Cruz et al. (2010) - Densidade populacional em culturas',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String cropType = inputs['crop_type'].toString();
      final String cultivarCycle = inputs['cultivar_cycle'].toString();
      final String plantingObjective = inputs['planting_objective'].toString();
      final String soilFertility = inputs['soil_fertility'].toString();
      final String waterAvailability = inputs['water_availability'].toString();
      final String plantingSeason = inputs['planting_season'].toString();
      final double rowSpacing = double.parse(inputs['row_spacing'].toString());
      final int? targetPopulation = inputs['target_population'] != null 
          ? int.tryParse(inputs['target_population'].toString())
          : null;
      final double fieldArea = double.parse(inputs['field_area'].toString());
      final String machineryType = inputs['machinery_type'].toString();
      final double seedGermination = double.parse(inputs['seed_germination'].toString());
      final double expectedLosses = double.parse(inputs['expected_losses'].toString());
      final Map<String, dynamic> cropData = _getCropDensityData(cropType);
      final Map<String, dynamic> optimalDensity = _calculateOptimalDensity(
        cropType, cultivarCycle, plantingObjective, soilFertility, 
        waterAvailability, plantingSeason, cropData);

      final int finalTargetPopulation = targetPopulation ?? 
          (optimalDensity['optimal_population'] as int);
      final Map<String, dynamic> spacing = _calculateSpacing(
        finalTargetPopulation, rowSpacing, machineryType, cropData);
      final Map<String, dynamic> seedRequirements = _calculateSeedRequirements(
        finalTargetPopulation, fieldArea, seedGermination, expectedLosses, cropData);
      final Map<String, dynamic> spatialArrangement = _analyzeSpatialArrangement(
        rowSpacing, spacing['plant_spacing_cm'] as double, cropType, optimalDensity);
      final Map<String, dynamic> adjustmentRecommendations = _generateAdjustmentRecommendations(
        finalTargetPopulation, optimalDensity, soilFertility, waterAvailability, cropType);
      final Map<String, dynamic> standardComparison = _compareWithStandards(
        finalTargetPopulation, rowSpacing, cropType, plantingObjective);
      final List<Map<String, dynamic>> plantingSchedule = _generatePlantingSchedule(
        fieldArea, spacing, machineryType);
      final Map<String, dynamic> efficiencyIndicators = _calculateEfficiencyIndicators(
        spatialArrangement, optimalDensity, standardComparison);
      final Map<String, dynamic> economicAnalysis = _calculateEconomicAnalysis(
        seedRequirements, fieldArea, cropType, finalTargetPopulation);
      final List<String> technicalRecommendations = _generateTechnicalRecommendations(
        cropType, spatialArrangement, optimalDensity, adjustmentRecommendations,
        machineryType, soilFertility);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'População Recomendada',
            value: CalculatorMath.roundTo((optimalDensity['optimal_population'] as int).toDouble(), 0),
            unit: 'plantas/ha',
            description: 'População ótima para as condições especificadas',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Espaçamento na Linha',
            value: CalculatorMath.roundTo(spacing['plant_spacing_cm'] as double, 1),
            unit: 'cm',
            description: 'Distância entre plantas na fileira',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Plantas por Metro Linear',
            value: CalculatorMath.roundTo(spacing['plants_per_meter'] as double, 1),
            unit: 'plantas/m',
            description: 'Número de plantas por metro de fileira',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Sementes Necessárias',
            value: CalculatorMath.roundTo(seedRequirements['total_seeds'] as double, 0),
            unit: 'sementes',
            description: 'Total de sementes para a área',
          ),
          CalculationResultValue(
            label: 'Quantidade de Sementes',
            value: CalculatorMath.roundTo(seedRequirements['seed_weight_kg'] as double, 1),
            unit: 'kg',
            description: 'Peso total das sementes necessárias',
          ),
          CalculationResultValue(
            label: 'Índice de Adequação',
            value: CalculatorMath.roundTo(spatialArrangement['adequacy_index'] as double, 1),
            unit: '%',
            description: 'Adequação do arranjo espacial',
          ),
          CalculationResultValue(
            label: 'Eficiência de Área',
            value: CalculatorMath.roundTo(efficiencyIndicators['area_efficiency'] as double, 1),
            unit: '%',
            description: 'Eficiência de utilização da área',
          ),
          CalculationResultValue(
            label: 'Competição Estimada',
            value: CalculatorMath.roundTo(spatialArrangement['competition_index'] as double, 2),
            unit: 'índice',
            description: 'Índice de competição entre plantas',
          ),
          CalculationResultValue(
            label: 'Tempo de Plantio',
            value: CalculatorMath.roundTo(plantingSchedule.isNotEmpty ? 
                (plantingSchedule.last['tempo_acumulado'] as double) : 0.0, 1),
            unit: 'horas',
            description: 'Tempo estimado para plantio total',
          ),
          CalculationResultValue(
            label: 'Custo de Sementes',
            value: CalculatorMath.roundTo(economicAnalysis['seed_cost'] as double, 0),
            unit: 'R\$',
            description: 'Custo total das sementes',
          ),
          CalculationResultValue(
            label: 'Produtividade Estimada',
            value: CalculatorMath.roundTo(optimalDensity['estimated_yield'] as double, 0),
            unit: 'kg/ha',
            description: 'Produtividade estimada com densidade ótima',
          ),
          CalculationResultValue(
            label: 'Ajuste Recomendado',
            value: CalculatorMath.roundTo((adjustmentRecommendations['population_adjustment'] as int).toDouble(), 0),
            unit: 'plantas/ha',
            description: 'Ajuste sugerido na população',
          ),
        ],
        recommendations: technicalRecommendations,
        tableData: plantingSchedule,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  Map<String, dynamic> _getCropDensityData(String cropType) {
    final Map<String, Map<String, dynamic>> cropDatabase = {
      'Milho': {
        'optimal_population': 65000,
        'min_population': 45000,
        'max_population': 85000,
        'row_spacing_options': [45, 50, 70, 80],
        'seed_weight_1000': 320.0, // gramas
        'plant_architecture': 'ereta',
        'light_interception_factor': 0.85,
        'competition_sensitivity': 'média',
        'yield_response_curve': 'exponencial',
      },
      'Soja': {
        'optimal_population': 320000,
        'min_population': 220000,
        'max_population': 450000,
        'row_spacing_options': [20, 25, 30, 35, 40, 45],
        'seed_weight_1000': 150.0,
        'plant_architecture': 'ramificada',
        'light_interception_factor': 0.90,
        'competition_sensitivity': 'baixa',
        'yield_response_curve': 'platô',
      },
      'Feijão': {
        'optimal_population': 250000,
        'min_population': 180000,
        'max_population': 350000,
        'row_spacing_options': [30, 35, 40, 45],
        'seed_weight_1000': 250.0,
        'plant_architecture': 'compacta',
        'light_interception_factor': 0.80,
        'competition_sensitivity': 'alta',
        'yield_response_curve': 'quadrática',
      },
      'Trigo': {
        'optimal_population': 4500000,
        'min_population': 3000000,
        'max_population': 6000000,
        'row_spacing_options': [15, 17, 20],
        'seed_weight_1000': 45.0,
        'plant_architecture': 'perfilhamento',
        'light_interception_factor': 0.92,
        'competition_sensitivity': 'baixa',
        'yield_response_curve': 'linear',
      },
      'Arroz': {
        'optimal_population': 3500000,
        'min_population': 2500000,
        'max_population': 5000000,
        'row_spacing_options': [17, 20, 25],
        'seed_weight_1000': 25.0,
        'plant_architecture': 'perfilhamento',
        'light_interception_factor': 0.88,
        'competition_sensitivity': 'baixa',
        'yield_response_curve': 'platô',
      },
      'Algodão': {
        'optimal_population': 120000,
        'min_population': 80000,
        'max_population': 180000,
        'row_spacing_options': [60, 70, 80, 90],
        'seed_weight_1000': 110.0,
        'plant_architecture': 'ramificada',
        'light_interception_factor': 0.85,
        'competition_sensitivity': 'média',
        'yield_response_curve': 'quadrática',
      },
      'Cana-de-açúcar': {
        'optimal_population': 85000,
        'min_population': 60000,
        'max_population': 120000,
        'row_spacing_options': [140, 150, 180],
        'seed_weight_1000': 0.0, // Mudas
        'plant_architecture': 'ereta',
        'light_interception_factor': 0.95,
        'competition_sensitivity': 'baixa',
        'yield_response_curve': 'linear',
      },
      'Girassol': {
        'optimal_population': 45000,
        'min_population': 35000,
        'max_population': 65000,
        'row_spacing_options': [60, 70, 80],
        'seed_weight_1000': 60.0,
        'plant_architecture': 'ereta',
        'light_interception_factor': 0.85,
        'competition_sensitivity': 'alta',
        'yield_response_curve': 'quadrática',
      },
      'Sorgo': {
        'optimal_population': 180000,
        'min_population': 120000,
        'max_population': 250000,
        'row_spacing_options': [45, 50, 70],
        'seed_weight_1000': 30.0,
        'plant_architecture': 'ereta',
        'light_interception_factor': 0.82,
        'competition_sensitivity': 'média',
        'yield_response_curve': 'linear',
      },
      'Tomate': {
        'optimal_population': 25000,
        'min_population': 15000,
        'max_population': 40000,
        'row_spacing_options': [100, 120, 150],
        'seed_weight_1000': 3.5,
        'plant_architecture': 'indeterminada',
        'light_interception_factor': 0.90,
        'competition_sensitivity': 'alta',
        'yield_response_curve': 'quadrática',
      },
      'Batata': {
        'optimal_population': 45000,
        'min_population': 35000,
        'max_population': 60000,
        'row_spacing_options': [75, 80, 90],
        'seed_weight_1000': 0.0, // Tubérculos-semente
        'plant_architecture': 'compacta',
        'light_interception_factor': 0.85,
        'competition_sensitivity': 'média',
        'yield_response_curve': 'quadrática',
      },
      'Cebola': {
        'optimal_population': 500000,
        'min_population': 350000,
        'max_population': 700000,
        'row_spacing_options': [20, 25, 30],
        'seed_weight_1000': 4.0,
        'plant_architecture': 'compacta',
        'light_interception_factor': 0.75,
        'competition_sensitivity': 'alta',
        'yield_response_curve': 'quadrática',
      },
      'Cenoura': {
        'optimal_population': 1000000,
        'min_population': 700000,
        'max_population': 1400000,
        'row_spacing_options': [15, 20, 25],
        'seed_weight_1000': 1.2,
        'plant_architecture': 'compacta',
        'light_interception_factor': 0.70,
        'competition_sensitivity': 'muito alta',
        'yield_response_curve': 'quadrática',
      },
      'Alface': {
        'optimal_population': 300000,
        'min_population': 200000,
        'max_population': 450000,
        'row_spacing_options': [25, 30, 35],
        'seed_weight_1000': 1.0,
        'plant_architecture': 'roseta',
        'light_interception_factor': 0.80,
        'competition_sensitivity': 'alta',
        'yield_response_curve': 'quadrática',
      },
    };

    return cropDatabase[cropType] ?? cropDatabase['Milho']!;
  }

  Map<String, dynamic> _calculateOptimalDensity(
    String cropType,
    String cultivarCycle,
    String plantingObjective,
    String soilFertility,
    String waterAvailability,
    String plantingSeason,
    Map<String, dynamic> cropData,
  ) {
    int basePopulation = cropData['optimal_population'] as int;
    double adjustmentFactor = 1.0;
    final Map<String, double> cycleFactors = {
      'Super Precoce': 1.15,
      'Precoce': 1.10,
      'Médio': 1.0,
      'Tardio': 0.90,
    };
    adjustmentFactor *= (cycleFactors[cultivarCycle] ?? 1.0);
    final Map<String, double> objectiveFactors = {
      'Produção de Grãos': 1.0,
      'Silagem': 1.2,
      'Consumo In Natura': 0.9,
      'Sementes': 0.8,
      'Forragem': 1.3,
      'Industrialização': 1.05,
    };
    adjustmentFactor *= (objectiveFactors[plantingObjective] ?? 1.0);
    final Map<String, double> fertilityFactors = {
      'Muito Baixa': 0.8,
      'Baixa': 0.9,
      'Média': 1.0,
      'Alta': 1.1,
      'Muito Alta': 1.15,
    };
    adjustmentFactor *= (fertilityFactors[soilFertility] ?? 1.0);
    final Map<String, double> waterFactors = {
      'Sequeiro': 0.85,
      'Irrigado': 1.15,
      'Várzea': 1.05,
      'Supplementar': 1.0,
    };
    adjustmentFactor *= (waterFactors[waterAvailability] ?? 1.0);
    final Map<String, double> seasonFactors = {
      'Safra Principal': 1.0,
      'Safrinha': 0.9,
      'Terceira Safra': 0.85,
      'Ano Todo': 0.95,
    };
    adjustmentFactor *= (seasonFactors[plantingSeason] ?? 1.0);

    final int optimalPopulation = (basePopulation * adjustmentFactor).round();
    final int minPop = cropData['min_population'] as int;
    final int maxPop = cropData['max_population'] as int;
    final int finalPopulation = math.max(minPop, math.min(maxPop, optimalPopulation));
    final double estimatedYield = _estimateYieldByDensity(
        finalPopulation, basePopulation, cropType, soilFertility, waterAvailability);

    return {
      'optimal_population': finalPopulation,
      'adjustment_factor': adjustmentFactor,
      'estimated_yield': estimatedYield,
      'population_range': {
        'min': minPop,
        'max': maxPop,
        'optimal': finalPopulation,
      },
    };
  }

  double _estimateYieldByDensity(
    int currentPopulation,
    int basePopulation,
    String cropType,
    String soilFertility,
    String waterAvailability,
  ) {
    final Map<String, double> baseYields = {
      'Milho': 8000.0,
      'Soja': 3200.0,
      'Feijão': 2500.0,
      'Trigo': 3000.0,
      'Arroz': 6000.0,
      'Algodão': 1500.0, // @
      'Cana-de-açúcar': 80000.0,
      'Girassol': 2000.0,
      'Sorgo': 4500.0,
      'Tomate': 60000.0,
      'Batata': 25000.0,
      'Cebola': 35000.0,
      'Cenoura': 30000.0,
      'Alface': 25000.0,
    };

    double baseYield = baseYields[cropType] ?? 5000.0;
    final Map<String, double> fertilityYieldFactors = {
      'Muito Baixa': 0.6,
      'Baixa': 0.75,
      'Média': 1.0,
      'Alta': 1.2,
      'Muito Alta': 1.35,
    };
    baseYield *= (fertilityYieldFactors[soilFertility] ?? 1.0);
    final Map<String, double> waterYieldFactors = {
      'Sequeiro': 0.8,
      'Irrigado': 1.3,
      'Várzea': 1.1,
      'Supplementar': 1.1,
    };
    baseYield *= (waterYieldFactors[waterAvailability] ?? 1.0);
    final double densityRatio = currentPopulation / basePopulation;
    double densityFactor = 1.0;

    if (densityRatio <= 0.7) {
      densityFactor = 0.85; // Sublotado
    } else if (densityRatio <= 0.9) {
      densityFactor = 0.95; // Ligeiramente sublotado
    } else if (densityRatio <= 1.1) {
      densityFactor = 1.0; // Ótimo
    } else if (densityRatio <= 1.3) {
      densityFactor = 0.98; // Ligeiramente superlotado
    } else {
      densityFactor = 0.9; // Superlotado
    }

    return baseYield * densityFactor;
  }

  Map<String, dynamic> _calculateSpacing(
    int targetPopulation,
    double rowSpacing,
    String machineryType,
    Map<String, dynamic> cropData,
  ) {
    final double rowSpacingM = rowSpacing / 100;
    final double areaPerPlant = 10000.0 / targetPopulation; // m²/planta
    final double plantSpacingM = areaPerPlant / rowSpacingM;
    final double plantSpacingCm = plantSpacingM * 100;
    final double plantsPerMeter = 1.0 / plantSpacingM;
    final Map<String, double> machineryPrecision = {
      'Manual': 0.90,
      'Tração Animal': 0.85,
      'Plantadeira de Precisão': 0.95,
      'Semeadora Pneumática': 0.98,
      'Transplantadora': 0.90,
    };

    final double precision = machineryPrecision[machineryType] ?? 0.90;
    final double effectivePlantSpacing = plantSpacingCm / precision;

    return {
      'plant_spacing_cm': plantSpacingCm,
      'plant_spacing_m': plantSpacingM,
      'plants_per_meter': plantsPerMeter,
      'effective_spacing': effectivePlantSpacing,
      'machinery_precision': precision * 100,
      'area_per_plant_m2': areaPerPlant,
    };
  }

  Map<String, dynamic> _calculateSeedRequirements(
    int targetPopulation,
    double fieldArea,
    double seedGermination,
    double expectedLosses,
    Map<String, dynamic> cropData,
  ) {
    final double establishmentEfficiency = (seedGermination / 100) * ((100 - expectedLosses) / 100);
    final double seedsPerHa = targetPopulation / establishmentEfficiency;
    final double totalSeeds = seedsPerHa * fieldArea;
    final double seedWeight1000 = cropData['seed_weight_1000'] as double;
    double seedWeightKg = 0.0;
    
    if (seedWeight1000 > 0) {
      seedWeightKg = (totalSeeds * seedWeight1000) / 1000000; // kg
    }
    const double safetyMargin = 1.05;
    final double finalSeedQuantity = totalSeeds * safetyMargin;
    final double finalSeedWeight = seedWeightKg * safetyMargin;

    return {
      'seeds_per_ha': seedsPerHa,
      'total_seeds': finalSeedQuantity,
      'seed_weight_kg': finalSeedWeight,
      'establishment_efficiency': establishmentEfficiency * 100,
      'safety_margin': (safetyMargin - 1) * 100,
    };
  }

  Map<String, dynamic> _analyzeSpatialArrangement(
    double rowSpacing,
    double plantSpacing,
    String cropType,
    Map<String, dynamic> optimalDensity,
  ) {
    final double rectangularity = rowSpacing / plantSpacing;
    final Map<String, Map<String, double>> idealRectangularity = {
      'Milho': {'min': 1.5, 'max': 3.0},
      'Soja': {'min': 0.5, 'max': 2.0},
      'Feijão': {'min': 1.0, 'max': 2.5},
      'Trigo': {'min': 0.8, 'max': 1.5},
      'default': {'min': 1.0, 'max': 2.5},
    };

    final Map<String, double> idealRange = idealRectangularity[cropType] ?? 
                                          idealRectangularity['default']!;
    double adequacyIndex = 100.0;
    if (rectangularity < idealRange['min']!) {
      adequacyIndex = 80.0 - (idealRange['min']! - rectangularity) * 20;
    } else if (rectangularity > idealRange['max']!) {
      adequacyIndex = 80.0 - (rectangularity - idealRange['max']!) * 15;
    }
    adequacyIndex = math.max(0, math.min(100, adequacyIndex));
    final double competitionIndex = 1.0 / math.sqrt(rowSpacing * plantSpacing);

    return {
      'rectangularity': rectangularity,
      'adequacy_index': adequacyIndex,
      'competition_index': competitionIndex,
      'spatial_classification': _classifyArrangement(rectangularity, idealRange),
    };
  }

  String _classifyArrangement(double rectangularity, Map<String, double> idealRange) {
    if (rectangularity >= idealRange['min']! && rectangularity <= idealRange['max']!) {
      return 'Ótimo';
    } else if (rectangularity < idealRange['min']!) {
      return 'Muito Retangular';
    } else {
      return 'Muito Alongado';
    }
  }

  Map<String, dynamic> _generateAdjustmentRecommendations(
    int currentPopulation,
    Map<String, dynamic> optimalDensity,
    String soilFertility,
    String waterAvailability,
    String cropType,
  ) {
    final int optimalPop = optimalDensity['optimal_population'] as int;
    final int populationDifference = optimalPop - currentPopulation;
    
    String recommendation = '';
    if ((populationDifference < 0 ? -populationDifference : populationDifference) <= optimalPop * 0.05) {
      recommendation = 'População adequada - manter densidade atual';
    } else if (populationDifference > 0) {
      recommendation = 'Aumentar densidade de plantio';
    } else {
      recommendation = 'Reduzir densidade de plantio';
    }

    return {
      'population_adjustment': populationDifference,
      'adjustment_percentage': (populationDifference / currentPopulation) * 100,
      'recommendation': recommendation,
      'justification': _getAdjustmentJustification(populationDifference, cropType),
    };
  }

  String _getAdjustmentJustification(int difference, String cropType) {
    if ((difference < 0 ? -difference : difference) <= 5000) {
      return 'Densidade próxima ao ótimo - ajustes mínimos necessários';
    } else if (difference > 0) {
      return 'Densidade baixa pode reduzir produtividade e aumentar competição com plantas daninhas';
    } else {
      return 'Densidade alta pode aumentar competição e reduzir desenvolvimento individual das plantas';
    }
  }

  Map<String, dynamic> _compareWithStandards(
    int currentPopulation,
    double rowSpacing,
    String cropType,
    String plantingObjective,
  ) {
    final Map<String, Map<String, dynamic>> technicalStandards = {
      'Milho': {
        'embrapa': 65000,
        'cooperativa': 70000,
        'empresa_sementes': 68000,
        'row_spacing_standard': 50.0,
      },
      'Soja': {
        'embrapa': 300000,
        'cooperativa': 320000,
        'empresa_sementes': 350000,
        'row_spacing_standard': 30.0,
      },
      'Feijão': {
        'embrapa': 250000,
        'cooperativa': 280000,
        'empresa_sementes': 260000,
        'row_spacing_standard': 35.0,
      },
      'default': {
        'embrapa': 100000,
        'cooperativa': 110000,
        'empresa_sementes': 105000,
        'row_spacing_standard': 50.0,
      },
    };

    final Map<String, dynamic> standards = technicalStandards[cropType] ?? 
                                          technicalStandards['default']!;

    final int embrapaStandard = standards['embrapa'] as int;
    final double standardRowSpacing = standards['row_spacing_standard'] as double;

    return {
      'deviation_from_embrapa': ((currentPopulation - embrapaStandard) / embrapaStandard) * 100,
      'row_spacing_deviation': ((rowSpacing - standardRowSpacing) / standardRowSpacing) * 100,
      'compliance_level': _assessCompliance(currentPopulation, embrapaStandard),
    };
  }

  String _assessCompliance(int current, int standard) {
    final double value = (current - standard) / standard;
    final double deviation = (value < 0 ? -value : value) * 100;
    
    if (deviation <= 10) {
      return 'Conforme padrão técnico';
    } else if (deviation <= 20) {
      return 'Próximo ao padrão';
    } else {
      return 'Fora do padrão recomendado';
    }
  }

  List<Map<String, dynamic>> _generatePlantingSchedule(
    double fieldArea,
    Map<String, dynamic> spacing,
    String machineryType,
  ) {
    final List<Map<String, dynamic>> schedule = [];
    final Map<String, double> workRates = {
      'Manual': 0.05,
      'Tração Animal': 0.3,
      'Plantadeira de Precisão': 1.2,
      'Semeadora Pneumática': 1.8,
      'Transplantadora': 0.8,
    };

    final double workRate = workRates[machineryType] ?? 1.0;
    final double totalTime = fieldArea / workRate;
    final int phases = math.min(5, (fieldArea / 10).ceil());
    final double areaPerPhase = fieldArea / phases;
    final double timePerPhase = totalTime / phases;

    for (int i = 1; i <= phases; i++) {
      schedule.add({
        'fase': i,
        'area_fase': CalculatorMath.roundTo(areaPerPhase, 1),
        'tempo_fase': CalculatorMath.roundTo(timePerPhase, 1),
        'tempo_acumulado': CalculatorMath.roundTo(timePerPhase * i, 1),
        'observacao': i == 1 ? 'Início do plantio' : 
                     i == phases ? 'Finalização' : 'Continuação',
      });
    }

    return schedule;
  }

  Map<String, dynamic> _calculateEfficiencyIndicators(
    Map<String, dynamic> spatialArrangement,
    Map<String, dynamic> optimalDensity,
    Map<String, dynamic> standardComparison,
  ) {
    final double adequacyIndex = spatialArrangement['adequacy_index'] as double;
    final double competitionIndex = spatialArrangement['competition_index'] as double;
    final double areaEfficiency = adequacyIndex;
    final double lightEfficiency = math.max(0, 100 - (competitionIndex - 1) * 50);
    final double globalEfficiency = (areaEfficiency + lightEfficiency) / 2;

    return {
      'area_efficiency': areaEfficiency,
      'light_efficiency': lightEfficiency,
      'global_efficiency': globalEfficiency,
      'competition_level': _classifyCompetition(competitionIndex),
    };
  }

  String _classifyCompetition(double index) {
    if (index <= 1.5) {
      return 'Baixa';
    } else if (index <= 2.5) {
      return 'Média';
    } else if (index <= 3.5) {
      return 'Alta';
    } else {
      return 'Muito Alta';
    }
  }

  Map<String, dynamic> _calculateEconomicAnalysis(
    Map<String, dynamic> seedRequirements,
    double fieldArea,
    String cropType,
    int population,
  ) {
    final Map<String, double> seedPrices = {
      'Milho': 25.0,
      'Soja': 15.0,
      'Feijão': 8.0,
      'Trigo': 3.5,
      'Arroz': 4.0,
      'Algodão': 35.0,
      'Girassol': 12.0,
      'Sorgo': 18.0,
      'Tomate': 850.0,
      'Batata': 4.5, // R\$/kg tubérculo-semente
      'Cebola': 120.0,
      'Cenoura': 180.0,
      'Alface': 200.0,
    };

    final double seedPrice = seedPrices[cropType] ?? 20.0;
    final double seedWeightKg = seedRequirements['seed_weight_kg'] as double;
    final double seedCost = seedWeightKg * seedPrice;
    final double costPerHa = seedCost / fieldArea;
    final double estimatedRevenue = fieldArea * 5000 * 0.60; // Estimativa genérica
    final double costBenefitRatio = seedCost / estimatedRevenue;

    return {
      'seed_cost': seedCost,
      'cost_per_ha': costPerHa,
      'cost_benefit_ratio': costBenefitRatio,
      'seed_percentage_of_cost': 15.0, // Estimativa: sementes = 15% do custo total
    };
  }

  List<String> _generateTechnicalRecommendations(
    String cropType,
    Map<String, dynamic> spatialArrangement,
    Map<String, dynamic> optimalDensity,
    Map<String, dynamic> adjustmentRecommendations,
    String machineryType,
    String soilFertility,
  ) {
    final List<String> recommendations = [];
    final double adequacyIndex = spatialArrangement['adequacy_index'] as double;
    if (adequacyIndex < 80) {
      recommendations.add('Arranjo espacial inadequado - considerar ajustar espaçamento entre fileiras.');
    }
    final int adjustment = adjustmentRecommendations['population_adjustment'] as int;
    if ((adjustment < 0 ? -adjustment : adjustment) > 10000) {
      recommendations.add('Densidade significativamente diferente do ótimo - revisar população de plantas.');
    }
    final double competitionIndex = spatialArrangement['competition_index'] as double;
    if (competitionIndex > 3.0) {
      recommendations.add('Alta competição entre plantas - considerar aumentar espaçamento.');
    }
    switch (cropType) {
      case 'Milho':
        recommendations.add('Milho: manter estande uniforme para maximizar produtividade.');
        break;
      case 'Soja':
        recommendations.add('Soja: densidade adequada favorece fechamento da cultura.');
        break;
      case 'Feijão':
        recommendations.add('Feijão: evitar adensamento excessivo que favorece doenças.');
        break;
    }
    if (machineryType == 'Manual') {
      recommendations.add('Plantio manual: maior atenção à uniformidade do espaçamento.');
    } else if (machineryType.contains('Precisão')) {
      recommendations.add('Plantadeira de precisão: calibrar para distribuição uniforme.');
    }
    if (soilFertility == 'Baixa' || soilFertility == 'Muito Baixa') {
      recommendations.add('Solo de baixa fertilidade - considerar densidade menor e adubação adequada.');
    }
    recommendations.add('Monitorar emergência para confirmar estande planejado.');
    recommendations.add('Calibrar equipamentos antes do plantio para precisão.');
    recommendations.add('Considerar teste de germinação das sementes.');
    recommendations.add('Adaptar densidade às condições específicas da propriedade.');

    return recommendations;
  }
}
