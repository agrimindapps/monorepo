import 'dart:convert';
import '../../domain/entities/flappy_statistics.dart';
import '../../domain/entities/enums.dart';

/// Data model for Flappy difficulty stats persistence
class FlappyDifficultyStatsModel {
  final String difficulty;
  final int gamesPlayed;
  final int highScore;
  final int totalScore;
  final int totalPipesPassed;
  final int bestTimeSeconds;

  const FlappyDifficultyStatsModel({
    required this.difficulty,
    this.gamesPlayed = 0,
    this.highScore = 0,
    this.totalScore = 0,
    this.totalPipesPassed = 0,
    this.bestTimeSeconds = 0,
  });

  factory FlappyDifficultyStatsModel.fromEntity(FlappyDifficultyStats entity) {
    return FlappyDifficultyStatsModel(
      difficulty: entity.difficulty.name,
      gamesPlayed: entity.gamesPlayed,
      highScore: entity.highScore,
      totalScore: entity.totalScore,
      totalPipesPassed: entity.totalPipesPassed,
      bestTimeSeconds: entity.bestTimeSeconds,
    );
  }

  FlappyDifficultyStats toEntity() {
    return FlappyDifficultyStats(
      difficulty: FlappyDifficulty.values.firstWhere(
        (d) => d.name == difficulty,
        orElse: () => FlappyDifficulty.medium,
      ),
      gamesPlayed: gamesPlayed,
      highScore: highScore,
      totalScore: totalScore,
      totalPipesPassed: totalPipesPassed,
      bestTimeSeconds: bestTimeSeconds,
    );
  }

