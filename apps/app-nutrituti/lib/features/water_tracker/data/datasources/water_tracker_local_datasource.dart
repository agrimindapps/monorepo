import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../../../../drift_database/nutrituti_database.dart';
import '../../../../drift_database/daos/water_tracker_dao.dart';
import '../../domain/entities/water_record_entity.dart';
import '../../domain/entities/water_goal_entity.dart';
import '../../domain/entities/water_streak_entity.dart';
import '../../domain/entities/water_achievement_entity.dart';
import '../../domain/entities/water_custom_cup_entity.dart';
import '../../domain/entities/water_reminder_entity.dart';
import '../../domain/entities/water_daily_progress_entity.dart';

/// Data source for Water Tracker using Drift
class WaterTrackerLocalDatasource {
  final WaterTrackerDao _dao;
  final _uuid = const Uuid();

  WaterTrackerLocalDatasource(this._dao);

  // ==================== RECORDS ====================

  Future<WaterRecordEntity> addRecord({
    required int amountMl,
    String? note,
    String? cupType,
  }) async {
    final id = _uuid.v4();
    final timestamp = DateTime.now();
    
    await _dao.addRecord(WaterRecordsCompanion.insert(
      id: id,
      amount: amountMl,
      timestamp: timestamp,
      note: drift.Value(note),
    ));

    return WaterRecordEntity(
      id: id,
      amountMl: amountMl,
      timestamp: timestamp,
      note: note,
      cupType: cupType,
    );
  }

  Future<List<WaterRecordEntity>> getTodayRecords() async {
    final records = await _dao.getTodayRecords();
    return records.map(_mapRecordToEntity).toList();
  }

  Stream<List<WaterRecordEntity>> watchTodayRecords() {
    return _dao.watchTodayRecords().map(
      (records) => records.map(_mapRecordToEntity).toList(),
    );
  }

