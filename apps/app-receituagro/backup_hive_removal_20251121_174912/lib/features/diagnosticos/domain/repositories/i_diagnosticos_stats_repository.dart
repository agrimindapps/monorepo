import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';

/// Repository for statistics and popularity operations
///
/// Responsibilities:
/// - Aggregate statistics about diagnosticos
/// - Retrieve popular diagnosticos
/// - Count diagnosticos by filters
///
/// Used by DiagnosticosStatsService for analytics and reporting.
///
/// Part of the Interface Segregation Principle refactoring.
abstract class IDiagnosticosStatsRepository {
  /// Obter estatísticas gerais
  ///
  /// Returns aggregated statistics including:
  /// - Total count of diagnosticos
  /// - Count of unique defensivos, culturas, pragas
  Future<Either<Failure, Map<String, dynamic>>> getStatistics();

  /// Obter diagnósticos populares
  ///
  /// Returns a list of popular diagnosticos (first N by default).
  /// Used for recommendations and UI displays.
  Future<Either<Failure, List<DiagnosticoEntity>>> getPopularDiagnosticos({
    int limit = 10,
  });

  /// Contar diagnósticos por filtros
  ///
  /// Returns count of diagnosticos matching the given filters.
  /// All filters are optional and combined with AND logic.
  Future<Either<Failure, int>> countByFilters({
    String? defensivo,
    String? cultura,
    String? praga,
  });
}
