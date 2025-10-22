// Domain imports:
import '../../domain/entities/high_score.dart';

/// Model for HighScore (extends entity, adds JSON serialization)
class HighScoreModel extends HighScore {
  const HighScoreModel({required super.score});

  /// Create from JSON
  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(score: json['score'] as int? ?? 0);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'score': score};
  }

  /// Create from entity
  factory HighScoreModel.fromEntity(HighScore entity) {
    return HighScoreModel(score: entity.score);
  }

  /// Empty score
  factory HighScoreModel.empty() => const HighScoreModel(score: 0);
}
