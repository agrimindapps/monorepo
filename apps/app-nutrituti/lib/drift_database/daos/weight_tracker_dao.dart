import 'package:drift/drift.dart';
import '../nutrituti_database.dart';
import '../tables/weight_records_table.dart';
import '../tables/weight_achievements_table.dart';
import '../tables/weight_goals_table.dart';
import '../tables/weight_milestones_table.dart';
import '../tables/weight_reminders_table.dart';
import '../tables/weight_daily_stats_table.dart';

part 'weight_tracker_dao.g.dart';

@DriftAccessor(tables: [
  WeightRecords,
  WeightAchievements,
  WeightGoals,
  WeightMilestones,
  WeightReminders,
  WeightDailyStats,
])
class WeightTrackerDao extends DatabaseAccessor<NutritutiDatabase>
    with _$WeightTrackerDaoMixin {
  WeightTrackerDao(super.db);

  // ==================== WEIGHT RECORDS ====================

  Future<List<WeightRecord>> getAllRecords() {
    return (select(weightRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  Future<List<WeightRecord>> getRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(weightRecords)
          ..where((tbl) =>
              tbl.timestamp.isBiggerOrEqualValue(start) &
              tbl.timestamp.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  Future<WeightRecord?> getLatestRecord() {
    return (select(weightRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<WeightRecord?> getFirstRecord() {
    return (select(weightRecords)
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<WeightRecord?> watchLatestRecord() {
    return (select(weightRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<int> addRecord(WeightRecordsCompanion record) {
    return into(weightRecords).insert(record);
  }

  Future<int> deleteRecord(String id) {
    return (delete(weightRecords)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> updateRecord(String id, WeightRecordsCompanion record) {
    return (update(weightRecords)..where((t) => t.id.equals(id))).write(record);
  }

  Future<List<WeightRecord>> getLast30DaysRecords() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 30);
    return getRecordsByDateRange(start, now);
  }

  Stream<List<WeightRecord>> watchLast30DaysRecords() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 30);
    return (select(weightRecords)
          ..where((tbl) =>
              tbl.timestamp.isBiggerOrEqualValue(start) &
              tbl.timestamp.isSmallerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .watch();
  }

  // ==================== GOALS ====================

  Future<WeightGoal?> getCurrentGoal() {
    return (select(weightGoals)..limit(1)).getSingleOrNull();
  }

  Stream<WeightGoal?> watchCurrentGoal() {
    return (select(weightGoals)..limit(1)).watchSingleOrNull();
  }

  Future<void> upsertGoal(WeightGoalsCompanion goal) async {
    final existing = await getCurrentGoal();
    if (existing != null) {
      await (update(weightGoals)..where((t) => t.id.equals(existing.id)))
          .write(goal);
    } else {
      await into(weightGoals).insert(goal);
    }
  }

  // ==================== MILESTONES ====================

  Future<List<WeightMilestone>> getAllMilestones() {
    return (select(weightMilestones)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Stream<List<WeightMilestone>> watchAllMilestones() {
    return (select(weightMilestones)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<int> addMilestone(WeightMilestonesCompanion milestone) {
    return into(weightMilestones).insert(milestone);
  }

  Future<int> updateMilestone(String id, WeightMilestonesCompanion milestone) {
    return (update(weightMilestones)..where((t) => t.id.equals(id)))
        .write(milestone);
  }

  Future<int> deleteMilestone(String id) {
    return (delete(weightMilestones)..where((t) => t.id.equals(id))).go();
  }

  Future<void> achieveMilestone(String id) async {
    await (update(weightMilestones)..where((t) => t.id.equals(id))).write(
      WeightMilestonesCompanion(
        isAchieved: const Value(true),
        achievedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> generateMilestonesFromGoal(
    double initialWeight,
    double targetWeight,
  ) async {
    // Clear existing milestones
    await delete(weightMilestones).go();

    final isLosingWeight = targetWeight < initialWeight;
    final totalChange = (initialWeight - targetWeight).abs();
    final milestoneInterval = 2.0; // Every 2kg

    final numMilestones = (totalChange / milestoneInterval).floor();
    final now = DateTime.now();

    for (int i = 1; i <= numMilestones && i <= 10; i++) {
      final milestoneWeight = isLosingWeight
          ? initialWeight - (i * milestoneInterval)
          : initialWeight + (i * milestoneInterval);

      await into(weightMilestones).insert(WeightMilestonesCompanion.insert(
        id: 'milestone_$i',
        targetWeight: milestoneWeight,
        title: isLosingWeight
            ? '-${(i * milestoneInterval).toStringAsFixed(0)}kg'
            : '+${(i * milestoneInterval).toStringAsFixed(0)}kg',
        sortOrder: Value(i),
        createdAt: now,
      ));
    }
  }

  // ==================== ACHIEVEMENTS ====================

  Future<List<WeightAchievement>> getAllAchievements() {
    return (select(weightAchievements)
          ..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
        .get();
  }

  Stream<List<WeightAchievement>> watchAllAchievements() {
    return (select(weightAchievements)
          ..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
        .watch();
  }

  Future<WeightAchievement?> getAchievementByType(String type) {
    return (select(weightAchievements)..where((t) => t.type.equals(type)))
        .getSingleOrNull();
  }

  Future<void> upsertAchievement(WeightAchievementsCompanion achievement) async {
    final existing = await getAchievementByType(achievement.type.value);
    if (existing != null) {
      await (update(weightAchievements)..where((t) => t.id.equals(existing.id)))
          .write(achievement);
    } else {
      await into(weightAchievements).insert(achievement);
    }
  }

  Future<void> unlockAchievement(String type) async {
    await (update(weightAchievements)..where((t) => t.type.equals(type))).write(
      WeightAchievementsCompanion(
        isUnlocked: const Value(true),
        unlockedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateAchievementProgress(String type, int progress) async {
    await (update(weightAchievements)..where((t) => t.type.equals(type))).write(
      WeightAchievementsCompanion(
        currentProgress: Value(progress),
      ),
    );
  }

  Future<void> initializeAchievements() async {
    final existing = await getAllAchievements();
    if (existing.isEmpty) {
      final achievements = [
        WeightAchievementsCompanion.insert(
          id: 'first_weigh',
          type: 'first_weigh',
          title: 'Primeira Pesagem',
          description: 'Registre seu primeiro peso',
          emoji: '📝',
          requiredValue: const Value(1),
          category: const Value('beginner'),
        ),
        WeightAchievementsCompanion.insert(
          id: 'consistent_7',
          type: 'consistent_7',
          title: 'Consistente',
          description: 'Pese-se por 7 dias seguidos',
          emoji: '📅',
          requiredValue: const Value(7),
          category: const Value('streak'),
        ),
        WeightAchievementsCompanion.insert(
          id: 'month_complete',
          type: 'month_complete',
          title: 'Mês Completo',
          description: 'Registre 30 pesagens',
          emoji: '🗓️',
          requiredValue: const Value(30),
          category: const Value('milestone'),
        ),
        WeightAchievementsCompanion.insert(
          id: 'lost_2kg',
          type: 'lost_2kg',
          title: 'Perdeu 2kg',
          description: 'Perdeu 2kg do peso inicial',
          emoji: '🎯',
          requiredValue: const Value(2),
          category: const Value('progress'),
        ),
        WeightAchievementsCompanion.insert(
          id: 'lost_5kg',
          type: 'lost_5kg',
          title: 'Perdeu 5kg',
          description: 'Perdeu 5kg do peso inicial',
          emoji: '⭐',
          requiredValue: const Value(5),
          category: const Value('progress'),
        ),
        WeightAchievementsCompanion.insert(
          id: 'lost_10kg',
          type: 'lost_10kg',
          title: 'Perdeu 10kg',
          description: 'Perdeu 10kg do peso inicial',
          emoji: '🏆',
          requiredValue: const Value(10),
          category: const Value('progress'),
        ),
        WeightAchievementsCompanion.insert(
          id: 'healthy_bmi',
          type: 'healthy_bmi',
          title: 'IMC Saudável',
          description: 'Alcançou IMC entre 18.5-24.9',
          emoji: '💚',
          requiredValue: const Value(1),
          category: const Value('health'),
        ),
        WeightAchievementsCompanion.insert(
          id: 'goal_reached',
          type: 'goal_reached',
          title: 'Meta Atingida',
          description: 'Chegou no peso meta',
          emoji: '👑',
          requiredValue: const Value(1),
          category: const Value('goal'),
        ),
        WeightAchievementsCompanion.insert(
          id: 'halfway',
          type: 'halfway',
          title: 'Metade do Caminho',
          description: 'Atingiu 50% da meta',
          emoji: '🚀',
          requiredValue: const Value(50),
          category: const Value('progress'),
        ),
        WeightAchievementsCompanion.insert(
          id: 'early_riser',
          type: 'early_riser',
          title: 'Madrugador',
          description: 'Pesou de manhã por 7 dias',
          emoji: '🌅',
          requiredValue: const Value(7),
          category: const Value('habit'),
        ),
      ];
      for (final achievement in achievements) {
        await into(weightAchievements).insert(achievement);
      }
    }
  }

  // ==================== REMINDERS ====================

  Future<WeightReminder?> getReminderSettings() {
    return (select(weightReminders)..limit(1)).getSingleOrNull();
  }

  Stream<WeightReminder?> watchReminderSettings() {
    return (select(weightReminders)..limit(1)).watchSingleOrNull();
  }

  Future<void> upsertReminder(WeightRemindersCompanion reminder) async {
    final existing = await getReminderSettings();
    if (existing != null) {
      await (update(weightReminders)..where((t) => t.id.equals(existing.id)))
          .write(reminder);
    } else {
      await into(weightReminders).insert(reminder);
    }
  }

  // ==================== DAILY STATS ====================

  Future<WeightDailyStat?> getDailyStat(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return (select(weightDailyStats)
          ..where((t) => t.date.equals(startOfDay)))
        .getSingleOrNull();
  }

  Future<List<WeightDailyStat>> getDailyStatsRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(weightDailyStats)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<void> upsertDailyStat(WeightDailyStatsCompanion stat) async {
    final existing = await getDailyStat(stat.date.value);
    if (existing != null) {
      await (update(weightDailyStats)..where((t) => t.id.equals(existing.id)))
          .write(stat);
    } else {
      await into(weightDailyStats).insert(stat);
    }
  }

  // ==================== STATISTICS ====================

  Future<int> getTotalRecordsCount() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM weight_records',
    ).getSingle();
    return result.read<int>('count');
  }

  Future<int> getConsecutiveDays() async {
    final records = await getAllRecords();
    if (records.isEmpty) return 0;

    int streak = 1;
    DateTime? lastDate;

    for (final record in records) {
      final recordDate = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );

      if (lastDate == null) {
        lastDate = recordDate;
        continue;
      }

      final daysDiff = lastDate.difference(recordDate).inDays;
      if (daysDiff == 1) {
        streak++;
        lastDate = recordDate;
      } else if (daysDiff > 1) {
        break;
      }
    }

    return streak;
  }

  Future<int> getMorningWeighCount() async {
    final result = await customSelect(
      "SELECT COUNT(*) as count FROM weight_records WHERE time_of_day = 'morning'",
    ).getSingle();
    return result.read<int>('count');
  }

  Future<double?> getMinWeight() async {
    final records = await getAllRecords();
    if (records.isEmpty) return null;
    return records.map((r) => r.weightKg).reduce((a, b) => a < b ? a : b);
  }

  Future<double?> getMaxWeight() async {
    final records = await getAllRecords();
    if (records.isEmpty) return null;
    return records.map((r) => r.weightKg).reduce((a, b) => a > b ? a : b);
  }

  Future<double?> getAverageWeight(int days) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - days);
    final records = await getRecordsByDateRange(start, now);
    if (records.isEmpty) return null;
    final total = records.fold<double>(0, (sum, r) => sum + r.weightKg);
    return total / records.length;
  }

  Future<List<MapEntry<DateTime, double>>> getWeeklyData() async {
    final now = DateTime.now();
    final results = <MapEntry<DateTime, double>>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = date.add(const Duration(days: 1));
      final records = await getRecordsByDateRange(date, nextDate);
      if (records.isNotEmpty) {
        // Take the first weight of the day (usually morning)
        results.add(MapEntry(date, records.first.weightKg));
      }
    }

    return results;
  }

  Future<List<MapEntry<DateTime, double>>> getMonthlyData() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 30);
    final records = await getRecordsByDateRange(start, now);

    // Group by date and take first record of each day
    final Map<String, double> dailyWeights = {};
    for (final record in records) {
      final dateKey =
          '${record.timestamp.year}-${record.timestamp.month}-${record.timestamp.day}';
      if (!dailyWeights.containsKey(dateKey)) {
        dailyWeights[dateKey] = record.weightKg;
      }
    }

    return dailyWeights.entries.map((e) {
      final parts = e.key.split('-');
      return MapEntry(
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
        e.value,
      );
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }
}
