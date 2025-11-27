import 'dart:async';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:app_nutrituti/core/providers/dependency_providers.dart';
import 'package:app_nutrituti/drift_database/daos/water_tracker_dao.dart';
import 'package:app_nutrituti/features/water_tracker/data/datasources/water_tracker_local_datasource.dart';
import 'package:app_nutrituti/features/water_tracker/data/repositories/water_tracker_repository_impl.dart';
import 'package:app_nutrituti/features/water_tracker/data/services/water_notification_service.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_achievement_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_custom_cup_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_daily_progress_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_goal_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_record_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_reminder_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_statistics_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_streak_entity.dart';

part 'water_tracker_providers.g.dart';

// ==================== DEPENDENCY PROVIDERS ====================

@Riverpod(keepAlive: true)
WaterTrackerDao waterTrackerDao(Ref ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.waterTrackerDao;
}

@riverpod
WaterTrackerLocalDatasource waterTrackerLocalDatasource(Ref ref) {
  final dao = ref.watch(waterTrackerDaoProvider);
  return WaterTrackerLocalDatasource(dao);
}

@riverpod
WaterTrackerRepositoryImpl waterTrackerRepository(Ref ref) {
  final datasource = ref.watch(waterTrackerLocalDatasourceProvider);
  final logger = Logger();
  return WaterTrackerRepositoryImpl(datasource, logger);
}

// ==================== TODAY PROGRESS ====================

@riverpod
class TodayProgress extends _$TodayProgress {
  @override
  FutureOr<WaterDailyProgressEntity> build() async {
    final repository = ref.watch(waterTrackerRepositoryProvider);
    final result = await repository.getTodayProgress();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (progress) => progress,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.getTodayProgress();
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (progress) => AsyncValue.data(progress),
    );
  }
}

// ==================== TODAY RECORDS ====================

@riverpod
class TodayRecords extends _$TodayRecords {
  @override
  FutureOr<List<WaterRecordEntity>> build() async {
    final repository = ref.watch(waterTrackerRepositoryProvider);
    final result = await repository.getTodayRecords();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (records) => records,
    );
  }

  Future<void> addRecord(int amountMl, {String? note, String? cupType}) async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.addWaterRecord(
      amountMl: amountMl,
      note: note,
      cupType: cupType,
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.invalidateSelf();
        ref.invalidate(todayProgressProvider);
        ref.invalidate(currentStreakProvider);
        ref.invalidate(achievementsProvider);
        ref.invalidate(statisticsProvider);
      },
    );
  }

  Future<void> deleteRecord(String id) async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.deleteRecord(id);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.invalidateSelf();
        ref.invalidate(todayProgressProvider);
      },
    );
  }
}

// ==================== GOAL ====================

@riverpod
class WaterGoal extends _$WaterGoal {
  @override
  FutureOr<WaterGoalEntity> build() async {
    final repository = ref.watch(waterTrackerRepositoryProvider);
    final result = await repository.getCurrentGoal();
    return result.fold(
      (failure) => WaterGoalEntity.defaultGoal(),
      (goal) => goal,
    );
  }

  Future<void> updateDailyGoal(int goalMl) async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.updateDailyGoal(goalMl);

    result.fold(
      (failure) => throw Exception(failure.message),
      (goal) {
        state = AsyncValue.data(goal);
        ref.invalidate(todayProgressProvider);
      },
    );
  }

  Future<void> updateGoalByWeight(double weightKg) async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.updateGoalByWeight(weightKg);

    result.fold(
      (failure) => throw Exception(failure.message),
      (goal) {
        state = AsyncValue.data(goal);
        ref.invalidate(todayProgressProvider);
      },
    );
  }

  Future<void> setActivityAdjustment(int adjustmentMl) async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.setActivityAdjustment(adjustmentMl);

    result.fold(
      (failure) => throw Exception(failure.message),
      (goal) {
        state = AsyncValue.data(goal);
        ref.invalidate(todayProgressProvider);
      },
    );
  }
}

// ==================== STREAK ====================

