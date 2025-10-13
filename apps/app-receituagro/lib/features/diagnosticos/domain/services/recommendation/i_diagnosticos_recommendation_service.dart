import 'package:core/core.dart';

import '../../entities/diagnostico_entity.dart';

/// Interface for recommendation logic for diagnosticos
/// Follows Single Responsibility Principle (SOLID)
///
/// This service handles business logic for recommending
/// diagnosticos based on cultura-praga combinations and
/// scoring/ranking algorithms.
abstract class IDiagnosticosRecommendationService {
  /// Get recommended diagnosticos for a cultura-praga combination
  ///
  /// Returns diagnosticos ordered by relevance score:
  /// 1. Exact matches (cultura + praga)
  /// 2. Partial matches (only cultura or only praga)
  /// 3. Popular/commonly used diagnosticos
  ///
  /// Scoring factors:
  /// - Data completeness (completo > parcial > incompleto)
  /// - Application type availability (both > single)
  /// - Dosage information quality
  ///
  /// Returns up to [limit] recommendations ordered by score (highest first).
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecommendations({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  });

  /// Score a diagnostico for a specific cultura-praga combination
  ///
  /// Scoring algorithm (0-100 scale):
  /// - Exact match (cultura + praga): +50 points
  /// - Cultura match only: +25 points
  /// - Praga match only: +25 points
  /// - Completeness: completo +15, parcial +10, incompleto +5
  /// - Application types: both +10, single +5
  /// - Valid dosage: +10 points
  ///
  /// This method is useful for:
  /// - Client-side sorting/ranking
  /// - A/B testing different scoring algorithms
  /// - Custom recommendation logic
  ///
  /// Returns score between 0 and 100.
  double scoreRecommendation(
    DiagnosticoEntity diagnostico,
    String idCultura,
    String idPraga,
  );
}
