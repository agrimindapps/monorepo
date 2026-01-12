import '../entities/simon_stats.dart';

abstract class ISimonStatsRepository {
  Future<SimonStats> getStats();
  Future<void> updateStats(SimonStats stats);
  Future<void> resetStats();
}
