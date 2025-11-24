import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/high_score.dart';
import '../repositories/quiz_image_repository.dart';

/// Use case that loads the high score from storage
class LoadHighScoreUseCase {
  final QuizImageRepository repository;

  LoadHighScoreUseCase(this.repository);

  Future<Either<Failure, HighScore>> call() async {
    return await repository.getHighScore();
  }
}
