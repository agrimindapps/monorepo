import '../entities/batalha_naval_stats.dart';

abstract class IBatalhaNavalStatsRepository {
  Future<BatalhaNavalStats> getStats();
  Future<void> updateStats(BatalhaNavalStats stats);
  Future<void> resetStats();
}
