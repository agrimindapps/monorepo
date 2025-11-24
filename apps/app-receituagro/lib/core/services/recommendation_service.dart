import 'package:core/core.dart';

import '../../features/diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../features/diagnosticos/domain/repositories/i_diagnosticos_query_repository.dart';
import 'i_recommendation_service.dart';

/// Implementation of RecommendationService
/// 
/// Handles all recommendation logic for diagnosticos recommendations.
/// Extracted from DiagnosticosNotifier to follow SRP.
/// 
/// Can be used by:
/// - DiagnosticosNotifier (for recommendations in presentation)
/// - DiagnosticosRecommendationsNotifier (dedicated notifier)
/// - Other features needing recommendations

class RecommendationService implements IRecommendationService {
  final IDiagnosticosQueryRepository _queryRepository;

  RecommendationService(this._queryRepository);

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecommendations({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  }) async {
    try {
      // Get diagnosticos for this cultura + praga combination
      final result = await _queryRepository.queryByTriplaCombinacao(
        idCultura: idCultura,
        idPraga: idPraga,
      );

      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          // Sort by completude and dosage for better recommendations
          final sorted = _rankRecommendations(diagnosticos);
          
          // Limit to requested count
          return Right(sorted.take(limit).toList());
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Error getting recommendations: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> validateCompatibility({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) async {
    try {
      // Get diagnosticos for the triple combination
      final result = await _queryRepository.queryByTriplaCombinacao(
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
      );

      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          // Compatible if at least one diagnostico exists for this combination
          return Right(diagnosticos.isNotEmpty);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Error validating compatibility: ${e.toString()}'),
      );
    }
  }

  @override
  double scoreDiagnostico(
    DiagnosticoEntity diagnostico, {
    required String? contextoCultura,
    required String? contextoPraga,
    required String? contextoDefensivo,
  }) {
    double score = 50.0; // Base score

    // Bonus for completude (more complete = higher score)
    final completudeScore = _scoreCompletude(diagnostico.completude);
    score += completudeScore;

    // Bonus if matches current context
    if (contextoCultura != null &&
        (diagnostico.idCultura == contextoCultura ||
            diagnostico.nomeCultura?.toLowerCase() ==
                contextoCultura.toLowerCase())) {
      score += 15.0;
    }

    if (contextoPraga != null &&
        (diagnostico.idPraga == contextoPraga ||
            diagnostico.nomePraga?.toLowerCase() ==
                contextoPraga.toLowerCase())) {
      score += 15.0;
    }

    if (contextoDefensivo != null &&
        (diagnostico.idDefensivo == contextoDefensivo ||
            diagnostico.nomeDefensivo?.toLowerCase() ==
                contextoDefensivo.toLowerCase())) {
      score += 10.0;
    }

    // Bonus for good dosage range
    final dosageScore = _scoreDosage(diagnostico.dosagem.dosageAverage);
    score += dosageScore;

    // Cap at 100
    return score > 100.0 ? 100.0 : score;
  }

  /// Ranks diagnosticos by relevance (higher score = better recommendation)
  List<DiagnosticoEntity> _rankRecommendations(
    List<DiagnosticoEntity> diagnosticos,
  ) {
    final ranked = List<DiagnosticoEntity>.from(diagnosticos);
    ranked.sort((a, b) {
      // Primary: Sort by completude (complete first)
      final completudeComparison =
          b.completude.index.compareTo(a.completude.index);
      if (completudeComparison != 0) return completudeComparison;

      // Secondary: Sort by dosage (reasonable dosages first)
      final aDosage = a.dosagem.dosageAverage;
      final bDosage = b.dosagem.dosageAverage;
      
      // Prefer reasonable dosages (between 0.5 and 10)
      final aScore = _isReasonableDosage(aDosage) ? 1 : 0;
      final bScore = _isReasonableDosage(bDosage) ? 1 : 0;
      
      if (aScore != bScore) return bScore.compareTo(aScore);

      // Tertiary: Sort by ID (stable sort)
      return a.id.compareTo(b.id);
    });

    return ranked;
  }

  /// Scores completude level
  double _scoreCompletude(DiagnosticoCompletude completude) {
    switch (completude) {
      case DiagnosticoCompletude.completo:
        return 30.0;
      case DiagnosticoCompletude.parcial:
        return 15.0;
      case DiagnosticoCompletude.incompleto:
        return 0.0;
    }
  }

  /// Scores dosage value
  double _scoreDosage(double dosage) {
    // Prefer dosages between 0.5 and 10
    if (dosage >= 0.5 && dosage <= 10.0) {
      return 10.0;
    }
    if (dosage >= 0.1 && dosage < 0.5) {
      return 5.0;
    }
    if (dosage > 10.0 && dosage <= 50.0) {
      return 5.0;
    }
    return 0.0;
  }

  /// Checks if dosage is in reasonable range
  bool _isReasonableDosage(double dosage) {
    return dosage >= 0.5 && dosage <= 10.0;
  }
}
