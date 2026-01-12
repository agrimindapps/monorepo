import '../entities/reversi_stats.dart';

abstract class IReversiStatsRepository {
  Future<ReversiStats> getStats();
  Future<void> updateStats(ReversiStats stats);
  Future<void> resetStats();
}
