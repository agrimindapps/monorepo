import 'package:dartz/dartz.dart';

import '../entities/high_score_entity.dart';
import '../repositories/soletrando_repository.dart';

/// Use case to load high scores from storage
class LoadHighScoreUseCase {
  final SoletrandoRepository repository;

  LoadHighScoreUseCase(this.repository);

  Future<Either<Failure, HighScoresCollection>> call() async {
    final result = await repository.loadHighScores();

    return result.fold(
      (failure) {
        // If loading fails, return empty collection
        return Right(HighScoresCollection.empty());
      },
      (highScores) => Right(highScores),
    );
  }
}
