import 'package:core/core.dart' hide Column;

import '../services/stats/i_diagnosticos_stats_service.dart';

/// Use Case para obter estatísticas dos diagnósticos
/// Responsabilidade única: Retornar estatísticas agregadas
@injectable
class GetDiagnosticosStatsUseCase {
  final IDiagnosticosStatsService _statsService;

  const GetDiagnosticosStatsUseCase(this._statsService);

  /// Retorna estatísticas completas dos diagnósticos
  ///
  /// Retorna: Either com dynamic ou Failure
  Future<Either<Failure, dynamic>> call() async {
    try {
      return await _statsService.getStatistics();
    } catch (e) {
      return Left(
        CacheFailure('Erro ao carregar estatísticas: ${e.toString()}'),
      );
    }
  }

  /// Retorna diagnósticos mais populares
  ///
  /// Parâmetros:
  /// - [limit]: Limite de diagnósticos (padrão: 10)
  ///
  /// Retorna: Either com List ou Failure
  Future<Either<Failure, List<dynamic>>> getPopular({int limit = 10}) async {
    try {
      if (limit <= 0) {
        return const Left(CacheFailure('Limit deve ser maior que 0'));
      }

      return await _statsService.getPopularDiagnosticos(limit: limit);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao carregar diagnósticos populares: ${e.toString()}',
        ),
      );
    }
  }
}
