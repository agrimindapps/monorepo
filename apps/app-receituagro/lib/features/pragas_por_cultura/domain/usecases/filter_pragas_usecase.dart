import 'package:core/core.dart' hide Column;

import '../../presentation/services/pragas_cultura_error_message_service.dart';
import 'pragas_cultura_params.dart';

/// Use Case para filtrar pragas (lógica pura - sem I/O).
///
/// Responsabilidade: Filtrar pragas baseado em critérios
/// Parâmetros: [FilterPragasParams] com pragas e filtros
/// Retorno: Either<Failure, List<dynamic>> com pragas filtradas
/// Validações: Lista não vazia (validação básica)
/// Nota: Use case de lógica pura - sem chamadas de repositório

class FilterPragasUseCase {
  final PragasCulturaErrorMessageService errorService;

  const FilterPragasUseCase(this.errorService);

  /// Executa a filtragem de pragas.
  ///
  /// Parâmetros:
  /// - [params] contém [pragas] e [PragasCulturaFilter]
  ///
  /// Retorna um [Future] contendo:
  /// - [Right] com [List<dynamic>] de pragas filtradas em caso de sucesso
  /// - [Left] com [Failure] em caso de erro
  ///
  /// Lógica de Filtragem:
  /// - Se [onlyCriticas]: filtra apenas pragas críticas
  /// - Se [onlyNormais]: filtra apenas pragas normais
  /// - Se [tipoPraga]: filtra por tipo específico (Insetos, Doenças, Daninhas)
  Future<Either<Failure, List<dynamic>>> call(FilterPragasParams params) async {
    try {
      final pragas = params.pragas;
      final filter = params.filter;

      if (pragas.isEmpty) {
        return const Right(<dynamic>[]);
      }

      // Aplica filtros sobre a lista de pragas
      List<dynamic> filtradas = pragas;

      // Filtro por criticidade
      if (filter.onlyCriticas) {
        // Mantém apenas as pragas críticas (isCritica == true)
        filtradas = filtradas
            .where((p) => p is Map && (p['isCritica'] as bool? ?? false))
            .toList();
      } else if (filter.onlyNormais) {
        // Mantém apenas as pragas normais (isCritica == false)
        filtradas = filtradas
            .where((p) => p is Map && !(p['isCritica'] as bool? ?? false))
            .toList();
      }

      // Filtro por tipo de praga
      if (filter.tipoPraga != null && filter.tipoPraga!.isNotEmpty) {
        filtradas = filtradas
            .where(
              (p) =>
                  p is Map &&
                  (p['praga'] is Map
                      ? (p['praga']['tipoPraga'] as String? ?? '') ==
                            filter.tipoPraga
                      : false),
            )
            .toList();
      }

      return Right(filtradas);
    } catch (e) {
      return Left(
        UnexpectedFailure(errorService.getFilterPragasError(e.toString())),
      );
    }
  }
}
