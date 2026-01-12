import '../entities/dino_run_stats.dart';

abstract class IDinoRunStatsRepository {
  Future<DinoRunStats> getStats();
  Future<void> updateStats(DinoRunStats stats);
  Future<void> resetStats();
}
