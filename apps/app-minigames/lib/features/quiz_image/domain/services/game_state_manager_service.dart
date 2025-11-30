
import '../entities/enums.dart';
import '../entities/game_state.dart';

/// Service responsible for game state management in image quiz
///
/// Handles:
/// - Game state transitions (ready/playing/gameOver)
/// - Answer state management (unanswered/correct/incorrect)
/// - Game over detection
/// - State validation
class GameStateManagerService {
  GameStateManagerService();

  // ============================================================================
  // Game State Transitions
  // ============================================================================

  /// Checks if game can start
  bool canStartGame(QuizGameState state) {
    return state.gameState == GameStateEnum.ready && state.questions.isNotEmpty;
  }

  /// Starts the game
  GameStateTransitionResult startGame(QuizGameState currentState) {
    if (!canStartGame(currentState)) {
      return const GameStateTransitionResult(
        success: false,
        errorMessage:
            'Cannot start game. State must be ready and questions must be loaded.',
        newState: GameStateEnum.ready,
      );
    }

    return const GameStateTransitionResult(
      success: true,
      errorMessage: null,
      newState: GameStateEnum.playing,
    );
  }

  /// Ends the game
  GameStateTransitionResult endGame(QuizGameState currentState) {
    return const GameStateTransitionResult(
      success: true,
      errorMessage: null,
      newState: GameStateEnum.gameOver,
    );
  }

  /// Checks if game is in playing state
  bool isPlaying(GameStateEnum gameState) {
    return gameState == GameStateEnum.playing;
  }

  /// Checks if game is ready to start
  bool isReady(GameStateEnum gameState) {
    return gameState == GameStateEnum.ready;
  }

  /// Checks if game is over
  bool isGameOver(GameStateEnum gameState) {
    return gameState == GameStateEnum.gameOver;
  }

  // ============================================================================
  // Answer State Management
  // ============================================================================

  /// Checks if current question is unanswered
  bool isQuestionUnanswered(AnswerState answerState) {
    return answerState == AnswerState.unanswered;
  }

  /// Checks if current question has been answered
  bool isQuestionAnswered(AnswerState answerState) {
    return answerState != AnswerState.unanswered;
  }

  /// Checks if answer was correct
  bool isAnswerCorrect(AnswerState answerState) {
    return answerState == AnswerState.correct;
  }

  /// Checks if answer was incorrect
  bool isAnswerIncorrect(AnswerState answerState) {
    return answerState == AnswerState.incorrect;
  }

  /// Gets the new answer state based on correctness
  AnswerState getAnswerState(bool isCorrect) {
    return isCorrect ? AnswerState.correct : AnswerState.incorrect;
  }

  // ============================================================================
  // Game Over Detection
  // ============================================================================

  /// Determines if game should end (all questions completed)
  bool shouldEndGame({
    required int currentQuestionIndex,
    required int totalQuestions,
    required AnswerState currentAnswerState,
  }) {
    // Game ends if:
    // 1. Current question is the last one
    // 2. Current question has been answered
    final isLastQuestion = currentQuestionIndex >= totalQuestions - 1;
    final hasAnswered = isQuestionAnswered(currentAnswerState);

    return isLastQuestion && hasAnswered;
  }

  /// Gets game over reason
  GameOverReason getGameOverReason({
    required int currentQuestionIndex,
    required int totalQuestions,
  }) {
    if (currentQuestionIndex >= totalQuestions - 1) {
      return GameOverReason.questionsCompleted;
    }
    return GameOverReason.none;
  }

  // ============================================================================
  // State Validation
  // ============================================================================

