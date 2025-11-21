import 'package:core/core.dart' hide Column;

import '../../entities/diagnostico_entity.dart';

/// Interface for statistics and analytics on diagnosticos
/// Follows Single Responsibility Principle (SOLID)
///
/// This service handles all analytics operations including
/// aggregate statistics, popular items, and counting operations.
abstract class IDiagnosticosStatsService {
  /// Get comprehensive statistics about all diagnosticos
  ///
  /// Statistics include:
  /// - Total count
  /// - Count by completeness level (completo/parcial/incompleto)
  /// - Count by defensivo
  /// - Count by cultura
  /// - Count by praga
  /// - Top diagnosticos by usage/popularity
  ///
  /// This is a heavy operation and should be cached when possible.
  Future<Either<Failure, DiagnosticosStats>> getStatistics();

  /// Get most popular diagnosticos
  ///
  /// Popularity is determined by:
  /// - Usage frequency
  /// - Completeness (completo > parcial > incompleto)
  /// - Recency of updates
  ///
  /// Returns up to [limit] diagnosticos ordered by popularity (highest first).
  Future<Either<Failure, List<DiagnosticoPopular>>> getPopularDiagnosticos({
    int limit = 10,
  });

  /// Count diagnosticos matching specified filters
  ///
  /// Efficient counting operation without fetching full entities.
  /// Useful for:
  /// - Pagination metadata
  /// - Filter result previews
  /// - Performance dashboards
  ///
  /// Returns count of matching diagnosticos.
  Future<Either<Failure, int>> countByFilters(
    DiagnosticoSearchFilters filters,
  );

  // ========== Client-side stats methods ==========

  /// Calculate statistics from in-memory list
  ///
  /// Useful for client-side analytics after filtering.
  /// Same structure as getStatistics() but operates on provided list.
  DiagnosticosStats calculateStatsFromList(
    List<DiagnosticoEntity> diagnosticos,
  );

  /// Extract popular diagnosticos from in-memory list
  ///
  /// Useful for client-side ranking after filtering.
  /// Returns up to [limit] diagnosticos ordered by quality score.
  List<DiagnosticoPopular> extractPopularFromList(
    List<DiagnosticoEntity> diagnosticos, {
    int limit = 10,
  });
}