  Future<List<WaterRecordEntity>> getRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final records = await _dao.getRecordsByDateRange(start, end);
    return records.map(_mapRecordToEntity).toList();
  }

  Future<void> deleteRecord(String id) async {
    await _dao.deleteRecord(id);
  }

  Future<int> getTodayTotal() async {
    return await _dao.getTodayTotal();
  }

  Stream<int> watchTodayTotal() {
    return _dao.watchTodayTotal();
  }

  // ==================== GOALS ====================

  Future<WaterGoalEntity> getCurrentGoal() async {
    final goal = await _dao.getCurrentGoal();
    if (goal == null) {
      return WaterGoalEntity.defaultGoal();
    }
    return _mapGoalToEntity(goal);
  }

  Stream<WaterGoalEntity> watchCurrentGoal() {
    return _dao.watchCurrentGoal().map(
      (goal) => goal != null ? _mapGoalToEntity(goal) : WaterGoalEntity.defaultGoal(),
    );
  }

  Future<WaterGoalEntity> upsertGoal(WaterGoalEntity goal) async {
    await _dao.upsertGoal(WaterGoalsCompanion(
      id: drift.Value(goal.id),
      dailyGoalMl: drift.Value(goal.dailyGoalMl),
      weightKg: drift.Value(goal.weightKg),
      calculatedGoalMl: drift.Value(goal.calculatedGoalMl),
      useCalculatedGoal: drift.Value(goal.useCalculatedGoal),
      activityAdjustmentMl: drift.Value(goal.activityAdjustmentMl),
      createdAt: drift.Value(goal.createdAt),
      updatedAt: drift.Value(DateTime.now()),
    ));
    return goal.copyWith(updatedAt: DateTime.now());
  }

  // ==================== STREAKS ====================

  Future<WaterStreakEntity> getCurrentStreak() async {
    final streak = await _dao.getCurrentStreak();
    if (streak == null) {
      return WaterStreakEntity.empty();
    }
    return _mapStreakToEntity(streak);
  }

  Stream<WaterStreakEntity> watchCurrentStreak() {
    return _dao.watchCurrentStreak().map(
      (streak) => streak != null ? _mapStreakToEntity(streak) : WaterStreakEntity.empty(),
    );
  }

  Future<void> incrementStreak() async {
    await _dao.incrementStreak();
  }

  Future<void> resetStreak() async {
    await _dao.resetStreak();
  }

  Future<void> upsertStreak(WaterStreakEntity streak) async {
    await _dao.upsertStreak(WaterStreaksCompanion(
      id: drift.Value(streak.id),
      currentStreak: drift.Value(streak.currentStreak),
      bestStreak: drift.Value(streak.bestStreak),
      lastRecordDate: drift.Value(streak.lastRecordDate),
      streakStartDate: drift.Value(streak.streakStartDate),
      canRecover: drift.Value(streak.canRecover),
      updatedAt: drift.Value(DateTime.now()),
    ));
  }

  // ==================== CUSTOM CUPS ====================

  Future<List<WaterCustomCupEntity>> getAllCustomCups() async {
    final cups = await _dao.getAllCustomCups();
    return cups.map(_mapCupToEntity).toList();
  }

  Stream<List<WaterCustomCupEntity>> watchAllCustomCups() {
    return _dao.watchAllCustomCups().map(
      (cups) => cups.map(_mapCupToEntity).toList(),
    );
  }

  Future<WaterCustomCupEntity> addCustomCup({
    required String name,
    required int amountMl,
    String? iconName,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final cups = await getAllCustomCups();
    final sortOrder = cups.length;

    await _dao.addCustomCup(WaterCustomCupsCompanion.insert(
      id: id,
      name: name,
      amountMl: amountMl,
      iconName: drift.Value(iconName),
      sortOrder: drift.Value(sortOrder),
      isDefault: const drift.Value(false),
      createdAt: now,
    ));

    return WaterCustomCupEntity(
      id: id,
      name: name,
      amountMl: amountMl,
      iconName: iconName,
      sortOrder: sortOrder,
      isDefault: false,
      createdAt: now,
    );
  }

  Future<void> updateCustomCup(WaterCustomCupEntity cup) async {
    await _dao.updateCustomCup(
      cup.id,
      WaterCustomCupsCompanion(
        name: drift.Value(cup.name),
        amountMl: drift.Value(cup.amountMl),
        iconName: drift.Value(cup.iconName),
        sortOrder: drift.Value(cup.sortOrder),
      ),
    );
  }

  Future<void> deleteCustomCup(String id) async {
    await _dao.deleteCustomCup(id);
  }

  Future<void> initializeDefaultCups() async {
    await _dao.initializeDefaultCups();
  }

  // ==================== REMINDERS ====================

  Future<WaterReminderEntity> getReminderSettings() async {
    final settings = await _dao.getReminderSettings();
    if (settings == null) {
      return WaterReminderEntity.defaultSettings();
    }
    return _mapReminderToEntity(settings);
  }

  Stream<WaterReminderEntity> watchReminderSettings() {
    return _dao.watchReminderSettings().map(
      (settings) => settings != null 
          ? _mapReminderToEntity(settings) 
          : WaterReminderEntity.defaultSettings(),
    );
  }

  Future<void> upsertReminderSettings(WaterReminderEntity settings) async {
    await _dao.upsertReminder(WaterRemindersCompanion(
      id: drift.Value(settings.id),
      isEnabled: drift.Value(settings.isEnabled),
      intervalMinutes: drift.Value(settings.intervalMinutes),
      startTime: drift.Value(settings.startTime),
      endTime: drift.Value(settings.endTime),
      adaptiveReminders: drift.Value(settings.adaptiveReminders),
      adaptiveThresholdMinutes: drift.Value(settings.adaptiveThresholdMinutes),
      createdAt: drift.Value(settings.createdAt),
      updatedAt: drift.Value(DateTime.now()),
    ));
  }

  // ==================== DAILY PROGRESS ====================

  Future<WaterDailyProgressEntity?> getDailyProgress(DateTime date) async {
    final progress = await _dao.getDailyProgress(date);
    if (progress == null) return null;
    return _mapProgressToEntity(progress);
  }

  Stream<WaterDailyProgressEntity?> watchTodayProgress() {
    return _dao.watchTodayProgress().map(
      (progress) => progress != null ? _mapProgressToEntity(progress) : null,
    );
  }

  Future<List<WaterDailyProgressEntity>> getProgressRange(
    DateTime start,
    DateTime end,
  ) async {
    final progressList = await _dao.getDailyProgressRange(start, end);
    return progressList.map(_mapProgressToEntity).toList();
  }

  Future<void> updateDailyProgress(WaterDailyProgressEntity progress) async {
    await _dao.updateDailyProgress(WaterDailyProgressTableCompanion(
      id: drift.Value(progress.id),
      date: drift.Value(progress.date),
      totalMl: drift.Value(progress.totalMl),
      goalMl: drift.Value(progress.goalMl),
      goalAchieved: drift.Value(progress.goalAchieved),
      recordCount: drift.Value(progress.recordCount),
      firstRecordTime: drift.Value(progress.firstRecordTime),
      lastRecordTime: drift.Value(progress.lastRecordTime),
      updatedAt: drift.Value(DateTime.now()),
    ));
  }

  // ==================== ACHIEVEMENTS ====================

  Future<List<WaterAchievementEntity>> getAllAchievements() async {
    final achievements = await _dao.getAllAchievements();
    return achievements.map(_mapAchievementToEntity).toList();
  }

  Stream<List<WaterAchievementEntity>> watchAllAchievements() {
    return _dao.watchAllAchievements().map(
      (achievements) => achievements.map(_mapAchievementToEntity).toList(),
    );
  }

  Future<void> unlockAchievement(String type) async {
    await _dao.unlockAchievement(type);
  }

  Future<void> updateAchievementProgress(String type, int progress) async {
    await _dao.updateAchievementProgress(type, progress);
  }

  Future<void> initializeAchievements() async {
    await _dao.initializeAchievements();
  }

  // ==================== STATISTICS ====================

  Future<int> getTotalRecordsCount() async {
    return await _dao.getTotalRecordsCount();
  }

  Future<int> getDaysWithRecords() async {
    return await _dao.getDaysWithRecords();
  }

  Future<double> getAverageDaily(int days) async {
    return await _dao.getAverageDaily(days);
  }

  Future<List<MapEntry<DateTime, int>>> getWeeklyData() async {
    return await _dao.getWeeklyData();
  }

  // ==================== MAPPERS ====================

  WaterRecordEntity _mapRecordToEntity(WaterRecord record) {
    return WaterRecordEntity(
      id: record.id,
      amountMl: record.amount,
      timestamp: record.timestamp,
      note: record.note,
    );
  }

  WaterGoalEntity _mapGoalToEntity(WaterGoal goal) {
    return WaterGoalEntity(
      id: goal.id,
      dailyGoalMl: goal.dailyGoalMl,
      weightKg: goal.weightKg,
      calculatedGoalMl: goal.calculatedGoalMl,
      useCalculatedGoal: goal.useCalculatedGoal,
      activityAdjustmentMl: goal.activityAdjustmentMl,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
    );
  }

  WaterStreakEntity _mapStreakToEntity(WaterStreak streak) {
    return WaterStreakEntity(
      id: streak.id,
      currentStreak: streak.currentStreak,
      bestStreak: streak.bestStreak,
      lastRecordDate: streak.lastRecordDate,
      streakStartDate: streak.streakStartDate,
      canRecover: streak.canRecover,
      updatedAt: streak.updatedAt,
    );
  }

  WaterCustomCupEntity _mapCupToEntity(WaterCustomCup cup) {
    return WaterCustomCupEntity(
      id: cup.id,
      name: cup.name,
      amountMl: cup.amountMl,
      iconName: cup.iconName,
      sortOrder: cup.sortOrder,
      isDefault: cup.isDefault,
      createdAt: cup.createdAt,
    );
  }

  WaterReminderEntity _mapReminderToEntity(WaterReminder reminder) {
    return WaterReminderEntity(
      id: reminder.id,
      isEnabled: reminder.isEnabled,
      intervalMinutes: reminder.intervalMinutes,
      startTime: reminder.startTime,
      endTime: reminder.endTime,
      adaptiveReminders: reminder.adaptiveReminders,
      adaptiveThresholdMinutes: reminder.adaptiveThresholdMinutes,
      createdAt: reminder.createdAt,
      updatedAt: reminder.updatedAt,
    );
  }

  WaterDailyProgressEntity _mapProgressToEntity(WaterDailyProgress progress) {
    return WaterDailyProgressEntity(
      id: progress.id,
      date: progress.date,
      totalMl: progress.totalMl,
      goalMl: progress.goalMl,
      goalAchieved: progress.goalAchieved,
      recordCount: progress.recordCount,
      firstRecordTime: progress.firstRecordTime,
      lastRecordTime: progress.lastRecordTime,
      updatedAt: progress.updatedAt,
    );
  }

  WaterAchievementEntity _mapAchievementToEntity(WaterAchievement achievement) {
    return WaterAchievementEntity(
      id: achievement.id,
      type: WaterAchievementType.fromString(achievement.type),
      title: achievement.title,
      description: achievement.description,
      unlockedAt: achievement.unlockedAt,
      iconName: achievement.iconName,
      isUnlocked: achievement.isUnlocked,
      requiredValue: achievement.requiredValue,
      currentProgress: achievement.currentProgress,
      category: achievement.category,
    );
  }
}
