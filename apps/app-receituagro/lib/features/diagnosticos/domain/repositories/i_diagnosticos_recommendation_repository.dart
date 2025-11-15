import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';

/// Repository for recommendation operations
///
/// Responsibilities:
/// - Get recommendations for a specific cultura and praga combination
///
/// Used by DiagnosticosRecommendationService for providing recommendations.
///
/// Part of the Interface Segregation Principle refactoring.
abstract class IDiagnosticosRecommendationRepository {
  /// Obter recomendações para cultura e praga
  ///
  /// Returns diagnosticos (recommendations) for the given cultura and praga.
  /// Used by recommendation engine to suggest diagnosticos based on user selection.
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecomendacoesPara({
    required String culturaId,
    required String pragaId,
  });
}