  factory FlappyDifficultyStatsModel.fromJson(Map<String, dynamic> json) {
    return FlappyDifficultyStatsModel(
      difficulty: json['difficulty'] as String? ?? 'medium',
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      highScore: json['highScore'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      totalPipesPassed: json['totalPipesPassed'] as int? ?? 0,
      bestTimeSeconds: json['bestTimeSeconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'gamesPlayed': gamesPlayed,
      'highScore': highScore,
      'totalScore': totalScore,
      'totalPipesPassed': totalPipesPassed,
      'bestTimeSeconds': bestTimeSeconds,
    };
  }
}

/// Data model for Flappy game mode stats persistence
class FlappyGameModeStatsModel {
  final String gameMode;
  final int gamesPlayed;
  final int highScore;
  final int totalScore;
  final int gamesCompleted;

  const FlappyGameModeStatsModel({
    required this.gameMode,
    this.gamesPlayed = 0,
    this.highScore = 0,
    this.totalScore = 0,
    this.gamesCompleted = 0,
  });

  factory FlappyGameModeStatsModel.fromEntity(FlappyGameModeStats entity) {
    return FlappyGameModeStatsModel(
      gameMode: entity.gameMode.name,
      gamesPlayed: entity.gamesPlayed,
      highScore: entity.highScore,
      totalScore: entity.totalScore,
      gamesCompleted: entity.gamesCompleted,
    );
  }

  FlappyGameModeStats toEntity() {
    return FlappyGameModeStats(
      gameMode: FlappyGameMode.values.firstWhere(
        (m) => m.name == gameMode,
        orElse: () => FlappyGameMode.classic,
      ),
      gamesPlayed: gamesPlayed,
      highScore: highScore,
      totalScore: totalScore,
      gamesCompleted: gamesCompleted,
    );
  }

  factory FlappyGameModeStatsModel.fromJson(Map<String, dynamic> json) {
    return FlappyGameModeStatsModel(
      gameMode: json['gameMode'] as String? ?? 'classic',
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      highScore: json['highScore'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      gamesCompleted: json['gamesCompleted'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameMode': gameMode,
      'gamesPlayed': gamesPlayed,
      'highScore': highScore,
      'totalScore': totalScore,
      'gamesCompleted': gamesCompleted,
    };
  }
}

/// Data model for Flappy statistics persistence
class FlappyStatisticsModel {
  final FlappyDifficultyStatsModel easyStats;
  final FlappyDifficultyStatsModel mediumStats;
  final FlappyDifficultyStatsModel hardStats;
  final FlappyGameModeStatsModel classicStats;
  final FlappyGameModeStatsModel timeAttackStats;
  final FlappyGameModeStatsModel speedRunStats;
  final FlappyGameModeStatsModel nightModeStats;
  final FlappyGameModeStatsModel hardcoreStats;
  final int totalGamesPlayed;
  final int totalPipesPassed;
  final int totalFlaps;
  final int totalCollisions;
  final int totalSecondsPlayed;
  final int highestScore;
  final int totalScore;
  final int currentStreak;
  final int bestStreak;
  final int currentStreak5Plus;
  final int bestStreak5Plus;
  final int currentStreak10Plus;
  final int bestStreak10Plus;
  final int timesBeatenHighScore;
  final int closeCallsCount;
  final int longestFlightSeconds;
  final int powerUpsCollected;
  final int shieldSaves;
  final int? lastPlayedAtTimestamp;

  const FlappyStatisticsModel({
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
    this.lastPlayedAtTimestamp,
  });

  factory FlappyStatisticsModel.empty() {
    return FlappyStatisticsModel(
      easyStats: const FlappyDifficultyStatsModel(difficulty: 'easy'),
      mediumStats: const FlappyDifficultyStatsModel(difficulty: 'medium'),
      hardStats: const FlappyDifficultyStatsModel(difficulty: 'hard'),
      classicStats: const FlappyGameModeStatsModel(gameMode: 'classic'),
      timeAttackStats: const FlappyGameModeStatsModel(gameMode: 'timeAttack'),
      speedRunStats: const FlappyGameModeStatsModel(gameMode: 'speedRun'),
      nightModeStats: const FlappyGameModeStatsModel(gameMode: 'nightMode'),
      hardcoreStats: const FlappyGameModeStatsModel(gameMode: 'hardcore'),
    );
  }

  factory FlappyStatisticsModel.fromEntity(FlappyStatistics entity) {
    return FlappyStatisticsModel(
      easyStats: FlappyDifficultyStatsModel.fromEntity(entity.easyStats),
      mediumStats: FlappyDifficultyStatsModel.fromEntity(entity.mediumStats),
      hardStats: FlappyDifficultyStatsModel.fromEntity(entity.hardStats),
      classicStats: FlappyGameModeStatsModel.fromEntity(entity.classicStats),
      timeAttackStats:
          FlappyGameModeStatsModel.fromEntity(entity.timeAttackStats),
      speedRunStats: FlappyGameModeStatsModel.fromEntity(entity.speedRunStats),
      nightModeStats:
          FlappyGameModeStatsModel.fromEntity(entity.nightModeStats),
      hardcoreStats: FlappyGameModeStatsModel.fromEntity(entity.hardcoreStats),
      totalGamesPlayed: entity.totalGamesPlayed,
      totalPipesPassed: entity.totalPipesPassed,
      totalFlaps: entity.totalFlaps,
      totalCollisions: entity.totalCollisions,
      totalSecondsPlayed: entity.totalSecondsPlayed,
      highestScore: entity.highestScore,
      totalScore: entity.totalScore,
      currentStreak: entity.currentStreak,
      bestStreak: entity.bestStreak,
      currentStreak5Plus: entity.currentStreak5Plus,
      bestStreak5Plus: entity.bestStreak5Plus,
      currentStreak10Plus: entity.currentStreak10Plus,
      bestStreak10Plus: entity.bestStreak10Plus,
      timesBeatenHighScore: entity.timesBeatenHighScore,
      closeCallsCount: entity.closeCallsCount,
      longestFlightSeconds: entity.longestFlightSeconds,
      powerUpsCollected: entity.powerUpsCollected,
      shieldSaves: entity.shieldSaves,
      lastPlayedAtTimestamp: entity.lastPlayedAt?.millisecondsSinceEpoch,
    );
  }

  FlappyStatistics toEntity() {
    return FlappyStatistics(
      easyStats: easyStats.toEntity(),
      mediumStats: mediumStats.toEntity(),
      hardStats: hardStats.toEntity(),
      classicStats: classicStats.toEntity(),
      timeAttackStats: timeAttackStats.toEntity(),
      speedRunStats: speedRunStats.toEntity(),
      nightModeStats: nightModeStats.toEntity(),
      hardcoreStats: hardcoreStats.toEntity(),
      totalGamesPlayed: totalGamesPlayed,
      totalPipesPassed: totalPipesPassed,
      totalFlaps: totalFlaps,
      totalCollisions: totalCollisions,
      totalSecondsPlayed: totalSecondsPlayed,
      highestScore: highestScore,
      totalScore: totalScore,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      currentStreak5Plus: currentStreak5Plus,
      bestStreak5Plus: bestStreak5Plus,
      currentStreak10Plus: currentStreak10Plus,
      bestStreak10Plus: bestStreak10Plus,
      timesBeatenHighScore: timesBeatenHighScore,
      closeCallsCount: closeCallsCount,
      longestFlightSeconds: longestFlightSeconds,
      powerUpsCollected: powerUpsCollected,
      shieldSaves: shieldSaves,
      lastPlayedAt: lastPlayedAtTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(lastPlayedAtTimestamp!)
          : null,
    );
  }

  factory FlappyStatisticsModel.fromJson(Map<String, dynamic> json) {
    return FlappyStatisticsModel(
      easyStats: json['easyStats'] != null
          ? FlappyDifficultyStatsModel.fromJson(
              json['easyStats'] as Map<String, dynamic>)
          : const FlappyDifficultyStatsModel(difficulty: 'easy'),
      mediumStats: json['mediumStats'] != null
          ? FlappyDifficultyStatsModel.fromJson(
              json['mediumStats'] as Map<String, dynamic>)
          : const FlappyDifficultyStatsModel(difficulty: 'medium'),
      hardStats: json['hardStats'] != null
          ? FlappyDifficultyStatsModel.fromJson(
              json['hardStats'] as Map<String, dynamic>)
          : const FlappyDifficultyStatsModel(difficulty: 'hard'),
      classicStats: json['classicStats'] != null
          ? FlappyGameModeStatsModel.fromJson(
              json['classicStats'] as Map<String, dynamic>)
          : const FlappyGameModeStatsModel(gameMode: 'classic'),
      timeAttackStats: json['timeAttackStats'] != null
          ? FlappyGameModeStatsModel.fromJson(
              json['timeAttackStats'] as Map<String, dynamic>)
          : const FlappyGameModeStatsModel(gameMode: 'timeAttack'),
      speedRunStats: json['speedRunStats'] != null
          ? FlappyGameModeStatsModel.fromJson(
              json['speedRunStats'] as Map<String, dynamic>)
          : const FlappyGameModeStatsModel(gameMode: 'speedRun'),
      nightModeStats: json['nightModeStats'] != null
          ? FlappyGameModeStatsModel.fromJson(
              json['nightModeStats'] as Map<String, dynamic>)
          : const FlappyGameModeStatsModel(gameMode: 'nightMode'),
      hardcoreStats: json['hardcoreStats'] != null
          ? FlappyGameModeStatsModel.fromJson(
              json['hardcoreStats'] as Map<String, dynamic>)
          : const FlappyGameModeStatsModel(gameMode: 'hardcore'),
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      totalPipesPassed: json['totalPipesPassed'] as int? ?? 0,
      totalFlaps: json['totalFlaps'] as int? ?? 0,
      totalCollisions: json['totalCollisions'] as int? ?? 0,
      totalSecondsPlayed: json['totalSecondsPlayed'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      currentStreak5Plus: json['currentStreak5Plus'] as int? ?? 0,
      bestStreak5Plus: json['bestStreak5Plus'] as int? ?? 0,
      currentStreak10Plus: json['currentStreak10Plus'] as int? ?? 0,
      bestStreak10Plus: json['bestStreak10Plus'] as int? ?? 0,
      timesBeatenHighScore: json['timesBeatenHighScore'] as int? ?? 0,
      closeCallsCount: json['closeCallsCount'] as int? ?? 0,
      longestFlightSeconds: json['longestFlightSeconds'] as int? ?? 0,
      powerUpsCollected: json['powerUpsCollected'] as int? ?? 0,
      shieldSaves: json['shieldSaves'] as int? ?? 0,
      lastPlayedAtTimestamp: json['lastPlayedAtTimestamp'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'easyStats': easyStats.toJson(),
      'mediumStats': mediumStats.toJson(),
      'hardStats': hardStats.toJson(),
      'classicStats': classicStats.toJson(),
      'timeAttackStats': timeAttackStats.toJson(),
      'speedRunStats': speedRunStats.toJson(),
      'nightModeStats': nightModeStats.toJson(),
      'hardcoreStats': hardcoreStats.toJson(),
      'totalGamesPlayed': totalGamesPlayed,
      'totalPipesPassed': totalPipesPassed,
      'totalFlaps': totalFlaps,
      'totalCollisions': totalCollisions,
      'totalSecondsPlayed': totalSecondsPlayed,
      'highestScore': highestScore,
      'totalScore': totalScore,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'currentStreak5Plus': currentStreak5Plus,
      'bestStreak5Plus': bestStreak5Plus,
      'currentStreak10Plus': currentStreak10Plus,
      'bestStreak10Plus': bestStreak10Plus,
      'timesBeatenHighScore': timesBeatenHighScore,
      'closeCallsCount': closeCallsCount,
      'longestFlightSeconds': longestFlightSeconds,
      'powerUpsCollected': powerUpsCollected,
      'shieldSaves': shieldSaves,
      'lastPlayedAtTimestamp': lastPlayedAtTimestamp,
    };
  }

  factory FlappyStatisticsModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return FlappyStatisticsModel.fromJson(json);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
