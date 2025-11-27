import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../../../../drift_database/nutrituti_database.dart';
import '../../../../drift_database/daos/weight_tracker_dao.dart';
import '../../domain/entities/weight_record_entity.dart';
import '../../domain/entities/weight_goal_entity.dart';
import '../../domain/entities/weight_milestone_entity.dart';
import '../../domain/entities/weight_achievement_entity.dart';
import '../../domain/entities/weight_reminder_entity.dart';

/// Data source for Weight Tracker using Drift
class WeightTrackerLocalDatasource {
  final WeightTrackerDao _dao;
  final _uuid = const Uuid();

  WeightTrackerLocalDatasource(this._dao);

  // ==================== RECORDS ====================

  Future<WeightRecordEntity> addRecord({
    required double weightKg,
    String? note,
    WeightTimeOfDay timeOfDay = WeightTimeOfDay.morning,
  }) async {
    final id = _uuid.v4();
    final timestamp = DateTime.now();

    await _dao.addRecord(WeightRecordsCompanion.insert(
      id: id,
      weightKg: weightKg,
      timestamp: timestamp,
      note: drift.Value(note),
      timeOfDay: drift.Value(timeOfDay.value),
    ));

    return WeightRecordEntity(
      id: id,
      weightKg: weightKg,
      timestamp: timestamp,
      note: note,
      timeOfDay: timeOfDay,
    );
  }

  Future<List<WeightRecordEntity>> getAllRecords() async {
    final records = await _dao.getAllRecords();
    return records.map(_mapRecordToEntity).toList();
  }

  Future<WeightRecordEntity?> getLatestRecord() async {
    final record = await _dao.getLatestRecord();
    return record != null ? _mapRecordToEntity(record) : null;
  }

  Future<WeightRecordEntity?> getFirstRecord() async {
    final record = await _dao.getFirstRecord();
    return record != null ? _mapRecordToEntity(record) : null;
  }

  Stream<WeightRecordEntity?> watchLatestRecord() {
    return _dao.watchLatestRecord().map(
          (record) => record != null ? _mapRecordToEntity(record) : null,
        );
  }

