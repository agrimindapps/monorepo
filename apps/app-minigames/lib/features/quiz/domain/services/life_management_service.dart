
/// Service responsible for game life management and game over conditions
///
/// Handles:
/// - Life deduction logic
/// - Game over detection
/// - Penalty application
/// - Life statistics
class LifeManagementService {
  // ============================================================================
  // Constants
  // ============================================================================

  /// Initial number of lives at game start
  static const int initialLives = 3;

  /// Lives lost per wrong answer
  static const int livesLostPerError = 1;

  /// Lives lost per timeout
  static const int livesLostPerTimeout = 1;

  /// Minimum lives (game over threshold)
  static const int minLives = 0;

  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Deducts lives for incorrect answer
  LifeDeductionResult deductLivesForIncorrectAnswer(int currentLives) {
    final newLives =
        (currentLives - livesLostPerError).clamp(minLives, initialLives);

    return LifeDeductionResult(
      newLives: newLives,
      livesLost: currentLives - newLives,
      reason: LifeLossReason.incorrectAnswer,
      isGameOver: newLives <= minLives,
    );
  }

  /// Deducts lives for timeout
  LifeDeductionResult deductLivesForTimeout(int currentLives) {
    final newLives =
        (currentLives - livesLostPerTimeout).clamp(minLives, initialLives);

    return LifeDeductionResult(
      newLives: newLives,
      livesLost: currentLives - newLives,
      reason: LifeLossReason.timeout,
      isGameOver: newLives <= minLives,
    );
  }

  /// Checks if game is over based on lives
  bool isGameOver(int lives) {
    return lives <= minLives;
  }

  /// Determines game over reason
  GameOverReason determineGameOverReason({
    required int lives,
    required bool hasMoreQuestions,
  }) {
    if (lives <= minLives) {
      return GameOverReason.noLivesLeft;
    } else if (!hasMoreQuestions) {
      return GameOverReason.questionsCompleted;
    }

    return GameOverReason.none; // Game not over
  }

  // ============================================================================
  // Life Status
  // ============================================================================

  /// Gets life status information
  LifeStatus getLifeStatus(int lives) {
    if (lives >= initialLives) {
      return LifeStatus.full;
    } else if (lives >= 2) {
      return LifeStatus.safe;
    } else if (lives == 1) {
      return LifeStatus.danger;
    } else {
      return LifeStatus.dead;
    }
  }

  /// Gets life percentage (0.0 to 1.0)
  double getLifePercentage(int lives) {
    return (lives / initialLives).clamp(0.0, 1.0);
  }

  /// Checks if player is in danger zone (1 life left)
  bool isInDangerZone(int lives) {
    return lives == 1;
  }

  /// Checks if player is safe (2+ lives)
  bool isSafe(int lives) {
    return lives >= 2;
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets life management statistics
  LifeStatistics getStatistics({
    required int currentLives,
    required int totalErrors,
    required int totalTimeouts,
  }) {
    final livesLost = initialLives - currentLives;
    final survivalRate = getLifePercentage(currentLives);
    final status = getLifeStatus(currentLives);

    return LifeStatistics(
      currentLives: currentLives,
      initialLives: initialLives,
      livesLost: livesLost,
      survivalRate: survivalRate,
      status: status,
      totalErrors: totalErrors,
      totalTimeouts: totalTimeouts,
      totalPenalties: totalErrors + totalTimeouts,
    );
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates life count
  LifeValidation validateLives(int lives) {
    final errors = <String>[];

    if (lives < minLives) {
      errors.add('Lives cannot be less than $minLives');
    }

    if (lives > initialLives) {
      errors.add('Lives cannot exceed $initialLives');
    }

    return LifeValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Calculates lives remaining after N errors
  int calculateLivesAfterErrors({
    required int currentLives,
    required int errorCount,
  }) {
    return (currentLives - (errorCount * livesLostPerError))
        .clamp(minLives, initialLives);
  }

  /// Calculates maximum errors allowed before game over
  int getMaxAllowedErrors(int currentLives) {
    return currentLives ~/ livesLostPerError;
  }

  /// Gets warning level based on lives
  WarningLevel getWarningLevel(int lives) {
    if (lives <= 0) {
      return WarningLevel.critical;
    } else if (lives == 1) {
      return WarningLevel.high;
    } else if (lives == 2) {
      return WarningLevel.medium;
    } else {
      return WarningLevel.low;
    }
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of life deduction
class LifeDeductionResult {
  final int newLives;
  final int livesLost;
  final LifeLossReason reason;
  final bool isGameOver;

  const LifeDeductionResult({
    required this.newLives,
    required this.livesLost,
    required this.reason,
    required this.isGameOver,
  });
}

/// Reason for losing lives
enum LifeLossReason {
  incorrectAnswer,
  timeout;

  String get label {
    switch (this) {
      case LifeLossReason.incorrectAnswer:
        return 'Incorrect Answer';
      case LifeLossReason.timeout:
        return 'Time Out';
    }
  }
}

/// Reason for game over
enum GameOverReason {
  none,
  noLivesLeft,
  questionsCompleted;

  String get label {
    switch (this) {
      case GameOverReason.none:
        return 'Game Active';
      case GameOverReason.noLivesLeft:
        return 'No Lives Left';
      case GameOverReason.questionsCompleted:
        return 'All Questions Completed';
    }
  }

  bool get isGameOver => this != GameOverReason.none;
}

/// Life status classification
enum LifeStatus {
  full,
  safe,
  danger,
  dead;

  String get label {
    switch (this) {
      case LifeStatus.full:
        return 'Full Health';
      case LifeStatus.safe:
        return 'Safe';
      case LifeStatus.danger:
        return 'Danger!';
      case LifeStatus.dead:
        return 'Game Over';
    }
  }
}

/// Statistics about life management
class LifeStatistics {
  final int currentLives;
  final int initialLives;
  final int livesLost;
  final double survivalRate;
  final LifeStatus status;
  final int totalErrors;
  final int totalTimeouts;
  final int totalPenalties;

  const LifeStatistics({
    required this.currentLives,
    required this.initialLives,
    required this.livesLost,
    required this.survivalRate,
    required this.status,
    required this.totalErrors,
    required this.totalTimeouts,
    required this.totalPenalties,
  });

  /// Gets survival percentage (0-100)
  double get survivalPercentage => survivalRate * 100;
}

/// Validation result for lives
class LifeValidation {
  final bool isValid;
  final List<String> errors;

  const LifeValidation({
    required this.isValid,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Warning level based on lives
enum WarningLevel {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case WarningLevel.low:
        return 'All Good';
      case WarningLevel.medium:
        return 'Be Careful';
      case WarningLevel.high:
        return 'Last Chance!';
      case WarningLevel.critical:
        return 'Game Over';
    }
  }
}
