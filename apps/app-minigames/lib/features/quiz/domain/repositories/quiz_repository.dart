// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/quiz_question.dart';
import '../entities/high_score.dart';

/// Repository interface for quiz operations
abstract class QuizRepository {
  /// Get all available quiz questions
  Future<Either<Failure, List<QuizQuestion>>> getQuestions();

  /// Load high score
  Future<Either<Failure, HighScore>> loadHighScore();

  /// Save high score
  Future<Either<Failure, void>> saveHighScore(int score);
}
