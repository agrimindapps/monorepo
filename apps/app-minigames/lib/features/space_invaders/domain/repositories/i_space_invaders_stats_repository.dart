import '../entities/space_invaders_stats.dart';

abstract class ISpaceInvadersStatsRepository {
  Future<SpaceInvadersStats> getStats();
  Future<void> updateStats(SpaceInvadersStats stats);
  Future<void> resetStats();
}
