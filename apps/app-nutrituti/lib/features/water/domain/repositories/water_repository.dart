import 'package:app_nutrituti/core/error/failures.dart';
import 'package:app_nutrituti/features/water/domain/entities/water_achievement.dart';
import 'package:app_nutrituti/features/water/domain/entities/water_record.dart';
import 'package:dartz/dartz.dart';

/// Repository interface for water intake data
/// Follows Repository Pattern with Either Failure or T for error handling
abstract class WaterRepository {
  /// Add a new water record
  /// Returns the created record or a Failure
  Future<Either<Failure, WaterRecord>> addWaterRecord(WaterRecord record);

  /// Get all water records
  /// Returns list of records or a Failure
  Future<Either<Failure, List<WaterRecord>>> getWaterRecords();

  /// Get water records for a specific date
  /// Returns list of records for that day or a Failure
  Future<Either<Failure, List<WaterRecord>>> getWaterRecordsByDate(DateTime date);

  /// Get water records within a date range
  /// Returns list of records or a Failure
  Future<Either<Failure, List<WaterRecord>>> getWaterRecordsInRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Delete a water record by ID
  /// Returns Unit on success or a Failure
  Future<Either<Failure, Unit>> deleteWaterRecord(String id);

  /// Update an existing water record
  /// Returns the updated record or a Failure
  Future<Either<Failure, WaterRecord>> updateWaterRecord(WaterRecord record);

  /// Get the current daily water goal (ml)
  /// Returns the goal amount or a Failure
  Future<Either<Failure, int>> getDailyGoal();

  /// Update the daily water goal (ml)
  /// Returns the new goal amount or a Failure
  Future<Either<Failure, int>> updateDailyGoal(int goalAmount);

  /// Get all unlocked achievements
  /// Returns list of achievements or a Failure
  Future<Either<Failure, List<WaterAchievement>>> getAchievements();

  /// Add a new achievement
  /// Returns the created achievement or a Failure
  Future<Either<Failure, WaterAchievement>> addAchievement(WaterAchievement achievement);

  /// Check if a specific achievement has been unlocked
  /// Returns true/false or a Failure
  Future<Either<Failure, bool>> hasAchievement(AchievementType type);

  /// Get total water consumed for a specific date (ml)
  /// Returns total amount or a Failure
  Future<Either<Failure, int>> getTotalForDate(DateTime date);

  /// Get current streak (consecutive days meeting goal)
  /// Returns streak count or a Failure
  Future<Either<Failure, int>> getCurrentStreak();
}
