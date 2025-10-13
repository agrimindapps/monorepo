import 'package:core/core.dart';

import '../../entities/diagnostico_entity.dart';
import '../../repositories/i_diagnosticos_repository.dart';
import 'i_diagnosticos_recommendation_service.dart';

/// Implementation of recommendation service for diagnosticos
///
/// Provides business logic for scoring and recommending diagnosticos
/// based on cultura-praga combinations and quality metrics.
@Injectable(as: IDiagnosticosRecommendationService)
class DiagnosticosRecommendationService
    implements IDiagnosticosRecommendationService {
  final IDiagnosticosRepository _repository;

  DiagnosticosRecommendationService(this._repository);

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecommendations({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  }) async {
    // Validate parameters
    if (idCultura.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da cultura não pode estar vazio'),
      );
    }

    if (idPraga.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da praga não pode estar vazio'),
      );
    }

    if (limit < 1) {
      return const Left(
        ValidationFailure('Limite deve ser maior que zero'),
      );
    }

    if (limit > 50) {
      return const Left(
        ValidationFailure('Limite não pode exceder 50 resultados'),
      );
    }

    // Delegate to repository
    return _repository.getRecomendacoesPara(
      idCultura: idCultura,
      idPraga: idPraga,
      limit: limit,
    );
  }

  @override
  double scoreRecommendation(
    DiagnosticoEntity diagnostico,
    String idCultura,
    String idPraga,
  ) {
    double score = 0;

    // Exact match bonus (50 points max)
    final culturaMatch = diagnostico.idCultura == idCultura;
    final pragaMatch = diagnostico.idPraga == idPraga;

    if (culturaMatch && pragaMatch) {
      score += 50; // Perfect match
    } else if (culturaMatch) {
      score += 25; // Partial match - cultura
    } else if (pragaMatch) {
      score += 25; // Partial match - praga
    }

    // Completeness score (15 points max)
    switch (diagnostico.completude) {
      case DiagnosticoCompletude.completo:
        score += 15;
        break;
      case DiagnosticoCompletude.parcial:
        score += 10;
        break;
      case DiagnosticoCompletude.incompleto:
        score += 5;
        break;
    }

    // Application types availability (10 points max)
    final tiposDisponiveis = diagnostico.aplicacao.tiposDisponiveis.length;
    if (tiposDisponiveis >= 2) {
      score += 10; // Both terrestre and aerea
    } else if (tiposDisponiveis == 1) {
      score += 5; // Only one type
    }

    // Valid dosage information (10 points max)
    if (diagnostico.hasDosagemValida) {
      score += 10;

      // Bonus for dosage range (more flexible)
      if (diagnostico.dosagem.hasRange) {
        score += 5;
      }
    }

    // Ensure score is within 0-100 range
    return score.clamp(0, 100);
  }
}
