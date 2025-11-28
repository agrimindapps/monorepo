import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Statistics for a specific Flappy Bird difficulty level
class FlappyDifficultyStats extends Equatable {
  final FlappyDifficulty difficulty;
  final int gamesPlayed;
  final int highScore;
  final int totalScore;
  final int totalPipesPassed;
  final int bestTimeSeconds;

  const FlappyDifficultyStats({
    required this.difficulty,
    this.gamesPlayed = 0,
    this.highScore = 0,
    this.totalScore = 0,
    this.totalPipesPassed = 0,
    this.bestTimeSeconds = 0,
  });

  factory FlappyDifficultyStats.empty(FlappyDifficulty difficulty) {
    return FlappyDifficultyStats(difficulty: difficulty);
  }

  FlappyDifficultyStats copyWith({
    FlappyDifficulty? difficulty,
    int? gamesPlayed,
    int? highScore,
    int? totalScore,
    int? totalPipesPassed,
    int? bestTimeSeconds,
  }) {
    return FlappyDifficultyStats(
      difficulty: difficulty ?? this.difficulty,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      highScore: highScore ?? this.highScore,
      totalScore: totalScore ?? this.totalScore,
      totalPipesPassed: totalPipesPassed ?? this.totalPipesPassed,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
    );
  }

  @override
  List<Object?> get props => [
        difficulty,
        gamesPlayed,
        highScore,
        totalScore,
        totalPipesPassed,
        bestTimeSeconds,
      ];
}

/// Statistics for a specific Flappy Bird game mode
class FlappyGameModeStats extends Equatable {
  final FlappyGameMode gameMode;
  final int gamesPlayed;
  final int highScore;
  final int totalScore;
  final int gamesCompleted; // For Time Attack: survived to end

  const FlappyGameModeStats({
    required this.gameMode,
    this.gamesPlayed = 0,
    this.highScore = 0,
    this.totalScore = 0,
    this.gamesCompleted = 0,
  });

  factory FlappyGameModeStats.empty(FlappyGameMode mode) {
    return FlappyGameModeStats(gameMode: mode);
  }

  FlappyGameModeStats copyWith({
    FlappyGameMode? gameMode,
    int? gamesPlayed,
    int? highScore,
    int? totalScore,
    int? gamesCompleted,
  }) {
    return FlappyGameModeStats(
      gameMode: gameMode ?? this.gameMode,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      highScore: highScore ?? this.highScore,
      totalScore: totalScore ?? this.totalScore,
      gamesCompleted: gamesCompleted ?? this.gamesCompleted,
    );
  }

  @override
  List<Object?> get props => [
        gameMode,
        gamesPlayed,
        highScore,
        totalScore,
        gamesCompleted,
      ];
}

/// Expanded statistics for Flappy Bird achievements
class FlappyStatistics extends Equatable {
  // Per difficulty stats
  final FlappyDifficultyStats easyStats;
  final FlappyDifficultyStats mediumStats;
  final FlappyDifficultyStats hardStats;

  // Per game mode stats
  final FlappyGameModeStats classicStats;
  final FlappyGameModeStats timeAttackStats;
  final FlappyGameModeStats speedRunStats;
  final FlappyGameModeStats nightModeStats;
  final FlappyGameModeStats hardcoreStats;

  // Global stats
  final int totalGamesPlayed;
  final int totalPipesPassed;
  final int totalFlaps;
  final int totalCollisions;
  final int totalSecondsPlayed;
  final int highestScore;
  final int totalScore;
  final int currentStreak; // Partidas com score > 0
  final int bestStreak;
  final int currentStreak5Plus; // Partidas com score >= 5
  final int bestStreak5Plus;
  final int currentStreak10Plus; // Partidas com score >= 10
  final int bestStreak10Plus;
  final int timesBeatenHighScore;
  final int closeCallsCount;
  final int longestFlightSeconds;
  final int powerUpsCollected;
  final int shieldSaves;
  final DateTime? lastPlayedAt;

