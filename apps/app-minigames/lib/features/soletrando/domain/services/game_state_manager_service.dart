import 'package:injectable/injectable.dart';

import '../entities/enums.dart';
import '../entities/game_state_entity.dart';

/// Service responsible for game state management
///
/// Handles:
/// - Game status transitions
/// - Mistake tracking and game over detection
/// - Word completion detection
/// - Game validation
/// - Statistics
@lazySingleton
class GameStateManagerService {
  GameStateManagerService();

  // ============================================================================
  // Game Status Management
  // ============================================================================

  /// Checks if game is active (can accept inputs)
  bool isGameActive(GameStatus status) {
    return status == GameStatus.playing;
  }

  /// Checks if game is over (any end state)
  bool isGameOver(GameStatus status) {
    return status == GameStatus.gameOver ||
        status == GameStatus.timeUp ||
        status == GameStatus.error;
  }

  /// Checks if word is completed
  bool isWordCompleted(GameStatus status) {
    return status == GameStatus.wordCompleted;
  }

  /// Checks if game can continue (active or word completed)
  bool canContinuePlaying(GameStatus status) {
    return isGameActive(status) || isWordCompleted(status);
  }

  // ============================================================================
  // Mistake Management
  // ============================================================================

  /// Increments mistake count
  int incrementMistakes(int currentMistakes) {
    return currentMistakes + 1;
  }

  /// Checks if game over due to mistakes
  bool isGameOverByMistakes({
    required int mistakes,
    required int maxMistakes,
  }) {
    return mistakes >= maxMistakes;
  }

  /// Gets new game status after mistake
  GameStatus getStatusAfterMistake({
    required int newMistakes,
    required int maxMistakes,
    required GameStatus currentStatus,
  }) {
    if (isGameOverByMistakes(mistakes: newMistakes, maxMistakes: maxMistakes)) {
      return GameStatus.gameOver;
    }
    return currentStatus;
  }

  /// Gets mistake result
  MistakeResult processMistake({
    required int currentMistakes,
    required int maxMistakes,
    required GameStatus currentStatus,
  }) {
    final newMistakes = incrementMistakes(currentMistakes);
    final newStatus = getStatusAfterMistake(
      newMistakes: newMistakes,
      maxMistakes: maxMistakes,
      currentStatus: currentStatus,
    );
    final isGameOver = isGameOverByMistakes(
      mistakes: newMistakes,
      maxMistakes: maxMistakes,
    );

    return MistakeResult(
      newMistakes: newMistakes,
      newStatus: newStatus,
      isGameOver: isGameOver,
      mistakesRemaining: maxMistakes - newMistakes,
    );
  }

  // ============================================================================
  // Word Completion Detection
  // ============================================================================

  /// Checks if all letters are revealed
  bool areAllLettersRevealed({
    required int revealedCount,
    required int totalLetters,
  }) {
    return revealedCount >= totalLetters && totalLetters > 0;
  }

  /// Gets status for word completion
  GameStatus getStatusForWordCompletion() {
    return GameStatus.wordCompleted;
  }

  /// Increments words completed count
  int incrementWordsCompleted(int currentCount) {
    return currentCount + 1;
  }

  /// Gets word completion result
  WordCompletionResult processWordCompletion({
    required int currentWordsCompleted,
  }) {
    final newWordsCompleted = incrementWordsCompleted(currentWordsCompleted);
    final newStatus = getStatusForWordCompletion();

    return WordCompletionResult(
      newWordsCompleted: newWordsCompleted,
      newStatus: newStatus,
      isFirstWord: newWordsCompleted == 1,
    );
  }

  // ============================================================================
  // Time Management
  // ============================================================================

  /// Checks if time is up
  bool isTimeUp(int timeRemaining) {
    return timeRemaining <= 0;
  }

  /// Checks if time is critical (≤10 seconds)
  bool isCriticalTime(int timeRemaining) {
    return timeRemaining <= 10 && timeRemaining > 0;
  }

  /// Gets time status
  TimeStatus getTimeStatus({
    required int timeRemaining,
    required int totalTime,
  }) {
    if (timeRemaining <= 0) {
      return TimeStatus.expired;
    }

    final percentage = timeRemaining / totalTime;

    if (percentage <= 0.15) {
      return TimeStatus.critical;
    } else if (percentage <= 0.35) {
      return TimeStatus.low;
    } else if (percentage <= 0.60) {
      return TimeStatus.medium;
    } else {
      return TimeStatus.good;
    }
  }

