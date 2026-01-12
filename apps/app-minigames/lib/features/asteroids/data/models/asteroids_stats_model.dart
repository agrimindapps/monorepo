import '../../domain/entities/asteroids_stats.dart';

class AsteroidsStatsModel extends AsteroidsStats {
  const AsteroidsStatsModel({
    super.totalGames,
    super.totalScore,
    super.highestScore,
    super.totalAsteroidsDestroyed,
    super.highestWave,
  });

  factory AsteroidsStatsModel.fromEntity(AsteroidsStats entity) {
    return AsteroidsStatsModel(
      totalGames: entity.totalGames,
      totalScore: entity.totalScore,
      highestScore: entity.highestScore,
      totalAsteroidsDestroyed: entity.totalAsteroidsDestroyed,
      highestWave: entity.highestWave,
    );
  }

  factory AsteroidsStatsModel.fromJson(Map<String, dynamic> json) {
    return AsteroidsStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      totalAsteroidsDestroyed: json['totalAsteroidsDestroyed'] as int? ?? 0,
      highestWave: json['highestWave'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'totalScore': totalScore,
      'highestScore': highestScore,
      'totalAsteroidsDestroyed': totalAsteroidsDestroyed,
      'highestWave': highestWave,
    };
  }
}
