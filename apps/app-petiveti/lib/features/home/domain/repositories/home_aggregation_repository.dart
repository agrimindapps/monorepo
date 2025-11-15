import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_stats.dart';

/// **ISP - Interface Segregation Principle**
/// Segregated repository for home aggregation data
/// Single Responsibility: Aggregate data from multiple sources for dashboard
abstract class HomeAggregationRepository {
  /// Get dashboard statistics aggregated from all features
  Future<Either<Failure, HomeStats>> getStats();

  /// Refresh stats data
  Future<Either<Failure, HomeStats>> refreshStats();

  /// Get health status summary
  Future<Either<Failure, Map<String, dynamic>>> getHealthStatus();
}
