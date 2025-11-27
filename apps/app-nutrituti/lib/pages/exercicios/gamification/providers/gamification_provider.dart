import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../drift_database/daos/gamification_dao.dart';
import '../../../../drift_database/nutrituti_database.dart';
import '../enums/challenge_type.dart';
import '../enums/exercicio_categoria.dart';
import '../models/achievement_definition.dart';
import '../models/user_fitness_profile.dart';
import '../models/weekly_challenge.dart';
import '../models/workout_session.dart';
import '../services/fitquest_constants.dart';
import '../services/gamification_service.dart';

part 'gamification_provider.g.dart';

const _uuid = Uuid();

// ============================================================================
// DATABASE PROVIDER
// ============================================================================

@Riverpod(keepAlive: true)
NutritutiDatabase nutritutiDatabase(Ref ref) {
  final db = NutritutiDatabase.production();
  ref.onDispose(() => db.close());
  return db;
}

@Riverpod(keepAlive: true)
GamificationDao gamificationDao(Ref ref) {
  return ref.watch(nutritutiDatabaseProvider).gamificationDao;
}

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

@Riverpod(keepAlive: true)
GamificationService gamificationService(Ref ref) {
  return const GamificationService();
}

// ============================================================================
// STATE CLASSES
// ============================================================================

/// Estado da gamificação
class GamificationState {
  const GamificationState({
    required this.profile,
    required this.weeklyChallenge,
    required this.achievements,
    this.activeSession,
    this.recentXpGain,
    this.newlyUnlockedAchievements = const [],
    this.didLevelUp = false,
    this.oldLevel,
  });

  final UserFitnessProfile profile;
  final WeeklyChallenge? weeklyChallenge;
  final List<AchievementWithProgress> achievements;
  final WorkoutSession? activeSession;
  final int? recentXpGain;
  final List<AchievementDefinition> newlyUnlockedAchievements;
  final bool didLevelUp;
  final int? oldLevel;

  GamificationState copyWith({
    UserFitnessProfile? profile,
    WeeklyChallenge? weeklyChallenge,
    List<AchievementWithProgress>? achievements,
    WorkoutSession? activeSession,
    int? recentXpGain,
    List<AchievementDefinition>? newlyUnlockedAchievements,
    bool? didLevelUp,
    int? oldLevel,
  }) {
    return GamificationState(
      profile: profile ?? this.profile,
      weeklyChallenge: weeklyChallenge ?? this.weeklyChallenge,
      achievements: achievements ?? this.achievements,
      activeSession: activeSession ?? this.activeSession,
      recentXpGain: recentXpGain ?? this.recentXpGain,
      newlyUnlockedAchievements:
          newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
      didLevelUp: didLevelUp ?? this.didLevelUp,
      oldLevel: oldLevel ?? this.oldLevel,
    );
  }

  factory GamificationState.initial() => GamificationState(
        profile: UserFitnessProfile.empty(),
        weeklyChallenge: null,
        achievements: [],
      );
}

// ============================================================================
// MAIN GAMIFICATION NOTIFIER
// ============================================================================

@Riverpod(keepAlive: true)
class GamificationNotifier extends _$GamificationNotifier {
  static const _defaultProfileId = 'default';

  GamificationDao get _dao => ref.read(gamificationDaoProvider);
  GamificationService get _service => ref.read(gamificationServiceProvider);

  @override
  Future<GamificationState> build() async {
    // Load initial state
    final profileEntity =
        await _dao.getOrCreateProfile(_defaultProfileId);
    final profile = _profileFromEntity(profileEntity);

    // Load weekly challenge
    final challengeEntity =
        await _dao.getActiveChallenge(_defaultProfileId);
    final challenge = challengeEntity != null
        ? _challengeFromEntity(challengeEntity)
        : null;

    // Load achievements
    final achievementEntities =
        await _dao.getAchievements(_defaultProfileId);
    final achievements = _buildAchievementsWithProgress(
      profile,
      achievementEntities,
    );

    // Load active session
    final sessionEntity =
        await _dao.getActiveSession(_defaultProfileId);
    final activeSession = sessionEntity != null
        ? _sessionFromEntity(sessionEntity)
        : null;

    return GamificationState(
      profile: profile,
      weeklyChallenge: challenge,
      achievements: achievements,
      activeSession: activeSession,
    );
  }

  // ============================================================================
  // XP ACTIONS
  // ============================================================================

