// Domain imports:
import '../../domain/entities/high_score_entity.dart';

/// Data model for high score (extends entity with JSON serialization)
class HighScoreModel extends HighScoreEntity {
  const HighScoreModel({
    required super.score,
    super.achievedAt,
  });

  /// Create from entity
  factory HighScoreModel.fromEntity(HighScoreEntity entity) {
    return HighScoreModel(
      score: entity.score,
      achievedAt: entity.achievedAt,
    );
  }

  /// Create from JSON
  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      score: json['score'] as int? ?? 0,
      achievedAt: json['achievedAt'] != null
          ? DateTime.parse(json['achievedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'achievedAt': achievedAt?.toIso8601String(),
    };
  }

  /// Create empty model
  factory HighScoreModel.empty() {
    return const HighScoreModel(score: 0);
  }
}
