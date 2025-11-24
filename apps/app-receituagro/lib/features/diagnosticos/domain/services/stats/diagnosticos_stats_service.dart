import 'package:core/core.dart' hide Column;

import '../../entities/diagnostico_entity.dart';
import '../../repositories/i_diagnosticos_repository.dart';
import 'i_diagnosticos_stats_service.dart';

/// Implementation of statistics service for diagnosticos
///
/// Provides analytics and aggregate operations on diagnosticos data.

class DiagnosticosStatsService implements IDiagnosticosStatsService {
  final IDiagnosticosRepository _repository;

  DiagnosticosStatsService(this._repository);

  @override
  Future<Either<Failure, DiagnosticosStats>> getStatistics() async {
    final result = await _repository.getStatistics();
    return result.fold(
      (failure) => Left(failure),
      (stats) => Right(DiagnosticosStats(
        total: stats['total'] as int,
        completos: 0, // TODO: Calculate from data
        parciais: 0, // TODO: Calculate from data
        incompletos: 0, // TODO: Calculate from data
        porDefensivo: {}, // TODO: Calculate from data
        porCultura: {}, // TODO: Calculate from data
        porPraga: {}, // TODO: Calculate from data
        topDiagnosticos: [], // TODO: Calculate from data
      )),
    );
  }

  @override
  Future<Either<Failure, List<DiagnosticoPopular>>> getPopularDiagnosticos({
    int limit = 10,
  }) async {
    if (limit < 1) {
      return const Left(
        ValidationFailure('Limite deve ser maior que zero'),
      );
    }

    if (limit > 100) {
      return const Left(
        ValidationFailure('Limite não pode exceder 100 resultados'),
      );
    }

    final result = await _repository.getPopularDiagnosticos(limit: limit);
    return result.fold(
      (failure) => Left(failure),
      (diagnosticos) => Right(
        diagnosticos.map((d) => DiagnosticoPopular(
          defensivo: d.nomeDefensivo ?? d.idDefensivo,
          cultura: d.nomeCultura ?? d.idCultura,
          praga: d.nomePraga ?? d.idPraga,
          count: 0, // Not tracked in current implementation
        )).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, int>> countByFilters(
    DiagnosticoSearchFilters filters,
  ) async {
    // Allow counting without filters (returns total count)
    // Validate dosage range if specified
    if (filters.dosagemMinima != null && filters.dosagemMaxima != null) {
      if (filters.dosagemMinima! < 0) {
        return const Left(
          ValidationFailure('Dosagem mínima não pode ser negativa'),
        );
      }
      if (filters.dosagemMaxima! < 0) {
        return const Left(
          ValidationFailure('Dosagem máxima não pode ser negativa'),
        );
      }
      if (filters.dosagemMinima! >= filters.dosagemMaxima!) {
        return const Left(
          ValidationFailure('Dosagem mínima deve ser menor que a máxima'),
        );
      }
    }

    return _repository.countByFilters(
      defensivo: filters.idDefensivo,
      cultura: filters.idCultura,
      praga: filters.idPraga,
    );
  }

  // ========== Client-side stats methods ==========

  @override
  DiagnosticosStats calculateStatsFromList(
    List<DiagnosticoEntity> diagnosticos,
  ) {
    // Calculate counts by completeness
    int completos = 0;
    int parciais = 0;
    int incompletos = 0;

    // Maps for grouping
    final Map<String, int> porDefensivo = {};
    final Map<String, int> porCultura = {};
    final Map<String, int> porPraga = {};

    for (final diagnostico in diagnosticos) {
      // Count by completeness
      switch (diagnostico.completude) {
        case DiagnosticoCompletude.completo:
          completos++;
          break;
        case DiagnosticoCompletude.parcial:
          parciais++;
          break;
        case DiagnosticoCompletude.incompleto:
          incompletos++;
          break;
      }

      // Count by defensivo
      final defensivoKey = diagnostico.nomeDefensivo ?? diagnostico.idDefensivo;
      porDefensivo[defensivoKey] = (porDefensivo[defensivoKey] ?? 0) + 1;

      // Count by cultura
      final culturaKey = diagnostico.nomeCultura ?? diagnostico.idCultura;
      porCultura[culturaKey] = (porCultura[culturaKey] ?? 0) + 1;

      // Count by praga
      final pragaKey = diagnostico.nomePraga ?? diagnostico.idPraga;
      porPraga[pragaKey] = (porPraga[pragaKey] ?? 0) + 1;
    }

    // Extract top diagnosticos (by completeness score)
    final topDiagnosticos = extractPopularFromList(diagnosticos, limit: 10);

    return DiagnosticosStats(
      total: diagnosticos.length,
      completos: completos,
      parciais: parciais,
      incompletos: incompletos,
      porDefensivo: porDefensivo,
      porCultura: porCultura,
      porPraga: porPraga,
      topDiagnosticos: topDiagnosticos,
    );
  }

  @override
  List<DiagnosticoPopular> extractPopularFromList(
    List<DiagnosticoEntity> diagnosticos, {
    int limit = 10,
  }) {
    // Group diagnosticos by combination (defensivo-cultura-praga)
    final Map<String, List<DiagnosticoEntity>> grouped = {};

    for (final diagnostico in diagnosticos) {
      // Create key for grouping
      final defensivo = diagnostico.nomeDefensivo ?? diagnostico.idDefensivo;
      final cultura = diagnostico.nomeCultura ?? diagnostico.idCultura;
      final praga = diagnostico.nomePraga ?? diagnostico.idPraga;
      final key = '$defensivo|$cultura|$praga';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(diagnostico);
    }

    // Convert to DiagnosticoPopular and sort by count
    final popular = grouped.entries.map((entry) {
      final parts = entry.key.split('|');
      return DiagnosticoPopular(
        defensivo: parts[0],
        cultura: parts[1],
        praga: parts[2],
        count: entry.value.length,
      );
    }).toList();

    // Sort by count (descending) and take limit
    popular.sort((a, b) => b.count.compareTo(a.count));

    return popular.take(limit).toList();
  }
}