  /// Validates if answer can be selected
  AnswerSelectionValidation validateAnswerSelection({
    required GameStateEnum gameState,
    required AnswerState currentAnswerState,
  }) {
    final errors = <String>[];

    if (!isPlaying(gameState)) {
      errors.add('Game is not in playing state');
    }

    if (isQuestionAnswered(currentAnswerState)) {
      errors.add('Question already answered');
    }

    return AnswerSelectionValidation(
      canSelect: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validates if timer can be updated
  TimerUpdateValidation validateTimerUpdate({
    required GameStateEnum gameState,
    required AnswerState currentAnswerState,
  }) {
    final errors = <String>[];

    if (!isPlaying(gameState)) {
      errors.add('Game is not in playing state');
    }

    // Timer should not update if question is already answered
    final shouldUpdate = isQuestionUnanswered(currentAnswerState);

    return TimerUpdateValidation(
      shouldUpdate: shouldUpdate && errors.isEmpty,
      errors: errors,
    );
  }

  /// Validates if can proceed to next question
  NextQuestionValidation validateNextQuestion({
    required GameStateEnum gameState,
    required int currentQuestionIndex,
    required int totalQuestions,
  }) {
    final errors = <String>[];

    if (!isPlaying(gameState)) {
      errors.add('Game is not in playing state');
    }

    final hasMoreQuestions = currentQuestionIndex < totalQuestions - 1;

    return NextQuestionValidation(
      canProceed: hasMoreQuestions && errors.isEmpty,
      isLastQuestion: !hasMoreQuestions,
      errors: errors,
    );
  }

  /// Validates if timeout can be handled
  TimeoutValidation validateTimeout({
    required GameStateEnum gameState,
    required AnswerState currentAnswerState,
  }) {
    final errors = <String>[];

    if (!isPlaying(gameState)) {
      errors.add('Game is not in playing state');
    }

    if (isQuestionAnswered(currentAnswerState)) {
      errors.add('Question already answered');
    }

    return TimeoutValidation(
      canHandle: errors.isEmpty,
      errors: errors,
    );
  }

  // ============================================================================
  // Score Management
  // ============================================================================

  /// Updates correct answers count
  int updateCorrectAnswers({
    required int currentCount,
    required bool isCorrect,
  }) {
    return isCorrect ? currentCount + 1 : currentCount;
  }

  /// Calculates score percentage
  double calculateScorePercentage({
    required int correctAnswers,
    required int totalQuestions,
  }) {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions * 100).clamp(0.0, 100.0);
  }

  /// Checks if score is perfect (100%)
  bool isPerfectScore({
    required int correctAnswers,
    required int totalQuestions,
  }) {
    return correctAnswers == totalQuestions && totalQuestions > 0;
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets game statistics
  GameStatistics getStatistics({
    required int correctAnswers,
    required int totalQuestions,
    required int currentQuestionIndex,
  }) {
    final questionsAnswered = currentQuestionIndex + 1;
    final incorrectAnswers = questionsAnswered - correctAnswers;
    final scorePercentage = calculateScorePercentage(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );
    final isPerfect = isPerfectScore(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );

    return GameStatistics(
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      totalQuestions: totalQuestions,
      questionsAnswered: questionsAnswered,
      scorePercentage: scorePercentage,
      isPerfect: isPerfect,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of game state transition
class GameStateTransitionResult {
  final bool success;
  final String? errorMessage;
  final GameStateEnum newState;

  const GameStateTransitionResult({
    required this.success,
    required this.errorMessage,
    required this.newState,
  });
}

/// Game over reason classification
enum GameOverReason {
  none,
  questionsCompleted;

  String get label {
    switch (this) {
      case GameOverReason.none:
        return 'Game In Progress';
      case GameOverReason.questionsCompleted:
        return 'All Questions Completed';
    }
  }
}

/// Answer selection validation result
class AnswerSelectionValidation {
  final bool canSelect;
  final List<String> errors;

  const AnswerSelectionValidation({
    required this.canSelect,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Timer update validation result
class TimerUpdateValidation {
  final bool shouldUpdate;
  final List<String> errors;

  const TimerUpdateValidation({
    required this.shouldUpdate,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Next question validation result
class NextQuestionValidation {
  final bool canProceed;
  final bool isLastQuestion;
  final List<String> errors;

  const NextQuestionValidation({
    required this.canProceed,
    required this.isLastQuestion,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Timeout validation result
class TimeoutValidation {
  final bool canHandle;
  final List<String> errors;

  const TimeoutValidation({
    required this.canHandle,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Game statistics
class GameStatistics {
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalQuestions;
  final int questionsAnswered;
  final double scorePercentage;
  final bool isPerfect;

  const GameStatistics({
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalQuestions,
    required this.questionsAnswered,
    required this.scorePercentage,
    required this.isPerfect,
  });

  /// Gets accuracy as value from 0.0 to 1.0
  double get accuracy => scorePercentage / 100;

  /// Gets incorrect percentage
  double get incorrectPercentage => 100 - scorePercentage;
}
