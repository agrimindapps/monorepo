import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../drift_database/daos/water_dao.dart';
import '../../../../drift_database/nutrituti_database.dart';
import '../models/water_achievement_model.dart';
import '../models/water_record_model.dart';
import '../../domain/entities/water_achievement.dart' as domain;

/// Local data source for water intake data
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
  Future<WaterAchievementModel> addAchievement(
    WaterAchievementModel achievement,
  );

  /// Check if a specific achievement exists
  Future<bool> hasAchievement(String achievementId);

  /// Clear all local data (for testing/logout)
  Future<void> clearAllData();
}

class WaterLocalDataSourceImpl implements WaterLocalDataSource {
  static const String _dailyGoalKey = 'water_daily_goal';
  static const String _currentStreakKey = 'water_current_streak';
  static const int _defaultDailyGoal = 2000; // 2000ml = 2 liters

  final SharedPreferences _prefs;
  final WaterDao _waterDao;

  WaterLocalDataSourceImpl(this._prefs, this._waterDao);

  @override
  Future<WaterRecordModel> addRecord(WaterRecordModel record) async {
    try {
      final companion = WaterRecordsCompanion(
        id: drift.Value(record.id),
        amount: drift.Value(record.amount),
        timestamp: drift.Value(record.timestamp),
        note: drift.Value(record.note),
      );
      await _waterDao.addRecord(companion);
      return record;
    } catch (e) {
      throw CacheException('Failed to add water record: $e');
    }
  }

  @override
  Future<WaterRecordModel> updateRecord(WaterRecordModel record) async {
    try {
      final companion = WaterRecordsCompanion(
        id: drift.Value(record.id),
        amount: drift.Value(record.amount),
        timestamp: drift.Value(record.timestamp),
        note: drift.Value(record.note),
      );
      await _waterDao.updateRecord(record.id, companion);
      return record;
    } catch (e) {
      throw CacheException('Failed to update water record: $e');
    }
  }

  @override
  Future<void> deleteRecord(String id) async {
    try {
      await _waterDao.deleteRecord(id);
    } catch (e) {
      throw CacheException('Failed to delete water record: $e');
    }
  }

  @override
  Future<List<WaterRecordModel>> getRecords() async {
    try {
      final records = await _waterDao.getAllRecords();
      return records.map(_recordFromDrift).toList();
    } catch (e) {
      throw CacheException('Failed to get water records: $e');
    }
  }

  @override
  Future<List<WaterRecordModel>> getRecordsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final records = await _waterDao.getRecordsByDateRange(
        startOfDay,
        endOfDay,
      );
      return records.map(_recordFromDrift).toList();
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
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      final records = await _waterDao.getRecordsByDateRange(start, end);
      return records.map(_recordFromDrift).toList();
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
      final achievements = await _waterDao.getAllAchievements();
      return achievements.map(_achievementFromDrift).toList();
    } catch (e) {
      throw CacheException('Failed to get achievements: $e');
    }
  }

  @override
  Future<WaterAchievementModel> addAchievement(
    WaterAchievementModel achievement,
  ) async {
    try {
      // Check if achievement already exists
      final existing = await _waterDao.getAchievementById(achievement.id);
      if (existing != null) {
        throw CacheException('Achievement already exists: ${achievement.id}');
      }

      final companion = WaterAchievementsCompanion(
        id: drift.Value(achievement.id),
        type: drift.Value(achievement.type.toString().split('.').last),
        title: drift.Value(achievement.title),
        description: drift.Value(achievement.description),
        unlockedAt: drift.Value(achievement.unlockedAt),
        iconName: drift.Value(achievement.iconName),
      );

      await _waterDao.addAchievement(companion);
      return achievement;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to add achievement: $e');
    }
  }

  @override
  Future<bool> hasAchievement(String achievementId) async {
    try {
      final achievement = await _waterDao.getAchievementById(achievementId);
      return achievement != null;
    } catch (e) {
      throw CacheException('Failed to check achievement: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _waterDao.deleteAllRecords();
      await _waterDao.deleteAllAchievements();
      await _prefs.remove(_dailyGoalKey);
      await _prefs.remove(_currentStreakKey);
    } catch (e) {
      throw CacheException('Failed to clear all data: $e');
    }
  }

  // Conversion methods
  WaterRecordModel _recordFromDrift(WaterRecord record) {
    return WaterRecordModel(
      id: record.id,
      amount: record.amount,
      timestamp: record.timestamp,
      note: record.note,
    );
  }

  WaterAchievementModel _achievementFromDrift(WaterAchievement achievement) {
    return WaterAchievementModel(
      id: achievement.id,
      type: _parseAchievementType(achievement.type),
      title: achievement.title,
      description: achievement.description,
      unlockedAt: achievement.unlockedAt,
      iconName: achievement.iconName,
    );
  }

  domain.AchievementType _parseAchievementType(String type) {
    switch (type) {
      case 'firstRecord':
        return domain.AchievementType.firstRecord;
      case 'threeDayStreak':
        return domain.AchievementType.threeDayStreak;
      case 'sevenDayStreak':
        return domain.AchievementType.sevenDayStreak;
      case 'monthlyGoal':
        return domain.AchievementType.monthlyGoal;
      case 'perfectWeek':
        return domain.AchievementType.perfectWeek;
      case 'hydrationHero':
        return domain.AchievementType.hydrationHero;
      default:
        return domain.AchievementType.firstRecord;
    }
  }
}
