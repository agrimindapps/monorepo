import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/weight.dart';

abstract class WeightRepository {
  /// Retorna todos os registros de peso não deletados
  Future<Either<Failure, List<Weight>>> getWeights();

  /// Retorna registros de peso de um animal específico
  Future<Either<Failure, List<Weight>>> getWeightsByAnimalId(String animalId);

  /// Retorna o último registro de peso de um animal
  Future<Either<Failure, Weight?>> getLatestWeightByAnimalId(String animalId);

  /// Retorna histórico de peso por período
  Future<Either<Failure, List<Weight>>> getWeightHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Retorna um registro de peso específico pelo ID
  Future<Either<Failure, Weight>> getWeightById(String id);

  /// Adiciona um novo registro de peso
  Future<Either<Failure, void>> addWeight(Weight weight);

  /// Atualiza um registro de peso existente
  Future<Either<Failure, void>> updateWeight(Weight weight);

  /// Remove um registro de peso (soft delete)
  Future<Either<Failure, void>> deleteWeight(String id);

  /// Remove permanentemente um registro de peso
  Future<Either<Failure, void>> hardDeleteWeight(String id);

  /// Retorna stream de registros de peso para observar mudanças em tempo real
  Stream<List<Weight>> watchWeights();

  /// Retorna stream de registros de peso de um animal específico
  Stream<List<Weight>> watchWeightsByAnimalId(String animalId);

  /// Busca registros de peso por critérios
  Future<Either<Failure, List<Weight>>> searchWeights(
    String animalId, {
    double? minWeight,
    double? maxWeight,
    DateTime? startDate,
    DateTime? endDate,
    int? bodyConditionScore,
  });

  /// Calcula estatísticas de peso para um animal
  Future<Either<Failure, WeightStatistics>> getWeightStatistics(String animalId);

  /// Identifica tendências de peso para um animal
  Future<Either<Failure, WeightTrendAnalysis>> analyzeWeightTrend(
    String animalId, {
    int periodInDays = 90,
  });

  /// Identifica variações bruscas de peso
  Future<Either<Failure, List<Weight>>> getAbnormalWeightChanges(
    String animalId, {
    double thresholdPercentage = 10.0,
    int timeFrameDays = 30,
  });

  /// Exporta dados de peso para backup/sync
  Future<Either<Failure, List<Map<String, dynamic>>>> exportWeightData();

  /// Importa dados de peso de backup/sync
  Future<Either<Failure, void>> importWeightData(List<Map<String, dynamic>> data);

  /// Conta total de registros de peso por animal
  Future<Either<Failure, int>> getWeightRecordsCount(String animalId);

  /// Calcula IMC animal (se aplicável para a espécie)
  Future<Either<Failure, double?>> calculateAnimalBMI(String animalId);
}

/// Classe para estatísticas de peso
class WeightStatistics {
  final double? currentWeight;
  final double? averageWeight;
  final double? minWeight;
  final double? maxWeight;
  final WeightTrend? overallTrend;
  final double? totalWeightChange;
  final double? averageWeightChange;
  final int totalRecords;
  final DateTime? firstRecordDate;
  final DateTime? lastRecordDate;
  final Map<BodyCondition, int> bodyConditionDistribution;

  const WeightStatistics({
    this.currentWeight,
    this.averageWeight,
    this.minWeight,
    this.maxWeight,
    this.overallTrend,
    this.totalWeightChange,
    this.averageWeightChange,
    required this.totalRecords,
    this.firstRecordDate,
    this.lastRecordDate,
    this.bodyConditionDistribution = const {},
  });

  /// Retorna se há dados suficientes para análise
  bool get hasSufficientData => totalRecords >= 2;

  /// Retorna se há tendência de ganho de peso
  bool get isGainingWeight => overallTrend == WeightTrend.gaining;

  /// Retorna se há tendência de perda de peso
  bool get isLosingWeight => overallTrend == WeightTrend.losing;

  /// Retorna se o peso está estável
  bool get isStableWeight => overallTrend == WeightTrend.stable;
}

/// Classe para análise de tendência de peso
class WeightTrendAnalysis {
  final WeightTrend trend;
  final double trendStrength; // 0.0 to 1.0 (strength of the trend)
  final List<WeightPoint> dataPoints;
  final double? projectedWeightIn30Days;
  final double? projectedWeightIn90Days;
  final List<String> recommendations;
  final List<String> alerts;

  const WeightTrendAnalysis({
    required this.trend,
    required this.trendStrength,
    required this.dataPoints,
    this.projectedWeightIn30Days,
    this.projectedWeightIn90Days,
    this.recommendations = const [],
    this.alerts = const [],
  });

  /// Retorna se a tendência é forte
  bool get isStrongTrend => trendStrength > 0.7;

  /// Retorna se a tendência é preocupante
  bool get isConcerningTrend => alerts.isNotEmpty;

  /// Retorna se há recomendações
  bool get hasRecommendations => recommendations.isNotEmpty;
}

/// Ponto de dados para análise de tendência
class WeightPoint {
  final DateTime date;
  final double weight;
  final int? bodyConditionScore;

  const WeightPoint({
    required this.date,
    required this.weight,
    this.bodyConditionScore,
  });
}