  /// Gets status for time up
  GameStatus getStatusForTimeUp() {
    return GameStatus.timeUp;
  }

  // ============================================================================
  // Game Validation
  // ============================================================================

  /// Validates game can accept letter input
  GameInputValidation validateLetterInput(GameStateEntity state) {
    final errors = <String>[];

    if (!isGameActive(state.status)) {
      errors.add('Jogo não está ativo');
    }

    return GameInputValidation(
      canAcceptInput: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validates hint can be used
  HintUsageValidation validateHintUsage(GameStateEntity state) {
    final errors = <String>[];

    if (!isGameActive(state.status)) {
      errors.add('Jogo não está ativo');
    }

    if (!state.canUseHint) {
      errors.add('Sem dicas disponíveis');
    }

    return HintUsageValidation(
      canUse: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validates word can be skipped
  WordSkipValidation validateWordSkip(GameStateEntity state) {
    final errors = <String>[];

    if (!isGameActive(state.status)) {
      errors.add('Jogo não está ativo');
    }

    return WordSkipValidation(
      canSkip: errors.isEmpty,
      errors: errors,
    );
  }

  // ============================================================================
  // Progress Tracking
  // ============================================================================

  /// Gets game progress information
  GameProgress getProgress({
    required int revealedLetters,
    required int totalLetters,
    required int mistakes,
    required int maxMistakes,
    required int timeRemaining,
    required int totalTime,
  }) {
    final letterProgress =
        totalLetters > 0 ? revealedLetters / totalLetters : 0.0;
    final mistakeProgress = maxMistakes > 0 ? mistakes / maxMistakes : 0.0;
    final timeProgress = totalTime > 0 ? timeRemaining / totalTime : 0.0;

    return GameProgress(
      letterProgress: letterProgress,
      mistakeProgress: mistakeProgress,
      timeProgress: timeProgress,
      revealedLetters: revealedLetters,
      totalLetters: totalLetters,
      mistakes: mistakes,
      maxMistakes: maxMistakes,
      timeRemaining: timeRemaining,
    );
  }

  /// Checks if game is in danger (high mistakes or low time)
  bool isGameInDanger({
    required int mistakes,
    required int maxMistakes,
    required int timeRemaining,
    required int totalTime,
  }) {
    final mistakePercentage = mistakes / maxMistakes;
    final timePercentage = timeRemaining / totalTime;

    return mistakePercentage >= 0.7 || timePercentage <= 0.2;
  }

  // ============================================================================
  // Difficulty Assessment
  // ============================================================================

  /// Gets current difficulty level based on game state
  DifficultyLevel getCurrentDifficultyLevel({
    required GameDifficulty difficulty,
    required int mistakes,
    required int timeRemaining,
  }) {
    if (difficulty == GameDifficulty.hard) {
      return DifficultyLevel.veryHard;
    } else if (difficulty == GameDifficulty.medium) {
      if (mistakes >= 2 || timeRemaining <= 20) {
        return DifficultyLevel.hard;
      }
      return DifficultyLevel.medium;
    } else {
      if (mistakes >= 4 || timeRemaining <= 30) {
        return DifficultyLevel.medium;
      }
      return DifficultyLevel.easy;
    }
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets comprehensive game statistics
  GameStatistics getStatistics({
    required GameStateEntity state,
    required int totalGuesses,
  }) {
    final progress = getProgress(
      revealedLetters: state.correctLetters,
      totalLetters: state.letters.length,
      mistakes: state.mistakes,
      maxMistakes: state.difficulty.mistakesAllowed,
      timeRemaining: state.timeRemaining,
      totalTime: state.difficulty.timeInSeconds,
    );

    final timeStatus = getTimeStatus(
      timeRemaining: state.timeRemaining,
      totalTime: state.difficulty.timeInSeconds,
    );

    final inDanger = isGameInDanger(
      mistakes: state.mistakes,
      maxMistakes: state.difficulty.mistakesAllowed,
      timeRemaining: state.timeRemaining,
      totalTime: state.difficulty.timeInSeconds,
    );

    final accuracy = totalGuesses > 0
        ? (state.guessedLetters.length - state.mistakes) / totalGuesses
        : 0.0;

    return GameStatistics(
      score: state.score,
      wordsCompleted: state.wordsCompleted,
      mistakes: state.mistakes,
      hintsUsed: state.hintsUsed,
      progress: progress,
      timeStatus: timeStatus,
      inDanger: inDanger,
      accuracy: accuracy,
      status: state.status,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Mistake processing result
class MistakeResult {
  final int newMistakes;
  final GameStatus newStatus;
  final bool isGameOver;
  final int mistakesRemaining;

  const MistakeResult({
    required this.newMistakes,
    required this.newStatus,
    required this.isGameOver,
    required this.mistakesRemaining,
  });

  /// Checks if in danger zone (1 mistake remaining)
  bool get isInDangerZone => mistakesRemaining == 1;

  /// Gets warning message
  String get warningMessage {
    if (isGameOver) {
      return 'Game Over! Sem mais tentativas';
    } else if (isInDangerZone) {
      return 'Cuidado! Última tentativa';
    } else {
      return '$mistakesRemaining tentativas restantes';
    }
  }
}

/// Word completion result
class WordCompletionResult {
  final int newWordsCompleted;
  final GameStatus newStatus;
  final bool isFirstWord;

  const WordCompletionResult({
    required this.newWordsCompleted,
    required this.newStatus,
    required this.isFirstWord,
  });

  /// Gets completion message
  String get message {
    if (isFirstWord) {
      return 'Primeira palavra completada!';
    }
    return 'Palavra $newWordsCompleted completada!';
  }
}

/// Time status classification
enum TimeStatus {
  good,
  medium,
  low,
  critical,
  expired;

  String get label {
    switch (this) {
      case TimeStatus.good:
        return 'Tempo Bom';
      case TimeStatus.medium:
        return 'Tempo OK';
      case TimeStatus.low:
        return 'Tempo Baixo';
      case TimeStatus.critical:
        return 'Tempo Crítico!';
      case TimeStatus.expired:
        return 'Tempo Esgotado';
    }
  }

  String get emoji {
    switch (this) {
      case TimeStatus.good:
        return '✅';
      case TimeStatus.medium:
        return '⏱️';
      case TimeStatus.low:
        return '⚠️';
      case TimeStatus.critical:
        return '🔴';
      case TimeStatus.expired:
        return '❌';
    }
  }
}

/// Difficulty level assessment
enum DifficultyLevel {
  easy,
  medium,
  hard,
  veryHard;

  String get label {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Fácil';
      case DifficultyLevel.medium:
        return 'Médio';
      case DifficultyLevel.hard:
        return 'Difícil';
      case DifficultyLevel.veryHard:
        return 'Muito Difícil';
    }
  }
}

/// Game input validation
class GameInputValidation {
  final bool canAcceptInput;
  final List<String> errors;

  const GameInputValidation({
    required this.canAcceptInput,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Hint usage validation
class HintUsageValidation {
  final bool canUse;
  final List<String> errors;

  const HintUsageValidation({
    required this.canUse,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Word skip validation
class WordSkipValidation {
  final bool canSkip;
  final List<String> errors;

  const WordSkipValidation({
    required this.canSkip,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Game progress information
class GameProgress {
  final double letterProgress;
  final double mistakeProgress;
  final double timeProgress;
  final int revealedLetters;
  final int totalLetters;
  final int mistakes;
  final int maxMistakes;
  final int timeRemaining;

  const GameProgress({
    required this.letterProgress,
    required this.mistakeProgress,
    required this.timeProgress,
    required this.revealedLetters,
    required this.totalLetters,
    required this.mistakes,
    required this.maxMistakes,
    required this.timeRemaining,
  });

  /// Gets letter progress as percentage
  double get letterProgressPercentage => letterProgress * 100;

  /// Gets mistake progress as percentage
  double get mistakeProgressPercentage => mistakeProgress * 100;

  /// Gets time progress as percentage
  double get timeProgressPercentage => timeProgress * 100;

  /// Checks if word is complete
  bool get isComplete => revealedLetters == totalLetters;
}

/// Comprehensive game statistics
class GameStatistics {
  final int score;
  final int wordsCompleted;
  final int mistakes;
  final int hintsUsed;
  final GameProgress progress;
  final TimeStatus timeStatus;
  final bool inDanger;
  final double accuracy;
  final GameStatus status;

  const GameStatistics({
    required this.score,
    required this.wordsCompleted,
    required this.mistakes,
    required this.hintsUsed,
    required this.progress,
    required this.timeStatus,
    required this.inDanger,
    required this.accuracy,
    required this.status,
  });

  /// Gets accuracy as percentage
  double get accuracyPercentage => accuracy * 100;

  /// Checks if performance is good (>80% accuracy)
  bool get isGoodPerformance => accuracy >= 0.8;
}
