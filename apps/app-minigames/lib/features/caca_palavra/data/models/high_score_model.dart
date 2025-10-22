import '../../domain/entities/high_score.dart';

/// Data model for HighScore with JSON serialization
class HighScoreModel extends HighScore {
  const HighScoreModel({
    required super.easyFastest,
    required super.mediumFastest,
    required super.hardFastest,
  });

  const HighScoreModel.empty() : super.empty();

  factory HighScoreModel.fromEntity(HighScore entity) {
    return HighScoreModel(
      easyFastest: entity.easyFastest,
      mediumFastest: entity.mediumFastest,
      hardFastest: entity.hardFastest,
    );
  }

  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      easyFastest: json['easyFastest'] as int? ?? 0,
      mediumFastest: json['mediumFastest'] as int? ?? 0,
      hardFastest: json['hardFastest'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'easyFastest': easyFastest,
      'mediumFastest': mediumFastest,
      'hardFastest': hardFastest,
    };
  }

  @override
  HighScoreModel copyWith({
    int? easyFastest,
    int? mediumFastest,
    int? hardFastest,
  }) {
    return HighScoreModel(
      easyFastest: easyFastest ?? this.easyFastest,
      mediumFastest: mediumFastest ?? this.mediumFastest,
      hardFastest: hardFastest ?? this.hardFastest,
    );
  }
}
