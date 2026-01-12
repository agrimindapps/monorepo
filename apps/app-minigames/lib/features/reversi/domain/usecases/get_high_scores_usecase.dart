import '../entities/reversi_score.dart';
import '../repositories/i_reversi_score_repository.dart';

class GetHighScoresUseCase {
  final IReversiScoreRepository _repository;

  GetHighScoresUseCase(this._repository);

  Future<List<ReversiScore>> call({int limit = 10}) async {
    return _repository.getTopScores(limit: limit);
  }
}