  Future<List<WeightRecordEntity>> getRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final records = await _dao.getRecordsByDateRange(start, end);
    return records.map(_mapRecordToEntity).toList();
  }

  Future<List<WeightRecordEntity>> getLast30DaysRecords() async {
    final records = await _dao.getLast30DaysRecords();
    return records.map(_mapRecordToEntity).toList();
  }

  Stream<List<WeightRecordEntity>> watchLast30DaysRecords() {
    return _dao.watchLast30DaysRecords().map(
          (records) => records.map(_mapRecordToEntity).toList(),
        );
  }

  Future<WeightRecordEntity> updateRecord(WeightRecordEntity record) async {
    await _dao.updateRecord(
      record.id,
      WeightRecordsCompanion(
        weightKg: drift.Value(record.weightKg),
        note: drift.Value(record.note),
        timeOfDay: drift.Value(record.timeOfDay.value),
      ),
    );
    return record;
  }

  Future<void> deleteRecord(String id) async {
    await _dao.deleteRecord(id);
  }

  // ==================== GOALS ====================

  Future<WeightGoalEntity> getCurrentGoal() async {
    final goal = await _dao.getCurrentGoal();
    if (goal == null) {
      return WeightGoalEntity.defaultGoal();
    }
    return _mapGoalToEntity(goal);
  }

  Stream<WeightGoalEntity> watchCurrentGoal() {
    return _dao.watchCurrentGoal().map(
          (goal) =>
              goal != null ? _mapGoalToEntity(goal) : WeightGoalEntity.defaultGoal(),
        );
  }

  Future<WeightGoalEntity> upsertGoal(WeightGoalEntity goal) async {
    await _dao.upsertGoal(WeightGoalsCompanion(
      id: drift.Value(goal.id),
      targetWeight: drift.Value(goal.targetWeight),
      initialWeight: drift.Value(goal.initialWeight),
      heightCm: drift.Value(goal.heightCm),
      deadline: drift.Value(goal.deadline),
      createdAt: drift.Value(goal.createdAt),
      updatedAt: drift.Value(DateTime.now()),
    ));
    return goal.copyWith(updatedAt: DateTime.now());
  }

  // ==================== MILESTONES ====================

  Future<List<WeightMilestoneEntity>> getAllMilestones() async {
    final milestones = await _dao.getAllMilestones();
    return milestones.map(_mapMilestoneToEntity).toList();
  }

  Stream<List<WeightMilestoneEntity>> watchAllMilestones() {
    return _dao.watchAllMilestones().map(
          (milestones) => milestones.map(_mapMilestoneToEntity).toList(),
        );
  }

  Future<void> generateMilestonesFromGoal(
    double initialWeight,
    double targetWeight,
  ) async {
    await _dao.generateMilestonesFromGoal(initialWeight, targetWeight);
  }

  Future<void> achieveMilestone(String id) async {
    await _dao.achieveMilestone(id);
  }

  // ==================== ACHIEVEMENTS ====================

  Future<List<WeightAchievementEntity>> getAllAchievements() async {
    final achievements = await _dao.getAllAchievements();
    return achievements.map(_mapAchievementToEntity).toList();
  }

  Stream<List<WeightAchievementEntity>> watchAllAchievements() {
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

  // ==================== REMINDERS ====================

  Future<WeightReminderEntity> getReminderSettings() async {
    final settings = await _dao.getReminderSettings();
    if (settings == null) {
      return WeightReminderEntity.defaultSettings();
    }
    return _mapReminderToEntity(settings);
  }

  Stream<WeightReminderEntity> watchReminderSettings() {
    return _dao.watchReminderSettings().map(
          (settings) => settings != null
              ? _mapReminderToEntity(settings)
              : WeightReminderEntity.defaultSettings(),
        );
  }

  Future<void> upsertReminderSettings(WeightReminderEntity settings) async {
    await _dao.upsertReminder(WeightRemindersCompanion(
      id: drift.Value(settings.id),
      isEnabled: drift.Value(settings.isEnabled),
      time: drift.Value(settings.time),
      message: drift.Value(settings.message),
      createdAt: drift.Value(settings.createdAt),
      updatedAt: drift.Value(DateTime.now()),
    ));
  }

  // ==================== STATISTICS ====================

  Future<int> getTotalRecordsCount() async {
    return await _dao.getTotalRecordsCount();
  }

  Future<int> getConsecutiveDays() async {
    return await _dao.getConsecutiveDays();
  }

  Future<int> getMorningWeighCount() async {
    return await _dao.getMorningWeighCount();
  }

  Future<double?> getMinWeight() async {
    return await _dao.getMinWeight();
  }

  Future<double?> getMaxWeight() async {
    return await _dao.getMaxWeight();
  }

  Future<double?> getAverageWeight(int days) async {
    return await _dao.getAverageWeight(days);
  }

  Future<List<MapEntry<DateTime, double>>> getWeeklyData() async {
    return await _dao.getWeeklyData();
  }

  Future<List<MapEntry<DateTime, double>>> getMonthlyData() async {
    return await _dao.getMonthlyData();
  }

  // ==================== MAPPERS ====================

  WeightRecordEntity _mapRecordToEntity(WeightRecord record) {
    return WeightRecordEntity(
      id: record.id,
      weightKg: record.weightKg,
      timestamp: record.timestamp,
      note: record.note,
      timeOfDay: WeightTimeOfDay.fromString(record.timeOfDay),
    );
  }

  WeightGoalEntity _mapGoalToEntity(WeightGoal goal) {
    return WeightGoalEntity(
      id: goal.id,
      targetWeight: goal.targetWeight,
      initialWeight: goal.initialWeight,
      heightCm: goal.heightCm,
      deadline: goal.deadline,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
    );
  }

  WeightMilestoneEntity _mapMilestoneToEntity(WeightMilestone milestone) {
    return WeightMilestoneEntity(
      id: milestone.id,
      targetWeight: milestone.targetWeight,
      title: milestone.title,
      isAchieved: milestone.isAchieved,
      achievedAt: milestone.achievedAt,
      sortOrder: milestone.sortOrder,
      createdAt: milestone.createdAt,
    );
  }

  WeightAchievementEntity _mapAchievementToEntity(WeightAchievement achievement) {
    return WeightAchievementEntity(
      id: achievement.id,
      type: WeightAchievementType.fromString(achievement.type),
      title: achievement.title,
      description: achievement.description,
      emoji: achievement.emoji,
      unlockedAt: achievement.unlockedAt,
      isUnlocked: achievement.isUnlocked,
      requiredValue: achievement.requiredValue,
      currentProgress: achievement.currentProgress,
      category: achievement.category,
    );
  }

  WeightReminderEntity _mapReminderToEntity(WeightReminder reminder) {
    return WeightReminderEntity(
      id: reminder.id,
      isEnabled: reminder.isEnabled,
      time: reminder.time,
      message: reminder.message,
      createdAt: reminder.createdAt,
      updatedAt: reminder.updatedAt,
    );
  }
}
