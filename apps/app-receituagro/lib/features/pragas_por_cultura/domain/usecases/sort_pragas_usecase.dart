import 'package:core/core.dart';

import 'pragas_cultura_params.dart';

/// Use Case para ordenar pragas (lógica pura - sem I/O).
///
/// Responsabilidade: Ordenar pragas por critério específico
/// Parâmetros: [SortPragasParams] com pragas e critério de ordenação
/// Retorno: Either<Failure, List<dynamic>> com pragas ordenadas
/// Validações: Lista não vazia (validação básica)
/// Nota: Use case de lógica pura - sem chamadas de repositório
@injectable
class SortPragasUseCase {
  const SortPragasUseCase();

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
  Future<Either<Failure, List<dynamic>>> call(
    SortPragasParams params,
  ) async {
    try {
      final pragas = List<dynamic>.from(params.pragas);
      final sortBy = params.sortBy;

      if (pragas.isEmpty) {
        return const Right(<dynamic>[]);
      }

      // Aplica a ordenação baseado no critério
      switch (sortBy) {
        case 'nome':
          // Ordena por nome comum alfabeticamente
          pragas.sort((a, b) {
            final nomeA = a is Map && a['praga'] is Map
                ? (a['praga']['nomeComum'] as String?) ?? ''
                : '';
            final nomeB = b is Map && b['praga'] is Map
                ? (b['praga']['nomeComum'] as String?) ?? ''
                : '';
            return nomeA.compareTo(nomeB);
          });
          break;

        case 'diagnosticos':
          // Ordena por quantidade de diagnósticos (descendente)
          pragas.sort((a, b) {
            final diagA = a is Map ? (a['quantidadeDiagnosticos'] as int?) ?? 0 : 0;
            final diagB = b is Map ? (b['quantidadeDiagnosticos'] as int?) ?? 0 : 0;
            return diagB.compareTo(diagA); // Descendente
          });
          break;

        case 'ameaca':
        default:
          // Ordena por criticidade (descendente), depois por quantidade de diagnósticos
          pragas.sort((a, b) {
            // Comparar criticidade primeiro (críticas primeiro)
            final criticaA = a is Map ? (a['isCritica'] as bool?) ?? false : false;
            final criticaB = b is Map ? (b['isCritica'] as bool?) ?? false : false;

            if (criticaA != criticaB) {
              return criticaA ? -1 : 1; // true (crítica) vem primeiro
            }

            // Se criticidade é igual, ordena por quantidade de diagnósticos
            final diagA = a is Map ? (a['quantidadeDiagnosticos'] as int?) ?? 0 : 0;
            final diagB = b is Map ? (b['quantidadeDiagnosticos'] as int?) ?? 0 : 0;
            return diagB.compareTo(diagA); // Descendente
          });
          break;
      }

      return Right(pragas);
    } catch (e) {
      return Left(
        UnexpectedFailure('Erro ao ordenar pragas: ${e.toString()}'),
      );
    }
  }
}
