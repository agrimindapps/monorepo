import 'dart:math';


import '../entities/enums.dart';
import '../entities/quiz_question.dart';

/// Service responsible for quiz question management in image quiz
///
/// Handles:
/// - Question selection and shuffling
/// - Question option adjustment based on difficulty
/// - Question progression and navigation
/// - Timer management
/// - Quiz statistics
class QuestionManagerService {
  final Random _random;

  QuestionManagerService({Random? random}) : _random = random ?? Random();

  // ============================================================================
  // Question Selection and Shuffling
  // ============================================================================

  /// Shuffles questions for randomized quiz
  List<QuizQuestion> shuffleQuestions(List<QuizQuestion> questions) {
    final shuffled = List<QuizQuestion>.from(questions);
    shuffled.shuffle(_random);
    return shuffled;
  }

  /// Selects a specific number of random questions from the pool
  List<QuizQuestion> selectQuestions({
    required List<QuizQuestion> allQuestions,
    required int count,
  }) {
    if (count >= allQuestions.length) {
      return allQuestions;
    }

    final shuffled = shuffleQuestions(allQuestions);
    return shuffled.take(count).toList();
  }

  /// Generates game questions with difficulty-based option adjustment
  QuestionGenerationResult generateGameQuestions({
    required List<QuizQuestion> allQuestions,
    required GameDifficulty difficulty,
    int questionsCount = 10,
  }) {
    // Validate we have enough questions
    if (allQuestions.length < questionsCount) {
      return QuestionGenerationResult(
        questions: [],
        success: false,
        errorMessage:
            'Insufficient questions. Need at least $questionsCount, but only ${allQuestions.length} available.',
      );
    }

    // Select random questions
    final selected = selectQuestions(
      allQuestions: allQuestions,
      count: questionsCount,
    );

    // Adjust options based on difficulty
    final adjusted = adjustQuestionsForDifficulty(
      questions: selected,
      difficulty: difficulty,
    );

    return QuestionGenerationResult(
      questions: adjusted,
      success: true,
      errorMessage: null,
    );
  }

  /// Adjusts question options based on difficulty level
  List<QuizQuestion> adjustQuestionsForDifficulty({
    required List<QuizQuestion> questions,
    required GameDifficulty difficulty,
  }) {
    final optionsCount = difficulty.optionsCount;

    return questions.map((question) {
      // If question already has fewer or equal options than required, keep all
      if (question.options.length <= optionsCount) {
        return question;
      }

      // Create adjusted options list
      final adjustedOptions = _createAdjustedOptions(
        question: question,
        targetCount: optionsCount,
      );

      return QuizQuestion(
        id: question.id,
        question: question.question,
        imageUrl: question.imageUrl,
        options: adjustedOptions,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
      );
    }).toList();
  }

  /// Creates adjusted options list for a question
  List<String> _createAdjustedOptions({
    required QuizQuestion question,
    required int targetCount,
  }) {
    // Start with correct answer
    final adjustedOptions = <String>[question.correctAnswer];

    // Get other options (excluding correct answer)
    final otherOptions = question.options
        .where((option) => option != question.correctAnswer)
        .toList();

    // Shuffle and take required number of wrong options
    otherOptions.shuffle(_random);
    adjustedOptions.addAll(otherOptions.take(targetCount - 1));

    // Shuffle final options so correct answer is not always first
    adjustedOptions.shuffle(_random);

    return adjustedOptions;
  }

  // ============================================================================
  // Question Validation
  // ============================================================================

  /// Validates question list
  QuestionListValidation validateQuestions(List<QuizQuestion> questions) {
    final errors = <String>[];

    if (questions.isEmpty) {
      errors.add('Question list cannot be empty');
    }

    // Check for duplicate IDs
    final ids = questions.map((q) => q.id).toList();
    final uniqueIds = ids.toSet();
    if (ids.length != uniqueIds.length) {
      errors.add('Duplicate question IDs found');
    }

    // Validate each question
    for (final question in questions) {
      if (question.options.isEmpty) {
        errors.add('Question ${question.id} has no options');
      }

      if (!question.options.contains(question.correctAnswer)) {
        errors.add('Question ${question.id} correct answer not in options');
      }

      if (question.imageUrl.isEmpty) {
        errors.add('Question ${question.id} has no image URL');
      }
    }

    return QuestionListValidation(
      isValid: errors.isEmpty,
      errors: errors,
      totalQuestions: questions.length,
    );
  }

  // ============================================================================
  // Question Navigation
  // ============================================================================

  /// Checks if there are more questions
  bool hasMoreQuestions({
    required int currentIndex,
    required int totalQuestions,
  }) {
    return currentIndex < totalQuestions - 1;
  }

  /// Gets next question index
  int getNextQuestionIndex(int currentIndex) {
    return currentIndex + 1;
  }

  /// Gets current question
  QuizQuestion? getCurrentQuestion({
    required List<QuizQuestion> questions,
    required int currentIndex,
  }) {
    if (currentIndex >= 0 && currentIndex < questions.length) {
      return questions[currentIndex];
    }
    return null;
  }

  /// Checks if on last question
  bool isLastQuestion({
    required int currentIndex,
    required int totalQuestions,
  }) {
    return currentIndex >= totalQuestions - 1;
  }

