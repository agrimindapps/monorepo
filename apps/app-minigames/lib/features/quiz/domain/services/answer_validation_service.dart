
import '../entities/enums.dart';
import '../entities/quiz_question.dart';

/// Service responsible for answer validation and scoring
///
/// Handles:
/// - Answer correctness validation
/// - Score calculation based on time left
/// - Answer statistics
/// - Response time analysis
class AnswerValidationService {
  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Validates if answer is correct
  bool isCorrectAnswer({
    required QuizQuestion question,
    required String selectedAnswer,
  }) {
    return question.correctAnswer == selectedAnswer;
  }

  /// Calculates score earned from correct answer
  ///
  /// Score = timeLeft (faster answers = higher score)
  int calculateScore({
    required int timeLeft,
    required QuizDifficulty difficulty,
  }) {
    // Base score is time left
    return timeLeft;
  }

  /// Calculates bonus score based on speed
  ///
  /// Returns bonus points for very fast answers
  int calculateSpeedBonus({
    required int timeLeft,
    required int totalTime,
  }) {
    final speedPercentage = (timeLeft / totalTime * 100);

    // Speed bonus tiers
    if (speedPercentage >= 90) {
      return 10; // Answered in first 10% of time
    } else if (speedPercentage >= 75) {
      return 5; // Answered in first 25% of time
    } else if (speedPercentage >= 50) {
      return 2; // Answered in first 50% of time
    }

    return 0; // No bonus
  }

  /// Processes answer validation and returns result
  AnswerValidationResult validateAnswer({
    required QuizQuestion question,
    required String selectedAnswer,
    required int timeLeft,
    required QuizDifficulty difficulty,
  }) {
    final isCorrect = isCorrectAnswer(
      question: question,
      selectedAnswer: selectedAnswer,
    );

    if (isCorrect) {
      final baseScore = calculateScore(
        timeLeft: timeLeft,
        difficulty: difficulty,
      );

      final speedBonus = calculateSpeedBonus(
        timeLeft: timeLeft,
        totalTime: difficulty.timeInSeconds,
      );

      return AnswerValidationResult(
        isCorrect: true,
        scoreEarned: baseScore + speedBonus,
        baseScore: baseScore,
        speedBonus: speedBonus,
        answerState: AnswerState.correct,
      );
    } else {
      return const AnswerValidationResult(
        isCorrect: false,
        scoreEarned: 0,
        baseScore: 0,
        speedBonus: 0,
        answerState: AnswerState.incorrect,
      );
    }
  }

  // ============================================================================
  // Answer Analysis
  // ============================================================================

  /// Analyzes answer speed
  AnswerSpeed analyzeSpeed({
    required int timeLeft,
    required int totalTime,
  }) {
    final speedPercentage = (timeLeft / totalTime * 100);

    if (speedPercentage >= 90) {
      return AnswerSpeed.veryFast;
    } else if (speedPercentage >= 75) {
      return AnswerSpeed.fast;
    } else if (speedPercentage >= 50) {
      return AnswerSpeed.medium;
    } else if (speedPercentage >= 25) {
      return AnswerSpeed.slow;
    } else {
      return AnswerSpeed.verySlow;
    }
  }

