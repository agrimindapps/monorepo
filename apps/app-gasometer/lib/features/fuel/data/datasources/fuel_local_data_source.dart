import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/local_data_service.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../models/fuel_supply_model.dart';

abstract class FuelLocalDataSource {
  Future<List<FuelRecordEntity>> getAllFuelRecords();
  Future<List<FuelRecordEntity>> getFuelRecordsByVehicle(String vehicleId);
  Future<FuelRecordEntity?> getFuelRecordById(String id);
  Future<FuelRecordEntity> addFuelRecord(FuelRecordEntity fuelRecord);
  Future<FuelRecordEntity> updateFuelRecord(FuelRecordEntity fuelRecord);
  Future<void> deleteFuelRecord(String id);
  Future<List<FuelRecordEntity>> searchFuelRecords(String query);
  Future<void> clearAllFuelRecords();
  Stream<List<FuelRecordEntity>> watchFuelRecords();
  Stream<List<FuelRecordEntity>> watchFuelRecordsByVehicle(String vehicleId);
}

@LazySingleton(as: FuelLocalDataSource)
class FuelLocalDataSourceImpl implements FuelLocalDataSource {

  FuelLocalDataSourceImpl(this._localDataService);
  final LocalDataService _localDataService;

  @override
  Future<List<FuelRecordEntity>> getAllFuelRecords() async {
    try {
      final records = _localDataService.getAllFuelRecords()
          .map((record) => _mapToEntity(FuelSupplyModel.fromHiveMap(record)))
          .toList();
      
      // Sort by date descending
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (e) {
      throw CacheException('Erro ao buscar registros de combustível: ${e.toString()}');
    }
  }

  @override
  Future<List<FuelRecordEntity>> getFuelRecordsByVehicle(String vehicleId) async {
    try {
      final records = _localDataService.getFuelRecordsByVehicle(vehicleId)
          .map((record) => _mapToEntity(FuelSupplyModel.fromHiveMap(record)))
          .toList();
      
      // Sort by date descending
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (e) {
      throw CacheException('Erro ao buscar registros por veículo: ${e.toString()}');
    }
  }

  @override
  Future<FuelRecordEntity?> getFuelRecordById(String id) async {
    try {
      final recordData = _localDataService.getFuelRecord(id);
      
      if (recordData == null) return null;
      
      final model = FuelSupplyModel.fromHiveMap(recordData);
      return _mapToEntity(model);
    } catch (e) {
      throw CacheException('Erro ao buscar registro por ID: ${e.toString()}');
    }
  }

  @override
  Future<FuelRecordEntity> addFuelRecord(FuelRecordEntity fuelRecord) async {
    try {
      final model = _mapToModel(fuelRecord);
      await _localDataService.saveFuelRecord(fuelRecord.id, model.toHiveMap());
      return fuelRecord;
    } catch (e) {
      throw CacheException('Erro ao adicionar registro: ${e.toString()}');
    }
  }

  @override
  Future<FuelRecordEntity> updateFuelRecord(FuelRecordEntity fuelRecord) async {
    try {
      final existingData = _localDataService.getFuelRecord(fuelRecord.id);
      
      if (existingData == null) {
        throw const CacheException('Registro não encontrado para atualização');
      }
      
      final updatedRecord = fuelRecord.copyWith(
        updatedAt: DateTime.now(),
      );
      
      final model = _mapToModel(updatedRecord).copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );
      
      await _localDataService.saveFuelRecord(updatedRecord.id, model.toHiveMap());
      return updatedRecord;
    } catch (e) {
      throw CacheException('Erro ao atualizar registro: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteFuelRecord(String id) async {
    try {
      await _localDataService.deleteFuelRecord(id);
    } catch (e) {
      throw CacheException('Erro ao deletar registro: ${e.toString()}');
    }
  }

  @override
  Future<List<FuelRecordEntity>> searchFuelRecords(String query) async {
    try {
      final allRecords = await getAllFuelRecords();
      final lowerQuery = query.toLowerCase();
      
      return allRecords.where((record) {
        return record.gasStationName?.toLowerCase().contains(lowerQuery) == true ||
               record.gasStationBrand?.toLowerCase().contains(lowerQuery) == true ||
               record.notes?.toLowerCase().contains(lowerQuery) == true ||
               record.address?.toLowerCase().contains(lowerQuery) == true;
      }).toList();
    } catch (e) {
      throw CacheException('Erro ao buscar registros: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAllFuelRecords() async {
    try {
      // Clear all fuel records - we'll need to implement this in LocalDataService
      final allRecords = _localDataService.getAllFuelRecords();
      for (final record in allRecords) {
        final id = record['id'] as String?;
        if (id != null) {
          await _localDataService.deleteFuelRecord(id);
        }
      }
    } catch (e) {
      throw CacheException('Erro ao limpar registros: ${e.toString()}');
    }
  }

  @override
  Stream<List<FuelRecordEntity>> watchFuelRecords() {
    // For now, return a simple stream - in production you'd implement proper listening
    return Stream.periodic(const Duration(seconds: 1), (_) => null)
        .asyncMap((_) => getAllFuelRecords());
  }

  @override
  Stream<List<FuelRecordEntity>> watchFuelRecordsByVehicle(String vehicleId) {
    return watchFuelRecords()
        .map((records) => records.where((record) => record.vehicleId == vehicleId).toList());
  }

  // Helper methods
  FuelRecordEntity _mapToEntity(FuelSupplyModel model) {
    return FuelRecordEntity(
      id: model.id,
      userId: model.userId ?? '',
      vehicleId: model.vehicleId,
      fuelType: _mapIntToFuelType(model.fuelType),
      liters: model.liters,
      pricePerLiter: model.pricePerLiter,
      totalPrice: model.totalPrice,
      odometer: model.odometer,
      date: DateTime.fromMillisecondsSinceEpoch(model.date),
      gasStationName: model.gasStationName,
      gasStationBrand: null, // Not available in current model
      fullTank: model.fullTank ?? true,
      notes: model.notes,
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      latitude: null,
      longitude: null,
      previousOdometer: null,
      distanceTraveled: null,
      consumption: null,
    );
  }

  FuelSupplyModel _mapToModel(FuelRecordEntity entity) {
    return FuelSupplyModel.create(
      id: entity.id,
      userId: entity.userId?.isEmpty == true ? null : entity.userId,
      vehicleId: entity.vehicleId,
      date: entity.date.millisecondsSinceEpoch,
      odometer: entity.odometer,
      liters: entity.liters,
      totalPrice: entity.totalPrice,
      fullTank: entity.fullTank,
      pricePerLiter: entity.pricePerLiter,
      gasStationName: entity.gasStationName,
      notes: entity.notes,
      fuelType: _mapFuelTypeToInt(entity.fuelType),
    );
  }

  FuelType _mapIntToFuelType(int type) {
    switch (type) {
      case 1: return FuelType.gasoline;
      case 2: return FuelType.ethanol;
      case 3: return FuelType.diesel;
      case 4: return FuelType.gas;
      case 5: return FuelType.hybrid;
      default: return FuelType.gasoline;
    }
  }

  int _mapFuelTypeToInt(FuelType type) {
    switch (type) {
      case FuelType.gasoline: return 1;
      case FuelType.ethanol: return 2;
      case FuelType.diesel: return 3;
      case FuelType.gas: return 4;
      case FuelType.hybrid: return 5;
      case FuelType.electric: return 6;
    }
  }
}