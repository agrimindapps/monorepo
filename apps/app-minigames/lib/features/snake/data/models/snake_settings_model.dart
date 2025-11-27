import 'dart:convert';

// Domain imports:
import '../../domain/entities/snake_settings.dart';
import '../../domain/entities/enums.dart';

/// Model for SnakeSettings (extends entity, adds JSON serialization)
class SnakeSettingsModel extends SnakeSettings {
  const SnakeSettingsModel({
    super.soundEnabled,
    super.vibrationEnabled,
    super.swipeSensitivity,
    super.gridSize,
    super.showGrid,
    super.colorBlindMode,
    super.defaultGameMode,
    super.defaultDifficulty,
    super.tutorialShown,
  });

  /// Create from JSON
  factory SnakeSettingsModel.fromJson(Map<String, dynamic> json) {
    return SnakeSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      swipeSensitivity: (json['swipeSensitivity'] as num?)?.toDouble() ?? 1.0,
      gridSize: json['gridSize'] as int? ?? 20,
      showGrid: json['showGrid'] as bool? ?? true,
      colorBlindMode: json['colorBlindMode'] as bool? ?? false,
      defaultGameMode: _parseGameMode(json['defaultGameMode']),
      defaultDifficulty: _parseDifficulty(json['defaultDifficulty']),
      tutorialShown: json['tutorialShown'] as bool? ?? false,
    );
  }

  static SnakeGameMode _parseGameMode(dynamic value) {
    if (value == null) return SnakeGameMode.classic;
    try {
      return SnakeGameMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SnakeGameMode.classic,
      );
    } catch (_) {
      return SnakeGameMode.classic;
    }
  }

  static SnakeDifficulty _parseDifficulty(dynamic value) {
    if (value == null) return SnakeDifficulty.medium;
    try {
      return SnakeDifficulty.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SnakeDifficulty.medium,
      );
    } catch (_) {
      return SnakeDifficulty.medium;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'swipeSensitivity': swipeSensitivity,
      'gridSize': gridSize,
      'showGrid': showGrid,
      'colorBlindMode': colorBlindMode,
      'defaultGameMode': defaultGameMode.name,
      'defaultDifficulty': defaultDifficulty.name,
      'tutorialShown': tutorialShown,
    };
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory SnakeSettingsModel.fromJsonString(String jsonString) {
    return SnakeSettingsModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Create from entity
  factory SnakeSettingsModel.fromEntity(SnakeSettings entity) {
    return SnakeSettingsModel(
      soundEnabled: entity.soundEnabled,
      vibrationEnabled: entity.vibrationEnabled,
      swipeSensitivity: entity.swipeSensitivity,
      gridSize: entity.gridSize,
      showGrid: entity.showGrid,
      colorBlindMode: entity.colorBlindMode,
      defaultGameMode: entity.defaultGameMode,
      defaultDifficulty: entity.defaultDifficulty,
      tutorialShown: entity.tutorialShown,
    );
  }

  /// Default settings
  factory SnakeSettingsModel.defaults() => const SnakeSettingsModel();
}
