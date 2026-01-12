import '../entities/asteroids_stats.dart';

abstract class IAsteroidsStatsRepository {
  Future<AsteroidsStats> getStats();
  Future<void> updateStats(AsteroidsStats stats);
  Future<void> resetStats();
}
