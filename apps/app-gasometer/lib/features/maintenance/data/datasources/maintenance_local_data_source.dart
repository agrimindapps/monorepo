import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/local_data_service.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../mappers/maintenance_mapper.dart';
import '../models/maintenance_model.dart';

abstract class MaintenanceLocalDataSource {
  Future<List<MaintenanceEntity>> getAllMaintenanceRecords();
  Future<List<MaintenanceEntity>> getMaintenanceRecordsByVehicle(String vehicleId);
  Future<MaintenanceEntity?> getMaintenanceRecordById(String id);
  Future<MaintenanceEntity> addMaintenanceRecord(MaintenanceEntity maintenance);
  Future<MaintenanceEntity> updateMaintenanceRecord(MaintenanceEntity maintenance);
  Future<void> deleteMaintenanceRecord(String id);
  Future<List<MaintenanceEntity>> searchMaintenanceRecords(String query);
  Future<void> clearAllMaintenanceRecords();
  Stream<List<MaintenanceEntity>> watchMaintenanceRecords();
  Stream<List<MaintenanceEntity>> watchMaintenanceRecordsByVehicle(String vehicleId);
}

@LazySingleton(as: MaintenanceLocalDataSource)
class MaintenanceLocalDataSourceImpl implements MaintenanceLocalDataSource {

  MaintenanceLocalDataSourceImpl(this._localDataService);
  final LocalDataService _localDataService;

  @override
  Future<List<MaintenanceEntity>> getAllMaintenanceRecords() async {
    try {
      final records = _localDataService.getAllMaintenanceRecords()
          .map((record) => MaintenanceMapper.modelToEntity(MaintenanceModel.fromHiveMap(record)))
          .toList();
      records.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
      return records;
    } catch (e) {
      throw CacheException('Erro ao buscar registros de manutenção: ${e.toString()}');
    }
  }

  @override
  Future<List<MaintenanceEntity>> getMaintenanceRecordsByVehicle(String vehicleId) async {
    try {
      final records = _localDataService.getAllMaintenanceRecords()
          .where((record) => record['veiculoId'] == vehicleId)
          .map((record) => MaintenanceMapper.modelToEntity(MaintenanceModel.fromHiveMap(record)))
          .toList();
      records.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
      return records;
    } catch (e) {
      throw CacheException('Erro ao buscar registros por veículo: ${e.toString()}');
    }
  }

  @override
  Future<MaintenanceEntity?> getMaintenanceRecordById(String id) async {
    try {
      final recordData = _localDataService.getMaintenanceRecord(id);
      
      if (recordData == null) return null;
      
      final model = MaintenanceModel.fromHiveMap(recordData);
      return MaintenanceMapper.modelToEntity(model);
    } catch (e) {
      throw CacheException('Erro ao buscar registro por ID: ${e.toString()}');
    }
  }

  @override
  Future<MaintenanceEntity> addMaintenanceRecord(MaintenanceEntity maintenance) async {
    try {
      final model = MaintenanceMapper.entityToModel(maintenance);
      await _localDataService.saveMaintenanceRecord(maintenance.id, model.toHiveMap());
      return maintenance;
    } catch (e) {
      throw CacheException('Erro ao adicionar registro: ${e.toString()}');
    }
  }

  @override
  Future<MaintenanceEntity> updateMaintenanceRecord(MaintenanceEntity maintenance) async {
    try {
      final existingData = _localDataService.getMaintenanceRecord(maintenance.id);
      
      if (existingData == null) {
        throw const CacheException('Registro não encontrado para atualização');
      }
      
      final updatedMaintenance = maintenance.copyWith(
        updatedAt: DateTime.now(),
      );
      
      final existingModel = MaintenanceModel.fromHiveMap(existingData);
      final model = MaintenanceMapper.updateModelFromEntity(existingModel, updatedMaintenance);
      
      await _localDataService.saveMaintenanceRecord(updatedMaintenance.id, model.toHiveMap());
      return updatedMaintenance;
    } catch (e) {
      throw CacheException('Erro ao atualizar registro: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMaintenanceRecord(String id) async {
    try {
      final recordData = _localDataService.getMaintenanceRecord(id);
      if (recordData == null) {
        throw const CacheException('Registro não encontrado para exclusão');
      }
      
      await _localDataService.deleteMaintenanceRecord(id);
    } catch (e) {
      throw CacheException('Erro ao deletar registro: ${e.toString()}');
    }
  }

  @override
  Future<List<MaintenanceEntity>> searchMaintenanceRecords(String query) async {
    try {
      final allRecords = await getAllMaintenanceRecords();
      final lowerQuery = query.toLowerCase();
      
      return allRecords.where((record) {
        return record.title.toLowerCase().contains(lowerQuery) ||
               record.description.toLowerCase().contains(lowerQuery) ||
               record.workshopName?.toLowerCase().contains(lowerQuery) == true ||
               record.notes?.toLowerCase().contains(lowerQuery) == true;
      }).toList();
    } catch (e) {
      throw CacheException('Erro ao buscar registros: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAllMaintenanceRecords() async {
    try {
      final allRecords = _localDataService.getAllMaintenanceRecords();
      for (final record in allRecords) {
        final id = record['id'] as String?;
        if (id != null) {
          await _localDataService.deleteMaintenanceRecord(id);
        }
      }
    } catch (e) {
      throw CacheException('Erro ao limpar registros: ${e.toString()}');
    }
  }

  @override
  Stream<List<MaintenanceEntity>> watchMaintenanceRecords() {
    return Stream.periodic(const Duration(seconds: 1), (_) => null)
        .asyncMap((_) => getAllMaintenanceRecords());
  }

  @override
  Stream<List<MaintenanceEntity>> watchMaintenanceRecordsByVehicle(String vehicleId) {
    return watchMaintenanceRecords()
        .map((records) => records.where((record) => record.vehicleId == vehicleId).toList());
  }
}