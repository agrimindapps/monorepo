import '../entities/arkanoid_score.dart';
import '../repositories/i_arkanoid_score_repository.dart';

class GetHighScoresUseCase {
  final IArkanoidScoreRepository _repository;

  GetHighScoresUseCase(this._repository);

  Future<List<ArkanoidScore>> call({int limit = 10}) async {
    return _repository.getTopScores(limit: limit);
  }
}
