import 'dart:convert';

import 'package:drift/drift.dart';

import '../nutrituti_database.dart';
import '../tables/fitness_profiles_table.dart';
import '../tables/fitness_achievements_table.dart';
import '../tables/weekly_challenges_table.dart';
import '../tables/workout_sessions_table.dart';

part 'gamification_dao.g.dart';

/// DAO para operações de gamificação FitQuest
@DriftAccessor(tables: [
  FitnessProfiles,
  FitnessAchievements,
  WeeklyChallenges,
  WorkoutSessions,
])
class GamificationDao extends DatabaseAccessor<NutritutiDatabase>
    with _$GamificationDaoMixin {
  GamificationDao(NutritutiDatabase db) : super(db);

  // ============================================================================
  // FITNESS PROFILE OPERATIONS
  // ============================================================================

  /// Get fitness profile by ID
  Future<FitnessProfile?> getProfile(String id) {
    return (select(fitnessProfiles)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get or create default profile
  Future<FitnessProfile> getOrCreateProfile(String id) async {
    final existing = await getProfile(id);
    if (existing != null) return existing;

    final companion = FitnessProfilesCompanion.insert(
      id: id,
      createdAt: Value(DateTime.now()),
    );
    await into(fitnessProfiles).insert(companion);
    return (await getProfile(id))!;
  }

  /// Watch fitness profile by ID
  Stream<FitnessProfile?> watchProfile(String id) {
    return (select(fitnessProfiles)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Update fitness profile
  Future<int> updateProfile(String id, FitnessProfilesCompanion companion) {
    return (update(fitnessProfiles)..where((t) => t.id.equals(id))).write(
      companion.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Add XP to profile
  Future<void> addXp(String id, int xp) async {
    final profile = await getOrCreateProfile(id);
    final newTotalXp = profile.totalXp + xp;
    final newLevel = _calculateLevel(newTotalXp);

    await updateProfile(
      id,
      FitnessProfilesCompanion(
        totalXp: Value(newTotalXp),
        currentLevel: Value(newLevel),
      ),
    );
  }

  /// Update streak days
  Future<void> updateStreak(String id, int streakDays, int bestStreak) async {
    await updateProfile(
      id,
      FitnessProfilesCompanion(
        streakDays: Value(streakDays),
        bestStreak: Value(bestStreak),
        lastWorkoutDate: Value(DateTime.now()),
      ),
    );
  }

  /// Increment workout stats
  Future<void> incrementWorkoutStats(
    String id, {
    required int minutes,
    required int calories,
    required String category,
  }) async {
    final profile = await getOrCreateProfile(id);

    // Parse existing categories
    List<String> categories = [];
    try {
      categories = (jsonDecode(profile.categoriesUsed) as List).cast<String>();
    } catch (_) {
      categories = [];
    }

    if (!categories.contains(category)) {
      categories.add(category);
    }

    await updateProfile(
      id,
      FitnessProfilesCompanion(
        totalWorkouts: Value(profile.totalWorkouts + 1),
        totalMinutes: Value(profile.totalMinutes + minutes),
        totalCalories: Value(profile.totalCalories + calories),
        categoriesUsed: Value(jsonEncode(categories)),
        lastWorkoutDate: Value(DateTime.now()),
      ),
    );
  }

  /// Increment special counters
  Future<void> incrementSpecialCounter(
    String id, {
    bool isEarlyBird = false,
    bool isNightOwl = false,
    bool isWeekendWarrior = false,
  }) async {
    final profile = await getOrCreateProfile(id);

    await updateProfile(
      id,
      FitnessProfilesCompanion(
        earlyBirdCount:
            Value(profile.earlyBirdCount + (isEarlyBird ? 1 : 0)),
        nightOwlCount: Value(profile.nightOwlCount + (isNightOwl ? 1 : 0)),
        weekendWarriorCount:
            Value(profile.weekendWarriorCount + (isWeekendWarrior ? 1 : 0)),
      ),
    );
  }

  // ============================================================================
  // ACHIEVEMENTS OPERATIONS
  // ============================================================================

  /// Get all achievements for profile
  Future<List<FitnessAchievement>> getAchievements(String profileId) {
    return (select(fitnessAchievements)
          ..where((t) => t.profileId.equals(profileId)))
        .get();
  }

  /// Get specific achievement progress
  Future<FitnessAchievement?> getAchievementProgress(
    String profileId,
    String achievementId,
  ) {
    return (select(fitnessAchievements)
          ..where((t) =>
              t.profileId.equals(profileId) &
              t.achievementId.equals(achievementId)))
        .getSingleOrNull();
  }

  /// Watch achievements for profile
  Stream<List<FitnessAchievement>> watchAchievements(String profileId) {
    return (select(fitnessAchievements)
          ..where((t) => t.profileId.equals(profileId)))
        .watch();
  }

  /// Upsert achievement progress
  Future<void> upsertAchievementProgress(
    String profileId,
    String achievementId,
    int progress, {
    bool isUnlocked = false,
    DateTime? unlockedAt,
  }) async {
    final existing = await getAchievementProgress(profileId, achievementId);

    if (existing != null) {
      await (update(fitnessAchievements)..where((t) => t.id.equals(existing.id)))
          .write(FitnessAchievementsCompanion(
        progress: Value(progress),
        isUnlocked: Value(isUnlocked),
        unlockedAt: Value(unlockedAt),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      await into(fitnessAchievements).insert(FitnessAchievementsCompanion.insert(
        achievementId: achievementId,
        profileId: profileId,
        progress: Value(progress),
        isUnlocked: Value(isUnlocked),
        unlockedAt: Value(unlockedAt),
      ));
    }
  }

  /// Unlock achievement
  Future<void> unlockAchievement(String profileId, String achievementId) async {
    await upsertAchievementProgress(
      profileId,
      achievementId,
      100,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
  }

  // ============================================================================
  // WEEKLY CHALLENGES OPERATIONS
  // ============================================================================

  /// Get active weekly challenge for profile
  Future<WeeklyChallengeEntity?> getActiveChallenge(String profileId) {
    final now = DateTime.now();
    return (select(weeklyChallenges)
          ..where((t) =>
              t.profileId.equals(profileId) &
              t.isCompleted.equals(false) &
              t.endDate.isBiggerThanValue(now)))
        .getSingleOrNull();
  }

  /// Watch active weekly challenge
  Stream<WeeklyChallengeEntity?> watchActiveChallenge(String profileId) {
    final now = DateTime.now();
    return (select(weeklyChallenges)
          ..where((t) =>
              t.profileId.equals(profileId) &
              t.isCompleted.equals(false) &
              t.endDate.isBiggerThanValue(now)))
        .watchSingleOrNull();
  }

  /// Get all challenges for profile
  Future<List<WeeklyChallengeEntity>> getChallenges(String profileId) {
    return (select(weeklyChallenges)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();
  }

  /// Create weekly challenge
  Future<void> createChallenge(WeeklyChallengesCompanion challenge) async {
    await into(weeklyChallenges).insert(challenge);
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress(String id, int progress) async {
    await (update(weeklyChallenges)..where((t) => t.id.equals(id))).write(
      WeeklyChallengesCompanion(
        currentProgress: Value(progress),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Complete challenge
  Future<void> completeChallenge(String id) async {
    await (update(weeklyChallenges)..where((t) => t.id.equals(id))).write(
      WeeklyChallengesCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // WORKOUT SESSIONS OPERATIONS
  // ============================================================================

  /// Get active workout session
  Future<WorkoutSessionEntity?> getActiveSession(String profileId) {
    return (select(workoutSessions)
          ..where(
              (t) => t.profileId.equals(profileId) & t.isActive.equals(true)))
        .getSingleOrNull();
  }

  /// Watch active workout session
  Stream<WorkoutSessionEntity?> watchActiveSession(String profileId) {
    return (select(workoutSessions)
          ..where(
              (t) => t.profileId.equals(profileId) & t.isActive.equals(true)))
        .watchSingleOrNull();
  }

  /// Get workout session by ID
  Future<WorkoutSessionEntity?> getSession(String id) {
    return (select(workoutSessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get completed sessions for profile
  Future<List<WorkoutSessionEntity>> getCompletedSessions(
    String profileId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final query = select(workoutSessions)
      ..where((t) =>
          t.profileId.equals(profileId) & t.isActive.equals(false));

    if (startDate != null) {
      query.where((t) => t.startTime.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.startTime.isSmallerOrEqualValue(endDate));
    }

    return (query..orderBy([(t) => OrderingTerm.desc(t.startTime)])).get();
  }

  /// Start new workout session
  Future<void> startSession(WorkoutSessionsCompanion session) async {
    await into(workoutSessions).insert(session);
  }

  /// Update workout session
  Future<void> updateSession(String id, WorkoutSessionsCompanion session) async {
    await (update(workoutSessions)..where((t) => t.id.equals(id))).write(
      session.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Pause workout session
  Future<void> pauseSession(String id) async {
    await updateSession(id, const WorkoutSessionsCompanion(isPaused: Value(true)));
  }

  /// Resume workout session
  Future<void> resumeSession(String id, int totalPausedMs) async {
    await updateSession(
      id,
      WorkoutSessionsCompanion(
        isPaused: const Value(false),
        pausedDurationMs: Value(totalPausedMs),
      ),
    );
  }

  /// Finish workout session
  Future<void> finishSession(
    String id, {
    required int calories,
    required int xpEarned,
  }) async {
    await updateSession(
      id,
      WorkoutSessionsCompanion(
        isActive: const Value(false),
        isPaused: const Value(false),
        endTime: Value(DateTime.now()),
        estimatedCalories: Value(calories),
        xpEarned: Value(xpEarned),
      ),
    );
  }

  /// Delete workout session
  Future<void> deleteSession(String id) async {
    await (delete(workoutSessions)..where((t) => t.id.equals(id))).go();
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  int _calculateLevel(int totalXp) {
    const thresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (totalXp >= thresholds[i]) return i + 1;
    }
    return 1;
  }
}
