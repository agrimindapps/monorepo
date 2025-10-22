// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/high_score.dart';
import '../repositories/quiz_repository.dart';

/// Use case to load high score
@injectable
class LoadHighScoreUseCase {
  final QuizRepository repository;

  LoadHighScoreUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, HighScore>> call() async {
    return await repository.loadHighScore();
  }
}
