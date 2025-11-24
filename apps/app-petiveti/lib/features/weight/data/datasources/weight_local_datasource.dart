import 'package:drift/drift.dart';

import '../../../../database/petiveti_database.dart';
import '../models/weight_model.dart';

abstract class WeightLocalDataSource {
  Future<List<WeightModel>> getWeightRecords(String userId);
  Future<List<WeightModel>> getWeightRecordsByAnimalId(int animalId);
  Future<WeightModel?> getWeightRecordById(int id);
  Future<WeightModel?> getLatestWeight(int animalId);
  Future<int> addWeightRecord(WeightModel record);
  Future<bool> updateWeightRecord(WeightModel record);
  Future<bool> deleteWeightRecord(int id);
  Stream<List<WeightModel>> watchWeightRecordsByAnimalId(int animalId);

  // Additional methods used by repository
  Future<List<WeightModel>> getWeights();
  Future<List<WeightModel>> getWeightsByAnimalId(String animalId);
  Future<WeightModel?> getWeightById(String id);
  Future<WeightModel?> getLatestWeightByAnimalId(String animalId);
  Future<List<WeightModel>> getWeightHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> cacheWeight(WeightModel weight);
  Future<void> updateWeight(WeightModel weight);
  Future<void> deleteWeight(int id);
  Future<void> hardDeleteWeight(String id);
  Future<void> cacheWeights(List<WeightModel> weights);
  Future<int> getWeightsCount(String animalId);
  Stream<List<WeightModel>> watchWeights();
  Stream<List<WeightModel>> watchWeightsByAnimalId(String animalId);
}

class WeightLocalDataSourceImpl implements WeightLocalDataSource {
  final PetivetiDatabase _database;

  WeightLocalDataSourceImpl(this._database);

  @override
  Future<List<WeightModel>> getWeightRecords(String userId) async {
    final records = await _database.weightDao.getAllWeightRecords(userId);
    return records.map(_toModel).toList();
  }

  @override
  Future<List<WeightModel>> getWeightRecordsByAnimalId(int animalId) async {
    final records = await _database.weightDao.getWeightRecordsByAnimal(
      animalId,
    );
    return records.map(_toModel).toList();
  }

  @override
  Future<WeightModel?> getWeightRecordById(int id) async {
    final record = await _database.weightDao.getWeightRecordById(id);
    return record != null ? _toModel(record) : null;
  }

  @override
  Future<WeightModel?> getLatestWeight(int animalId) async {
    final record = await _database.weightDao.getLatestWeight(animalId);
    return record != null ? _toModel(record) : null;
  }

  @override
  Future<int> addWeightRecord(WeightModel record) async {
    final companion = _toCompanion(record);
    return await _database.weightDao.createWeightRecord(companion);
  }

  @override
  Future<bool> updateWeightRecord(WeightModel record) async {
    if (record.id == null) return false;
    final companion = _toCompanion(record, forUpdate: true);
    return await _database.weightDao.updateWeightRecord(record.id!, companion);
  }

  @override
  Future<bool> deleteWeightRecord(int id) async {
    return await _database.weightDao.deleteWeightRecord(id);
  }

  @override
  Stream<List<WeightModel>> watchWeightRecordsByAnimalId(int animalId) {
    return _database.weightDao
        .watchWeightRecordsByAnimal(animalId)
        .map((records) => records.map(_toModel).toList());
  }

  // Additional methods for repository compatibility
  @override
  Future<List<WeightModel>> getWeights() async {
    final records = await _database.weightDao.getAllWeightRecords('');
    return records.map(_toModel).toList();
  }

  @override
  Future<List<WeightModel>> getWeightsByAnimalId(String animalId) async {
    final intId = int.tryParse(animalId) ?? 0;
    return getWeightRecordsByAnimalId(intId);
  }

  @override
  Future<WeightModel?> getWeightById(String id) async {
    final intId = int.tryParse(id) ?? 0;
    return getWeightRecordById(intId);
  }

  @override
  Future<WeightModel?> getLatestWeightByAnimalId(String animalId) async {
    final intId = int.tryParse(animalId) ?? 0;
    return getLatestWeight(intId);
  }

  @override
  Future<List<WeightModel>> getWeightHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final intId = int.tryParse(animalId) ?? 0;
    final records = await _database.weightDao.getWeightRecordsByAnimal(intId);
    return records
        .where(
          (r) =>
              r.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              r.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .map(_toModel)
        .toList();
  }

  @override
  Future<void> cacheWeight(WeightModel weight) async {
    await addWeightRecord(weight);
  }

  @override
  Future<void> updateWeight(WeightModel weight) async {
    await updateWeightRecord(weight);
  }

  @override
  Future<void> deleteWeight(int id) async {
    await deleteWeightRecord(id);
  }

  @override
  Future<void> hardDeleteWeight(String id) async {
    final intId = int.tryParse(id) ?? 0;
    await _database.weightDao.deleteWeightRecord(intId);
  }

  @override
  Future<void> cacheWeights(List<WeightModel> weights) async {
    for (final weight in weights) {
      await cacheWeight(weight);
    }
  }

  @override
  Future<int> getWeightsCount(String animalId) async {
    final weights = await getWeightsByAnimalId(animalId);
    return weights.length;
  }

  @override
  Stream<List<WeightModel>> watchWeights() {
    // Retorna todos os registros de peso (sem filtro por animal)
    return Stream.value(<void>[]).asyncMap((_) async {
      final records = await _database.weightDao.getAllWeightRecords('');
      return records.map(_toModel).toList();
    });
  }

  @override
  Stream<List<WeightModel>> watchWeightsByAnimalId(String animalId) {
    final intId = int.tryParse(animalId) ?? 0;
    return watchWeightRecordsByAnimalId(intId);
  }

  WeightModel _toModel(WeightRecord record) {
    return WeightModel(
      id: record.id,
      animalId: record.animalId,
      weight: record.weight,
      unit: record.unit,
      userId: record.userId,
      date: record.date,
      notes: record.notes,
      createdAt: record.createdAt,
      isDeleted: record.isDeleted,
    );
  }

  WeightRecordsCompanion _toCompanion(
    WeightModel model, {
    bool forUpdate = false,
  }) {
    if (forUpdate) {
      return WeightRecordsCompanion(
        id: model.id != null ? Value(model.id!) : const Value.absent(),
        animalId: Value(model.animalId),
        weight: Value(model.weight),
        unit: Value(model.unit),
        date: Value(model.date),
        notes: Value.absentIfNull(model.notes),
        userId: Value(model.userId),
      );
    }

    return WeightRecordsCompanion.insert(
      animalId: model.animalId,
      weight: model.weight,
      unit: Value(model.unit),
      date: model.date,
      notes: Value.absentIfNull(model.notes),
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }
}
