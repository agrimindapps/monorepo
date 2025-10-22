import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score_entity.dart';

/// Data model for high score with JSON serialization
class HighScoreModel extends HighScoreEntity {
  const HighScoreModel({
    required super.score,
    required super.moves,
    required super.duration,
    required super.boardSize,
    required super.achievedAt,
  });

  /// Creates model from entity
  factory HighScoreModel.fromEntity(HighScoreEntity entity) {
    return HighScoreModel(
      score: entity.score,
      moves: entity.moves,
      duration: entity.duration,
      boardSize: entity.boardSize,
      achievedAt: entity.achievedAt,
    );
  }

  /// Creates model from JSON
  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      score: json['score'] as int,
      moves: json['moves'] as int,
      duration: Duration(milliseconds: json['durationMs'] as int),
      boardSize: BoardSize.values.firstWhere(
        (size) => size.name == json['boardSize'],
        orElse: () => BoardSize.size4x4,
      ),
      achievedAt: DateTime.parse(json['achievedAt'] as String),
    );
  }

  /// Converts model to JSON
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'moves': moves,
      'durationMs': duration.inMilliseconds,
      'boardSize': boardSize.name,
      'achievedAt': achievedAt.toIso8601String(),
    };
  }

  /// Creates empty model
  factory HighScoreModel.empty(BoardSize boardSize) {
    return HighScoreModel(
      score: 0,
      moves: 0,
      duration: Duration.zero,
      boardSize: boardSize,
      achievedAt: DateTime.now(),
    );
  }

  @override
  HighScoreModel copyWith({
    int? score,
    int? moves,
    Duration? duration,
    BoardSize? boardSize,
    DateTime? achievedAt,
  }) {
    return HighScoreModel(
      score: score ?? this.score,
      moves: moves ?? this.moves,
      duration: duration ?? this.duration,
      boardSize: boardSize ?? this.boardSize,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }
}
