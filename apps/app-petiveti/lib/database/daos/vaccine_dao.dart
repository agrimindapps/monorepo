import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/vaccines_table.dart';

part 'vaccine_dao.g.dart';

@DriftAccessor(tables: [Vaccines])
class VaccineDao extends DatabaseAccessor<PetivetiDatabase> with _$VaccineDaoMixin {
  VaccineDao(super.db);

  /// Get all vaccines for a user
  Future<List<Vaccine>> getAllVaccines(String userId) {
    return (select(vaccines)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.dateTimestamp)]))
      .get();
  }

  /// Get vaccines by animal ID
  Future<List<Vaccine>> getVaccinesByAnimal(int animalId) {
    return (select(vaccines)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.dateTimestamp)]))
      .get();
  }

  /// Watch vaccines for an animal
  Stream<List<Vaccine>> watchVaccinesByAnimal(int animalId) {
    return (select(vaccines)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.dateTimestamp)]))
      .watch();
  }

  /// Get vaccine by ID
  Future<Vaccine?> getVaccineById(int id) {
    return (select(vaccines)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .getSingleOrNull();
  }

  /// Create vaccine
  Future<int> createVaccine(VaccinesCompanion vaccine) {
    return into(vaccines).insert(vaccine);
  }

  /// Update vaccine
  Future<bool> updateVaccine(int id, VaccinesCompanion vaccine) async {
    final count = await (update(vaccines)..where((tbl) => tbl.id.equals(id)))
      .write(vaccine.copyWith(updatedAtTimestamp: Value(DateTime.now().millisecondsSinceEpoch)));
    return count > 0;
  }

  /// Delete vaccine
  Future<bool> deleteVaccine(int id) async {
    final count = await (update(vaccines)..where((tbl) => tbl.id.equals(id)))
      .write(VaccinesCompanion(
        isDeleted: const Value(true),
        updatedAtTimestamp: Value(DateTime.now().millisecondsSinceEpoch),
      ));
    return count > 0;
  }

  /// Get upcoming vaccines (next due date in the future)
  Future<List<Vaccine>> getUpcomingVaccines(int animalId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(vaccines)
      ..where((tbl) => 
        tbl.animalId.equals(animalId) & 
        tbl.isDeleted.equals(false) &
        tbl.nextDueDateTimestamp.isNotNull() &
        tbl.nextDueDateTimestamp.isBiggerOrEqualValue(now))
      ..orderBy([(t) => OrderingTerm.asc(t.nextDueDateTimestamp)]))
      .get();
  }
}
