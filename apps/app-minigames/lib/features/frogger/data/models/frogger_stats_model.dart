import '../../domain/entities/frogger_stats.dart';

class FroggerStatsModel extends FroggerStats {
  const FroggerStatsModel({
    super.totalGames,
    super.totalScore,
    super.highestScore,
    super.totalCrossingsCompleted,
    super.highestWave,
  });

  factory FroggerStatsModel.fromEntity(FroggerStats entity) {
    return FroggerStatsModel(
      totalGames: entity.totalGames,
      totalScore: entity.totalScore,
      highestScore: entity.highestScore,
      totalCrossingsCompleted: entity.totalCrossingsCompleted,
      highestWave: entity.highestWave,
    );
  }

  factory FroggerStatsModel.fromJson(Map<String, dynamic> json) {
    return FroggerStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      totalCrossingsCompleted: json['totalCrossingsCompleted'] as int? ?? 0,
      highestWave: json['highestWave'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'totalScore': totalScore,
      'highestScore': highestScore,
      'totalCrossingsCompleted': totalCrossingsCompleted,
      'highestWave': highestWave,
    };
  }
}
