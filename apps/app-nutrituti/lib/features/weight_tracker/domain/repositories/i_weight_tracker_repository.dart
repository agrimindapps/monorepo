import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weight_achievement_entity.dart';
import '../entities/weight_goal_entity.dart';
import '../entities/weight_milestone_entity.dart';
import '../entities/weight_record_entity.dart';
import '../entities/weight_reminder_entity.dart';
import '../entities/weight_statistics_entity.dart';

/// Repository interface for Weight Tracker 2.0
abstract class IWeightTrackerRepository {
  // ==================== RECORDS ====================

  /// Add a new weight record
  Future<Either<Failure, WeightRecordEntity>> addWeightRecord({
    required double weightKg,
    String? note,
    WeightTimeOfDay timeOfDay,
  });

  /// Get all records
  Future<Either<Failure, List<WeightRecordEntity>>> getAllRecords();

  /// Get the latest record
  Future<Either<Failure, WeightRecordEntity?>> getLatestRecord();

  /// Watch latest record as stream
  Stream<Either<Failure, WeightRecordEntity?>> watchLatestRecord();

  /// Get records for a specific date range
  Future<Either<Failure, List<WeightRecordEntity>>> getRecordsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get last 30 days records
  Future<Either<Failure, List<WeightRecordEntity>>> getLast30DaysRecords();

  /// Watch last 30 days records
  Stream<Either<Failure, List<WeightRecordEntity>>> watchLast30DaysRecords();

  /// Update a record
  Future<Either<Failure, WeightRecordEntity>> updateRecord(
    WeightRecordEntity record,
  );

  /// Delete a record
  Future<Either<Failure, Unit>> deleteRecord(String id);

  // ==================== GOALS ====================

  /// Get current weight goal
  Future<Either<Failure, WeightGoalEntity>> getCurrentGoal();

  /// Watch current goal as stream
  Stream<Either<Failure, WeightGoalEntity>> watchCurrentGoal();

  /// Create or update goal
  Future<Either<Failure, WeightGoalEntity>> upsertGoal(WeightGoalEntity goal);

  // ==================== MILESTONES ====================

  /// Get all milestones
  Future<Either<Failure, List<WeightMilestoneEntity>>> getMilestones();

  /// Watch milestones as stream
  Stream<Either<Failure, List<WeightMilestoneEntity>>> watchMilestones();

  /// Generate milestones from goal
  Future<Either<Failure, Unit>> generateMilestones();

  /// Check and update milestone achievements
  Future<Either<Failure, List<WeightMilestoneEntity>>> checkMilestoneAchievements(
    double currentWeight,
  );

  // ==================== ACHIEVEMENTS ====================

  /// Get all achievements
  Future<Either<Failure, List<WeightAchievementEntity>>> getAchievements();

  /// Watch achievements as stream
  Stream<Either<Failure, List<WeightAchievementEntity>>> watchAchievements();

  /// Check and unlock achievements based on current progress
  Future<Either<Failure, List<WeightAchievementEntity>>> checkAndUnlockAchievements();

  /// Initialize default achievements
  Future<Either<Failure, Unit>> initializeAchievements();

  // ==================== REMINDERS ====================

  /// Get reminder settings
  Future<Either<Failure, WeightReminderEntity>> getReminderSettings();

  /// Watch reminder settings as stream
  Stream<Either<Failure, WeightReminderEntity>> watchReminderSettings();

  /// Update reminder settings
  Future<Either<Failure, WeightReminderEntity>> updateReminderSettings(
    WeightReminderEntity settings,
  );

  // ==================== STATISTICS ====================

  /// Get comprehensive statistics
  Future<Either<Failure, WeightStatisticsEntity>> getStatistics();

  /// Get weekly chart data
  Future<Either<Failure, List<MapEntry<DateTime, double>>>> getWeeklyChartData();

  /// Get monthly chart data
  Future<Either<Failure, List<MapEntry<DateTime, double>>>> getMonthlyChartData();
}
