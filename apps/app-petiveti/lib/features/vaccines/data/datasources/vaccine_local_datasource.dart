import 'package:drift/drift.dart';

import '../../../../database/petiveti_database.dart';
import '../models/vaccine_model.dart';

abstract class VaccineLocalDataSource {
  Future<List<VaccineModel>> getVaccines(String userId);
  Future<List<VaccineModel>> getVaccinesByAnimalId(int animalId);
  Future<List<VaccineModel>> getUpcomingVaccines(int animalId);
  Future<VaccineModel?> getVaccineById(int id);
  Future<int> addVaccine(VaccineModel vaccine);
  Future<bool> updateVaccine(VaccineModel vaccine);
  Future<bool> deleteVaccine(int id);
  Stream<List<VaccineModel>> watchVaccinesByAnimalId(int animalId);
}

class VaccineLocalDataSourceImpl implements VaccineLocalDataSource {
  final PetivetiDatabase _database;

  VaccineLocalDataSourceImpl(this._database);

  @override
  Future<List<VaccineModel>> getVaccines(String userId) async {
    final vaccines = await _database.vaccineDao.getAllVaccines(userId);
    return vaccines.map(_toModel).toList();
  }

  @override
  Future<List<VaccineModel>> getVaccinesByAnimalId(int animalId) async {
    final vaccines = await _database.vaccineDao.getVaccinesByAnimal(animalId);
    return vaccines.map(_toModel).toList();
  }

  @override
  Future<List<VaccineModel>> getUpcomingVaccines(int animalId) async {
    final vaccines = await _database.vaccineDao.getUpcomingVaccines(animalId);
    return vaccines.map(_toModel).toList();
  }

  @override
  Future<VaccineModel?> getVaccineById(int id) async {
    final vaccine = await _database.vaccineDao.getVaccineById(id);
    return vaccine != null ? _toModel(vaccine) : null;
  }

  @override
  Future<int> addVaccine(VaccineModel vaccine) async {
    final companion = _toCompanion(vaccine);
    return await _database.vaccineDao.createVaccine(companion);
  }

  @override
  Future<bool> updateVaccine(VaccineModel vaccine) async {
    if (vaccine.id == null) return false;
    final companion = _toCompanion(vaccine, forUpdate: true);
    return await _database.vaccineDao.updateVaccine(vaccine.id!, companion);
  }

  @override
  Future<bool> deleteVaccine(int id) async {
    return await _database.vaccineDao.deleteVaccine(id);
  }

  @override
  Stream<List<VaccineModel>> watchVaccinesByAnimalId(int animalId) {
    return _database.vaccineDao
        .watchVaccinesByAnimal(animalId)
        .map((vaccines) => vaccines.map(_toModel).toList());
  }

  VaccineModel _toModel(Vaccine vaccine) {
    return VaccineModel(
      id: vaccine.id,
      animalId: vaccine.animalId,
      name: vaccine.name,
      veterinarian: vaccine.veterinarian,
      dateTimestamp: vaccine.dateTimestamp,
      nextDueDateTimestamp: vaccine.nextDueDateTimestamp,
      batch: vaccine.batch,
      manufacturer: vaccine.manufacturer,
      dosage: vaccine.dosage,
      notes: vaccine.notes,
      isRequired: vaccine.isRequired,
      isCompleted: vaccine.isCompleted,
      reminderDateTimestamp: vaccine.reminderDateTimestamp,
      status: vaccine.status,
      createdAtTimestamp: vaccine.createdAtTimestamp,
      updatedAtTimestamp: vaccine.updatedAtTimestamp,
      isDeleted: vaccine.isDeleted,
    );
  }

  VaccinesCompanion _toCompanion(VaccineModel model, {bool forUpdate = false}) {
    if (forUpdate) {
      return VaccinesCompanion(
        id: model.id != null ? Value(model.id!) : const Value.absent(),
        animalId: Value(model.animalId),
        name: Value(model.name),
        veterinarian: Value(model.veterinarian),
        dateTimestamp: Value(model.dateTimestamp),
        nextDueDateTimestamp: Value.absentIfNull(model.nextDueDateTimestamp),
        batch: Value.absentIfNull(model.batch),
        manufacturer: Value.absentIfNull(model.manufacturer),
        dosage: Value.absentIfNull(model.dosage),
        notes: Value.absentIfNull(model.notes),
        isRequired: Value(model.isRequired),
        isCompleted: Value(model.isCompleted),
        reminderDateTimestamp: Value.absentIfNull(model.reminderDateTimestamp),
        status: Value(model.status),
        userId: const Value.absent(),
        updatedAtTimestamp: Value(DateTime.now().millisecondsSinceEpoch),
      );
    }

    return VaccinesCompanion.insert(
      animalId: model.animalId,
      name: model.name,
      veterinarian: model.veterinarian,
      dateTimestamp: model.dateTimestamp,
      userId: '',
      createdAtTimestamp: model.createdAtTimestamp,
      nextDueDateTimestamp: Value.absentIfNull(model.nextDueDateTimestamp),
      batch: Value.absentIfNull(model.batch),
      manufacturer: Value.absentIfNull(model.manufacturer),
      dosage: Value.absentIfNull(model.dosage),
      notes: Value.absentIfNull(model.notes),
      isRequired: Value(model.isRequired),
      isCompleted: Value(model.isCompleted),
      reminderDateTimestamp: Value.absentIfNull(model.reminderDateTimestamp),
      status: Value(model.status),
    );
  }
}
