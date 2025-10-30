import '../../domain/entities/defensivo_entity.dart';

/// Service responsible for calculating statistics from defensivos.
///
/// This service encapsulates statistics calculation logic, separating it from
/// the repository to improve Single Responsibility Principle (SRP) compliance.
///
/// Responsibilities:
/// - Calculate total count
/// - Count distinct classes, fabricantes, modos de ação
/// - Generate comprehensive stats maps
abstract class IDefensivosStatsService {
  /// Calculate comprehensive statistics for defensivos
  Map<String, int> calculateStats(List<DefensivoEntity> defensivos);

  /// Get count of distinct values for each dimension
  Map<String, int> getDistinctCounts(List<DefensivoEntity> defensivos);

  /// Get total defensivos count
  int getTotalCount(List<DefensivoEntity> defensivos);

  /// Get count of commercialized defensivos
  int getComercializadosCount(List<DefensivoEntity> defensivos);

  /// Get count of eligible defensivos
  int getElegivelCount(List<DefensivoEntity> defensivos);
}

/// Default implementation of stats service
class DefensivosStatsService implements IDefensivosStatsService {
  @override
  Map<String, int> calculateStats(List<DefensivoEntity> defensivos) {
    return {
      'total': getTotalCount(defensivos),
      'classes': _getDistinctClassesCount(defensivos),
      'fabricantes': _getDistinctFabricantesCount(defensivos),
      'modosAcao': _getDistinctModosAcaoCount(defensivos),
      'comercializados': getComercializadosCount(defensivos),
      'elegiveis': getElegivelCount(defensivos),
    };
  }

  @override
  Map<String, int> getDistinctCounts(List<DefensivoEntity> defensivos) {
    return {
      'classes': _getDistinctClassesCount(defensivos),
      'fabricantes': _getDistinctFabricantesCount(defensivos),
      'modosAcao': _getDistinctModosAcaoCount(defensivos),
    };
  }

  @override
  int getTotalCount(List<DefensivoEntity> defensivos) {
    return defensivos.length;
  }

  @override
  int getComercializadosCount(List<DefensivoEntity> defensivos) {
    return defensivos.where((d) => d.isComercializado).length;
  }

  @override
  int getElegivelCount(List<DefensivoEntity> defensivos) {
    return defensivos.where((d) => d.isElegivel).length;
  }

  /// Get count of distinct classe agronômica values
  int _getDistinctClassesCount(List<DefensivoEntity> defensivos) {
    return defensivos
        .map((d) => d.classeAgronomica)
        .where((c) => c != null && c.isNotEmpty)
        .toSet()
        .length;
  }

  /// Get count of distinct fabricante values
  int _getDistinctFabricantesCount(List<DefensivoEntity> defensivos) {
    return defensivos
        .map((d) => d.fabricante)
        .where((f) => f != null && f.isNotEmpty)
        .toSet()
        .length;
  }

  /// Get count of distinct modo de ação values
  int _getDistinctModosAcaoCount(List<DefensivoEntity> defensivos) {
    return defensivos
        .map((d) => d.modoAcao)
        .where((m) => m != null && m.isNotEmpty)
        .toSet()
        .length;
  }
}
