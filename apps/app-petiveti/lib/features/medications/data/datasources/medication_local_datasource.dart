import 'package:drift/drift.dart';

import '../../../../database/petiveti_database.dart';
import '../models/medication_model.dart';

abstract class MedicationLocalDataSource {
  Future<List<MedicationModel>> getMedications(String userId);
  Future<List<MedicationModel>> getMedicationsByAnimalId(int animalId);
  Future<List<MedicationModel>> getActiveMedications(String userId);
  Future<MedicationModel?> getMedicationById(int id);
  Future<int> addMedication(MedicationModel medication);
  Future<bool> updateMedication(MedicationModel medication);
  Future<bool> deleteMedication(int id);
  Stream<List<MedicationModel>> watchMedicationsByAnimalId(int animalId);
  Future<List<MedicationModel>> searchMedications(String query);
  Future<List<MedicationModel>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<MedicationModel>> checkMedicationConflicts(
    MedicationModel medication,
  );
  Future<int> getActiveMedicationsCount(String animalId);
  Future<void> hardDeleteMedication(String id);
  Future<void> discontinueMedication(String id, String reason);
  Stream<List<MedicationModel>> watchMedications();
  Stream<List<MedicationModel>> watchActiveMedications();
  Future<void> cacheMedications(List<MedicationModel> medications);
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  final PetivetiDatabase _database;

  MedicationLocalDataSourceImpl(this._database);

  @override
  Future<List<MedicationModel>> getMedications(String userId) async {
    final medications = await _database.medicationDao.getAllMedications(userId);
    return medications.map(_toModel).toList();
  }

  @override
  Future<List<MedicationModel>> getMedicationsByAnimalId(int animalId) async {
    final medications = await _database.medicationDao.getMedicationsByAnimal(
      animalId,
    );
    return medications.map(_toModel).toList();
  }

  @override
  Future<List<MedicationModel>> getActiveMedications(String userId) async {
    // Get all medications for the user
    final allMedications = await _database.medicationDao.getAllMedications(userId);
    
    // Filter active medications (not ended yet)
    final now = DateTime.now();
    final activeMedications = allMedications.where((med) {
      if (med.endDate == null) return true; // No end date = active
      return med.endDate!.isAfter(now) || med.endDate!.isAtSameMomentAs(now);
    }).toList();
    
    return activeMedications.map(_toModel).toList();
  }

  @override
  Future<MedicationModel?> getMedicationById(int id) async {
    final medication = await _database.medicationDao.getMedicationById(id);
    return medication != null ? _toModel(medication) : null;
  }

  @override
  Future<int> addMedication(MedicationModel medication) async {
    final companion = _toCompanion(medication);
    return await _database.medicationDao.createMedication(companion);
  }

  @override
  Future<bool> updateMedication(MedicationModel medication) async {
    if (medication.id == null) return false;
    final companion = _toCompanion(medication, forUpdate: true);
    return await _database.medicationDao.updateMedication(
      medication.id!,
      companion,
    );
  }

  @override
  Future<bool> deleteMedication(int id) async {
    return await _database.medicationDao.deleteMedication(id);
  }

  @override
  Stream<List<MedicationModel>> watchMedicationsByAnimalId(int animalId) {
    return _database.medicationDao
        .watchMedicationsByAnimal(animalId)
        .map((medications) => medications.map(_toModel).toList());
  }

  MedicationModel _toModel(Medication medication) {
    return MedicationModel(
      id: medication.id,
      animalId: medication.animalId,
      name: medication.name,
      dosage: medication.dosage,
      frequency: medication.frequency,
      duration: medication.duration,
      startDate: medication.startDate,
      endDate: medication.endDate,
      notes: medication.notes,
      veterinarian: medication.veterinarian,
      type: medication.type,
      userId: medication.userId,
      createdAt: medication.createdAt,
      updatedAt: medication.updatedAt,
      isDeleted: medication.isDeleted,
    );
  }

