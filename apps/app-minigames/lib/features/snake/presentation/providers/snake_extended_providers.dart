// Dart imports:
import 'dart:async';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Domain imports:
import '../../domain/entities/snake_statistics.dart';
import '../../domain/entities/player_level.dart';
import '../../domain/entities/snake_settings.dart';
import '../../domain/entities/enums.dart';
import '../../data/models/player_level_model.dart';
import '../../data/models/snake_settings_model.dart';
import 'snake_providers.dart';

part 'snake_extended_providers.g.dart';

/// Provider for snake statistics
@riverpod
class SnakeStatisticsNotifier extends _$SnakeStatisticsNotifier {
  @override
  FutureOr<SnakeStatistics> build() async {
    final dataSource = ref.read(snakeLocalDataSourceProvider);
    return await dataSource.loadStatistics();
  }

  /// Refresh statistics from storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dataSource = ref.read(snakeLocalDataSourceProvider);
      return await dataSource.loadStatistics();
    });
  }

  /// Record game end and update statistics
  Future<void> recordGameEnd({
    required int score,
    required int snakeLength,
    required int durationSeconds,
    required String deathType,
    required String difficulty,
    required String gameMode,
    required Map<String, int> powerUpsCollected,
    required int foodEaten,
  }) async {
    final dataSource = ref.read(snakeLocalDataSourceProvider);
    await dataSource.recordGameEnd(
      score: score,
      snakeLength: snakeLength,
      durationSeconds: durationSeconds,
      deathType: deathType,
      difficulty: difficulty,
      gameMode: gameMode,
      powerUpsCollected: powerUpsCollected,
      foodEaten: foodEaten,
    );
    await refresh();
  }
}

/// Provider for player level
@riverpod
class PlayerLevelNotifier extends _$PlayerLevelNotifier {
  @override
  FutureOr<PlayerLevel> build() async {
    final dataSource = ref.read(snakeLocalDataSourceProvider);
    return await dataSource.loadPlayerLevel();
  }

  /// Refresh player level from storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dataSource = ref.read(snakeLocalDataSourceProvider);
      return await dataSource.loadPlayerLevel();
    });
  }

  /// Add XP and check for level up
  /// Returns true if player leveled up
  Future<bool> addXp(int xp) async {
    final currentLevel = state.value;
    if (currentLevel == null) return false;

    final (newLevel, leveledUp) = currentLevel.addXp(xp);
    
    final dataSource = ref.read(snakeLocalDataSourceProvider);
    await dataSource.savePlayerLevel(
      PlayerLevelModel.fromEntity(newLevel),
    );
    
    state = AsyncValue.data(newLevel);
    return leveledUp;
  }
}

/// Provider for snake settings
@riverpod
class SnakeSettingsNotifier extends _$SnakeSettingsNotifier {
  @override
  FutureOr<SnakeSettings> build() async {
    final dataSource = ref.read(snakeLocalDataSourceProvider);
    return await dataSource.loadSettings();
  }

  /// Update a specific setting
  Future<void> updateSetting({
    bool? soundEnabled,
    bool? vibrationEnabled,
    double? swipeSensitivity,
    int? gridSize,
    bool? showGrid,
    bool? colorBlindMode,
    SnakeGameMode? defaultGameMode,
    SnakeDifficulty? defaultDifficulty,
    bool? tutorialShown,
  }) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      swipeSensitivity: swipeSensitivity,
      gridSize: gridSize,
      showGrid: showGrid,
      colorBlindMode: colorBlindMode,
      defaultGameMode: defaultGameMode,
      defaultDifficulty: defaultDifficulty,
      tutorialShown: tutorialShown,
    );

    final dataSource = ref.read(snakeLocalDataSourceProvider);
    await dataSource.saveSettings(
      SnakeSettingsModel.fromEntity(newSettings),
    );

    state = AsyncValue.data(newSettings);
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    final currentSettings = state.value;
    final newSettings = SnakeSettings.defaults.copyWith(
      tutorialShown: currentSettings?.tutorialShown ?? false,
    );

    final dataSource = ref.read(snakeLocalDataSourceProvider);
    await dataSource.saveSettings(
      SnakeSettingsModel.fromEntity(newSettings),
    );

    state = AsyncValue.data(newSettings);
  }

  /// Mark tutorial as shown
  Future<void> markTutorialShown() async {
    await updateSetting(tutorialShown: true);
  }
}
