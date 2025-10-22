import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/quiz_image_repository.dart';

/// Use case that saves a new high score to storage
@injectable
class SaveHighScoreUseCase {
  final QuizImageRepository repository;

  SaveHighScoreUseCase(this.repository);

  Future<Either<Failure, void>> call(int score) async {
    // Validate score is non-negative
    if (score < 0) {
      return const Left(ValidationFailure('Score cannot be negative'));
    }

    return await repository.saveHighScore(score);
  }
}