  MedicationsCompanion _toCompanion(
    MedicationModel model, {
    bool forUpdate = false,
  }) {
    if (forUpdate) {
      return MedicationsCompanion(
        id: model.id != null ? Value(model.id!) : const Value.absent(),
        animalId: Value(model.animalId),
        name: Value(model.name),
        dosage: Value(model.dosage),
        frequency: Value(model.frequency),
        duration: Value.absentIfNull(model.duration),
        startDate: Value(model.startDate),
        endDate: Value.absentIfNull(model.endDate),
        notes: Value.absentIfNull(model.notes),
        veterinarian: Value.absentIfNull(model.veterinarian),
        type: Value(model.type),
        userId: Value(model.userId),
        updatedAt: Value(DateTime.now()),
      );
    }

    return MedicationsCompanion.insert(
      animalId: model.animalId,
      name: model.name,
      dosage: model.dosage,
      frequency: model.frequency,
      duration: Value.absentIfNull(model.duration),
      startDate: model.startDate,
      endDate: Value.absentIfNull(model.endDate),
      notes: Value.absentIfNull(model.notes),
      veterinarian: Value.absentIfNull(model.veterinarian),
      type: Value(model.type),
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }

  @override
  Future<void> cacheMedications(List<MedicationModel> medications) async {
    // Batch insert/update medications
    await _database.batch((batch) {
      for (final medication in medications) {
        final companion = _toCompanion(medication);
        batch.insert(
          _database.medications,
          companion,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  @override
  Future<List<MedicationModel>> checkMedicationConflicts(
    MedicationModel medication,
  ) async {
    // Get all active medications for the same animal
    final animalMedications = await _database.medicationDao
        .getMedicationsByAnimal(medication.animalId);
    
    final now = DateTime.now();
    final conflicts = animalMedications.where((med) {
      // Skip the same medication if updating
      if (medication.id != null && med.id == medication.id) return false;
      
      // Check if it's active
      if (med.endDate != null && med.endDate!.isBefore(now)) return false;
      
      // Check for same medication name (potential conflict)
      return med.name.toLowerCase() == medication.name.toLowerCase();
    }).toList();
    
    return conflicts.map(_toModel).toList();
  }

  @override
  Future<void> discontinueMedication(String id, String reason) async {
    final medId = int.tryParse(id);
    if (medId == null) return;
    
    // Mark medication as ended with current date and add reason to notes
    await _database.medicationDao.updateMedication(
      medId,
      MedicationsCompanion(
        endDate: Value(DateTime.now()),
        notes: Value('Descontinuado: $reason'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<int> getActiveMedicationsCount(String animalId) async {
    final animalIdInt = int.tryParse(animalId);
    if (animalIdInt == null) return 0;
    
    final activeMedications = await _database.medicationDao
        .getActiveMedications(animalIdInt);
    return activeMedications.length;
  }

  @override
  Future<List<MedicationModel>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final animalIdInt = int.tryParse(animalId);
    if (animalIdInt == null) return [];
    
    final allMedications = await _database.medicationDao
        .getMedicationsByAnimal(animalIdInt);
    
    // Filter by date range
    final filtered = allMedications.where((med) {
      // Check if medication overlaps with the date range
      final medStart = med.startDate;
      final medEnd = med.endDate ?? DateTime.now();
      
      return (medStart.isBefore(endDate) || medStart.isAtSameMomentAs(endDate)) &&
             (medEnd.isAfter(startDate) || medEnd.isAtSameMomentAs(startDate));
    }).toList();
    
    return filtered.map(_toModel).toList();
  }

  @override
  Future<void> hardDeleteMedication(String id) async {
    final medId = int.tryParse(id);
    if (medId == null) return;
    
    // Permanently delete from database
    await (_database.delete(_database.medications)
          ..where((tbl) => tbl.id.equals(medId)))
        .go();
  }

  @override
  Future<List<MedicationModel>> searchMedications(String query) async {
    if (query.isEmpty) return [];
    
    final queryLower = query.toLowerCase();
    
    // Simple search in memory (could be optimized with Drift's like operator)
    final allMedications = await (_database.select(_database.medications)
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
    
    final results = allMedications.where((med) {
      return med.name.toLowerCase().contains(queryLower) ||
             (med.notes?.toLowerCase().contains(queryLower) ?? false) ||
             (med.veterinarian?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
    
    return results.map(_toModel).toList();
  }

  @override
  Stream<List<MedicationModel>> watchActiveMedications() {
    final now = DateTime.now();
    
    return (_database.select(_database.medications)
          ..where((tbl) => 
            tbl.isDeleted.equals(false) &
            (tbl.endDate.isNull() | tbl.endDate.isBiggerOrEqualValue(now)))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .watch()
        .map((medications) => medications.map(_toModel).toList());
  }

  @override
  Stream<List<MedicationModel>> watchMedications() {
    return (_database.select(_database.medications)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((medications) => medications.map(_toModel).toList());
  }
}
