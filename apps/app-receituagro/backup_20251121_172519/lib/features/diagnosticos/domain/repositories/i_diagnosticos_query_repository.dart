import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';

/// Repository for basic query operations on diagnosticos
///
/// Responsibilities:
/// - Query diagnosticos by defensivo, cultura, praga
/// - Query by triple combination (defensivo + cultura + praga)
/// - Query by general pattern matching
///
/// These are fundamental queries used by multiple services:
/// - DiagnosticosFilterService
/// - DiagnosticosRecommendationService
/// - DiagnosticosSearchService
///
/// Part of the Interface Segregation Principle refactoring.
abstract class IDiagnosticosQueryRepository {
  /// Busca diagnósticos por defensivo
  ///
  /// Basic query operation used by:
  /// - DiagnosticosFilterService.filterByDefensivo()
  /// - DiagnosticosSearchService.findSimilarDiagnosticos()
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByDefensivo(
    String idDefensivo,
  );

  /// Busca diagnósticos por cultura
  ///
  /// Basic query operation used by:
  /// - DiagnosticosFilterService.filterByCultura()
  /// - DiagnosticosRecommendationService.getRecommendations()
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByCultura(
    String idCultura,
  );

  /// Busca diagnósticos por praga
  ///
  /// Basic query operation used by:
  /// - DiagnosticosFilterService.filterByPraga()
  /// - DiagnosticosRecommendationService.getRecommendations()
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByPraga(String idPraga);

  /// Busca diagnósticos por combinação defensivo-cultura-praga
  ///
  /// Basic query operation for triple combination.
  /// Used by DiagnosticosFilterService.filterByTriplaCombinacao().
  /// All parameters are optional, at least one must be provided.
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  });

  /// Buscar por padrão geral (nome defensivo, cultura ou praga)
  ///
  /// Basic pattern search across multiple fields.
  /// Used by DiagnosticosSearchService.searchByPattern().
  /// Case-insensitive partial match on defensivo, cultura, and praga names.
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByPattern(
    String pattern,
  );
}
