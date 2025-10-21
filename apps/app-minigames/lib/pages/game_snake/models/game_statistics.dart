// Dart imports:
import 'dart:convert';

/**
 * Classe que representa as estatísticas detalhadas do jogo da cobra
 * 
 * Rastreia informações como:
 * - Total de jogos jogados
 * - Tempo total jogado
 * - Total de comida consumida
 * - Pontuação média
 * - Melhor sequência
 * - Estatísticas por tipo de comida
 */
class GameStatistics {
  final int totalGamesPlayed;
  final int totalTimePlayedSeconds;
  final int totalFoodEaten;
  final double averageScore;
  final int bestScore;
  final int bestStreak;
  final int longestSnake;
  final Map<String, int> foodTypeStats;
  final DateTime lastPlayedDate;
  final int totalSessionsToday;

  GameStatistics({
    this.totalGamesPlayed = 0,
    this.totalTimePlayedSeconds = 0,
    this.totalFoodEaten = 0,
    this.averageScore = 0.0,
    this.bestScore = 0,
    this.bestStreak = 0,
    this.longestSnake = 0,
    this.foodTypeStats = const {},
    DateTime? lastPlayedDate,
    this.totalSessionsToday = 0,
  }) : lastPlayedDate = lastPlayedDate ?? DateTime.now();

  /// Cria estatísticas vazias/iniciais
  GameStatistics.empty() : this();

  /// Cria uma nova instância com valores atualizados
  GameStatistics copyWith({
    int? totalGamesPlayed,
    int? totalTimePlayedSeconds,
    int? totalFoodEaten,
    double? averageScore,
    int? bestScore,
    int? bestStreak,
    int? longestSnake,
    Map<String, int>? foodTypeStats,
    DateTime? lastPlayedDate,
    int? totalSessionsToday,
  }) {
    return GameStatistics(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalTimePlayedSeconds: totalTimePlayedSeconds ?? this.totalTimePlayedSeconds,
      totalFoodEaten: totalFoodEaten ?? this.totalFoodEaten,
      averageScore: averageScore ?? this.averageScore,
      bestScore: bestScore ?? this.bestScore,
      bestStreak: bestStreak ?? this.bestStreak,
      longestSnake: longestSnake ?? this.longestSnake,
      foodTypeStats: foodTypeStats ?? Map.from(this.foodTypeStats),
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      totalSessionsToday: totalSessionsToday ?? this.totalSessionsToday,
    );
  }

  /// Atualiza estatísticas após uma partida
  GameStatistics updateAfterGame({
    required int gameScore,
    required int gameDurationSeconds,
    required int foodConsumed,
    required int snakeLength,
    required Map<String, int> foodTypesConsumed,
  }) {
    final newTotalGames = totalGamesPlayed + 1;
    final newTotalTime = totalTimePlayedSeconds + gameDurationSeconds;
    final newTotalFood = totalFoodEaten + foodConsumed;
    final newAverageScore = (totalGamesPlayed * averageScore + gameScore) / newTotalGames;
    final newBestScore = gameScore > bestScore ? gameScore : bestScore;
    final newLongestSnake = snakeLength > longestSnake ? snakeLength : longestSnake;
    
    // Atualiza estatísticas por tipo de comida
    final newFoodTypeStats = Map<String, int>.from(foodTypeStats);
    foodTypesConsumed.forEach((type, count) {
      newFoodTypeStats[type] = (newFoodTypeStats[type] ?? 0) + count;
    });

    // Verifica se é hoje para contagem de sessões diárias
    final now = DateTime.now();
    final isToday = now.year == lastPlayedDate.year &&
                   now.month == lastPlayedDate.month &&
                   now.day == lastPlayedDate.day;
    
    final newSessionsToday = isToday ? totalSessionsToday + 1 : 1;

    return copyWith(
      totalGamesPlayed: newTotalGames,
      totalTimePlayedSeconds: newTotalTime,
      totalFoodEaten: newTotalFood,
      averageScore: newAverageScore,
      bestScore: newBestScore,
      longestSnake: newLongestSnake,
      foodTypeStats: newFoodTypeStats,
      lastPlayedDate: now,
      totalSessionsToday: newSessionsToday,
    );
  }

  /// Calcula o tempo total jogado formatado
  String get formattedTotalTime {
    final hours = totalTimePlayedSeconds ~/ 3600;
    final minutes = (totalTimePlayedSeconds % 3600) ~/ 60;
    final seconds = totalTimePlayedSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Calcula o tempo médio por partida
  String get averageGameDuration {
    if (totalGamesPlayed == 0) return '0s';
    
    final avgSeconds = totalTimePlayedSeconds / totalGamesPlayed;
    final minutes = avgSeconds ~/ 60;
    final seconds = (avgSeconds % 60).round();
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Retorna o tipo de comida mais consumido
  String get favoriteFoodType {
    if (foodTypeStats.isEmpty) return 'Normal';
    
    return foodTypeStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Retorna taxa de eficiência (comida por jogo)
  double get efficiency {
    if (totalGamesPlayed == 0) return 0.0;
    return totalFoodEaten / totalGamesPlayed;
  }

  /// Serializa para JSON
  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalTimePlayedSeconds': totalTimePlayedSeconds,
      'totalFoodEaten': totalFoodEaten,
      'averageScore': averageScore,
      'bestScore': bestScore,
      'bestStreak': bestStreak,
      'longestSnake': longestSnake,
      'foodTypeStats': foodTypeStats,
      'lastPlayedDate': lastPlayedDate.toIso8601String(),
      'totalSessionsToday': totalSessionsToday,
    };
  }

  /// Cria instância a partir de JSON
  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    return GameStatistics(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalTimePlayedSeconds: json['totalTimePlayedSeconds'] ?? 0,
      totalFoodEaten: json['totalFoodEaten'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      bestScore: json['bestScore'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      longestSnake: json['longestSnake'] ?? 0,
      foodTypeStats: Map<String, int>.from(json['foodTypeStats'] ?? {}),
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'])
          : DateTime.now(),
      totalSessionsToday: json['totalSessionsToday'] ?? 0,
    );
  }

  /// Serializa para String JSON
  String toJsonString() => jsonEncode(toJson());

  /// Cria instância a partir de String JSON
  factory GameStatistics.fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return GameStatistics.fromJson(json);
    } catch (e) {
      // Retorna estatísticas vazias se houver erro na deserialização
      return GameStatistics.empty();
    }
  }

  @override
  String toString() {
    return 'GameStatistics('
           'games: $totalGamesPlayed, '
           'time: $formattedTotalTime, '
           'food: $totalFoodEaten, '
           'avg: ${averageScore.toStringAsFixed(1)}, '
           'best: $bestScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameStatistics &&
           other.totalGamesPlayed == totalGamesPlayed &&
           other.totalTimePlayedSeconds == totalTimePlayedSeconds &&
           other.totalFoodEaten == totalFoodEaten &&
           other.averageScore == averageScore &&
           other.bestScore == bestScore &&
           other.bestStreak == bestStreak &&
           other.longestSnake == longestSnake;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalGamesPlayed,
      totalTimePlayedSeconds,
      totalFoodEaten,
      averageScore,
      bestScore,
      bestStreak,
      longestSnake,
    );
  }
}
