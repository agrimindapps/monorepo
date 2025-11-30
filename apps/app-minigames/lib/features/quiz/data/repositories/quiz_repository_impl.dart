// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/exceptions.dart';
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/high_score.dart';
import '../../domain/repositories/quiz_repository.dart';

// Data imports:
import '../datasources/quiz_local_data_source.dart';

/// Implementation of QuizRepository
class QuizRepositoryImpl implements QuizRepository {
  final QuizLocalDataSource localDataSource;

  QuizRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<QuizQuestion>>> getQuestions() async {
    try {
      final questions = await localDataSource.getQuestions();
      return Right(questions);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, HighScore>> loadHighScore() async {
    try {
      final highScore = await localDataSource.loadHighScore();
      return Right(highScore);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveHighScore(int score) async {
    try {
      await localDataSource.saveHighScore(score);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
