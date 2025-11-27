import 'dart:math';

import 'package:uuid/uuid.dart';

import '../enums/challenge_type.dart';
import '../models/user_fitness_profile.dart';
import '../models/weekly_challenge.dart';
import '../models/achievement_definition.dart';
import 'fitquest_constants.dart';

/// Serviço de gamificação para o sistema FitQuest
class GamificationService {
  const GamificationService();

  static const _uuid = Uuid();
  static final _random = Random();

  // ============================================================================
  // XP CALCULATION
  // ============================================================================

  /// Calcula XP ganho por um treino
  int calculateXpForWorkout({
    required int durationMinutes,
    required int calories,
    required int streakDays,
  }) {
    // XP base: 2 por minuto + 1 por 10 calorias
    final baseXp = (durationMinutes * FitQuestConstants.xpPerMinute) +
        (calories ~/ 10 * FitQuestConstants.xpPer10Calories);

    // Bônus de streak: +10% por dia, máximo 50%
    final streakBonus = 1.0 +
        (streakDays * FitQuestConstants.streakBonusPerDay)
            .clamp(0, FitQuestConstants.maxStreakBonusPercent);

    return (baseXp * streakBonus).round();
  }

  // ============================================================================
  // LEVEL MANAGEMENT
  // ============================================================================

  /// Obtém o nível baseado no XP total
  int getLevelFromXp(int totalXp) {
    for (int level = 10; level >= 1; level--) {
      final threshold = FitQuestConstants.levelXpThresholds[level] ?? 0;
      if (totalXp >= threshold) return level;
    }
    return 1;
  }

  /// Obtém o título do nível
  String getLevelTitle(int level) {
    return FitQuestConstants.levelTitles[level.clamp(1, 10)] ?? 'Iniciante';
  }

  /// Obtém XP necessário para o próximo nível
  int getXpForNextLevel(int level) {
    if (level >= 10) return 0;
    final nextThreshold = FitQuestConstants.levelXpThresholds[level + 1] ?? 0;
    final currentThreshold = FitQuestConstants.levelXpThresholds[level] ?? 0;
    return nextThreshold - currentThreshold;
  }

  /// Obtém progresso de XP dentro do nível atual
  int getXpProgressInLevel(int totalXp, int level) {
    final currentThreshold = FitQuestConstants.levelXpThresholds[level] ?? 0;
    return totalXp - currentThreshold;
  }

  /// Verifica se houve level up
  bool didLevelUp(int oldXp, int newXp) {
    return getLevelFromXp(oldXp) < getLevelFromXp(newXp);
  }

  // ============================================================================
  // STREAK MANAGEMENT
  // ============================================================================

  /// Atualiza streak baseado na data do último treino
  int updateStreak({
    required DateTime? lastWorkout,
    required int currentStreak,
  }) {
    if (lastWorkout == null) return 1;

    final now = DateTime.now();
    final hoursDiff = now.difference(lastWorkout).inHours;

    // Se passou mais de 36 horas, perde o streak
    if (hoursDiff > FitQuestConstants.maxHoursBetweenWorkouts) {
      return 1;
    }

    // Se for no mesmo dia, mantém o streak
    if (_isSameDay(lastWorkout, now)) {
      return currentStreak;
    }

    // Se for no dia seguinte, incrementa
    return currentStreak + 1;
  }

  /// Verifica se o streak foi perdido
  bool isStreakLost({
    required DateTime? lastWorkout,
  }) {
    if (lastWorkout == null) return false;

    final hoursDiff = DateTime.now().difference(lastWorkout).inHours;
    return hoursDiff > FitQuestConstants.maxHoursBetweenWorkouts;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ============================================================================
  // WEEKLY CHALLENGE GENERATION
  // ============================================================================

  /// Gera um novo desafio semanal baseado no perfil do usuário
  WeeklyChallenge generateWeeklyChallenge(UserFitnessProfile profile) {
    final templates = FitQuestConstants.challengeTemplates;
    final templateIndex = _random.nextInt(templates.length);
    final template = templates[templateIndex];

    final type = template['type'] as ChallengeType;
    final baseTarget = template['baseTarget'] as int;
    final levelMultiplier = template['levelMultiplier'] as double;
    final xpReward = template['xpReward'] as int;

    // Ajusta meta baseado no nível
    final target = (baseTarget * pow(levelMultiplier, profile.currentLevel - 1)).round();

    // Calcula XP com bônus de nível
    final finalXpReward = (xpReward *
            (1 + profile.currentLevel * FitQuestConstants.challengeXpMultiplier))
        .round();

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 7));

