import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/high_score.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/quiz_image_repository.dart';
import '../datasources/quiz_image_local_data_source.dart';

/// Implementation of QuizImageRepository
/// Handles data operations for quiz game through local data source
class QuizImageRepositoryImpl implements QuizImageRepository {
  final QuizImageLocalDataSource localDataSource;

  QuizImageRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, HighScore>> getHighScore() async {
    try {
      final highScore = await localDataSource.getHighScore();
      return Right(highScore);
    } on CacheException {
      return const Left(CacheFailure('Failed to load high score'));
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error loading high score'));
    }
  }

  @override
  Future<Either<Failure, void>> saveHighScore(int score) async {
    try {
      await localDataSource.saveHighScore(score);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to save high score'));
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error saving high score'));
    }
  }

  @override
  Either<Failure, List<QuizQuestion>> getAvailableQuestions() {
    try {
      final questions = localDataSource.getAvailableQuestions();
      return Right(questions);
    } catch (e) {
      return const Left(DataFailure('Failed to load questions'));
    }
  }
}
