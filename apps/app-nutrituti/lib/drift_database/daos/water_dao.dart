import 'package:drift/drift.dart';
import '../nutrituti_database.dart';
import '../tables/water_records_table.dart';
import '../tables/water_achievements_table.dart';

part 'water_dao.g.dart';

@DriftAccessor(tables: [WaterRecords, WaterAchievements])
class WaterDao extends DatabaseAccessor<NutritutiDatabase>
    with _$WaterDaoMixin {
  WaterDao(NutritutiDatabase db) : super(db);

  // ==================== WATER RECORDS ====================

  /// Get all water records
  Future<List<WaterRecord>> getAllRecords() {
    return (select(
      waterRecords,
    )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).get();
  }

  /// Get records by date range
  Future<List<WaterRecord>> getRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(waterRecords)
          ..where(
            (tbl) =>
                tbl.timestamp.isBiggerOrEqualValue(start) &
                tbl.timestamp.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  /// Get records for today
  Future<List<WaterRecord>> getTodayRecords() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getRecordsByDateRange(startOfDay, endOfDay);
  }

  /// Get record by ID
  Future<WaterRecord?> getRecordById(String id) {
    return (select(
      waterRecords,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Watch all records
  Stream<List<WaterRecord>> watchAllRecords() {
    return (select(
      waterRecords,
    )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  }

  /// Watch today's records
  Stream<List<WaterRecord>> watchTodayRecords() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(waterRecords)
          ..where(
            (tbl) =>
                tbl.timestamp.isBiggerOrEqualValue(startOfDay) &
                tbl.timestamp.isSmallerOrEqualValue(endOfDay),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  /// Add water record
  Future<int> addRecord(WaterRecordsCompanion record) {
    return into(waterRecords).insert(record);
  }

  /// Update water record
  Future<int> updateRecord(String id, WaterRecordsCompanion record) {
    return (update(
      waterRecords,
    )..where((tbl) => tbl.id.equals(id))).write(record);
  }

  /// Delete water record
  Future<int> deleteRecord(String id) {
    return (delete(waterRecords)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Delete all records
  Future<int> deleteAllRecords() {
    return delete(waterRecords).go();
  }

  /// Get total amount for today
  Future<int> getTodayTotal() async {
    final records = await getTodayRecords();
    return records.fold<int>(0, (sum, r) => sum + r.amount);
  }

  // ==================== ACHIEVEMENTS ====================

  /// Get all achievements
  Future<List<WaterAchievement>> getAllAchievements() {
    return (select(
      waterAchievements,
    )..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)])).get();
  }

  /// Get achievement by ID
  Future<WaterAchievement?> getAchievementById(String id) {
    return (select(
      waterAchievements,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Get achievement by type
  Future<WaterAchievement?> getAchievementByType(String type) {
    return (select(
      waterAchievements,
    )..where((tbl) => tbl.type.equals(type))).getSingleOrNull();
  }

  /// Watch all achievements
  Stream<List<WaterAchievement>> watchAllAchievements() {
    return (select(
      waterAchievements,
    )..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)])).watch();
  }

  /// Add achievement
  Future<int> addAchievement(WaterAchievementsCompanion achievement) {
    return into(waterAchievements).insert(achievement);
  }

  /// Update achievement
  Future<int> updateAchievement(
    String id,
    WaterAchievementsCompanion achievement,
  ) {
    return (update(
      waterAchievements,
    )..where((tbl) => tbl.id.equals(id))).write(achievement);
  }

  /// Delete achievement
  Future<int> deleteAchievement(String id) {
    return (delete(waterAchievements)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Delete all achievements
  Future<int> deleteAllAchievements() {
    return delete(waterAchievements).go();
  }

  /// Check if achievement exists
  Future<bool> hasAchievement(String type) async {
    final achievement = await getAchievementByType(type);
    return achievement != null;
  }
}
