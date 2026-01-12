import '../../domain/entities/reversi_settings.dart';

class ReversiSettingsModel extends ReversiSettings {
  const ReversiSettingsModel({
    super.soundEnabled,
    super.showValidMoves,
    super.showMoveCount,
    super.difficulty,
  });

  factory ReversiSettingsModel.fromEntity(ReversiSettings entity) {
    return ReversiSettingsModel(
      soundEnabled: entity.soundEnabled,
      showValidMoves: entity.showValidMoves,
      showMoveCount: entity.showMoveCount,
      difficulty: entity.difficulty,
    );
  }

  factory ReversiSettingsModel.fromJson(Map<String, dynamic> json) {
    return ReversiSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      showValidMoves: json['showValidMoves'] as bool? ?? true,
      showMoveCount: json['showMoveCount'] as bool? ?? true,
      difficulty: ReversiDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'medium'),
        orElse: () => ReversiDifficulty.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'showValidMoves': showValidMoves,
      'showMoveCount': showMoveCount,
      'difficulty': difficulty.name,
    };
  }
}
