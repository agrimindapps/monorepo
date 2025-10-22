import '../../domain/entities/high_score.dart';

/// Data model for HighScore entity
/// Handles JSON serialization/deserialization
class HighScoreModel extends HighScore {
  const HighScoreModel({required super.score});

  /// Creates model from JSON
  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      score: json['score'] as int? ?? 0,
    );
  }

  /// Converts model to JSON
  Map<String, dynamic> toJson() {
    return {
      'score': score,
    };
  }

  /// Creates model from entity
  factory HighScoreModel.fromEntity(HighScore entity) {
    return HighScoreModel(score: entity.score);
  }
}
