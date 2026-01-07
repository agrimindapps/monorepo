import '../entities/calculation_result.dart';
import '../entities/calculator_parameter.dart';

/// Interface principal para Strategy Pattern das calculadoras
///
/// Define contrato comum para todas as estratégias de cálculo,
/// implementando Open/Closed Principle (OCP)
abstract class ICalculatorStrategy {
  /// ID único da estratégia
  String get strategyId;

  /// Nome da estratégia para exibição
  String get strategyName;

  /// Descrição detalhada da estratégia
  String get description;

  /// Parâmetros necessários para esta estratégia
  List<CalculatorParameter> get parameters;

  /// Validações específicas da estratégia
  Future<ValidationResult> validateInputs(Map<String, dynamic> inputs);

  /// Execução do cálculo principal
  Future<CalculationResult> executeCalculation(Map<String, dynamic> inputs);

  /// Pós-processamento dos resultados (opcional)
  Future<CalculationResult> postProcessResults(
    CalculationResult result,
    Map<String, dynamic> inputs,
  ) async {
    return result;
  }

  /// Verifica se a estratégia pode processar os dados fornecidos
  bool canProcess(Map<String, dynamic> inputs);

  /// Obtém metadados da estratégia
  StrategyMetadata get metadata;
}

/// Interface específica para calculadoras de nutrição
abstract class INutritionCalculatorStrategy extends ICalculatorStrategy {
  /// Calcula necessidades nutricionais básicas
  Future<NutritionalRequirements> calculateNutritionalNeeds(
    Map<String, dynamic> inputs,
  );

  /// Calcula fornecimento do solo
  Future<SoilSupply> calculateSoilSupply(Map<String, dynamic> inputs);

  /// Calcula fatores de eficiência
  Future<EfficiencyFactors> calculateEfficiencyFactors(
    Map<String, dynamic> inputs,
  );

  /// Gera recomendações de fertilizantes
  Future<FertilizerRecommendations> generateFertilizerRecommendations(
    NutritionalRequirements needs,
    SoilSupply supply,
    EfficiencyFactors efficiency,
  );
}

/// Interface para calculadoras de irrigação
abstract class IIrrigationCalculatorStrategy extends ICalculatorStrategy {
  /// Calcula necessidade hídrica
  Future<WaterRequirement> calculateWaterRequirement(
    Map<String, dynamic> inputs,
  );

  /// Calcula evapotranspiração
  Future<EvapotranspirationData> calculateEvapotranspiration(
    Map<String, dynamic> inputs,
  );

  /// Gera cronograma de irrigação
  Future<IrrigationSchedule> generateIrrigationSchedule(
    WaterRequirement requirement,
    Map<String, dynamic> fieldConditions,
  );
}

/// Interface para calculadoras de cultivo
abstract class ICropCalculatorStrategy extends ICalculatorStrategy {
  /// Calcula densidade de plantio
  Future<PlantingDensity> calculatePlantingDensity(Map<String, dynamic> inputs);

  /// Calcula predição de colheita
  Future<HarvestPrediction> calculateHarvestPrediction(
    Map<String, dynamic> inputs,
  );

  /// Calcula taxa de sementes
  Future<SeedRate> calculateSeedRate(Map<String, dynamic> inputs);
}

/// Interface para calculadoras de pecuária
abstract class ILivestockCalculatorStrategy extends ICalculatorStrategy {
  /// Calcula necessidades alimentares
  Future<FeedRequirements> calculateFeedRequirements(
    Map<String, dynamic> inputs,
  );

  /// Calcula ciclo reprodutivo
  Future<BreedingCycle> calculateBreedingCycle(Map<String, dynamic> inputs);

  /// Calcula capacidade de pastejo
  Future<GrazingCapacity> calculateGrazingCapacity(Map<String, dynamic> inputs);
}

/// Interface para calculadoras de solo
abstract class ISoilCalculatorStrategy extends ICalculatorStrategy {
  /// Analisa composição do solo
  Future<SoilComposition> analyzeSoilComposition(Map<String, dynamic> inputs);

