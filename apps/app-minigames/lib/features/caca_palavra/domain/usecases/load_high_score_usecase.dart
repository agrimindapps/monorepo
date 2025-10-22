import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/high_score.dart';
import '../repositories/caca_palavra_repository.dart';

/// Loads high score from storage
class LoadHighScoreUseCase {
  final CacaPalavraRepository repository;

  LoadHighScoreUseCase(this.repository);

  Future<Either<Failure, HighScore>> call() async {
    return await repository.loadHighScore();
  }
}
