import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/high_score.dart';
import '../entities/quiz_question.dart';

/// Repository interface for quiz image game data operations
abstract class QuizImageRepository {
  /// Loads the high score from persistent storage
  Future<Either<Failure, HighScore>> getHighScore();

  /// Saves a new high score to persistent storage
  Future<Either<Failure, void>> saveHighScore(int score);

  /// Returns all available quiz questions (15 hardcoded questions)
  Either<Failure, List<QuizQuestion>> getAvailableQuestions();
}