    final title = (template['title'] as String)
        .replaceAll('{target}', target.toString());
    final description = (template['description'] as String)
        .replaceAll('{target}', target.toString());

    return WeeklyChallenge(
      id: _uuid.v4(),
      title: title,
      description: description,
      type: type,
      target: target,
      currentProgress: 0,
      startDate: startDate,
      endDate: endDate,
      xpReward: finalXpReward,
    );
  }

  // ============================================================================
  // ACHIEVEMENT CHECKING
  // ============================================================================

  /// Verifica conquistas e retorna as que foram desbloqueadas
  List<AchievementWithProgress> checkAchievements(UserFitnessProfile profile) {
    final results = <AchievementWithProgress>[];

    for (final achievement in FitQuestConstants.achievements) {
      final progress = _getAchievementProgress(achievement, profile);
      final isUnlocked = progress >= achievement.target;

      results.add(AchievementWithProgress(
        definition: achievement,
        currentProgress: progress,
        isUnlocked: isUnlocked,
        unlockedAt: isUnlocked && profile.unlockedAchievements.contains(achievement.id)
            ? DateTime.now()
            : null,
      ));
    }

    return results;
  }

  /// Obtém conquistas recém-desbloqueadas
  List<AchievementDefinition> getNewlyUnlockedAchievements(
    UserFitnessProfile oldProfile,
    UserFitnessProfile newProfile,
  ) {
    final newlyUnlocked = <AchievementDefinition>[];

    for (final achievement in FitQuestConstants.achievements) {
      final oldProgress = _getAchievementProgress(achievement, oldProfile);
      final newProgress = _getAchievementProgress(achievement, newProfile);

      final wasUnlocked = oldProgress >= achievement.target;
      final isNowUnlocked = newProgress >= achievement.target;

      if (!wasUnlocked && isNowUnlocked) {
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  int _getAchievementProgress(
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
        return _getSpecialAchievementProgress(achievement.id, profile);
    }
  }

  int _getSpecialAchievementProgress(
    String achievementId,
    UserFitnessProfile profile,
  ) {
    switch (achievementId) {
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

  // ============================================================================
  // CHALLENGE PROGRESS
  // ============================================================================

  /// Atualiza progresso do desafio semanal
  WeeklyChallenge updateChallengeProgress({
    required WeeklyChallenge challenge,
    required int durationMinutes,
    required int calories,
    required int newStreak,
  }) {
    if (challenge.isCompleted || challenge.isExpired) return challenge;

    int newProgress;
    switch (challenge.type) {
      case ChallengeType.minutos:
        newProgress = challenge.currentProgress + durationMinutes;
        break;
      case ChallengeType.calorias:
        newProgress = challenge.currentProgress + calories;
        break;
      case ChallengeType.sessoes:
        newProgress = challenge.currentProgress + 1;
        break;
      case ChallengeType.streak:
        newProgress = newStreak;
        break;
    }

    final isCompleted = newProgress >= challenge.target;

    return challenge.copyWith(
      currentProgress: newProgress,
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );
  }

  // ============================================================================
  // SPECIAL ACHIEVEMENTS TRACKING
  // ============================================================================

  /// Verifica se treino é "Early Bird" (antes das 7h)
  bool isEarlyBirdWorkout(DateTime workoutTime) {
    return workoutTime.hour < 7;
  }

  /// Verifica se treino é "Night Owl" (após 21h)
  bool isNightOwlWorkout(DateTime workoutTime) {
    return workoutTime.hour >= 21;
  }

  /// Verifica se treino é "Weekend Warrior" (fim de semana)
  bool isWeekendWorkout(DateTime workoutTime) {
    return workoutTime.weekday == DateTime.saturday ||
        workoutTime.weekday == DateTime.sunday;
  }
}
