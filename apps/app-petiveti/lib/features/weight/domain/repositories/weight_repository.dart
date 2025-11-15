import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/weight.dart';
import 'weight_crud_repository.dart';
import 'weight_query_repository.dart';
import 'weight_analytics_repository.dart';
import 'weight_stream_repository.dart';

/// **ISP - Interface Segregation Principle**
/// Composite repository interface combining all weight concerns
/// Maintains backward compatibility with existing code
abstract class WeightRepository
    implements
        WeightCrudRepository,
        WeightQueryRepository,
        WeightAnalyticsRepository,
        WeightStreamRepository {
  /// Exporta dados de peso para backup/sync
  Future<Either<Failure, List<Map<String, dynamic>>>> exportWeightData();

  /// Importa dados de peso de backup/sync
  Future<Either<Failure, void>> importWeightData(List<Map<String, dynamic>> data);
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
