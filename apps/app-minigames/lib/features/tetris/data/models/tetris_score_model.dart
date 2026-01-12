import '../../domain/entities/tetris_score.dart';

/// Model para serialização do TetrisScore
class TetrisScoreModel extends TetrisScore {
  const TetrisScoreModel({
    required super.id,
    required super.score,
    required super.lines,
    required super.level,
    required super.duration,
    required super.completedAt,
    super.tetrisCount,
    super.maxTetrisCombo,
    super.playerName,
  });

  /// Cria model a partir de entity
  factory TetrisScoreModel.fromEntity(TetrisScore entity) {
    return TetrisScoreModel(
      id: entity.id,
      score: entity.score,
      lines: entity.lines,
      level: entity.level,
      duration: entity.duration,
      completedAt: entity.completedAt,
      tetrisCount: entity.tetrisCount,
      maxTetrisCombo: entity.maxTetrisCombo,
      playerName: entity.playerName,
    );
  }

  /// Cria model a partir de JSON
  factory TetrisScoreModel.fromJson(Map<String, dynamic> json) {
    return TetrisScoreModel(
      id: json['id'] as String,
      score: json['score'] as int,
      lines: json['lines'] as int,
      level: json['level'] as int,
      duration: Duration(milliseconds: json['durationMs'] as int),
      completedAt: DateTime.parse(json['completedAt'] as String),
      tetrisCount: json['tetrisCount'] as int? ?? 0,
      maxTetrisCombo: json['maxTetrisCombo'] as int? ?? 0,
      playerName: json['playerName'] as String?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'lines': lines,
      'level': level,
      'durationMs': duration.inMilliseconds,
      'completedAt': completedAt.toIso8601String(),
      'tetrisCount': tetrisCount,
      'maxTetrisCombo': maxTetrisCombo,
      'playerName': playerName,
    };
  }

  /// Converte para entity
  TetrisScore toEntity() {
    return TetrisScore(
      id: id,
      score: score,
      lines: lines,
      level: level,
      duration: duration,
      completedAt: completedAt,
      tetrisCount: tetrisCount,
      maxTetrisCombo: maxTetrisCombo,
      playerName: playerName,
    );
  }
}
