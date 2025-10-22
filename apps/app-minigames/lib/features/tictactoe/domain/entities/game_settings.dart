import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Immutable entity representing game configuration settings
class GameSettings extends Equatable {
  final GameMode gameMode;
  final Difficulty difficulty;

  const GameSettings({
    required this.gameMode,
    required this.difficulty,
  });

  /// Factory constructor for default settings
  const GameSettings.defaults()
      : gameMode = GameMode.vsPlayer,
        difficulty = Difficulty.medium;

  /// Creates a copy with updated fields
  GameSettings copyWith({
    GameMode? gameMode,
    Difficulty? difficulty,
  }) {
    return GameSettings(
      gameMode: gameMode ?? this.gameMode,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  List<Object> get props => [gameMode, difficulty];
}
