import '../../domain/entities/dino_run_stats.dart';

class DinoRunStatsModel extends DinoRunStats {
  const DinoRunStatsModel({
    super.totalGames,
    super.totalScore,
    super.highestScore,
    super.totalObstaclesJumped,
    super.highestDistance,
  });

  factory DinoRunStatsModel.fromEntity(DinoRunStats entity) {
    return DinoRunStatsModel(
      totalGames: entity.totalGames,
      totalScore: entity.totalScore,
      highestScore: entity.highestScore,
      totalObstaclesJumped: entity.totalObstaclesJumped,
      highestDistance: entity.highestDistance,
    );
  }

  factory DinoRunStatsModel.fromJson(Map<String, dynamic> json) {
    return DinoRunStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      totalObstaclesJumped: json['totalObstaclesJumped'] as int? ?? 0,
      highestDistance: json['highestDistance'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'totalScore': totalScore,
      'highestScore': highestScore,
      'totalObstaclesJumped': totalObstaclesJumped,
      'highestDistance': highestDistance,
    };
  }
}