  /// Gets answer quality based on time and correctness
  AnswerQuality getAnswerQuality({
    required bool isCorrect,
    required int timeLeft,
    required int totalTime,
  }) {
    if (!isCorrect) {
      return AnswerQuality.incorrect;
    }

    final speed = analyzeSpeed(timeLeft: timeLeft, totalTime: totalTime);

    switch (speed) {
      case AnswerSpeed.veryFast:
        return AnswerQuality.perfect;
      case AnswerSpeed.fast:
        return AnswerQuality.excellent;
      case AnswerSpeed.medium:
        return AnswerQuality.good;
      case AnswerSpeed.slow:
        return AnswerQuality.acceptable;
      case AnswerSpeed.verySlow:
        return AnswerQuality.poor;
    }
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets statistics about answer
  AnswerStatistics getStatistics({
    required QuizQuestion question,
    required String selectedAnswer,
    required int timeLeft,
    required int totalTime,
    required QuizDifficulty difficulty,
  }) {
    final isCorrect = isCorrectAnswer(
      question: question,
      selectedAnswer: selectedAnswer,
    );

    final timeUsed = totalTime - timeLeft;
    final speedPercentage = (timeLeft / totalTime * 100);
    final speed = analyzeSpeed(timeLeft: timeLeft, totalTime: totalTime);
    final quality = getAnswerQuality(
      isCorrect: isCorrect,
      timeLeft: timeLeft,
      totalTime: totalTime,
    );

    return AnswerStatistics(
      isCorrect: isCorrect,
      timeUsed: timeUsed,
      timeLeft: timeLeft,
      totalTime: totalTime,
      speedPercentage: speedPercentage,
      speed: speed,
      quality: quality,
      selectedAnswer: selectedAnswer,
      correctAnswer: question.correctAnswer,
    );
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates answer input
  AnswerInputValidation validateInput({
    required QuizQuestion question,
    required String selectedAnswer,
  }) {
    final errors = <String>[];

    if (selectedAnswer.trim().isEmpty) {
      errors.add('Answer cannot be empty');
    }

    if (!question.options.contains(selectedAnswer)) {
      errors.add('Answer not in available options');
    }

    return AnswerInputValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Checks if answer was given quickly (within first 25% of time)
  bool isQuickAnswer({
    required int timeLeft,
    required int totalTime,
  }) {
    final speedPercentage = (timeLeft / totalTime * 100);
    return speedPercentage >= 75;
  }

  /// Checks if answer was given slowly (within last 25% of time)
  bool isSlowAnswer({
    required int timeLeft,
    required int totalTime,
  }) {
    final speedPercentage = (timeLeft / totalTime * 100);
    return speedPercentage < 25;
  }

  /// Gets time pressure level (0.0 to 1.0)
  double getTimePressure({
    required int timeLeft,
    required int totalTime,
  }) {
    return 1.0 - (timeLeft / totalTime);
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of answer validation
class AnswerValidationResult {
  final bool isCorrect;
  final int scoreEarned;
  final int baseScore;
  final int speedBonus;
  final AnswerState answerState;

  const AnswerValidationResult({
    required this.isCorrect,
    required this.scoreEarned,
    required this.baseScore,
    required this.speedBonus,
    required this.answerState,
  });
}

/// Answer speed classification
enum AnswerSpeed {
  veryFast,
  fast,
  medium,
  slow,
  verySlow;

  String get label {
    switch (this) {
      case AnswerSpeed.veryFast:
        return 'Lightning Fast';
      case AnswerSpeed.fast:
        return 'Fast';
      case AnswerSpeed.medium:
        return 'Moderate';
      case AnswerSpeed.slow:
        return 'Slow';
      case AnswerSpeed.verySlow:
        return 'Very Slow';
    }
  }
}

/// Answer quality classification
enum AnswerQuality {
  perfect,
  excellent,
  good,
  acceptable,
  poor,
  incorrect;

  String get label {
    switch (this) {
      case AnswerQuality.perfect:
        return 'Perfect!';
      case AnswerQuality.excellent:
        return 'Excellent';
      case AnswerQuality.good:
        return 'Good';
      case AnswerQuality.acceptable:
        return 'OK';
      case AnswerQuality.poor:
        return 'Slow';
      case AnswerQuality.incorrect:
        return 'Incorrect';
    }
  }
}

/// Statistics about an answer
class AnswerStatistics {
  final bool isCorrect;
  final int timeUsed;
  final int timeLeft;
  final int totalTime;
  final double speedPercentage;
  final AnswerSpeed speed;
  final AnswerQuality quality;
  final String selectedAnswer;
  final String correctAnswer;

  const AnswerStatistics({
    required this.isCorrect,
    required this.timeUsed,
    required this.timeLeft,
    required this.totalTime,
    required this.speedPercentage,
    required this.speed,
    required this.quality,
    required this.selectedAnswer,
    required this.correctAnswer,
  });

  /// Gets response time as percentage (0-100)
  double get responseTimePercentage => (timeUsed / totalTime * 100);
}

/// Validation result for answer input
class AnswerInputValidation {
  final bool isValid;
  final List<String> errors;

  const AnswerInputValidation({
    required this.isValid,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}
