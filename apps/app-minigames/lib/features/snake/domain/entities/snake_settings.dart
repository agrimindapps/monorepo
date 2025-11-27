// Package imports:
import 'package:equatable/equatable.dart';

// Domain imports:
import 'enums.dart';

/// Entity representing game settings
class SnakeSettings extends Equatable {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final double swipeSensitivity;
  final int gridSize;
  final bool showGrid;
  final bool colorBlindMode;
  final SnakeGameMode defaultGameMode;
  final SnakeDifficulty defaultDifficulty;
  final bool tutorialShown;

  const SnakeSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.swipeSensitivity = 1.0,
    this.gridSize = 20,
    this.showGrid = true,
    this.colorBlindMode = false,
    this.defaultGameMode = SnakeGameMode.classic,
    this.defaultDifficulty = SnakeDifficulty.medium,
    this.tutorialShown = false,
  });

  /// Default settings
  static const SnakeSettings defaults = SnakeSettings();

  /// Available grid sizes
  static const List<int> availableGridSizes = [15, 20, 25, 30];

  /// Sensitivity range
  static const double minSensitivity = 0.5;
  static const double maxSensitivity = 2.0;

  /// Create a copy with modified fields
  SnakeSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    double? swipeSensitivity,
    int? gridSize,
    bool? showGrid,
    bool? colorBlindMode,
    SnakeGameMode? defaultGameMode,
    SnakeDifficulty? defaultDifficulty,
    bool? tutorialShown,
  }) {
    return SnakeSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      swipeSensitivity: swipeSensitivity ?? this.swipeSensitivity,
      gridSize: gridSize ?? this.gridSize,
      showGrid: showGrid ?? this.showGrid,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      defaultGameMode: defaultGameMode ?? this.defaultGameMode,
      defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
      tutorialShown: tutorialShown ?? this.tutorialShown,
    );
  }

  @override
  List<Object?> get props => [
        soundEnabled,
        vibrationEnabled,
        swipeSensitivity,
        gridSize,
        showGrid,
        colorBlindMode,
        defaultGameMode,
        defaultDifficulty,
        tutorialShown,
      ];
}
