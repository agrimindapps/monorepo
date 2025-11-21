import '../entities/praga_entity.dart';

/// Service responsible for calculating statistics from pragas.
///
/// This service encapsulates statistics calculation logic, separating it from
/// the repository to improve Single Responsibility Principle (SRP) compliance.
///
/// Responsibilities:
/// - Calculate total count of pragas
/// - Count pragas by tipo (inseto, doença, planta)
/// - Count distinct famílias
/// - Generate comprehensive stats maps
abstract class IPragasStatsService {
  /// Calculate comprehensive statistics for pragas
  Map<String, int> calculateStats(List<PragaEntity> pragas);

  /// Get count of pragas by specific tipo
  int getCountByTipo(List<PragaEntity> pragas, String tipo);

  /// Get total count of pragas
  int getTotalCount(List<PragaEntity> pragas);

  /// Get count of distinct famílias
  int getFamiliasCount(List<PragaEntity> pragas);
}
