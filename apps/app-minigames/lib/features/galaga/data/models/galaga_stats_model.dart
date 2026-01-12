import '../../domain/entities/galaga_stats.dart';

class GalagaStatsModel extends GalagaStats {
  const GalagaStatsModel({
    super.totalGames,
    super.totalScore,
    super.highestScore,
    super.totalEnemiesDestroyed,
    super.highestWave,
  });

  factory GalagaStatsModel.fromEntity(GalagaStats entity) {
    return GalagaStatsModel(
      totalGames: entity.totalGames,
      totalScore: entity.totalScore,
      highestScore: entity.highestScore,
      totalEnemiesDestroyed: entity.totalEnemiesDestroyed,
      highestWave: entity.highestWave,
    );
  }

  factory GalagaStatsModel.fromJson(Map<String, dynamic> json) {
    return GalagaStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      totalEnemiesDestroyed: json['totalEnemiesDestroyed'] as int? ?? 0,
      highestWave: json['highestWave'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'totalScore': totalScore,
      'highestScore': highestScore,
      'totalEnemiesDestroyed': totalEnemiesDestroyed,
      'highestWave': highestWave,
    };
  }
}
