import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/medications_table.dart';

part 'medication_dao.g.dart';

@DriftAccessor(tables: [Medications])
class MedicationDao extends DatabaseAccessor<PetivetiDatabase> with _$MedicationDaoMixin {
  MedicationDao(PetivetiDatabase db) : super(db);

  /// Get all medications for a user
  Future<List<Medication>> getAllMedications(String userId) {
    return (select(medications)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }

  /// Get medications by animal ID
  Future<List<Medication>> getMedicationsByAnimal(int animalId) {
    return (select(medications)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
      .get();
  }

  /// Watch medications for an animal
  Stream<List<Medication>> watchMedicationsByAnimal(int animalId) {
    return (select(medications)
      ..where((tbl) => tbl.animalId.equals(animalId) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
      .watch();
  }

  /// Get medication by ID
  Future<Medication?> getMedicationById(int id) {
    return (select(medications)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .getSingleOrNull();
  }

  /// Create medication
  Future<int> createMedication(MedicationsCompanion medication) {
    return into(medications).insert(medication);
  }

  /// Update medication
  Future<bool> updateMedication(int id, MedicationsCompanion medication) async {
    final count = await (update(medications)..where((tbl) => tbl.id.equals(id)))
      .write(medication.copyWith(updatedAt: Value(DateTime.now())));
    return count > 0;
  }

  /// Delete medication
  Future<bool> deleteMedication(int id) async {
    final count = await (update(medications)..where((tbl) => tbl.id.equals(id)))
      .write(MedicationsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
    return count > 0;
  }

  /// Get active medications (not ended yet)
  Future<List<Medication>> getActiveMedications(int animalId) {
    final now = DateTime.now();
    return (select(medications)
      ..where((tbl) => 
        tbl.animalId.equals(animalId) & 
        tbl.isDeleted.equals(false) &
        (tbl.endDate.isNull() | tbl.endDate.isBiggerOrEqualValue(now)))
      ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
      .get();
  }
}
