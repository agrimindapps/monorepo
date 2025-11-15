import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/weight.dart';
import '../repositories/weight_repository.dart';

/// **ISP - Interface Segregation Principle**
/// Analytics operations (Statistics, Trends, Abnormal patterns)
/// Single Responsibility: Handle weight analysis and reporting
abstract class WeightAnalyticsRepository {
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

  /// Calcula IMC animal (se aplicável para a espécie)
  Future<Either<Failure, double?>> calculateAnimalBMI(String animalId);
}
