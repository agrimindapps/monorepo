// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing player level and XP progression
class PlayerLevel extends Equatable {
  final int totalXp;

  const PlayerLevel({this.totalXp = 0});

  /// Empty player level
  factory PlayerLevel.empty() => const PlayerLevel();

  /// XP thresholds for each level (exponential progression)
  static const Map<int, int> levelThresholds = {
    1: 0,
    2: 100,
    3: 250,
    4: 450,
    5: 700,
    6: 1000,
    7: 1400,
    8: 1900,
    9: 2500,
    10: 3200,
    11: 4000,
    12: 4900,
    13: 5900,
    14: 7000,
    15: 8200,
    16: 9500,
    17: 10900,
    18: 12400,
    19: 14000,
    20: 15700,
    21: 17500,
    22: 19400,
    23: 21400,
    24: 23500,
    25: 25700,
    26: 28000,
    27: 30400,
    28: 32900,
    29: 35500,
    30: 38200,
    31: 41000,
    32: 43900,
    33: 46900,
    34: 50000,
    35: 53200,
    36: 56500,
    37: 59900,
    38: 63400,
    39: 67000,
    40: 70700,
    41: 74500,
    42: 78400,
    43: 82400,
    44: 86500,
    45: 90700,
    46: 95000,
    47: 99400,
    48: 103900,
    49: 108500,
    50: 113200,
  };

  /// Level titles
  static const Map<int, String> levelTitles = {
    1: 'Novato',
    5: 'Aprendiz',
    10: 'Jogador',
    15: 'Experiente',
    20: 'Veterano',
    25: 'Expert',
    30: 'Mestre',
    35: 'Grão-Mestre',
    40: 'Lenda',
    45: 'Mítico',
    50: 'Deus das Cobras',
  };

  /// Get current level based on total XP
  int get currentLevel {
    int level = 1;
    for (final entry in levelThresholds.entries) {
      if (totalXp >= entry.value) {
        level = entry.key;
      } else {
        break;
      }
    }
    return level;
  }

  /// Get title for current level
  String get title {
    int titleLevel = 1;
    for (final entry in levelTitles.entries) {
      if (currentLevel >= entry.key) {
        titleLevel = entry.key;
      }
    }
    return levelTitles[titleLevel] ?? 'Novato';
  }

  /// Get XP required to reach next level
  int get xpForNextLevel {
    final nextLevel = currentLevel + 1;
    if (nextLevel > 50) return 0;
    return levelThresholds[nextLevel] ?? 0;
  }

  /// Get XP at start of current level
  int get xpAtCurrentLevel => levelThresholds[currentLevel] ?? 0;

  /// Get XP progress within current level
  int get xpInCurrentLevel => totalXp - xpAtCurrentLevel;

  /// Get XP needed to level up from current level
  int get xpNeededForLevelUp => xpForNextLevel - xpAtCurrentLevel;

  /// Get level progress as percentage (0.0 to 1.0)
  double get levelProgressPercent {
    if (currentLevel >= 50) return 1.0;
    if (xpNeededForLevelUp <= 0) return 1.0;
    return xpInCurrentLevel / xpNeededForLevelUp;
  }

  /// Check if max level reached
  bool get isMaxLevel => currentLevel >= 50;

  /// Calculate XP for a game
  static int calculateXpForGame({
    required int score,
    required int snakeLength,
    required int survivalSeconds,
    required String difficulty,
    required int powerUpsCollected,
  }) {
    int baseXp = score * 2;
    int lengthBonus = snakeLength * 5;
    int survivalBonus = survivalSeconds ~/ 10;
    int powerUpBonus = powerUpsCollected * 10;

    double difficultyMultiplier = switch (difficulty) {
      'easy' => 1.0,
      'medium' => 1.5,
      'hard' => 2.0,
      _ => 1.0,
    };

    return ((baseXp + lengthBonus + survivalBonus + powerUpBonus) *
            difficultyMultiplier)
        .round();
  }

  /// Create a copy with modified fields
  PlayerLevel copyWith({int? totalXp}) {
    return PlayerLevel(totalXp: totalXp ?? this.totalXp);
  }

  /// Add XP and return new level (returns tuple of new level and whether leveled up)
  (PlayerLevel, bool) addXp(int xp) {
    final oldLevel = currentLevel;
    final newPlayerLevel = copyWith(totalXp: totalXp + xp);
    final leveledUp = newPlayerLevel.currentLevel > oldLevel;
    return (newPlayerLevel, leveledUp);
  }

  @override
  List<Object?> get props => [totalXp];
}