  /// Adiciona XP manualmente
  Future<void> addXp(int xp) async {
    final currentState = state.value;
    if (currentState == null) return;

    final oldLevel = currentState.profile.currentLevel;
    await _dao.addXp(_defaultProfileId, xp);

    final newProfile = await _loadProfile();
    final didLevelUp = newProfile.currentLevel > oldLevel;

    state = AsyncValue.data(currentState.copyWith(
      profile: newProfile,
      recentXpGain: xp,
      didLevelUp: didLevelUp,
      oldLevel: didLevelUp ? oldLevel : null,
    ));
  }

  // ============================================================================
  // WORKOUT SESSION ACTIONS
  // ============================================================================

  /// Inicia uma nova sessão de treino
  Future<void> startWorkoutSession({
    required String exerciseType,
    required ExercicioCategoria categoria,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Cancel any existing active session
    if (currentState.activeSession != null) {
      await _dao.deleteSession(currentState.activeSession!.id);
    }

    final sessionId = _uuid.v4();
    final now = DateTime.now();

    await _dao.startSession(WorkoutSessionsCompanion.insert(
      id: sessionId,
      profileId: _defaultProfileId,
      exerciseType: exerciseType,
      categoria: categoria.name,
      startTime: now,
    ));

    final session = WorkoutSession.start(
      id: sessionId,
      exerciseType: exerciseType,
      categoria: categoria,
    );

    state = AsyncValue.data(currentState.copyWith(
      activeSession: session,
    ));
  }

  /// Pausa a sessão ativa
  Future<void> pauseWorkout() async {
    final currentState = state.value;
    final session = currentState?.activeSession;
    if (session == null || !session.isActive || session.isPaused) return;

    await _dao.pauseSession(session.id);

    state = AsyncValue.data(currentState!.copyWith(
      activeSession: session.pause(),
    ));
  }

  /// Retoma a sessão pausada
  Future<void> resumeWorkout() async {
    final currentState = state.value;
    final session = currentState?.activeSession;
    if (session == null || !session.isActive || !session.isPaused) return;

    final resumed = session.resume();
    await _dao.resumeSession(
      session.id,
      resumed.pausedDuration.inMilliseconds,
    );

    state = AsyncValue.data(currentState!.copyWith(
      activeSession: resumed,
    ));
  }

  /// Finaliza a sessão de treino
  Future<void> finishWorkout() async {
    final currentState = state.value;
    final session = currentState?.activeSession;
    if (session == null || !session.isActive) return;

    final finished = session.finish();
    final now = DateTime.now();
    final oldProfile = currentState!.profile;
    final oldLevel = oldProfile.currentLevel;

    // Calculate XP
    final xp = _service.calculateXpForWorkout(
      durationMinutes: finished.durationMinutes,
      calories: finished.estimatedCalories,
      streakDays: oldProfile.streakDays,
    );

    // Finish session in DB
    await _dao.finishSession(
      session.id,
      calories: finished.estimatedCalories,
      xpEarned: xp,
    );

    // Add XP
    await _dao.addXp(_defaultProfileId, xp);

    // Update streak
    final newStreak = _service.updateStreak(
      lastWorkout: oldProfile.lastWorkoutDate,
      currentStreak: oldProfile.streakDays,
    );
    final bestStreak = newStreak > oldProfile.bestStreak
        ? newStreak
        : oldProfile.bestStreak;
    await _dao.updateStreak(_defaultProfileId, newStreak, bestStreak);

    // Update workout stats
    await _dao.incrementWorkoutStats(
      _defaultProfileId,
      minutes: finished.durationMinutes,
      calories: finished.estimatedCalories,
      category: finished.categoria.name,
    );

    // Check special achievements
    final isEarlyBird = _service.isEarlyBirdWorkout(now);
    final isNightOwl = _service.isNightOwlWorkout(now);
    final isWeekend = _service.isWeekendWorkout(now);

    if (isEarlyBird || isNightOwl || isWeekend) {
      await _dao.incrementSpecialCounter(
        _defaultProfileId,
        isEarlyBird: isEarlyBird,
        isNightOwl: isNightOwl,
        isWeekendWarrior: isWeekend,
      );
    }

    // Reload profile
    final newProfile = await _loadProfile();
    final didLevelUp = newProfile.currentLevel > oldLevel;

    // Check achievements
    final newlyUnlocked = _service.getNewlyUnlockedAchievements(
      oldProfile,
      newProfile,
    );

    // Update unlocked achievements in DB
    for (final achievement in newlyUnlocked) {
      await _dao.unlockAchievement(_defaultProfileId, achievement.id);
    }

    // Update challenge progress
    WeeklyChallenge? updatedChallenge;
    if (currentState.weeklyChallenge != null &&
        currentState.weeklyChallenge!.isActive) {
      updatedChallenge = _service.updateChallengeProgress(
        challenge: currentState.weeklyChallenge!,
        durationMinutes: finished.durationMinutes,
        calories: finished.estimatedCalories,
        newStreak: newStreak,
      );

      await _dao.updateChallengeProgress(
        updatedChallenge.id,
        updatedChallenge.currentProgress,
      );

      if (updatedChallenge.isCompleted) {
        await _dao.completeChallenge(updatedChallenge.id);
        // Add challenge XP
        await _dao.addXp(_defaultProfileId, updatedChallenge.xpReward);
      }
    }

    // Reload achievements
    final achievementEntities =
        await _dao.getAchievements(_defaultProfileId);
    final achievements = _buildAchievementsWithProgress(
      newProfile,
      achievementEntities,
    );

    state = AsyncValue.data(currentState.copyWith(
      profile: newProfile,
      activeSession: null,
      weeklyChallenge: updatedChallenge ?? currentState.weeklyChallenge,
      achievements: achievements,
      recentXpGain: xp,
      newlyUnlockedAchievements: newlyUnlocked,
      didLevelUp: didLevelUp,
      oldLevel: didLevelUp ? oldLevel : null,
    ));
  }

  /// Cancela a sessão ativa
  Future<void> cancelWorkout() async {
    final currentState = state.value;
    final session = currentState?.activeSession;
    if (session == null) return;

    await _dao.deleteSession(session.id);

    state = AsyncValue.data(currentState!.copyWith(
      activeSession: null,
    ));
  }

  // ============================================================================
  // CHALLENGE ACTIONS
  // ============================================================================

  /// Gera novo desafio semanal
  Future<void> generateNewWeeklyChallenge() async {
    final currentState = state.value;
    if (currentState == null) return;

    final challenge = _service.generateWeeklyChallenge(currentState.profile);

    await _dao.createChallenge(WeeklyChallengesCompanion.insert(
      id: challenge.id,
      profileId: _defaultProfileId,
      title: challenge.title,
      description: challenge.description,
      type: challenge.type.name,
      target: challenge.target,
      startDate: challenge.startDate,
      endDate: challenge.endDate,
      xpReward: challenge.xpReward,
    ));

    state = AsyncValue.data(currentState.copyWith(
      weeklyChallenge: challenge,
    ));
  }

  // ============================================================================
  // STREAK ACTIONS
  // ============================================================================

  /// Atualiza streak (para verificação diária)
  Future<void> checkAndUpdateStreak() async {
    final currentState = state.value;
    if (currentState == null) return;

    final profile = currentState.profile;

    if (_service.isStreakLost(lastWorkout: profile.lastWorkoutDate)) {
      await _dao.updateStreak(_defaultProfileId, 0, profile.bestStreak);

      final newProfile = profile.copyWith(streakDays: 0);
      state = AsyncValue.data(currentState.copyWith(profile: newProfile));
    }
  }

  // ============================================================================
  // CLEAR NOTIFICATIONS
  // ============================================================================

  /// Limpa notificações de level up e conquistas
  void clearNotifications() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(
      recentXpGain: null,
      newlyUnlockedAchievements: [],
      didLevelUp: false,
      oldLevel: null,
    ));
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  Future<UserFitnessProfile> _loadProfile() async {
    final entity = await _dao.getOrCreateProfile(_defaultProfileId);
    return _profileFromEntity(entity);
  }

