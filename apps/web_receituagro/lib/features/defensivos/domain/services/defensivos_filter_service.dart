import '../entities/defensivo.dart';
import '../entities/defensivo_filter.dart';
import '../entities/defensivo_info.dart';
import '../entities/diagnostico.dart';

/// Service responsible for filtering defensivos (SOLID - SRP)
class DefensivosFilterService {
  /// Filter defensivos by search query (name or active ingredient)
  List<Defensivo> filterByQuery(List<Defensivo> defensivos, String query) {
    if (query.trim().isEmpty) return defensivos;

    final lowerQuery = query.toLowerCase().trim();

    return defensivos.where((defensivo) {
      final nomeMatch = defensivo.nomeComum.toLowerCase().contains(lowerQuery);
      final ingredienteMatch =
          defensivo.ingredienteAtivo.toLowerCase().contains(lowerQuery);
      final fabricanteMatch =
          defensivo.fabricante.toLowerCase().contains(lowerQuery);

      return nomeMatch || ingredienteMatch || fabricanteMatch;
    }).toList();
  }

  /// Filter defensivos by fabricante
  List<Defensivo> filterByFabricante(
    List<Defensivo> defensivos,
    String fabricante,
  ) {
    if (fabricante.trim().isEmpty) return defensivos;

    final lowerFabricante = fabricante.toLowerCase().trim();

    return defensivos
        .where((d) => d.fabricante.toLowerCase().contains(lowerFabricante))
        .toList();
  }

  /// Filter defensivos by ingrediente ativo
  List<Defensivo> filterByIngredienteAtivo(
    List<Defensivo> defensivos,
    String ingredienteAtivo,
  ) {
    if (ingredienteAtivo.trim().isEmpty) return defensivos;

    final lowerIngrediente = ingredienteAtivo.toLowerCase().trim();

    return defensivos
        .where((d) =>
            d.ingredienteAtivo.toLowerCase().contains(lowerIngrediente))
        .toList();
  }

  /// Filter defensivos by DefensivoFilter enum
  /// Requires stats map with DefensivoStats for each defensivo
  List<Defensivo> filterByType(
    List<Defensivo> defensivos,
    DefensivoFilter filter,
    Map<String, DefensivoStats> statsMap,
  ) {
    if (filter == DefensivoFilter.todos) return defensivos;

    return defensivos.where((d) {
      final stats = statsMap[d.id] ?? const DefensivoStats.empty();

      switch (filter) {
        case DefensivoFilter.todos:
          return true;
        case DefensivoFilter.paraExportacao:
          // quantDiag === quantDiagP && temInfo > 0 && quantDiag > 0
          return stats.isReadyForExport;
        case DefensivoFilter.semDiagnostico:
          // quantDiag === 0 && quantDiagP === 0
          return stats.hasNoDiagnosticos;
        case DefensivoFilter.diagnosticoFaltante:
          // quantDiag !== quantDiagP
          return stats.hasMissingDiagnosticos;
        case DefensivoFilter.semInformacoes:
          // temInfo === 0
          return !stats.hasInfo;
      }
    }).toList();
  }

  /// Calculate stats for a single defensivo
  DefensivoStats calculateStats(
    Defensivo defensivo,
    List<Diagnostico> diagnosticos,
    DefensivoInfo? info,
  ) {
    final defDiagnosticos =
        diagnosticos.where((d) => d.defensivoId == defensivo.id).toList();

    // Count diagnosticos with dosage filled
    final filledCount = defDiagnosticos.where((d) {
      return (d.dsMin != null && d.dsMin!.isNotEmpty) ||
          (d.dsMax != null && d.dsMax!.isNotEmpty);
    }).length;

    // Count info fields filled
    final infoCount = _countFilledInfoFields(info);

    return DefensivoStats(
      quantDiag: defDiagnosticos.length,
      quantDiagP: filledCount,
      temInfo: infoCount,
    );
  }

  /// Calculate stats map for all defensivos
  Map<String, DefensivoStats> calculateStatsMap(
    List<Defensivo> defensivos,
    List<Diagnostico> diagnosticos,
    List<DefensivoInfo> infos,
  ) {
    final statsMap = <String, DefensivoStats>{};

    for (final defensivo in defensivos) {
      final info = infos.cast<DefensivoInfo?>().firstWhere(
            (i) => i?.defensivoId == defensivo.id,
            orElse: () => null,
          );

      statsMap[defensivo.id] = calculateStats(defensivo, diagnosticos, info);
    }

    return statsMap;
  }

  /// Count filled info fields
  int _countFilledInfoFields(DefensivoInfo? info) {
    if (info == null) return 0;

    var count = 0;
    if (info.embalagens != null && info.embalagens!.isNotEmpty) count++;
    if (info.tecnologia != null && info.tecnologia!.isNotEmpty) count++;
    if (info.pHumanas != null && info.pHumanas!.isNotEmpty) count++;
    if (info.pAmbiental != null && info.pAmbiental!.isNotEmpty) count++;
    if (info.manejoResistencia != null && info.manejoResistencia!.isNotEmpty) {
      count++;
    }
    if (info.compatibilidade != null && info.compatibilidade!.isNotEmpty) {
      count++;
    }
    if (info.manejoIntegrado != null && info.manejoIntegrado!.isNotEmpty) {
      count++;
    }

    return count;
  }
}
