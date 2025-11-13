import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/weight_records_table.dart';

part 'weight_dao.g.dart';

@DriftAccessor(tables: [WeightRecords])
class WeightDao extends DatabaseAccessor<PetivetiDatabase> with _$WeightDaoMixin {
  WeightDao(PetivetiDatabase db) : super(db);

  /// Get all weight records for a user
  Future<List<WeightRecord>> getAllWeightRecords(String userId) {
    return (select(weightRecords)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  /// Get weight records by animal ID
  Future<List<WeightRecord>> getWeightRecordsByAnimal(int animalId) {
    return (select(weightRecords)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  /// Watch weight records for an animal
  Stream<List<WeightRecord>> watchWeightRecordsByAnimal(int animalId) {
    return (select(weightRecords)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();
  }

  /// Get weight record by ID
  Future<WeightRecord?> getWeightRecordById(int id) {
    return (select(weightRecords)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .getSingleOrNull();
  }

  /// Create weight record
  Future<int> createWeightRecord(WeightRecordsCompanion record) {
    return into(weightRecords).insert(record);
  }

  /// Update weight record
  Future<bool> updateWeightRecord(int id, WeightRecordsCompanion record) async {
    return (update(weightRecords)..where((tbl) => tbl.id.equals(id))).write(record);
  }

  /// Delete weight record
  Future<bool> deleteWeightRecord(int id) async {
    return (update(weightRecords)..where((tbl) => tbl.id.equals(id)))
      .write(const WeightRecordsCompanion(isDeleted: Value(true)));
  }

  /// Get latest weight for an animal
  Future<WeightRecord?> getLatestWeight(int animalId) {
    return (select(weightRecords)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(1))
      .getSingleOrNull();
  }
}