  /// Gets progress information
  QuizProgress getProgress({
    required int currentIndex,
    required int totalQuestions,
  }) {
    final questionsCompleted = currentIndex;
    final questionsRemaining = totalQuestions - currentIndex - 1;
    final progressPercentage =
        ((currentIndex + 1) / totalQuestions * 100).clamp(0.0, 100.0);

    return QuizProgress(
      currentQuestionNumber: currentIndex + 1,
      totalQuestions: totalQuestions,
      questionsCompleted: questionsCompleted,
      questionsRemaining: questionsRemaining,
      progressPercentage: progressPercentage,
      isFirstQuestion: currentIndex == 0,
      isLastQuestion: currentIndex == totalQuestions - 1,
    );
  }

  // ============================================================================
  // Timer Management
  // ============================================================================

  /// Gets initial time for question based on difficulty
  int getInitialTime(GameDifficulty difficulty) {
    return difficulty.timeLimit;
  }

  /// Decrements timer by 1 second
  int decrementTimer(int currentTime) {
    return (currentTime - 1).clamp(0, 999);
  }

  /// Checks if time has run out
  bool isTimeUp(int timeLeft) {
    return timeLeft <= 0;
  }

  /// Gets time pressure level (0.0 to 1.0)
  double getTimePressure({
    required int timeLeft,
    required int totalTime,
  }) {
    return 1.0 - (timeLeft / totalTime).clamp(0.0, 1.0);
  }

  /// Checks if time is running low (< 25% remaining)
  bool isTimeLow({
    required int timeLeft,
    required int totalTime,
  }) {
    final percentage = (timeLeft / totalTime);
    return percentage < 0.25;
  }

  /// Checks if time is critical (< 10% remaining)
  bool isTimeCritical({
    required int timeLeft,
    required int totalTime,
  }) {
    final percentage = (timeLeft / totalTime);
    return percentage < 0.10;
  }

  /// Gets timer status
  TimerStatus getTimerStatus({
    required int timeLeft,
    required int totalTime,
  }) {
    final percentage = (timeLeft / totalTime);

    if (timeLeft <= 0) {
      return TimerStatus.expired;
    } else if (percentage < 0.10) {
      return TimerStatus.critical;
    } else if (percentage < 0.25) {
      return TimerStatus.low;
    } else if (percentage < 0.50) {
      return TimerStatus.medium;
    } else {
      return TimerStatus.good;
    }
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets quiz statistics
  QuizStatistics getStatistics({
    required List<QuizQuestion> questions,
    required int currentIndex,
    required int correctAnswers,
  }) {
    final totalQuestions = questions.length;
    final questionsAnswered = currentIndex + 1;
    final incorrectAnswers = questionsAnswered - correctAnswers;
    final accuracy = questionsAnswered > 0
        ? (correctAnswers / questionsAnswered * 100)
        : 0.0;

    return QuizStatistics(
      totalQuestions: totalQuestions,
      currentQuestionIndex: currentIndex,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      questionsAnswered: questionsAnswered,
      accuracy: accuracy,
    );
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Gets remaining questions count
  int getRemainingQuestionsCount({
    required int currentIndex,
    required int totalQuestions,
  }) {
    return (totalQuestions - currentIndex - 1).clamp(0, totalQuestions);
  }

  /// Calculates estimated time remaining (seconds)
  int estimateTimeRemaining({
    required int remainingQuestions,
    required GameDifficulty difficulty,
  }) {
    return remainingQuestions * difficulty.timeLimit;
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of question generation
class QuestionGenerationResult {
  final List<QuizQuestion> questions;
  final bool success;
  final String? errorMessage;

  const QuestionGenerationResult({
    required this.questions,
    required this.success,
    required this.errorMessage,
  });
}

/// Validation result for question list
class QuestionListValidation {
  final bool isValid;
  final List<String> errors;
  final int totalQuestions;

  const QuestionListValidation({
    required this.isValid,
    required this.errors,
    required this.totalQuestions,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Quiz progress information
class QuizProgress {
  final int currentQuestionNumber;
  final int totalQuestions;
  final int questionsCompleted;
  final int questionsRemaining;
  final double progressPercentage;
  final bool isFirstQuestion;
  final bool isLastQuestion;

  const QuizProgress({
    required this.currentQuestionNumber,
    required this.totalQuestions,
    required this.questionsCompleted,
    required this.questionsRemaining,
    required this.progressPercentage,
    required this.isFirstQuestion,
    required this.isLastQuestion,
  });

  /// Gets progress as fraction (0.0 to 1.0)
  double get progressFraction => progressPercentage / 100;
}

/// Timer status classification
enum TimerStatus {
  good,
  medium,
  low,
  critical,
  expired;

  String get label {
    switch (this) {
      case TimerStatus.good:
        return 'Good Time';
      case TimerStatus.medium:
        return 'Time OK';
      case TimerStatus.low:
        return 'Hurry Up!';
      case TimerStatus.critical:
        return 'Almost Out!';
      case TimerStatus.expired:
        return 'Time\'s Up!';
    }
  }
}

/// Quiz statistics
class QuizStatistics {
  final int totalQuestions;
  final int currentQuestionIndex;
  final int correctAnswers;
  final int incorrectAnswers;
  final int questionsAnswered;
  final double accuracy;

  const QuizStatistics({
    required this.totalQuestions,
    required this.currentQuestionIndex,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.questionsAnswered,
    required this.accuracy,
  });

  /// Gets error rate percentage
  double get errorRate => 100 - accuracy;

  /// Checks if perfect score (all correct)
  bool get isPerfect => incorrectAnswers == 0 && questionsAnswered > 0;
}
