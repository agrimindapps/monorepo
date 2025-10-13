import 'package:core/core.dart';

import '../entities/diagnostico_entity.dart';

/// Interface do repositório de diagnósticos (Domain Layer)
/// Define contratos para acesso aos dados seguindo Dependency Inversion Principle
///
/// REFACTORED: Simplified to CRUD + Basic Queries only (Phase 4 - God Object Refactoring)
/// Specialized operations moved to dedicated services:
/// - DiagnosticosFilterService: advanced filtering, completude, tipo aplicacao, dosagem
/// - DiagnosticosSearchService: complex search, similarity, patterns
/// - DiagnosticosRecommendationService: recommendations, scoring
/// - DiagnosticosStatsService: statistics, popular items, counting
/// - DiagnosticosMetadataService: defensivos, culturas, pragas lists, unidades
/// - DiagnosticosValidationService: existence checks, compatibility validation
///
/// This follows Single Responsibility Principle (SOLID)
abstract class IDiagnosticosRepository {
  // ========== CRUD Operations ==========

  /// Busca todos os diagnósticos com paginação opcional
  ///
  /// Core read operation for diagnosticos.
  /// Returns all diagnosticos with optional pagination support.
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  });

  /// Busca diagnóstico por ID
  ///
  /// Core read operation by unique identifier.
  /// Returns single diagnostico or null if not found.
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id);

  // ========== Basic Query Operations ==========
  // These are fundamental queries used by multiple services

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
