import '../../domain/entities/pragas_cultura_statistics.dart';

/// Service para cálculo de estatísticas de pragas por cultura
///
/// Responsabilidades:
/// - Contar pragas críticas vs normais
/// - Calcular percentuais
/// - Agregar dados por tipo
abstract class IPragasCulturaStatisticsService {
  /// Calcula estatísticas gerais
  PragasCulturaStatistics calculateStatistics(
    List<Map<String, dynamic>> pragas,
  );

  /// Conta pragas críticas
  int countCriticas(List<Map<String, dynamic>> pragas);

  /// Conta pragas normais
  int countNormais(List<Map<String, dynamic>> pragas);

  /// Calcula percentual de críticas
  double percentualCriticas(List<Map<String, dynamic>> pragas);

  /// Agrupa pragas por tipo
  Map<String, int> countByTipo(List<Map<String, dynamic>> pragas);
}

/// Implementação padrão do Statistics Service
class PragasCulturaStatisticsService
    implements IPragasCulturaStatisticsService {
  @override
  PragasCulturaStatistics calculateStatistics(
    List<Map<String, dynamic>> pragas,
  ) {
    final total = pragas.length;
    final criticas = countCriticas(pragas);
    final altoRisco = criticas; // Alto risco = críticas
    final totalDiag = _extractTotalDiagnosticos(pragas);
    final defensivos = _extractUnicoDefensivos(pragas);

    return PragasCulturaStatistics(
      totalPragas: total,
      pragasCriticas: criticas,
      pragasAltoRisco: altoRisco,
      totalDiagnosticos: totalDiag,
      defensivosUnicos: defensivos,
    );
  }

  @override
  int countCriticas(List<Map<String, dynamic>> pragas) {
    return pragas.where((p) => (p['isCritica'] as bool?) ?? false).length;
  }

  @override
  int countNormais(List<Map<String, dynamic>> pragas) {
    return pragas.where((p) => !((p['isCritica'] as bool?) ?? false)).length;
  }

  @override
  double percentualCriticas(List<Map<String, dynamic>> pragas) {
    if (pragas.isEmpty) return 0;
    final criticas = countCriticas(pragas);
    return (criticas / pragas.length) * 100;
  }

  @override
  Map<String, int> countByTipo(List<Map<String, dynamic>> pragas) {
    final counts = <String, int>{};
    for (final praga in pragas) {
      final tipo = praga['tipo'] as String?;
      if (tipo != null) {
        counts[tipo] = (counts[tipo] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Extrai total de diagnósticos
  int _extractTotalDiagnosticos(List<Map<String, dynamic>> pragas) {
    int total = 0;
    for (final praga in pragas) {
      final diagnosticos = praga['diagnosticos'] as List?;
      total += diagnosticos?.length ?? 0;
    }
    return total;
  }

  /// Extrai quantidade de defensivos únicos
  int _extractUnicoDefensivos(List<Map<String, dynamic>> pragas) {
    final defensivos = <String>{};
    for (final praga in pragas) {
      final defensivosLista = praga['defensivos'] as List?;
      if (defensivosLista != null) {
        for (final def in defensivosLista) {
          if (def is Map<String, dynamic>) {
            final id = def['id'] as String?;
            if (id != null) {
              defensivos.add(id);
            }
          }
        }
      }
    }
    return defensivos.length;
  }
}
