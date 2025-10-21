import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/water_achievement_model.dart';
import '../models/water_record_model.dart';

/// Local data source for water intake data using Hive and SharedPreferences
abstract class WaterLocalDataSource {
  /// Add a new water record
  Future<WaterRecordModel> addRecord(WaterRecordModel record);

  /// Update an existing water record
  Future<WaterRecordModel> updateRecord(WaterRecordModel record);

  /// Delete a water record by ID
  Future<void> deleteRecord(String id);

  /// Get all water records
  Future<List<WaterRecordModel>> getRecords();

  /// Get water records for a specific date
  Future<List<WaterRecordModel>> getRecordsByDate(DateTime date);

  /// Get water records within a date range
  Future<List<WaterRecordModel>> getRecordsInRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get the daily water goal (ml)
  Future<int> getDailyGoal();

  /// Set the daily water goal (ml)
  Future<void> setDailyGoal(int goal);

  /// Get the current streak count
  Future<int> getCurrentStreak();

  /// Update the streak count
  Future<void> updateStreak(int streak);

  /// Get all achievements
  Future<List<WaterAchievementModel>> getAchievements();

  /// Add a new achievement
  Future<WaterAchievementModel> addAchievement(WaterAchievementModel achievement);

  /// Check if a specific achievement exists
  Future<bool> hasAchievement(String achievementId);

  /// Clear all local data (for testing/logout)
  Future<void> clearAllData();
}

@Injectable(as: WaterLocalDataSource)
class WaterLocalDataSourceImpl implements WaterLocalDataSource {
  static const String _waterRecordsBoxName = 'water_records';
  static const String _waterAchievementsBoxName = 'water_achievements';
  static const String _dailyGoalKey = 'water_daily_goal';
  static const String _currentStreakKey = 'water_current_streak';
  static const int _defaultDailyGoal = 2000; // 2000ml = 2 liters

  final SharedPreferences _prefs;

  WaterLocalDataSourceImpl(this._prefs);

  /// Get or open the water records Hive box
  Future<Box<WaterRecordModel>> get _waterRecordsBox async {
    if (Hive.isBoxOpen(_waterRecordsBoxName)) {
      return Hive.box<WaterRecordModel>(_waterRecordsBoxName);
    }
    return await Hive.openBox<WaterRecordModel>(_waterRecordsBoxName);
  }

  /// Get or open the water achievements Hive box
  Future<Box<WaterAchievementModel>> get _achievementsBox async {
    if (Hive.isBoxOpen(_waterAchievementsBoxName)) {
      return Hive.box<WaterAchievementModel>(_waterAchievementsBoxName);
    }
    return await Hive.openBox<WaterAchievementModel>(_waterAchievementsBoxName);
  }

  @override
  Future<WaterRecordModel> addRecord(WaterRecordModel record) async {
    try {
      final box = await _waterRecordsBox;
      await box.put(record.id, record);
      return record;
    } catch (e) {
      throw CacheException('Failed to add water record: $e');
    }
  }

  @override
  Future<WaterRecordModel> updateRecord(WaterRecordModel record) async {
    try {
      final box = await _waterRecordsBox;

      if (!box.containsKey(record.id)) {
        throw CacheException('Water record not found: ${record.id}');
      }

      await box.put(record.id, record);
      return record;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to update water record: $e');
    }
  }

  @override
  Future<void> deleteRecord(String id) async {
    try {
      final box = await _waterRecordsBox;

      if (!box.containsKey(id)) {
        throw CacheException('Water record not found: $id');
      }

      await box.delete(id);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to delete water record: $e');
    }
  }

  @override
  Future<List<WaterRecordModel>> getRecords() async {
    try {
      final box = await _waterRecordsBox;
      return box.values.toList();
    } catch (e) {
      throw CacheException('Failed to get water records: $e');
    }
  }

  @override
  Future<List<WaterRecordModel>> getRecordsByDate(DateTime date) async {
    try {
      final box = await _waterRecordsBox;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return box.values
          .where((record) =>
              record.timestamp.isAfter(startOfDay) &&
              record.timestamp.isBefore(endOfDay))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      throw CacheException('Failed to get water records by date: $e');
    }
  }

  @override
  Future<List<WaterRecordModel>> getRecordsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final box = await _waterRecordsBox;
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      return box.values
          .where((record) =>
              record.timestamp.isAfter(start) && record.timestamp.isBefore(end))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      throw CacheException('Failed to get water records in range: $e');
    }
  }

  @override
  Future<int> getDailyGoal() async {
    try {
      return _prefs.getInt(_dailyGoalKey) ?? _defaultDailyGoal;
    } catch (e) {
      throw CacheException('Failed to get daily goal: $e');
    }
  }

  @override
  Future<void> setDailyGoal(int goal) async {
    try {
      if (goal <= 0) {
        throw CacheException('Daily goal must be greater than 0');
      }

      await _prefs.setInt(_dailyGoalKey, goal);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to set daily goal: $e');
    }
  }

  @override
  Future<int> getCurrentStreak() async {
    try {
      return _prefs.getInt(_currentStreakKey) ?? 0;
    } catch (e) {
      throw CacheException('Failed to get current streak: $e');
    }
  }

  @override
  Future<void> updateStreak(int streak) async {
    try {
      if (streak < 0) {
        throw CacheException('Streak cannot be negative');
      }

      await _prefs.setInt(_currentStreakKey, streak);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to update streak: $e');
    }
  }

  @override
  Future<List<WaterAchievementModel>> getAchievements() async {
    try {
      final box = await _achievementsBox;
      return box.values.toList()
        ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    } catch (e) {
      throw CacheException('Failed to get achievements: $e');
    }
  }

  @override
  Future<WaterAchievementModel> addAchievement(
      WaterAchievementModel achievement) async {
    try {
      final box = await _achievementsBox;

      // Check if achievement already exists
      if (box.containsKey(achievement.id)) {
        throw CacheException('Achievement already exists: ${achievement.id}');
      }

      await box.put(achievement.id, achievement);
      return achievement;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to add achievement: $e');
    }
  }

  @override
  Future<bool> hasAchievement(String achievementId) async {
    try {
      final box = await _achievementsBox;
      return box.containsKey(achievementId);
    } catch (e) {
      throw CacheException('Failed to check achievement: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      final recordsBox = await _waterRecordsBox;
      final achievementsBox = await _achievementsBox;

      await recordsBox.clear();
      await achievementsBox.clear();
      await _prefs.remove(_dailyGoalKey);
      await _prefs.remove(_currentStreakKey);
    } catch (e) {
      throw CacheException('Failed to clear all data: $e');
    }
  }
}
