import '../entities/frogger_stats.dart';

abstract class IFroggerStatsRepository {
  Future<FroggerStats> getStats();
  Future<void> updateStats(FroggerStats stats);
  Future<void> resetStats();
}