  const FlappyStatistics({
    required this.easyStats,
    required this.mediumStats,
    required this.hardStats,
    required this.classicStats,
    required this.timeAttackStats,
    required this.speedRunStats,
    required this.nightModeStats,
    required this.hardcoreStats,
    this.totalGamesPlayed = 0,
    this.totalPipesPassed = 0,
    this.totalFlaps = 0,
    this.totalCollisions = 0,
    this.totalSecondsPlayed = 0,
    this.highestScore = 0,
    this.totalScore = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.currentStreak5Plus = 0,
    this.bestStreak5Plus = 0,
    this.currentStreak10Plus = 0,
    this.bestStreak10Plus = 0,
    this.timesBeatenHighScore = 0,
    this.closeCallsCount = 0,
    this.longestFlightSeconds = 0,
    this.powerUpsCollected = 0,
    this.shieldSaves = 0,
    this.lastPlayedAt,
  });

  factory FlappyStatistics.empty() {
    return FlappyStatistics(
      easyStats: FlappyDifficultyStats.empty(FlappyDifficulty.easy),
      mediumStats: FlappyDifficultyStats.empty(FlappyDifficulty.medium),
      hardStats: FlappyDifficultyStats.empty(FlappyDifficulty.hard),
      classicStats: FlappyGameModeStats.empty(FlappyGameMode.classic),
      timeAttackStats: FlappyGameModeStats.empty(FlappyGameMode.timeAttack),
      speedRunStats: FlappyGameModeStats.empty(FlappyGameMode.speedRun),
      nightModeStats: FlappyGameModeStats.empty(FlappyGameMode.nightMode),
      hardcoreStats: FlappyGameModeStats.empty(FlappyGameMode.hardcore),
    );
  }

  /// Get stats for a specific difficulty
  FlappyDifficultyStats getStatsForDifficulty(FlappyDifficulty difficulty) {
    switch (difficulty) {
      case FlappyDifficulty.easy:
        return easyStats;
      case FlappyDifficulty.medium:
        return mediumStats;
      case FlappyDifficulty.hard:
        return hardStats;
    }
  }

  /// Get stats for a specific game mode
  FlappyGameModeStats getStatsForGameMode(FlappyGameMode mode) {
    switch (mode) {
      case FlappyGameMode.classic:
        return classicStats;
      case FlappyGameMode.timeAttack:
        return timeAttackStats;
      case FlappyGameMode.speedRun:
        return speedRunStats;
      case FlappyGameMode.nightMode:
        return nightModeStats;
      case FlappyGameMode.hardcore:
        return hardcoreStats;
    }
  }

  /// Total minutes played
  int get totalMinutesPlayed => totalSecondsPlayed ~/ 60;

  /// Average score per game
  double get averageScore =>
      totalGamesPlayed > 0 ? totalScore / totalGamesPlayed : 0.0;

