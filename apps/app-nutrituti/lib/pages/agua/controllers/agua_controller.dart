// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import '../models/achievement_model.dart';
import '../models/beber_agua_model.dart';
import '../repository/agua_repository.dart';

part 'agua_controller.g.dart';

/// State class for Agua feature
class AguaState {
  final double dailyWaterGoal;
  final double todayProgress;
  final List<BeberAgua> registros;
  final List<WaterAchievement> achievements;
  final bool isLoading;

  const AguaState({
    this.dailyWaterGoal = 2000.0,
    this.todayProgress = 0.0,
    this.registros = const [],
    this.achievements = const [],
    this.isLoading = false,
  });

  AguaState copyWith({
    double? dailyWaterGoal,
    double? todayProgress,
    List<BeberAgua>? registros,
    List<WaterAchievement>? achievements,
    bool? isLoading,
  }) {
    return AguaState(
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      todayProgress: todayProgress ?? this.todayProgress,
      registros: registros ?? this.registros,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider for AguaRepository
@riverpod
AguaRepository aguaRepository(AguaRepositoryRef ref) {
  return AguaRepository();
}

/// Main Agua Notifier
@riverpod
class AguaNotifier extends _$AguaNotifier {
  // Dicas de saúde relacionadas à água
  static const List<String> healthTips = [
    'Beber água ajuda a melhorar a concentração',
    'A hidratação é essencial para a saúde da pele',
    'Beba água antes, durante e depois de exercícios',
    'Água ajuda no funcionamento do intestino',
    'Mantenha uma garrafa de água sempre por perto',
  ];

  @override
  Future<AguaState> build() async {
    final repository = ref.watch(aguaRepositoryProvider);

    try {
      // Load initial data
      final dailyGoal = await repository.getDailyGoal();
      final todayProgress = await repository.getTodayProgress();
      final registros = await repository.getAll();
      final achievements = await _initializeAchievements();

      await _checkAndUpdateStreak();

      return AguaState(
        dailyWaterGoal: dailyGoal,
        todayProgress: todayProgress,
        registros: registros,
        achievements: achievements,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      return const AguaState();
    }
  }

  /// Initialize achievements
  Future<List<WaterAchievement>> _initializeAchievements() async {
    final repository = ref.read(aguaRepositoryProvider);
    final unlockedAchievements = await repository.getUnlockedAchievements();

    final achievements = [
      WaterAchievement(
        title: '🌱 Iniciante',
        description: 'Registrou água por 3 dias seguidos',
      ),
      WaterAchievement(
        title: '💧 Hidratado',
        description: 'Atingiu a meta diária 7 dias seguidos',
      ),
      WaterAchievement(
        title: '🌊 Mestre da Hidratação',
        description: 'Completou 30 dias seguidos',
      ),
    ];

    for (var achievement in achievements) {
      if (unlockedAchievements.contains(achievement.title)) {
        achievement.unlock();
      }
    }

    return achievements;
  }

  /// Add new water registro
  Future<void> addRegistro(BeberAgua registro) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repository = ref.read(aguaRepositoryProvider);

      await repository.add(registro);
      await repository.updateTodayProgress(registro.quantidade);

      final updatedProgress = await repository.getTodayProgress();
      final updatedRegistros = await repository.getAll();

      state = AsyncValue.data(currentState.copyWith(
        todayProgress: updatedProgress,
        registros: updatedRegistros,
        isLoading: false,
      ));

      await checkGoalAchievement();
    } catch (e) {
      debugPrint('Erro ao adicionar registro: $e');
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Update existing registro
  Future<void> updateRegistro(BeberAgua registro) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repository = ref.read(aguaRepositoryProvider);

      await repository.updated(registro);
      final updatedRegistros = await repository.getAll();

      state = AsyncValue.data(currentState.copyWith(
        registros: updatedRegistros,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Erro ao atualizar registro: $e');
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Delete registro
  Future<void> deleteRegistro(BeberAgua registro) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repository = ref.read(aguaRepositoryProvider);

      await repository.delete(registro);
      final updatedRegistros = await repository.getAll();

      state = AsyncValue.data(currentState.copyWith(
        registros: updatedRegistros,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Erro ao deletar registro: $e');
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Update daily goal
  Future<void> updateDailyGoal(double newGoal) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repository = ref.read(aguaRepositoryProvider);

      await repository.setDailyGoal(newGoal);

      state = AsyncValue.data(currentState.copyWith(
        dailyWaterGoal: newGoal,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Erro ao atualizar meta diária: $e');
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Check and update streak
  Future<void> _checkAndUpdateStreak() async {
    final repository = ref.read(aguaRepositoryProvider);
    final lastUpdate = await repository.getLastUpdate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastUpdate != null) {
      final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final yesterday = DateTime(today.year, today.month, today.day - 1);

      if (lastUpdateDate.isBefore(yesterday)) {
        // Reset streak if more than a day has passed
        await repository.resetStreak();
      }
    }

    // Update last update date
    await repository.setLastUpdate(today.millisecondsSinceEpoch);
  }

  /// Check goal achievements
  Future<void> checkGoalAchievement() async {
    final currentState = await future;

    if (currentState.todayProgress >= currentState.dailyWaterGoal) {
      final repository = ref.read(aguaRepositoryProvider);
      final currentStreak = await repository.incrementStreak();

      // Check and unlock achievements based on streak
      if (currentStreak >= 3) {
        await unlockAchievement('🌱 Iniciante');
      }

      if (currentStreak >= 7) {
        await unlockAchievement('💧 Hidratado');
      }

      if (currentStreak >= 30) {
        await unlockAchievement('🌊 Mestre da Hidratação');
      }
    }
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(String title) async {
    final currentState = await future;
    final achievements = [...currentState.achievements];

    final index = achievements.indexWhere((a) => a.title == title);
    if (index != -1 && !achievements[index].isUnlocked) {
      achievements[index].unlock();

      final repository = ref.read(aguaRepositoryProvider);
      await repository.addUnlockedAchievement(title);

      state = AsyncValue.data(currentState.copyWith(
        achievements: achievements,
      ));
    }
  }

  /// Get tip of the day
  String getTipOfTheDay() {
    return healthTips[DateTime.now().day % healthTips.length];
  }
}
