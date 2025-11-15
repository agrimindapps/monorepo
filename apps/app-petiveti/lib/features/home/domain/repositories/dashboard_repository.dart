import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_status.dart';

/// **ISP - Interface Segregation Principle**
/// Segregated repository for dashboard status
/// Single Responsibility: Handle dashboard-specific status and lifecycle
abstract class DashboardRepository {
  /// Get current dashboard status (online/offline, last updated, etc)
  Future<Either<Failure, DashboardStatus>> getStatus();

  /// Check connectivity status
  Future<Either<Failure, bool>> checkOnlineStatus();

  /// Refresh dashboard (triggers all data refresh)
  Future<Either<Failure, void>> refresh();

  /// Get last update timestamp
  Future<Either<Failure, DateTime>> getLastUpdateTime();
}