  FlappyStatistics copyWith({
    FlappyDifficultyStats? easyStats,
    FlappyDifficultyStats? mediumStats,
    FlappyDifficultyStats? hardStats,
    FlappyGameModeStats? classicStats,
    FlappyGameModeStats? timeAttackStats,
    FlappyGameModeStats? speedRunStats,
    FlappyGameModeStats? nightModeStats,
    FlappyGameModeStats? hardcoreStats,
    int? totalGamesPlayed,
    int? totalPipesPassed,
    int? totalFlaps,
    int? totalCollisions,
    int? totalSecondsPlayed,
    int? highestScore,
    int? totalScore,
    int? currentStreak,
    int? bestStreak,
    int? currentStreak5Plus,
    int? bestStreak5Plus,
    int? currentStreak10Plus,
    int? bestStreak10Plus,
    int? timesBeatenHighScore,
    int? closeCallsCount,
    int? longestFlightSeconds,
    int? powerUpsCollected,
    int? shieldSaves,
    DateTime? lastPlayedAt,
  }) {
    return FlappyStatistics(
      easyStats: easyStats ?? this.easyStats,
      mediumStats: mediumStats ?? this.mediumStats,
      hardStats: hardStats ?? this.hardStats,
      classicStats: classicStats ?? this.classicStats,
      timeAttackStats: timeAttackStats ?? this.timeAttackStats,
      speedRunStats: speedRunStats ?? this.speedRunStats,
      nightModeStats: nightModeStats ?? this.nightModeStats,
      hardcoreStats: hardcoreStats ?? this.hardcoreStats,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalPipesPassed: totalPipesPassed ?? this.totalPipesPassed,
      totalFlaps: totalFlaps ?? this.totalFlaps,
      totalCollisions: totalCollisions ?? this.totalCollisions,
      totalSecondsPlayed: totalSecondsPlayed ?? this.totalSecondsPlayed,
      highestScore: highestScore ?? this.highestScore,
      totalScore: totalScore ?? this.totalScore,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      currentStreak5Plus: currentStreak5Plus ?? this.currentStreak5Plus,
      bestStreak5Plus: bestStreak5Plus ?? this.bestStreak5Plus,
      currentStreak10Plus: currentStreak10Plus ?? this.currentStreak10Plus,
      bestStreak10Plus: bestStreak10Plus ?? this.bestStreak10Plus,
      timesBeatenHighScore: timesBeatenHighScore ?? this.timesBeatenHighScore,
      closeCallsCount: closeCallsCount ?? this.closeCallsCount,
      longestFlightSeconds: longestFlightSeconds ?? this.longestFlightSeconds,
      powerUpsCollected: powerUpsCollected ?? this.powerUpsCollected,
      shieldSaves: shieldSaves ?? this.shieldSaves,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
        easyStats,
        mediumStats,
        hardStats,
        classicStats,
        timeAttackStats,
        speedRunStats,
        nightModeStats,
        hardcoreStats,
        totalGamesPlayed,
        totalPipesPassed,
        totalFlaps,
        totalCollisions,
        totalSecondsPlayed,
        highestScore,
        totalScore,
        currentStreak,
        bestStreak,
        currentStreak5Plus,
        bestStreak5Plus,
        currentStreak10Plus,
        bestStreak10Plus,
        timesBeatenHighScore,
        closeCallsCount,
        longestFlightSeconds,
        powerUpsCollected,
        shieldSaves,
        lastPlayedAt,
      ];
}

/// Statistics tracked during a single Flappy Bird game session
class FlappySessionStats extends Equatable {
  final int pipesPassedThisGame;
  final int flapsThisGame;
  final int closeCallsThisGame;
  final int powerUpsCollectedThisGame;
  final int gameTimeSeconds;
  final bool usedShield;
  final bool beatHighScore;
  final DateTime? gameStartedAt;

  const FlappySessionStats({
    this.pipesPassedThisGame = 0,
    this.flapsThisGame = 0,
    this.closeCallsThisGame = 0,
    this.powerUpsCollectedThisGame = 0,
    this.gameTimeSeconds = 0,
    this.usedShield = false,
    this.beatHighScore = false,
    this.gameStartedAt,
  });

  factory FlappySessionStats.empty() => const FlappySessionStats();

  factory FlappySessionStats.started() => FlappySessionStats(
        gameStartedAt: DateTime.now(),
      );

  FlappySessionStats copyWith({
    int? pipesPassedThisGame,
    int? flapsThisGame,
    int? closeCallsThisGame,
    int? powerUpsCollectedThisGame,
    int? gameTimeSeconds,
    bool? usedShield,
    bool? beatHighScore,
    DateTime? gameStartedAt,
  }) {
    return FlappySessionStats(
      pipesPassedThisGame: pipesPassedThisGame ?? this.pipesPassedThisGame,
      flapsThisGame: flapsThisGame ?? this.flapsThisGame,
      closeCallsThisGame: closeCallsThisGame ?? this.closeCallsThisGame,
      powerUpsCollectedThisGame:
          powerUpsCollectedThisGame ?? this.powerUpsCollectedThisGame,
      gameTimeSeconds: gameTimeSeconds ?? this.gameTimeSeconds,
      usedShield: usedShield ?? this.usedShield,
      beatHighScore: beatHighScore ?? this.beatHighScore,
      gameStartedAt: gameStartedAt ?? this.gameStartedAt,
    );
  }

  @override
  List<Object?> get props => [
        pipesPassedThisGame,
        flapsThisGame,
        closeCallsThisGame,
        powerUpsCollectedThisGame,
        gameTimeSeconds,
        usedShield,
        beatHighScore,
        gameStartedAt,
      ];
}
