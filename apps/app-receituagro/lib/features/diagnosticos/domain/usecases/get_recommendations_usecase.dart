import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';
import '../services/recommendation/i_diagnosticos_recommendation_service.dart';

/// Use Case para obter recomendações de diagnósticos
/// Responsabilidade única: Retornar diagnósticos recomendados
@injectable
class GetRecommendationsUseCase {
  final IDiagnosticosRecommendationService _recommendationService;

  const GetRecommendationsUseCase(this._recommendationService);

  /// Retorna diagnósticos recomendados para uma cultura-praga
  ///
  /// Parâmetros:
  /// - [idCultura]: ID da cultura
  /// - [idPraga]: ID da praga
  /// - [limit]: Limite de recomendações (padrão: 10)
  ///
  /// Retorna: Either com List&lt;DiagnosticoEntity&gt; ou Failure
  Future<Either<Failure, List<DiagnosticoEntity>>> call({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  }) async {
    try {
      if (idCultura.isEmpty) {
        return const Left(CacheFailure('ID da cultura é obrigatório'));
      }

      if (idPraga.isEmpty) {
        return const Left(CacheFailure('ID da praga é obrigatório'));
      }

      if (limit <= 0) {
        return const Left(CacheFailure('Limit deve ser maior que 0'));
      }

      return await _recommendationService.getRecommendations(
        idCultura: idCultura,
        idPraga: idPraga,
        limit: limit,
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar recomendações: ${e.toString()}'),
      );
    }
  }
}
