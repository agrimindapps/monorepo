import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';

/// Repository for advanced search and similarity operations
///
/// Responsibilities:
/// - Search diagnosticos with complex filters
/// - Find similar diagnosticos
/// - Pattern-based search operations
///
/// Used by DiagnosticosSearchService for complex search functionality.
///
/// Part of the Interface Segregation Principle refactoring.
abstract class IDiagnosticosSearchRepository {
  /// Buscar com filtros avançados
  ///
  /// Advanced search with multiple filters including application type.
  /// Filters are optional and combined with AND logic.
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters({
    String? defensivo,
    String? cultura,
    String? praga,
    String? tipoAplicacao,
  });

  /// Buscar diagnósticos similares
  ///
  /// Finds diagnosticos similar to the given ID based on:
  /// - Same cultura OR same praga
  /// - Returns up to 10 results
  /// - Excludes the original diagnostico
  Future<Either<Failure, List<DiagnosticoEntity>>> getSimilarDiagnosticos(
    String idDiagnostico,
  );

  /// Buscar por padrão
  ///
  /// Pattern-based search across diagnosticos.
  /// Case-insensitive partial matching.
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(
    String pattern,
  );
}
