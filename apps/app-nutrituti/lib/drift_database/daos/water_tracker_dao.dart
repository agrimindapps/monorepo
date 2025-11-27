import 'package:drift/drift.dart';
import '../nutrituti_database.dart';
import '../tables/water_records_table.dart';
import '../tables/water_achievements_table.dart';
import '../tables/water_goals_table.dart';
import '../tables/water_streaks_table.dart';
import '../tables/water_custom_cups_table.dart';
import '../tables/water_reminders_table.dart';
import '../tables/water_daily_progress_table.dart';

part 'water_tracker_dao.g.dart';

@DriftAccessor(tables: [
  WaterRecords,
  WaterAchievements,
  WaterGoals,
  WaterStreaks,
  WaterCustomCups,
  WaterReminders,
  WaterDailyProgressTable,
])
class WaterTrackerDao extends DatabaseAccessor<NutritutiDatabase>
    with _$WaterTrackerDaoMixin {
  WaterTrackerDao(super.db);

  // ==================== WATER RECORDS ====================

  Future<List<WaterRecord>> getAllRecords() {
    return (select(waterRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  Future<List<WaterRecord>> getRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(waterRecords)
          ..where((tbl) =>
              tbl.timestamp.isBiggerOrEqualValue(start) &
              tbl.timestamp.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  Future<List<WaterRecord>> getTodayRecords() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getRecordsByDateRange(startOfDay, endOfDay);
  }

  Stream<List<WaterRecord>> watchTodayRecords() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(waterRecords)
          ..where((tbl) =>
              tbl.timestamp.isBiggerOrEqualValue(startOfDay) &
              tbl.timestamp.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  Future<int> addRecord(WaterRecordsCompanion record) {
    return into(waterRecords).insert(record);
  }

  Future<int> deleteRecord(String id) {
    return (delete(waterRecords)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> getTodayTotal() async {
    final records = await getTodayRecords();
    return records.fold<int>(0, (sum, r) => sum + r.amount);
  }

  Stream<int> watchTodayTotal() {
    return watchTodayRecords().map(
      (records) => records.fold<int>(0, (sum, r) => sum + r.amount),
    );
  }

  // ==================== GOALS ====================

  Future<WaterGoal?> getCurrentGoal() {
    return (select(waterGoals)..limit(1)).getSingleOrNull();
  }

  Stream<WaterGoal?> watchCurrentGoal() {
    return (select(waterGoals)..limit(1)).watchSingleOrNull();
  }

  Future<void> upsertGoal(WaterGoalsCompanion goal) async {
    final existing = await getCurrentGoal();
    if (existing != null) {
      await (update(waterGoals)..where((t) => t.id.equals(existing.id)))
          .write(goal);
    } else {
      await into(waterGoals).insert(goal);
    }
  }

  // ==================== STREAKS ====================

  Future<WaterStreak?> getCurrentStreak() {
    return (select(waterStreaks)..limit(1)).getSingleOrNull();
  }

  Stream<WaterStreak?> watchCurrentStreak() {
    return (select(waterStreaks)..limit(1)).watchSingleOrNull();
  }

  Future<void> upsertStreak(WaterStreaksCompanion streak) async {
    final existing = await getCurrentStreak();
    if (existing != null) {
      await (update(waterStreaks)..where((t) => t.id.equals(existing.id)))
          .write(streak);
    } else {
      await into(waterStreaks).insert(streak);
    }
  }

  Future<void> incrementStreak() async {
    final current = await getCurrentStreak();
    final now = DateTime.now();

    if (current == null) {
      await into(waterStreaks).insert(WaterStreaksCompanion.insert(
        id: 'default_streak',
        currentStreak: const Value(1),
        bestStreak: const Value(1),
        lastRecordDate: Value(now),
        streakStartDate: Value(now),
        updatedAt: now,
      ));
    } else {
      final newStreak = current.currentStreak + 1;
      final newBest =
          newStreak > current.bestStreak ? newStreak : current.bestStreak;
      await (update(waterStreaks)..where((t) => t.id.equals(current.id))).write(
        WaterStreaksCompanion(
          currentStreak: Value(newStreak),
          bestStreak: Value(newBest),
          lastRecordDate: Value(now),
          canRecover: const Value(false),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<void> resetStreak() async {
    final current = await getCurrentStreak();
    if (current != null) {
      await (update(waterStreaks)..where((t) => t.id.equals(current.id))).write(
        WaterStreaksCompanion(
          currentStreak: const Value(0),
          streakStartDate: const Value.absent(),
          canRecover: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ==================== CUSTOM CUPS ====================

  Future<List<WaterCustomCup>> getAllCustomCups() {
    return (select(waterCustomCups)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Stream<List<WaterCustomCup>> watchAllCustomCups() {
    return (select(waterCustomCups)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<int> addCustomCup(WaterCustomCupsCompanion cup) {
    return into(waterCustomCups).insert(cup);
  }

  Future<int> updateCustomCup(String id, WaterCustomCupsCompanion cup) {
    return (update(waterCustomCups)..where((t) => t.id.equals(id))).write(cup);
  }

  Future<int> deleteCustomCup(String id) {
    return (delete(waterCustomCups)..where((t) => t.id.equals(id))).go();
  }

  Future<void> initializeDefaultCups() async {
    final existing = await getAllCustomCups();
    if (existing.isEmpty) {
      final defaults = [
        WaterCustomCupsCompanion.insert(
          id: 'cup_150',
          name: 'Copo pequeno',
          amountMl: 150,
          iconName: const Value('local_drink'),
          sortOrder: const Value(0),
          isDefault: const Value(true),
          createdAt: DateTime.now(),
        ),
        WaterCustomCupsCompanion.insert(
          id: 'cup_250',
          name: 'Copo médio',
          amountMl: 250,
          iconName: const Value('local_drink'),
          sortOrder: const Value(1),
          isDefault: const Value(true),
          createdAt: DateTime.now(),
        ),
        WaterCustomCupsCompanion.insert(
          id: 'cup_350',
          name: 'Copo grande',
          amountMl: 350,
          iconName: const Value('local_drink'),
          sortOrder: const Value(2),
          isDefault: const Value(true),
          createdAt: DateTime.now(),
        ),
        WaterCustomCupsCompanion.insert(
          id: 'cup_500',
          name: 'Garrafa',
          amountMl: 500,
          iconName: const Value('water_bottle'),
          sortOrder: const Value(3),
          isDefault: const Value(true),
          createdAt: DateTime.now(),
        ),
      ];
      for (final cup in defaults) {
        await into(waterCustomCups).insert(cup);
      }
    }
  }

  // ==================== REMINDERS ====================

  Future<WaterReminder?> getReminderSettings() {
    return (select(waterReminders)..limit(1)).getSingleOrNull();
  }

  Stream<WaterReminder?> watchReminderSettings() {
    return (select(waterReminders)..limit(1)).watchSingleOrNull();
  }

  Future<void> upsertReminder(WaterRemindersCompanion reminder) async {
    final existing = await getReminderSettings();
    if (existing != null) {
      await (update(waterReminders)..where((t) => t.id.equals(existing.id)))
          .write(reminder);
    } else {
      await into(waterReminders).insert(reminder);
    }
  }

  // ==================== DAILY PROGRESS ====================

  Future<WaterDailyProgress?> getDailyProgress(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return (select(waterDailyProgressTable)
          ..where((t) => t.date.equals(startOfDay)))
        .getSingleOrNull();
  }

  Future<List<WaterDailyProgress>> getDailyProgressRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(waterDailyProgressTable)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Stream<WaterDailyProgress?> watchTodayProgress() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return (select(waterDailyProgressTable)
          ..where((t) => t.date.equals(startOfDay)))
        .watchSingleOrNull();
  }

  Future<void> updateDailyProgress(WaterDailyProgressTableCompanion progress) async {
    final existing = await getDailyProgress(progress.date.value);
    if (existing != null) {
      await (update(waterDailyProgressTable)
            ..where((t) => t.id.equals(existing.id)))
          .write(progress);
    } else {
      await into(waterDailyProgressTable).insert(progress);
    }
  }

  // ==================== ACHIEVEMENTS ====================

  Future<List<WaterAchievement>> getAllAchievements() {
    return (select(waterAchievements)
          ..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
        .get();
  }

  Stream<List<WaterAchievement>> watchAllAchievements() {
    return (select(waterAchievements)
          ..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
        .watch();
  }

  Future<WaterAchievement?> getAchievementByType(String type) {
    return (select(waterAchievements)..where((t) => t.type.equals(type)))
        .getSingleOrNull();
  }

  Future<void> upsertAchievement(WaterAchievementsCompanion achievement) async {
    final existing = await getAchievementByType(achievement.type.value);
    if (existing != null) {
      await (update(waterAchievements)..where((t) => t.id.equals(existing.id)))
          .write(achievement);
    } else {
      await into(waterAchievements).insert(achievement);
    }
  }

  Future<void> unlockAchievement(String type) async {
    await (update(waterAchievements)..where((t) => t.type.equals(type))).write(
      WaterAchievementsCompanion(
        isUnlocked: const Value(true),
        unlockedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateAchievementProgress(String type, int progress) async {
    await (update(waterAchievements)..where((t) => t.type.equals(type))).write(
      WaterAchievementsCompanion(
        currentProgress: Value(progress),
      ),
    );
  }

  Future<void> initializeAchievements() async {
    final existing = await getAllAchievements();
    if (existing.isEmpty) {
      final achievements = [
        WaterAchievementsCompanion.insert(
          id: 'first_drop',
          type: 'first_drop',
          title: '💧 Primeira Gota',
          description: 'Registre seu primeiro copo de água',
          iconName: const Value('water_drop'),
          requiredValue: const Value(1),
          category: const Value('beginner'),
        ),
        WaterAchievementsCompanion.insert(
          id: 'perfect_week',
          type: 'perfect_week',
          title: '🌊 Semana Perfeita',
          description: 'Atinja a meta por 7 dias seguidos',
          iconName: const Value('waves'),
          requiredValue: const Value(7),
          category: const Value('streak'),
        ),
        WaterAchievementsCompanion.insert(
          id: 'hydrated_month',
          type: 'hydrated_month',
          title: '🏆 Mês Hidratado',
          description: 'Atinja a meta por 30 dias seguidos',
          iconName: const Value('emoji_events'),
          requiredValue: const Value(30),
          category: const Value('streak'),
        ),
        WaterAchievementsCompanion.insert(
          id: 'early_bird',
          type: 'early_bird',
          title: '🌅 Madrugador',
          description: 'Beba água antes das 7h por 5 dias',
          iconName: const Value('wb_sunny'),
          requiredValue: const Value(5),
          category: const Value('habit'),
        ),
        WaterAchievementsCompanion.insert(
          id: 'super_hydrated',
          type: 'super_hydrated',
          title: '💪 Super Hidratado',
          description: 'Atinja 150% da meta em um dia',
          iconName: const Value('fitness_center'),
          requiredValue: const Value(150),
          category: const Value('challenge'),
        ),
        WaterAchievementsCompanion.insert(
          id: 'consistent',
          type: 'consistent',
          title: '⭐ Consistente',
          description: 'Faça 50 registros no total',
          iconName: const Value('star'),
          requiredValue: const Value(50),
          category: const Value('milestone'),
        ),
        WaterAchievementsCompanion.insert(
          id: 'master',
          type: 'master',
          title: '👑 Mestre',
          description: 'Complete 100 dias no total',
          iconName: const Value('workspace_premium'),
          requiredValue: const Value(100),
          category: const Value('milestone'),
        ),
      ];
      for (final achievement in achievements) {
        await into(waterAchievements).insert(achievement);
      }
    }
  }

  // ==================== STATISTICS ====================

  Future<int> getTotalRecordsCount() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM water_records',
    ).getSingle();
    return result.read<int>('count');
  }

  Future<int> getDaysWithRecords() async {
    final result = await customSelect(
      'SELECT COUNT(DISTINCT DATE(timestamp/1000, \'unixepoch\')) as count FROM water_records',
    ).getSingle();
    return result.read<int>('count');
  }

  Future<double> getAverageDaily(int days) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - days);
    final records = await getRecordsByDateRange(start, now);
    if (records.isEmpty) return 0;
    
    final total = records.fold<int>(0, (sum, r) => sum + r.amount);
    return total / days;
  }

  Future<List<MapEntry<DateTime, int>>> getWeeklyData() async {
    final now = DateTime.now();
    final results = <MapEntry<DateTime, int>>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = date.add(const Duration(days: 1));
      final records = await getRecordsByDateRange(date, nextDate);
      final total = records.fold<int>(0, (sum, r) => sum + r.amount);
      results.add(MapEntry(date, total));
    }

    return results;
  }
}
