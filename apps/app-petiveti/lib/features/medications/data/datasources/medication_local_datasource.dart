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
    // TODO: implement getActiveMedications
    throw UnimplementedError();
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
      startDate: medication.startDate,
      endDate: medication.endDate,
      notes: medication.notes,
      veterinarian: medication.veterinarian,
      type: 'other', // Default type, can be enhanced later
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
        startDate: Value(model.startDate),
        endDate: Value.absentIfNull(model.endDate),
        notes: Value.absentIfNull(model.notes),
        veterinarian: Value.absentIfNull(model.veterinarian),
        userId: Value(model.userId),
        updatedAt: Value(DateTime.now()),
      );
    }

    return MedicationsCompanion.insert(
      animalId: model.animalId,
      name: model.name,
      dosage: model.dosage,
      frequency: model.frequency,
      startDate: model.startDate,
      endDate: Value.absentIfNull(model.endDate),
      notes: Value.absentIfNull(model.notes),
      veterinarian: Value.absentIfNull(model.veterinarian),
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }

  @override
  Future<void> cacheMedications(List<MedicationModel> medications) {
    // TODO: implement cacheMedications
    throw UnimplementedError();
  }

  @override
  Future<List<MedicationModel>> checkMedicationConflicts(
    MedicationModel medication,
  ) {
    // TODO: implement checkMedicationConflicts
    throw UnimplementedError();
  }

  @override
  Future<void> discontinueMedication(String id, String reason) {
    // TODO: implement discontinueMedication
    throw UnimplementedError();
  }

  @override
  Future<int> getActiveMedicationsCount(String animalId) {
    // TODO: implement getActiveMedicationsCount
    throw UnimplementedError();
  }

  @override
  Future<List<MedicationModel>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) {
    // TODO: implement getMedicationHistory
    throw UnimplementedError();
  }

  @override
  Future<void> hardDeleteMedication(String id) {
    // TODO: implement hardDeleteMedication
    throw UnimplementedError();
  }

  @override
  Future<List<MedicationModel>> searchMedications(String query) {
    // TODO: implement searchMedications
    throw UnimplementedError();
  }

  @override
  Stream<List<MedicationModel>> watchActiveMedications() {
    // TODO: implement watchActiveMedications
    throw UnimplementedError();
  }

  @override
  Stream<List<MedicationModel>> watchMedications() {
    // TODO: implement watchMedications
    throw UnimplementedError();
  }
}
