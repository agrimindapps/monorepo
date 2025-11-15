import 'package:core/core.dart';

import '../../features/diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../features/diagnosticos/presentation/state/diagnosticos_search_state.dart';

/// Specialized Service for generating recommendations
/// 
/// Responsibility: Handle recommendation logic based on:
/// - Cultura + Praga combination
/// - Compatibility between defensivo-cultura-praga
/// - Risk scoring and suggestion ranking
/// 
/// This service is INDEPENDENT from state management.
/// It can be used by any layer (presentation, domain, or other services).
/// 
/// SOLID Principles:
/// - SRP: Single responsibility (recommendations only)
/// - OCP: Open for extension (can add new recommendation strategies)
/// - DIP: Depends on abstractions (repositories)
abstract class IRecommendationService {
  /// Gets recommendations for a given cultura + praga combination
  /// 
  /// Parameters:
  ///   - idCultura: ID of the cultura
  ///   - idPraga: ID of the praga
  ///   - limit: Maximum number of recommendations (default 10)
  /// 
  /// Returns Either<Failure, List<DiagnosticoEntity>> with ranked recommendations
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecommendations({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  });

  /// Validates compatibility between defensivo-cultura-praga
  /// 
  /// Returns Either<Failure, bool> - true if compatible
  Future<Either<Failure, bool>> validateCompatibility({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  });

  /// Scores a diagnostico based on multiple factors
  /// Higher score = better recommendation for current context
  /// 
  /// Returns a score between 0.0 and 100.0
  double scoreDiagnostico(
    DiagnosticoEntity diagnostico, {
    required String? contextoCultura,
    required String? contextoPraga,
    required String? contextoDefensivo,
  });
}
