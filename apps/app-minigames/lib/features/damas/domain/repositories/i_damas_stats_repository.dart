import '../entities/damas_stats.dart';

abstract class IDamasStatsRepository {
  Future<DamasStats> getStats();
  Future<void> updateStats(DamasStats stats);
  Future<void> resetStats();
}
