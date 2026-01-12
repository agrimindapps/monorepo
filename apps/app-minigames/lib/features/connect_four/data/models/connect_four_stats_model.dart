import '../../domain/entities/connect_four_stats.dart';

class ConnectFourStatsModel extends ConnectFourStats {
  const ConnectFourStatsModel({
    super.totalGames,
    super.totalScore,
    super.highestScore,
    super.totalCrossingsCompleted,
    super.highestWave,
  });

  factory ConnectFourStatsModel.fromEntity(ConnectFourStats entity) {
    return ConnectFourStatsModel(
      totalGames: entity.totalGames,
      totalScore: entity.totalScore,
      highestScore: entity.highestScore,
      totalCrossingsCompleted: entity.totalCrossingsCompleted,
      highestWave: entity.highestWave,
    );
  }

  factory ConnectFourStatsModel.fromJson(Map<String, dynamic> json) {
    return ConnectFourStatsModel(
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