@riverpod
class CurrentStreak extends _$CurrentStreak {
  @override
  FutureOr<WaterStreakEntity> build() async {
    final repository = ref.watch(waterTrackerRepositoryProvider);
    
    // Check streak status on init
    await repository.checkAndUpdateStreakStatus();
    
    final result = await repository.getCurrentStreak();
    return result.fold(
      (failure) => WaterStreakEntity.empty(),
      (streak) => streak,
    );
  }

  Future<void> refresh() async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.getCurrentStreak();
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (streak) => AsyncValue.data(streak),
    );
  }
}

// ==================== CUSTOM CUPS ====================

@riverpod
class CustomCups extends _$CustomCups {
  @override
  FutureOr<List<WaterCustomCupEntity>> build() async {
    final repository = ref.watch(waterTrackerRepositoryProvider);
    
    // Initialize default cups if needed
    await repository.initializeDefaultCups();
    
    final result = await repository.getCustomCups();
    return result.fold(
      (failure) => [],
      (cups) => cups,
    );
  }

  Future<void> addCup({
    required String name,
    required int amountMl,
    String? iconName,
  }) async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.addCustomCup(
      name: name,
      amountMl: amountMl,
      iconName: iconName,
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> updateCup(WaterCustomCupEntity cup) async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.updateCustomCup(cup);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> deleteCup(String id) async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.deleteCustomCup(id);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidateSelf(),
    );
  }
}

// ==================== ACHIEVEMENTS ====================

@riverpod
class Achievements extends _$Achievements {
  @override
  FutureOr<List<WaterAchievementEntity>> build() async {
    final repository = ref.watch(waterTrackerRepositoryProvider);
    
    // Initialize achievements if needed
    await repository.initializeAchievements();
    
    final result = await repository.getAchievements();
    return result.fold(
      (failure) => [],
      (achievements) => achievements,
    );
  }

  Future<void> checkAchievements() async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.checkAndUnlockAchievements();

    result.fold(
      (failure) => throw Exception(failure.message),
      (achievements) => state = AsyncValue.data(achievements),
    );
  }
}

// ==================== REMINDER SETTINGS ====================

@riverpod
class ReminderSettings extends _$ReminderSettings {
  @override
  FutureOr<WaterReminderEntity> build() async {
    final repository = ref.watch(waterTrackerRepositoryProvider);
    final result = await repository.getReminderSettings();
    return result.fold(
      (failure) => WaterReminderEntity.defaultSettings(),
      (settings) => settings,
    );
  }

  Future<void> updateSettings(WaterReminderEntity settings) async {
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.updateReminderSettings(settings);

    result.fold(
      (failure) => throw Exception(failure.message),
      (updated) => state = AsyncValue.data(updated),
    );
  }
}

// ==================== STATISTICS ====================

@riverpod
class Statistics extends _$Statistics {
  @override
  FutureOr<WaterStatisticsEntity> build() async {
    final repository = ref.watch(waterTrackerRepositoryProvider);
    final result = await repository.getStatistics();
    return result.fold(
      (failure) => const WaterStatisticsEntity(),
      (stats) => stats,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.getStatistics();
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (stats) => AsyncValue.data(stats),
    );
  }
}

// ==================== WEEKLY CHART DATA ====================

@riverpod
class WeeklyChartData extends _$WeeklyChartData {
  @override
  FutureOr<List<MapEntry<DateTime, int>>> build() async {
    final repository = ref.watch(waterTrackerRepositoryProvider);
    final result = await repository.getWeeklyChartData();
    return result.fold(
      (failure) => [],
      (data) => data,
    );
  }
}

// ==================== CALENDAR DATA ====================

@riverpod
class CalendarData extends _$CalendarData {
  @override
  FutureOr<List<WaterDailyProgressEntity>> build() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final repository = ref.watch(waterTrackerRepositoryProvider);
    final result = await repository.getProgressRange(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    return result.fold(
      (failure) => [],
      (progress) => progress,
    );
  }

