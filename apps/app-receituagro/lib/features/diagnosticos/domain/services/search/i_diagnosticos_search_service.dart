import 'package:core/core.dart' hide Column;

import '../../entities/diagnostico_entity.dart';

/// Interface for search operations on diagnosticos
/// Follows Single Responsibility Principle (SOLID)
///
/// This service handles all search-related operations including
/// structured filters, pattern matching, and similarity searches.
abstract class IDiagnosticosSearchService {
  /// Search diagnosticos using structured filters
  ///
  /// Supports multiple filter criteria combined with AND logic:
  /// - defensivo, cultura, praga (by ID or name)
  /// - tipo de aplicação (terrestre/aerea)
  /// - completude (completo/parcial/incompleto)
  /// - faixa de dosagem
  /// - limit for pagination
  ///
  /// Returns diagnosticos matching ALL specified criteria.
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters(
    DiagnosticoSearchFilters filters,
  );

  /// Search diagnosticos by general pattern
  ///
  /// Searches across multiple fields:
  /// - Nome do defensivo
  /// - Nome da cultura
  /// - Nome da praga
  ///
  /// Pattern matching is case-insensitive and partial.
  /// Example: "soja" matches "Soja", "SOJA", "Ferrugem da Soja"
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(
    String pattern,
  );

  /// Find similar diagnosticos to a given one
  ///
  /// Similarity criteria:
  /// - Same defensivo (highest priority)
  /// - Same praga (high priority)
  /// - Same cultura (medium priority)
  ///
  /// Returns up to [limit] diagnosticos ordered by relevance.
  /// Excludes the source diagnostico from results.
  Future<Either<Failure, List<DiagnosticoEntity>>> findSimilarDiagnosticos(
    String diagnosticoId, {
    int limit = 5,
  });

  // ========== Client-side search methods ==========

  /// Search in-memory list by pattern
  ///
  /// Useful for client-side search after initial query.
  /// Searches across defensivo, cultura, and praga names.
  /// Pattern matching is case-insensitive and partial.
  List<DiagnosticoEntity> searchInList(
    List<DiagnosticoEntity> diagnosticos,
    String pattern,
  );
}