  /// Calcula drenagem
  Future<DrainageAnalysis> calculateDrainage(Map<String, dynamic> inputs);

  /// Avalia qualidade do solo
  Future<SoilQuality> evaluateSoilQuality(Map<String, dynamic> inputs);
}

/// Resultado de validação para Strategy
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> sanitizedInputs;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.sanitizedInputs,
  });

  factory ValidationResult.success(Map<String, dynamic> sanitizedInputs) {
    return ValidationResult(
      isValid: true,
      errors: const [],
      warnings: const [],
      sanitizedInputs: sanitizedInputs,
    );
  }

  factory ValidationResult.failure(
    List<String> errors, [
    List<String>? warnings,
  ]) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings ?? const [],
      sanitizedInputs: const {},
    );
  }
}

// Helper functions for legacy compatibility
// ignore: non_constant_identifier_names
ValidationResult ValidationRight(Map<String, dynamic> sanitizedInputs) =>
    ValidationResult.success(sanitizedInputs);
// ignore: non_constant_identifier_names
ValidationResult ValidationLeft(List<String> errors) =>
    ValidationResult.failure(errors);

/// Metadados da estratégia
class StrategyMetadata {
  final String version;
  final List<String> supportedCrops;
  final List<String> supportedRegions;
  final String calculationMethod;
  final List<String> references;
  final DateTime lastUpdated;

  const StrategyMetadata({
    required this.version,
    required this.supportedCrops,
    required this.supportedRegions,
    required this.calculationMethod,
    required this.references,
    required this.lastUpdated,
  });
}

class NutritionalRequirements {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double organicMatter;
  final Map<String, double> micronutrients;

  const NutritionalRequirements({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.organicMatter,
    required this.micronutrients,
  });
}

class SoilSupply {
  final double availableNitrogen;
  final double availablePhosphorus;
  final double availablePotassium;
  final double organicMatterContribution;
  final Map<String, double> micronutrientSupply;

  const SoilSupply({
    required this.availableNitrogen,
    required this.availablePhosphorus,
    required this.availablePotassium,
    required this.organicMatterContribution,
    required this.micronutrientSupply,
  });
}

class EfficiencyFactors {
  final double nitrogenEfficiency;
  final double phosphorusEfficiency;
  final double potassiumEfficiency;
  final Map<String, double> micronutrientEfficiency;

  const EfficiencyFactors({
    required this.nitrogenEfficiency,
    required this.phosphorusEfficiency,
    required this.potassiumEfficiency,
    required this.micronutrientEfficiency,
  });
}

class FertilizerRecommendations {
  final List<FertilizerRecommendation> products;
  final List<ApplicationTiming> schedule;
  final double estimatedCost;
  final List<String> applicationNotes;

  const FertilizerRecommendations({
    required this.products,
    required this.schedule,
    required this.estimatedCost,
    required this.applicationNotes,
  });
}

class FertilizerRecommendation {
  final String productName;
  final double quantity;
  final String unit;
  final String nutrientContent;
  final List<String> applicationMethods;

  const FertilizerRecommendation({
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.nutrientContent,
    required this.applicationMethods,
  });
}

class ApplicationTiming {
  final String period;
  final double nitrogenAmount;
  final double phosphorusAmount;
  final double potassiumAmount;
  final String instructions;

  const ApplicationTiming({
    required this.period,
    required this.nitrogenAmount,
    required this.phosphorusAmount,
    required this.potassiumAmount,
    required this.instructions,
  });
}

class WaterRequirement {
  final double dailyRequirement;
  final double weeklyRequirement;
  final double seasonalRequirement;
  final String unit;

  const WaterRequirement({
    required this.dailyRequirement,
    required this.weeklyRequirement,
    required this.seasonalRequirement,
    required this.unit,
  });
}

class EvapotranspirationData {
  final double cropEvapotranspiration;
  final double referenceEvapotranspiration;
  final double cropCoefficient;
  final DateTime calculatedFor;