  Future<void> loadMonth(int year, int month) async {
    state = const AsyncValue.loading();
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0);
    
    final repository = ref.read(waterTrackerRepositoryProvider);
    final result = await repository.getProgressRange(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (progress) => AsyncValue.data(progress),
    );
  }
}

// ==================== DERIVED PROVIDERS ====================

/// Today's total water intake in ml
@riverpod
int todayTotalMl(Ref ref) {
  final progressAsync = ref.watch(todayProgressProvider);
  return progressAsync.maybeWhen(
    data: (progress) => progress.totalMl,
    orElse: () => 0,
  );
}

/// Today's progress percentage
@riverpod
double todayProgressPercentage(Ref ref) {
  final progressAsync = ref.watch(todayProgressProvider);
  return progressAsync.maybeWhen(
    data: (progress) => progress.progressPercentage,
    orElse: () => 0.0,
  );
}

/// Whether today's goal is achieved
@riverpod
bool isTodayGoalAchieved(Ref ref) {
  final progressAsync = ref.watch(todayProgressProvider);
  return progressAsync.maybeWhen(
    data: (progress) => progress.goalAchieved,
    orElse: () => false,
  );
}

/// Unlocked achievements only
@riverpod
List<WaterAchievementEntity> unlockedAchievements(Ref ref) {
  final achievementsAsync = ref.watch(achievementsProvider);
  return achievementsAsync.maybeWhen(
    data: (achievements) => achievements.where((a) => a.isUnlocked).toList(),
    orElse: () => [],
  );
}

/// Locked achievements only
@riverpod
List<WaterAchievementEntity> lockedAchievements(Ref ref) {
  final achievementsAsync = ref.watch(achievementsProvider);
  return achievementsAsync.maybeWhen(
    data: (achievements) => achievements.where((a) => !a.isUnlocked).toList(),
    orElse: () => [],
  );
}

// ==================== NOTIFICATION SERVICE ====================

/// Provider for the water notification service (singleton)
@Riverpod(keepAlive: true)
WaterNotificationService waterNotificationService(Ref ref) {
  return WaterNotificationService();
}

/// Manages notification scheduling based on reminder settings
@riverpod
class NotificationManager extends _$NotificationManager {
  @override
  FutureOr<bool> build() async {
    final service = ref.watch(waterNotificationServiceProvider);
    await service.initialize();
    
    // Watch for reminder settings changes
    final settingsAsync = ref.watch(reminderSettingsProvider);
    
    await settingsAsync.when(
      data: (settings) async {
        if (settings.isEnabled) {
          await service.scheduleWaterReminders(
            intervalMinutes: settings.intervalMinutes,
            startTime: settings.startTime,
            endTime: settings.endTime,
          );
        } else {
          await service.cancelAllReminders();
        }
      },
      loading: () async {},
      error: (_, __) async {},
    );
    
    return true;
  }
  
  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final service = ref.read(waterNotificationServiceProvider);
    return await service.requestPermissions();
  }
  
  /// Schedule adaptive reminder after recording water
  Future<void> scheduleAdaptiveReminder(DateTime lastRecordTime) async {
    final service = ref.read(waterNotificationServiceProvider);
    final settingsAsync = await ref.read(reminderSettingsProvider.future);
    
    if (settingsAsync.adaptiveReminders) {
      await service.scheduleAdaptiveReminder(
        lastRecordTime: lastRecordTime,
        thresholdMinutes: 180, // 3 hours
      );
    }
  }
  
  /// Show goal achieved notification
  Future<void> notifyGoalAchieved() async {
    final service = ref.read(waterNotificationServiceProvider);
    await service.showGoalAchievedNotification();
  }
  
  /// Show streak milestone notification
  Future<void> notifyStreakMilestone(int streakDays) async {
    final service = ref.read(waterNotificationServiceProvider);
    await service.showStreakNotification(streakDays);
  }
  
  /// Cancel all notifications
  Future<void> cancelAll() async {
    final service = ref.read(waterNotificationServiceProvider);
    await service.cancelAllReminders();
  }
}
