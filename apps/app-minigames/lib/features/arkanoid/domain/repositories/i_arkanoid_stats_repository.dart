import '../entities/arkanoid_stats.dart';

abstract class IArkanoidStatsRepository {
  Future<ArkanoidStats> getStats();
  Future<void> updateStats(ArkanoidStats stats);
  Future<void> resetStats();
}
