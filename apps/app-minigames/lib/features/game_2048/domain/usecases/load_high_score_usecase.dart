import 'package:core/core.dart';

import '../entities/enums.dart';
import '../entities/high_score_entity.dart';
import '../repositories/game_2048_repository.dart';

/// Loads high score from storage
class LoadHighScoreUseCase {
  final Game2048Repository _repository;

  LoadHighScoreUseCase(this._repository);

  /// Loads high score for specific board size
  Future<Either<Failure, HighScoreEntity>> call(BoardSize boardSize) async {
    try {
      final result = await _repository.loadHighScore(boardSize);

      return result.fold(
        (failure) {
          // If loading fails, return empty high score
          return Right(HighScoreEntity.empty(boardSize));
        },
        (highScore) => Right(highScore),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
