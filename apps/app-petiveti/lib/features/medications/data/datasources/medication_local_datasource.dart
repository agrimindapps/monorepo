import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../database/petiveti_database.dart';
import '../models/medication_model.dart';

abstract class MedicationLocalDataSource {
  Future<List<MedicationModel>> getMedications(String userId);
  Future<List<MedicationModel>> getMedicationsByAnimalId(int animalId);
  Future<List<MedicationModel>> getActiveMedications(int animalId);
  Future<MedicationModel?> getMedicationById(int id);
  Future<int> addMedication(MedicationModel medication);
  Future<bool> updateMedication(MedicationModel medication);
  Future<bool> deleteMedication(int id);
  Stream<List<MedicationModel>> watchMedicationsByAnimalId(int animalId);
}

@LazySingleton(as: MedicationLocalDataSource)
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
    final medications = await _database.medicationDao.getMedicationsByAnimal(animalId);
    return medications.map(_toModel).toList();
  }

  @override
  Future<List<MedicationModel>> getActiveMedications(int animalId) async {
    final medications = await _database.medicationDao.getActiveMedications(animalId);
    return medications.map(_toModel).toList();
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
    return await _database.medicationDao.updateMedication(medication.id!, companion);
  }

  @override
  Future<bool> deleteMedication(int id) async {
    return await _database.medicationDao.deleteMedication(id);
  }

  @override
  Stream<List<MedicationModel>> watchMedicationsByAnimalId(int animalId) {
    return _database.medicationDao.watchMedicationsByAnimal(animalId)
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

  MedicationsCompanion _toCompanion(MedicationModel model, {bool forUpdate = false}) {
    if (forUpdate) {
      return MedicationsCompanion(
        id: model.id != null ? Value(model.id!) : const Value.absent(),
        animalId: Value(model.animalId),
        name: Value(model.name),
        dosage: Value(model.dosage),
        frequency: Value(model.frequency),
        startDate: Value(model.startDate),
        endDate: Value.ofNullable(model.endDate),
        notes: Value.ofNullable(model.notes),
        veterinarian: Value.ofNullable(model.veterinarian),
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
      endDate: Value.ofNullable(model.endDate),
      notes: Value.ofNullable(model.notes),
      veterinarian: Value.ofNullable(model.veterinarian),
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }
}
