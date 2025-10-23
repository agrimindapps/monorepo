// Global game configuration constants

class GameConfig {
  // Grid sizes (for games that use grids)
  static const int defaultGridSize = 4;
  static const int minGridSize = 3;
  static const int maxGridSize = 8;

  // Timing
  static const int defaultTimeLimitSeconds = 60;
  static const int defaultCountdownSeconds = 3;

  // Scoring
  static const int baseScore = 10;
  static const int bonusMultiplier = 2;
  static const int perfectBonusMultiplier = 3;

  // Animation durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 400;
  static const int longAnimationDuration = 800;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultCardElevation = 4.0;

  // Game-specific defaults
  static const int defaultLives = 3;
  static const int defaultMaxScore = 9999999;

  // Storage keys
  static const String highScoreKey = 'high_score';
  static const String settingsKey = 'game_settings';
  static const String statsKey = 'game_stats';
  static const String achievementsKey = 'achievements';

  // Analytics
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Features toggles
  static const bool enableSounds = true;
  static const bool enableVibration = true;
  static const bool enableParticles = true;
}

/// Configurações de dificuldade pré-definidas
class DifficultyConfig {
  final int timeLimit;
  final int lives;
  final double speed;
  final int scoreMultiplier;

  const DifficultyConfig({
    required this.timeLimit,
    required this.lives,
    required this.speed,
    required this.scoreMultiplier,
  });

  static const easy = DifficultyConfig(
    timeLimit: 120,
    lives: 5,
    speed: 1.0,
    scoreMultiplier: 1,
  );

  static const medium = DifficultyConfig(
    timeLimit: 90,
    lives: 3,
    speed: 1.5,
    scoreMultiplier: 2,
  );

  static const hard = DifficultyConfig(
    timeLimit: 60,
    lives: 2,
    speed: 2.0,
    scoreMultiplier: 3,
  );

  static const expert = DifficultyConfig(
    timeLimit: 45,
    lives: 1,
    speed: 3.0,
    scoreMultiplier: 5,
  );
}

/// Cores padrão dos jogos
class GameColors {
  static const primaryColor = 0xFF6200EE;
  static const secondaryColor = 0xFF03DAC6;
  static const backgroundColor = 0xFFF5F5F5;
  static const errorColor = 0xFFB00020;
  static const successColor = 0xFF4CAF50;
  static const warningColor = 0xFFFF9800;
}

/// Assets paths
class GameAssets {
  static const String imagesPath = 'assets/images/';
  static const String soundsPath = 'assets/sounds/';
  static const String fontsPath = 'assets/fonts/';

  // Sounds
  static const String clickSound = '${soundsPath}click.mp3';
  static const String successSound = '${soundsPath}success.mp3';
  static const String errorSound = '${soundsPath}error.mp3';
  static const String gameOverSound = '${soundsPath}game_over.mp3';
  static const String winSound = '${soundsPath}win.mp3';
}
