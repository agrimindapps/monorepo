import 'package:injectable/injectable.dart';

/// Model representing score calculation result
class ScoreResult {
  /// The score for the current drop
  final int dropScore;

  /// The current combo multiplier
  final int combo;

  /// The total accumulated score
  final int totalScore;

  /// Whether this drop achieved a perfect placement bonus
  final bool isPerfect;

  const ScoreResult({
    required this.dropScore,
    required this.combo,
    required this.totalScore,
    required this.isPerfect,
  });
}

/// Service responsible for score calculation and combo management
///
/// This service handles all scoring mechanics:
/// - Score calculation based on precision
/// - Combo system management
/// - Perfect placement bonuses
/// - Score accumulation
@lazySingleton
class ScoringService {
  /// Base multiplier for score calculation
  static const int baseScoreMultiplier = 10;

  /// Maximum combo multiplier cap
  static const int maxCombo = 100;

  /// Calculates the score for a single block drop
  ///
  /// The score is based on the precision of the placement multiplied
  /// by the current combo. Perfect placements increase the combo,
  /// while imperfect placements reset it.
  ///
  /// [precision] The precision ratio (0.0 to 1.0)
  /// [isPerfect] Whether this placement is perfect (precision >= 0.9)
  /// [currentCombo] The current combo multiplier
  /// [currentTotalScore] The current total score
  ///
  /// Returns a [ScoreResult] with drop score, new combo, and updated total
  ScoreResult calculateScore({
    required double precision,
    required bool isPerfect,
    required int currentCombo,
    required int currentTotalScore,
  }) {
    // Update combo: increment on perfect, reset on imperfect
    final newCombo = _calculateNewCombo(
      isPerfect: isPerfect,
      currentCombo: currentCombo,
    );

    // Calculate score for this drop
    // Formula: (precision * baseMultiplier) * combo
    final precisionScore = (precision * baseScoreMultiplier).round();
    final dropScore = precisionScore * newCombo;

    // Add to total score
    final totalScore = currentTotalScore + dropScore;

    return ScoreResult(
      dropScore: dropScore,
      combo: newCombo,
      totalScore: totalScore,
      isPerfect: isPerfect,
    );
  }

  /// Calculates the new combo multiplier
  ///
  /// Perfect placements increase combo by 1, up to the maximum.
  /// Imperfect placements reset combo to 1.
  ///
  /// [isPerfect] Whether the placement was perfect
  /// [currentCombo] The current combo multiplier
  ///
  /// Returns the updated combo multiplier
  int _calculateNewCombo({
    required bool isPerfect,
    required int currentCombo,
  }) {
    if (isPerfect) {
      // Increment combo but cap at maximum
      return (currentCombo + 1).clamp(1, maxCombo);
    } else {
      // Reset combo to 1 on imperfect placement
      return 1;
    }
  }

  /// Calculates the combo multiplier for the next drop
  ///
  /// This is a public version of the combo calculation for external use.
  ///
  /// [isPerfect] Whether the placement was perfect
  /// [currentCombo] The current combo multiplier
  ///
  /// Returns the updated combo multiplier
  int calculateCombo({
    required bool isPerfect,
    required int currentCombo,
  }) {
    return _calculateNewCombo(
      isPerfect: isPerfect,
      currentCombo: currentCombo,
    );
  }

  /// Calculates only the drop score without updating combo or total
  ///
  /// Useful for previewing what score a placement would give.
  ///
  /// [precision] The precision ratio (0.0 to 1.0)
  /// [combo] The combo multiplier to use
  ///
  /// Returns the calculated drop score
  int calculateDropScore({
    required double precision,
    required int combo,
  }) {
    final precisionScore = (precision * baseScoreMultiplier).round();
    return precisionScore * combo;
  }

  /// Calculates the base precision score without combo multiplier
  ///
  /// [precision] The precision ratio (0.0 to 1.0)
  ///
  /// Returns the base score (0 to baseScoreMultiplier)
  int calculateBasePrecisionScore(double precision) {
    return (precision * baseScoreMultiplier)
        .round()
        .clamp(0, baseScoreMultiplier);
  }

  /// Determines the score tier based on total score
  ///
  /// [totalScore] The accumulated score
  ///
  /// Returns a tier string: 'Lendário', 'Mestre', 'Avançado', 'Intermediário', or 'Iniciante'
  String getScoreTier(int totalScore) {
    if (totalScore >= 1000) {
      return 'Lendário';
    } else if (totalScore >= 500) {
      return 'Mestre';
    } else if (totalScore >= 250) {
      return 'Avançado';
    } else if (totalScore >= 100) {
      return 'Intermediário';
    } else {
      return 'Iniciante';
    }
  }

  /// Checks if the current combo qualifies for a streak bonus
  ///
  /// [combo] The current combo multiplier
  ///
  /// Returns true if combo is at least 5 (hot streak)
  bool hasStreakBonus(int combo) {
    return combo >= 5;
  }

  /// Calculates bonus points for maintaining a streak
  ///
  /// [combo] The current combo multiplier
  ///
  /// Returns bonus points (0 if no streak, or combo * 5 for streaks)
  int calculateStreakBonus(int combo) {
    if (hasStreakBonus(combo)) {
      return combo * 5;
    }
    return 0;
  }

  /// Validates if a score value is valid
  ///
  /// [score] The score to validate
  ///
  /// Returns true if score is non-negative
  bool isValidScore(int score) {
    return score >= 0;
  }

  /// Calculates the percentage of maximum possible score achieved
  ///
  /// This compares the actual score against the theoretical maximum
  /// for a given number of blocks (assuming all perfect placements).
  ///
  /// [actualScore] The score achieved
  /// [blocksPlaced] Number of blocks placed
  ///
  /// Returns the percentage (0 to 100)
  double calculateScoreEfficiency({
    required int actualScore,
    required int blocksPlaced,
  }) {
    if (blocksPlaced == 0) return 0.0;

    // Maximum score is achieved with all perfect placements
    // Each perfect placement gives baseScoreMultiplier * combo
    // Combo increases from 1 to blocksPlaced
    // Sum = baseScoreMultiplier * (1 + 2 + 3 + ... + n)
    // = baseScoreMultiplier * n * (n + 1) / 2
    final maxPossibleScore =
        baseScoreMultiplier * blocksPlaced * (blocksPlaced + 1) ~/ 2;

    if (maxPossibleScore == 0) return 0.0;

    return (actualScore / maxPossibleScore * 100).clamp(0.0, 100.0);
  }

  /// Resets all score values to initial state
  ///
  /// Returns a [ScoreResult] with all values set to zero/initial state
  ScoreResult resetScore() {
    return const ScoreResult(
      dropScore: 0,
      combo: 1, // Combo starts at 1, not 0
      totalScore: 0,
      isPerfect: false,
    );
  }
}
