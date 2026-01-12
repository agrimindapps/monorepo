import '../entities/connect_four_score.dart';
import '../repositories/i_connect_four_score_repository.dart';

class GetHighScoresUseCase {
  final IConnectFourScoreRepository repository;

  GetHighScoresUseCase(this.repository);

  Future<List<ConnectFourScore>> call({int limit = 10}) async {
    final scores = await repository.getScores();
    return scores.take(limit).toList();
  }
}
