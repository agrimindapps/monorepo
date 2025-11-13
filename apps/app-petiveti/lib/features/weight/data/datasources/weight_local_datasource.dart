import 'package:injectable/injectable.dart';

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
}

@LazySingleton(as: WeightLocalDataSource)
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
    final records = await _database.weightDao.getWeightRecordsByAnimal(animalId);
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
    return await _database.weightDao.updateWeightRecord(int.parse(record.id!), companion);
  }

  @override
  Future<bool> deleteWeightRecord(int id) async {
    return await _database.weightDao.deleteWeightRecord(id);
  }

  @override
  Stream<List<WeightModel>> watchWeightRecordsByAnimalId(int animalId) {
    return _database.weightDao.watchWeightRecordsByAnimal(animalId)
        .map((records) => records.map(_toModel).toList());
  }

  WeightModel _toModel(WeightRecord record) {
    return WeightModel(
      id: record.id.toString(),
      animalId: record.animalId.toString(),
      weight: record.weight,
      unit: record.unit,
      date: record.date,
      notes: record.notes,
      userId: record.userId,
      createdAt: record.createdAt,
      isDeleted: record.isDeleted,
    );
  }

  WeightRecordsCompanion _toCompanion(WeightModel model, {bool forUpdate = false}) {
    if (forUpdate) {
      return WeightRecordsCompanion(
        id: model.id != null ? Value(int.parse(model.id!)) : const Value.absent(),
        animalId: Value(int.parse(model.animalId)),
        weight: Value(model.weight),
        unit: Value(model.unit),
        date: Value(model.date),
        notes: Value.ofNullable(model.notes),
        userId: Value(model.userId),
      );
    }

    return WeightRecordsCompanion.insert(
      animalId: int.parse(model.animalId),
      weight: model.weight,
      unit: Value(model.unit),
      date: model.date,
      notes: Value.ofNullable(model.notes),
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }
}
