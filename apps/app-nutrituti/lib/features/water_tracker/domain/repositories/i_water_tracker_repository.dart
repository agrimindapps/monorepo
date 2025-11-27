import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/water_achievement_entity.dart';
import '../entities/water_custom_cup_entity.dart';
import '../entities/water_daily_progress_entity.dart';
import '../entities/water_goal_entity.dart';
import '../entities/water_record_entity.dart';
import '../entities/water_reminder_entity.dart';
import '../entities/water_statistics_entity.dart';
import '../entities/water_streak_entity.dart';

/// Repository interface for Water Tracker 2.0
abstract class IWaterTrackerRepository {
  // ==================== RECORDS ====================

  /// Add a new water record
  Future<Either<Failure, WaterRecordEntity>> addWaterRecord({
    required int amountMl,
    String? note,
    String? cupType,
  });

  /// Get all records for today
  Future<Either<Failure, List<WaterRecordEntity>>> getTodayRecords();

  /// Watch today's records as stream
  Stream<Either<Failure, List<WaterRecordEntity>>> watchTodayRecords();

  /// Get records for a specific date range
  Future<Either<Failure, List<WaterRecordEntity>>> getRecordsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Delete a record
  Future<Either<Failure, Unit>> deleteRecord(String id);

  // ==================== GOALS ====================

  /// Get current water goal
  Future<Either<Failure, WaterGoalEntity>> getCurrentGoal();

  /// Watch current goal as stream
  Stream<Either<Failure, WaterGoalEntity>> watchCurrentGoal();

  /// Update daily goal manually
  Future<Either<Failure, WaterGoalEntity>> updateDailyGoal(int goalMl);

  /// Update goal based on weight (smart calculation)
  Future<Either<Failure, WaterGoalEntity>> updateGoalByWeight(double weightKg);

  /// Set activity adjustment for the day
  Future<Either<Failure, WaterGoalEntity>> setActivityAdjustment(int adjustmentMl);

  // ==================== STREAKS ====================

  /// Get current streak data
  Future<Either<Failure, WaterStreakEntity>> getCurrentStreak();

  /// Watch streak data as stream
  Stream<Either<Failure, WaterStreakEntity>> watchCurrentStreak();

  /// Update streak (called when goal is achieved)
  Future<Either<Failure, WaterStreakEntity>> updateStreakOnGoalAchieved();

  /// Check and update streak status (called on app start)
  Future<Either<Failure, WaterStreakEntity>> checkAndUpdateStreakStatus();

  // ==================== CUSTOM CUPS ====================

  /// Get all custom cups
  Future<Either<Failure, List<WaterCustomCupEntity>>> getCustomCups();

  /// Watch custom cups as stream
  Stream<Either<Failure, List<WaterCustomCupEntity>>> watchCustomCups();

  /// Add a new custom cup
  Future<Either<Failure, WaterCustomCupEntity>> addCustomCup({
    required String name,
    required int amountMl,
    String? iconName,
  });

  /// Update a custom cup
  Future<Either<Failure, WaterCustomCupEntity>> updateCustomCup(
    WaterCustomCupEntity cup,
  );

  /// Delete a custom cup
  Future<Either<Failure, Unit>> deleteCustomCup(String id);

  /// Initialize default cups (on first run)
  Future<Either<Failure, Unit>> initializeDefaultCups();

  // ==================== REMINDERS ====================

  /// Get reminder settings
  Future<Either<Failure, WaterReminderEntity>> getReminderSettings();

  /// Watch reminder settings as stream
  Stream<Either<Failure, WaterReminderEntity>> watchReminderSettings();

  /// Update reminder settings
  Future<Either<Failure, WaterReminderEntity>> updateReminderSettings(
    WaterReminderEntity settings,
  );

  // ==================== ACHIEVEMENTS ====================

  /// Get all achievements
  Future<Either<Failure, List<WaterAchievementEntity>>> getAchievements();

  /// Watch achievements as stream
  Stream<Either<Failure, List<WaterAchievementEntity>>> watchAchievements();

  /// Check and unlock achievements based on current progress
  Future<Either<Failure, List<WaterAchievementEntity>>> checkAndUnlockAchievements();

  /// Initialize default achievements
  Future<Either<Failure, Unit>> initializeAchievements();

  // ==================== DAILY PROGRESS ====================

  /// Get today's progress
  Future<Either<Failure, WaterDailyProgressEntity>> getTodayProgress();

  /// Watch today's progress as stream
  Stream<Either<Failure, WaterDailyProgressEntity>> watchTodayProgress();

  /// Get progress for a date range (for calendar view)
  Future<Either<Failure, List<WaterDailyProgressEntity>>> getProgressRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  // ==================== STATISTICS ====================

  /// Get comprehensive statistics
  Future<Either<Failure, WaterStatisticsEntity>> getStatistics();

  /// Get weekly data for chart
  Future<Either<Failure, List<MapEntry<DateTime, int>>>> getWeeklyChartData();
}
