import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/high_score.dart';
import '../repositories/tower_repository.dart';

/// Use case for loading high score
@injectable
class LoadHighScoreUseCase {
  final TowerRepository repository;

  LoadHighScoreUseCase(this.repository);

  Future<Either<Failure, HighScore>> call() async {
    return await repository.getHighScore();
  }
}
