import '../entities/connect_four_stats.dart';

abstract class IConnectFourStatsRepository {
  Future<ConnectFourStats> getStats();
  Future<void> updateStats(ConnectFourStats stats);
  Future<void> resetStats();
}