  const EvapotranspirationData({
    required this.cropEvapotranspiration,
    required this.referenceEvapotranspiration,
    required this.cropCoefficient,
    required this.calculatedFor,
  });
}

class IrrigationSchedule {
  final List<IrrigationEvent> events;
  final String frequency;
  final double totalWaterAmount;

  const IrrigationSchedule({
    required this.events,
    required this.frequency,
    required this.totalWaterAmount,
  });
}

class IrrigationEvent {
  final DateTime dateTime;
  final double waterAmount;
  final String method;
  final String notes;

  const IrrigationEvent({
    required this.dateTime,
    required this.waterAmount,
    required this.method,
    required this.notes,
  });
}

class PlantingDensity {
  final double plantsPerHectare;
  final double seedsPerMeter;
  final double rowSpacing;
  final double plantSpacing;

  const PlantingDensity({
    required this.plantsPerHectare,
    required this.seedsPerMeter,
    required this.rowSpacing,
    required this.plantSpacing,
  });
}

class HarvestPrediction {
  final DateTime estimatedHarvestDate;
  final double expectedYield;
  final String yieldUnit;
  final double confidenceLevel;

  const HarvestPrediction({
    required this.estimatedHarvestDate,
    required this.expectedYield,
    required this.yieldUnit,
    required this.confidenceLevel,
  });
}

class SeedRate {
  final double kgPerHectare;
  final double seedsPerHectare;
  final double adjustedRate;
  final String adjustmentReason;

  const SeedRate({
    required this.kgPerHectare,
    required this.seedsPerHectare,
    required this.adjustedRate,
    required this.adjustmentReason,
  });
}

class FeedRequirements {
  final double dailyFeedAmount;
  final Map<String, double> nutritionalComposition;
  final List<FeedComponent> feedComponents;
  final double estimatedCost;

  const FeedRequirements({
    required this.dailyFeedAmount,
    required this.nutritionalComposition,
    required this.feedComponents,
    required this.estimatedCost,
  });
}

class FeedComponent {
  final String ingredient;
  final double percentage;
  final double amount;
  final String unit;

  const FeedComponent({
    required this.ingredient,
    required this.percentage,
    required this.amount,
    required this.unit,
  });
}

class BreedingCycle {
  final DateTime nextBreedingDate;
  final DateTime expectedBirthDate;
  final int gestationPeriod;
  final List<String> breedingRecommendations;

  const BreedingCycle({
    required this.nextBreedingDate,
    required this.expectedBirthDate,
    required this.gestationPeriod,
    required this.breedingRecommendations,
  });
}

class GrazingCapacity {
  final double animalUnitsPerHectare;
  final double carryingCapacity;
  final int rotationPeriod;
  final List<String> managementRecommendations;

  const GrazingCapacity({
    required this.animalUnitsPerHectare,
    required this.carryingCapacity,
    required this.rotationPeriod,
    required this.managementRecommendations,
  });
}

class SoilComposition {
  final double clayPercentage;
  final double siltPercentage;
  final double sandPercentage;
  final String textureClass;
  final Map<String, double> chemicalProperties;

  const SoilComposition({
    required this.clayPercentage,
    required this.siltPercentage,
    required this.sandPercentage,
    required this.textureClass,
    required this.chemicalProperties,
  });
}

class DrainageAnalysis {
  final String drainageClass;
  final double infiltrationRate;
  final List<String> drainageIssues;
  final List<String> improvementRecommendations;

  const DrainageAnalysis({
    required this.drainageClass,
    required this.infiltrationRate,
    required this.drainageIssues,
    required this.improvementRecommendations,
  });
}

class SoilQuality {
  final double qualityIndex;
  final Map<String, double> qualityFactors;
  final List<String> limitingFactors;
  final List<String> improvementSuggestions;

  const SoilQuality({
    required this.qualityIndex,
    required this.qualityFactors,
    required this.limitingFactors,
    required this.improvementSuggestions,
  });
}