  UserFitnessProfile _profileFromEntity(FitnessProfile entity) {
    List<String> categories = [];
    try {
      categories = (jsonDecode(entity.categoriesUsed) as List).cast<String>();
    } catch (_) {
      categories = [];
    }

    return UserFitnessProfile(
      id: entity.id,
      totalXp: entity.totalXp,
      currentLevel: entity.currentLevel,
      streakDays: entity.streakDays,
      bestStreak: entity.bestStreak,
      totalWorkouts: entity.totalWorkouts,
      totalMinutes: entity.totalMinutes,
      totalCalories: entity.totalCalories,
      unlockedAchievements: const [], // Loaded separately
      lastWorkoutDate: entity.lastWorkoutDate,
      categoriesUsed: categories.toSet(),
      earlyBirdCount: entity.earlyBirdCount,
      nightOwlCount: entity.nightOwlCount,
      weekendWarriorCount: entity.weekendWarriorCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  WeeklyChallenge _challengeFromEntity(WeeklyChallengeEntity entity) {
    return WeeklyChallenge(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      type: ChallengeType.values.firstWhere(
        (t) => t.name == entity.type,
        orElse: () => ChallengeType.sessoes,
      ),
      target: entity.target,
      currentProgress: entity.currentProgress,
      startDate: entity.startDate,
      endDate: entity.endDate,
      xpReward: entity.xpReward,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
    );
  }

  WorkoutSession _sessionFromEntity(WorkoutSessionEntity entity) {
    return WorkoutSession(
      id: entity.id,
      exerciseType: entity.exerciseType,
      categoria: ExercicioCategoria.fromName(entity.categoria),
      startTime: entity.startTime,
      endTime: entity.endTime,
      pausedDuration: Duration(milliseconds: entity.pausedDurationMs),
      isActive: entity.isActive,
      isPaused: entity.isPaused,
      estimatedCalories: entity.estimatedCalories,
    );
  }

  List<AchievementWithProgress> _buildAchievementsWithProgress(
    UserFitnessProfile profile,
    List<FitnessAchievement> entities,
  ) {
    final entityMap = {for (final e in entities) e.achievementId: e};

    return FitQuestConstants.achievements.map((definition) {
      final entity = entityMap[definition.id];
      final progress = _getProgressForAchievement(definition, profile);

      return AchievementWithProgress(
        definition: definition,
        currentProgress: progress,
        isUnlocked: entity?.isUnlocked ?? progress >= definition.target,
        unlockedAt: entity?.unlockedAt,
      );
    }).toList();
  }

  int _getProgressForAchievement(
    AchievementDefinition achievement,
    UserFitnessProfile profile,
  ) {
    switch (achievement.type) {
      case AchievementType.streak:
        return profile.bestStreak;
      case AchievementType.count:
        return profile.totalWorkouts;
      case AchievementType.calories:
        return profile.totalCalories;
      case AchievementType.minutes:
        return profile.totalMinutes;
      case AchievementType.variety:
        return profile.categoriesUsed.length;
      case AchievementType.special:
        switch (achievement.id) {
          case 'early_bird':
            return profile.earlyBirdCount;
          case 'night_owl':
            return profile.nightOwlCount;
          case 'weekend_warrior':
            return profile.weekendWarriorCount;
          default:
            return 0;
        }
    }
  }
}

// ============================================================================
// DERIVED PROVIDERS
// ============================================================================

@riverpod
UserFitnessProfile? currentProfile(Ref ref) {
  return ref.watch(gamificationProvider).value?.profile;
}

@riverpod
int currentLevel(Ref ref) {
  return ref.watch(currentProfileProvider)?.currentLevel ?? 1;
}

@riverpod
String currentLevelTitle(Ref ref) {
  final level = ref.watch(currentLevelProvider);
  return ref.read(gamificationServiceProvider).getLevelTitle(level);
}

@riverpod
double levelProgress(Ref ref) {
  return ref.watch(currentProfileProvider)?.levelProgressPercent ?? 0.0;
}

@riverpod
int currentStreak(Ref ref) {
  return ref.watch(currentProfileProvider)?.streakDays ?? 0;
}

@riverpod
WeeklyChallenge? activeChallenge(Ref ref) {
  return ref.watch(gamificationProvider).value?.weeklyChallenge;
}

@riverpod
WorkoutSession? activeSession(Ref ref) {
  return ref.watch(gamificationProvider).value?.activeSession;
}

@riverpod
List<AchievementWithProgress> unlockedAchievements(Ref ref) {
  final achievements =
      ref.watch(gamificationProvider).value?.achievements ?? [];
  return achievements.where((a) => a.isUnlocked).toList();
}

@riverpod
List<AchievementWithProgress> lockedAchievements(Ref ref) {
  final achievements =
      ref.watch(gamificationProvider).value?.achievements ?? [];
  return achievements.where((a) => !a.isUnlocked).toList()
    ..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
}
