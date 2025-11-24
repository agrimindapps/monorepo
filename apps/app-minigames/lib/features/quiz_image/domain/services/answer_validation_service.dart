
import '../entities/enums.dart';
import '../entities/quiz_question.dart';

/// Service responsible for answer validation and scoring in quiz image game
///
/// Handles:
/// - Answer correctness validation
/// - Score calculation with accuracy tracking
/// - Answer quality classification
/// - Statistics tracking
class AnswerValidationService {
  AnswerValidationService();

  // ============================================================================
  // Answer Validation
  // ============================================================================

  /// Validates if the selected answer is correct
  bool isCorrectAnswer({
    required QuizQuestion question,
    required String selectedAnswer,
  }) {
    return question.isCorrect(selectedAnswer);
  }

  /// Validates answer with complete result
  AnswerValidationResult validateAnswer({
    required QuizQuestion question,
    required String selectedAnswer,
    required int timeLeft,
    required int totalTime,
  }) {
    final isCorrect = isCorrectAnswer(
      question: question,
      selectedAnswer: selectedAnswer,
    );

    final answerState = isCorrect ? AnswerState.correct : AnswerState.incorrect;
    final timeTaken = totalTime - timeLeft;
    final accuracy = getAnswerAccuracy(
      isCorrect: isCorrect,
      timeLeft: timeLeft,
      totalTime: totalTime,
    );

    return AnswerValidationResult(
      isCorrect: isCorrect,
      selectedAnswer: selectedAnswer,
      correctAnswer: question.correctAnswer,
      answerState: answerState,
      timeTaken: timeTaken,
      timeLeft: timeLeft,
      accuracy: accuracy,
    );
  }

  /// Validates if the selected answer is one of the available options
  bool isValidOption({
    required QuizQuestion question,
    required String selectedAnswer,
  }) {
    return question.options.contains(selectedAnswer);
  }

  // ============================================================================
  // Answer Quality Analysis
  // ============================================================================

  /// Gets answer accuracy as a value from 0.0 to 1.0
  /// Considers both correctness and time taken
  double getAnswerAccuracy({
    required bool isCorrect,
    required int timeLeft,
    required int totalTime,
  }) {
    if (!isCorrect) {
      return 0.0;
    }

    // Correct answer gets base 0.5, plus up to 0.5 based on speed
    final speedFactor = (timeLeft / totalTime).clamp(0.0, 1.0);
    return 0.5 + (speedFactor * 0.5);
  }

  /// Analyzes answer speed and returns classification
  AnswerSpeed analyzeSpeed({
    required int timeLeft,
    required int totalTime,
  }) {
    final timeUsedPercentage = ((totalTime - timeLeft) / totalTime);

    if (timeUsedPercentage < 0.25) {
      return AnswerSpeed.veryFast;
    } else if (timeUsedPercentage < 0.50) {
      return AnswerSpeed.fast;
    } else if (timeUsedPercentage < 0.75) {
      return AnswerSpeed.medium;
    } else if (timeUsedPercentage < 0.90) {
      return AnswerSpeed.slow;
    } else {
      return AnswerSpeed.verySlow;
    }
  }

  /// Gets answer quality classification
  AnswerQuality getAnswerQuality({
    required bool isCorrect,
    required int timeLeft,
    required int totalTime,
  }) {
    if (!isCorrect) {
      return AnswerQuality.incorrect;
    }

    final speed = analyzeSpeed(
      timeLeft: timeLeft,
      totalTime: totalTime,
    );

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

  /// Gets detailed statistics for an answer
  AnswerStatistics getStatistics({
    required bool isCorrect,
    required int timeLeft,
    required int totalTime,
    required int timeTaken,
  }) {
    final accuracy = getAnswerAccuracy(
      isCorrect: isCorrect,
      timeLeft: timeLeft,
      totalTime: totalTime,
    );

    final speed = analyzeSpeed(
      timeLeft: timeLeft,
      totalTime: totalTime,
    );

    final quality = getAnswerQuality(
      isCorrect: isCorrect,
      timeLeft: timeLeft,
      totalTime: totalTime,
    );

    final timePressure = 1.0 - (timeLeft / totalTime).clamp(0.0, 1.0);

    return AnswerStatistics(
      accuracy: accuracy,
      speed: speed,
      quality: quality,
      timeTaken: timeTaken,
      timeLeft: timeLeft,
      totalTime: totalTime,
      timePressure: timePressure,
    );
  }

  // ============================================================================
  // Input Validation
  // ============================================================================

  /// Validates answer input before processing
  AnswerInputValidation validateInput({
    required QuizQuestion question,
    required String selectedAnswer,
    required GameStateEnum gameState,
    required AnswerState currentAnswerState,
  }) {
    final errors = <String>[];

    // Check game state
    if (gameState != GameStateEnum.playing) {
      errors.add('Game is not in playing state');
    }

    // Check if already answered
    if (currentAnswerState != AnswerState.unanswered) {
      errors.add('Question already answered');
    }

    // Check if valid option
    if (!isValidOption(question: question, selectedAnswer: selectedAnswer)) {
      errors.add('Invalid answer option');
    }

    return AnswerInputValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of answer validation
class AnswerValidationResult {
  final bool isCorrect;
  final String selectedAnswer;
  final String correctAnswer;
  final AnswerState answerState;
  final int timeTaken;
  final int timeLeft;
  final double accuracy;

  const AnswerValidationResult({
    required this.isCorrect,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.answerState,
    required this.timeTaken,
    required this.timeLeft,
    required this.accuracy,
  });

  /// Returns the explanation message
  String get message {
    if (isCorrect) {
      return 'Correct answer! Well done!';
    } else {
      return 'Incorrect. The correct answer was: $correctAnswer';
    }
  }
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
        return 'Very Fast';
      case AnswerSpeed.fast:
        return 'Fast';
      case AnswerSpeed.medium:
        return 'Medium';
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
        return 'Excellent!';
      case AnswerQuality.good:
        return 'Good';
      case AnswerQuality.acceptable:
        return 'Acceptable';
      case AnswerQuality.poor:
        return 'Poor';
      case AnswerQuality.incorrect:
        return 'Incorrect';
    }
  }
}

/// Answer statistics
class AnswerStatistics {
  final double accuracy;
  final AnswerSpeed speed;
  final AnswerQuality quality;
  final int timeTaken;
  final int timeLeft;
  final int totalTime;
  final double timePressure;

  const AnswerStatistics({
    required this.accuracy,
    required this.speed,
    required this.quality,
    required this.timeTaken,
    required this.timeLeft,
    required this.totalTime,
    required this.timePressure,
  });

  /// Gets accuracy as percentage (0-100)
  double get accuracyPercentage => accuracy * 100;

  /// Gets time usage as percentage (0-100)
  double get timeUsagePercentage =>
      (timeTaken / totalTime * 100).clamp(0.0, 100.0);
}

/// Input validation result
class AnswerInputValidation {
  final bool isValid;
  final List<String> errors;

  const AnswerInputValidation({
    required this.isValid,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}
