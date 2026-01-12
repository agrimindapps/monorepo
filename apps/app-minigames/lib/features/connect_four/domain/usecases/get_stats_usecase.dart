import '../entities/connect_four_stats.dart';
import '../repositories/i_connect_four_stats_repository.dart';

class GetStatsUseCase {
  final IConnectFourStatsRepository repository;

  GetStatsUseCase(this.repository);

  Future<ConnectFourStats> call() async {
    return await repository.getStats();
  }
}
