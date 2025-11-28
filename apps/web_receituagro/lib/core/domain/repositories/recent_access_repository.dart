import 'package:dartz/dartz.dart';

import '../../error/failures.dart';
import '../entities/recent_access.dart';

/// Repository interface for recent access operations
abstract class RecentAccessRepository {
  /// Get all recent defensivos accessed
  Future<Either<Failure, List<RecentAccess>>> getRecentDefensivos();

  /// Get all recent pragas accessed
  Future<Either<Failure, List<RecentAccess>>> getRecentPragas();

  /// Add a new recent access entry
  Future<Either<Failure, void>> addRecentAccess(RecentAccess access);

  /// Clear history for a specific type
  Future<Either<Failure, void>> clearHistory(RecentAccessType type);

  /// Clear all recent access history
  Future<Either<Failure, void>> clearAllHistory();
}
