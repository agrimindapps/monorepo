import '../../domain/entities/tetris_stats.dart';

/// Model para serialização do TetrisStats
class TetrisStatsModel extends TetrisStats {
  const TetrisStatsModel({
    super.totalGames,
    super.totalScore,
    super.totalLines,
    super.highestScore,
    super.highestLines,
    super.highestLevel,
    super.totalPlayTime,
    super.lastPlayedAt,
    super.tetrisCount,
    super.maxTetrisCombo,
  });

  /// Cria model a partir de entity
  factory TetrisStatsModel.fromEntity(TetrisStats entity) {
    return TetrisStatsModel(
      totalGames: entity.totalGames,
      totalScore: entity.totalScore,
      totalLines: entity.totalLines,
      highestScore: entity.highestScore,
      highestLines: entity.highestLines,
      highestLevel: entity.highestLevel,
      totalPlayTime: entity.totalPlayTime,
      lastPlayedAt: entity.lastPlayedAt,
      tetrisCount: entity.tetrisCount,
      maxTetrisCombo: entity.maxTetrisCombo,
    );
  }

  /// Cria model a partir de JSON
  factory TetrisStatsModel.fromJson(Map<String, dynamic> json) {
    return TetrisStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      totalLines: json['totalLines'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      highestLines: json['highestLines'] as int? ?? 0,
      highestLevel: json['highestLevel'] as int? ?? 0,
      totalPlayTime: Duration(milliseconds: json['totalPlayTimeMs'] as int? ?? 0),
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'] as String)
          : null,
      tetrisCount: json['tetrisCount'] as int? ?? 0,
      maxTetrisCombo: json['maxTetrisCombo'] as int? ?? 0,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'totalScore': totalScore,
      'totalLines': totalLines,
      'highestScore': highestScore,
      'highestLines': highestLines,
      'highestLevel': highestLevel,
      'totalPlayTimeMs': totalPlayTime.inMilliseconds,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'tetrisCount': tetrisCount,
      'maxTetrisCombo': maxTetrisCombo,
    };
  }

  /// Converte para entity
  TetrisStats toEntity() {
    return TetrisStats(
      totalGames: totalGames,
      totalScore: totalScore,
      totalLines: totalLines,
      highestScore: highestScore,
      highestLines: highestLines,
      highestLevel: highestLevel,
      totalPlayTime: totalPlayTime,
      lastPlayedAt: lastPlayedAt,
      tetrisCount: tetrisCount,
      maxTetrisCombo: maxTetrisCombo,
    );
  }
}
