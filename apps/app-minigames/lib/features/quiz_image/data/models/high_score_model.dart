import '../../domain/entities/high_score.dart';

/// Data model for HighScore with JSON serialization
class HighScoreModel extends HighScore {
  const HighScoreModel({required super.score});

  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      score: json['score'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
    };
  }

  factory HighScoreModel.fromEntity(HighScore entity) {
    return HighScoreModel(score: entity.score);
  }
}
