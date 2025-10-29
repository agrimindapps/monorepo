import 'package:core/core.dart';

import '../entities/pragas_cultura_statistics.dart';
import 'pragas_cultura_params.dart';

/// Use Case para calcular estatísticas (lógica pura - sem I/O).
///
/// Responsabilidade: Calcular métricas agregadas sobre pragas
/// Parâmetros: [CalculateStatisticsParams] com lista de pragas
/// Retorno: Either<Failure, PragasCulturaStatistics> com estatísticas
/// Validações: Lista não vazia (validação básica)
/// Nota: Use case de lógica pura - sem chamadas de repositório
@injectable
class CalculateStatisticsUseCase {
  const CalculateStatisticsUseCase();

  /// Executa o cálculo de estatísticas.
  ///
  /// Parâmetros:
  /// - [params] contém [pragas] para análise
  ///
  /// Retorna um [Future] contendo:
  /// - [Right] com [PragasCulturaStatistics] em caso de sucesso
  /// - [Left] com [Failure] em caso de erro
  ///
  /// Cálculos Realizados:
  /// - [totalPragas]: Contagem total de pragas
  /// - [pragasCriticas]: Contagem de pragas críticas
  /// - [pragasAltoRisco]: Contagem de pragas com alto risco
  /// - [totalDiagnosticos]: Soma total de diagnósticos
  /// - [defensivosUnicos]: Contagem de defensivos únicos
  Future<Either<Failure, PragasCulturaStatistics>> call(
    CalculateStatisticsParams params,
  ) async {
    try {
      final pragas = params.pragas;

      if (pragas.isEmpty) {
        // Retorna estatísticas zeradas para lista vazia
        return const Right(
          PragasCulturaStatistics(
            totalPragas: 0,
            pragasCriticas: 0,
            pragasAltoRisco: 0,
            totalDiagnosticos: 0,
            defensivosUnicos: 0,
          ),
        );
      }

      // Calcula total de pragas
      final totalPragas = pragas.length;

      // Calcula pragas críticas (isCritica == true)
      final pragasCriticas = pragas.fold<int>(
        0,
        (contador, p) =>
            contador +
            ((p is Map && (p['isCritica'] as bool? ?? false)) ? 1 : 0),
      );

      // Calcula pragas de alto risco (nivelAmeaca == 'Alto')
      final pragasAltoRisco = pragas.fold<int>(
        0,
        (contador, p) =>
            contador +
            ((p is Map && (p['nivelAmeaca'] as String? ?? '') == 'Alto')
                ? 1
                : 0),
      );

      // Calcula total de diagnósticos (soma quantidadeDiagnosticos)
      final totalDiagnosticos = pragas.fold<int>(
        0,
        (total, p) =>
            total +
            (p is Map ? (p['quantidadeDiagnosticos'] as int?) ?? 0 : 0),
      );

      // Calcula defensivos únicos (conta defensivos relacionados únicos)
      final defensivosUnicos = _calcularDefensivosUnicos(pragas);

      // Cria objeto de estatísticas
      final statistics = PragasCulturaStatistics(
        totalPragas: totalPragas,
        pragasCriticas: pragasCriticas,
        pragasAltoRisco: pragasAltoRisco,
        totalDiagnosticos: totalDiagnosticos,
        defensivosUnicos: defensivosUnicos,
      );

      return Right(statistics);
    } catch (e) {
      return Left(
        UnexpectedFailure('Erro ao calcular estatísticas: ${e.toString()}'),
      );
    }
  }

  /// Calcula a contagem de defensivos únicos.
  ///
  /// Extrai todos os defensivos relacionados de cada praga
  /// e conta quantos são únicos no total
  int _calcularDefensivosUnicos(List<dynamic> pragas) {
    final defensivosSet = <String>{};

    for (final praga in pragas) {
      if (praga is Map && praga['defensivosRelacionados'] is List) {
        final defensivos = praga['defensivosRelacionados'] as List<dynamic>;
        for (final defensivo in defensivos) {
          if (defensivo is String) {
            defensivosSet.add(defensivo);
          } else if (defensivo is Map && defensivo['id'] is String) {
            defensivosSet.add(defensivo['id'] as String);
          }
        }
      }
    }

    return defensivosSet.length;
  }
}
