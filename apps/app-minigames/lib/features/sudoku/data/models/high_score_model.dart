import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score_entity.dart';

class HighScoreModel extends HighScoreEntity {
  const HighScoreModel({
    required super.bestTime,
    required super.fewestMistakes,
    required super.gamesCompleted,
    required super.difficulty,
    super.lastPlayedAt,
  });

  /// Factory from entity
  factory HighScoreModel.fromEntity(HighScoreEntity entity) {
    return HighScoreModel(
      bestTime: entity.bestTime,
      fewestMistakes: entity.fewestMistakes,
      gamesCompleted: entity.gamesCompleted,
      difficulty: entity.difficulty,
      lastPlayedAt: entity.lastPlayedAt,
    );
  }

  /// Factory from JSON
  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      bestTime: json['bestTime'] as int? ?? 0,
      fewestMistakes: json['fewestMistakes'] as int? ?? 0,
      gamesCompleted: json['gamesCompleted'] as int? ?? 0,
      difficulty: GameDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => GameDifficulty.medium,
      ),
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'bestTime': bestTime,
      'fewestMistakes': fewestMistakes,
      'gamesCompleted': gamesCompleted,
      'difficulty': difficulty.name,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    };
  }

  /// Copy with method
  HighScoreModel copyWithModel({
    int? bestTime,
    int? fewestMistakes,
    int? gamesCompleted,
    GameDifficulty? difficulty,
    DateTime? lastPlayedAt,
  }) {
    return HighScoreModel(
      bestTime: bestTime ?? this.bestTime,
      fewestMistakes: fewestMistakes ?? this.fewestMistakes,
      gamesCompleted: gamesCompleted ?? this.gamesCompleted,
      difficulty: difficulty ?? this.difficulty,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}
