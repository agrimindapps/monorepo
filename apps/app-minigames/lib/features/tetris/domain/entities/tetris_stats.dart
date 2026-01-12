import 'package:equatable/equatable.dart';

/// Entidade que representa estatísticas gerais do Tetris
class TetrisStats extends Equatable {
  /// Total de jogos completos
  final int totalGames;
  
  /// Pontuação total acumulada
  final int totalScore;
  
  /// Total de linhas completadas
  final int totalLines;
  
  /// Maior pontuação alcançada
  final int highestScore;
  
  /// Maior número de linhas em uma partida
  final int highestLines;
  
  /// Maior nível alcançado
  final int highestLevel;
  
  /// Tempo total jogado
  final Duration totalPlayTime;
  
  /// Última vez que jogou
  final DateTime? lastPlayedAt;
  
  /// Total de Tetris (4 linhas de uma vez)
  final int tetrisCount;
  
  /// Maior combo de Tetris consecutivos
  final int maxTetrisCombo;

  const TetrisStats({
    this.totalGames = 0,
    this.totalScore = 0,
    this.totalLines = 0,
    this.highestScore = 0,
    this.highestLines = 0,
    this.highestLevel = 0,
    this.totalPlayTime = Duration.zero,
    this.lastPlayedAt,
    this.tetrisCount = 0,
    this.maxTetrisCombo = 0,
  });

  /// Factory para stats vazias (primeiro uso)
  factory TetrisStats.empty() {
    return const TetrisStats();
  }

  /// Cria cópia com campos modificados
  TetrisStats copyWith({
    int? totalGames,
    int? totalScore,
    int? totalLines,
    int? highestScore,
    int? highestLines,
    int? highestLevel,
    Duration? totalPlayTime,
    DateTime? lastPlayedAt,
    int? tetrisCount,
    int? maxTetrisCombo,
  }) {
    return TetrisStats(
      totalGames: totalGames ?? this.totalGames,
      totalScore: totalScore ?? this.totalScore,
      totalLines: totalLines ?? this.totalLines,
      highestScore: highestScore ?? this.highestScore,
      highestLines: highestLines ?? this.highestLines,
      highestLevel: highestLevel ?? this.highestLevel,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      tetrisCount: tetrisCount ?? this.tetrisCount,
      maxTetrisCombo: maxTetrisCombo ?? this.maxTetrisCombo,
    );
  }

  /// Pontuação média por jogo
  double get averageScore {
    if (totalGames == 0) return 0;
    return totalScore / totalGames;
  }

  /// Média de linhas por jogo
  double get averageLinesPerGame {
    if (totalGames == 0) return 0;
    return totalLines / totalGames;
  }

  /// Tempo médio por jogo
  Duration get averageGameDuration {
    if (totalGames == 0) return Duration.zero;
    return Duration(
      milliseconds: totalPlayTime.inMilliseconds ~/ totalGames,
    );
  }

  /// Tempo total formatado (hh:mm:ss)
  String get formattedTotalPlayTime {
    final hours = totalPlayTime.inHours;
    final minutes = totalPlayTime.inMinutes.remainder(60);
    final seconds = totalPlayTime.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  List<Object?> get props => [
        totalGames,
        totalScore,
        totalLines,
        highestScore,
        highestLines,
        highestLevel,
        totalPlayTime,
        lastPlayedAt,
        tetrisCount,
        maxTetrisCombo,
      ];

  @override
  String toString() {
    return 'TetrisStats(games: $totalGames, highScore: $highestScore, avgScore: ${averageScore.toStringAsFixed(0)})';
  }
}
