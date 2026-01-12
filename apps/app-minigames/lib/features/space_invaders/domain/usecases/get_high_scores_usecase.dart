import '../entities/space_invaders_score.dart';
import '../repositories/i_space_invaders_score_repository.dart';

class GetHighScoresUseCase {
  final ISpaceInvadersScoreRepository _repository;

  GetHighScoresUseCase(this._repository);

  Future<List<SpaceInvadersScore>> call({int limit = 10}) async {
    return _repository.getTopScores(limit: limit);
  }
}
