import 'package:core/core.dart' hide Column;

import '../../presentation/services/pragas_cultura_error_message_service.dart';
import '../../presentation/services/pragas_cultura_sort_strategy_service.dart';
import 'pragas_cultura_params.dart';

/// Use Case para ordenar pragas (lógica pura - sem I/O).
///
/// Responsabilidade: Ordenar pragas baseado em critérios
/// Parâmetros: [SortPragasParams] com pragas e sortBy
/// Retorno: Either<Failure, List<dynamic>> com pragas ordenadas
/// Validações: Lista não vazia (validação básica)
/// Nota: Use case de lógica pura - sem chamadas de repositório
@injectable
class SortPragasUseCase {
  final PragasCulturaSortService sortService;
  final PragasCulturaErrorMessageService errorService;

  const SortPragasUseCase(this.sortService, this.errorService);

  /// Executa a ordenação de pragas.
  ///
  /// Parâmetros:
  /// - [params] contém [pragas] e [sortBy] (critério)
  ///
  /// Retorna um [Future] contendo:
  /// - [Right] com [List<dynamic>] de pragas ordenadas em caso de sucesso
  /// - [Left] com [Failure] em caso de erro
  ///
  /// Critérios de Ordenação:
  /// - 'nome': Ordena alfabeticamente por nome comum (A-Z)
  /// - 'diagnosticos': Ordena por quantidade de diagnósticos (descendente)
  /// - 'ameaca' (padrão): Ordena por criticidade, depois por quantidade de diagnósticos
  Future<Either<Failure, List<dynamic>>> call(SortPragasParams params) async {
    try {
      // Delegate sorting to service (follows SRP and OCP)
      final sortedPragas = sortService.sortPragas(params.pragas, params.sortBy);
      return Right(sortedPragas);
    } catch (e) {
      return Left(
        UnexpectedFailure(errorService.getSortPragasError(e.toString())),
      );
    }
  }
}
