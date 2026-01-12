import '../entities/galaga_stats.dart';

abstract class IGalagaStatsRepository {
  Future<GalagaStats> getStats();
  Future<void> updateStats(GalagaStats stats);
  Future<void> resetStats();
}
