import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/local_data_service.dart';
import '../models/maintenance_model.dart';
import '../../domain/entities/maintenance_entity.dart';

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
  final LocalDataService _localDataService;

  MaintenanceLocalDataSourceImpl(this._localDataService);

  @override
  Future<List<MaintenanceEntity>> getAllMaintenanceRecords() async {
    try {
      final records = _localDataService.getAllMaintenanceRecords()
          .map((record) => _mapToEntity(MaintenanceModel.fromHiveMap(record)))
          .toList();
      
      // Sort by date descending
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
          .map((record) => _mapToEntity(MaintenanceModel.fromHiveMap(record)))
          .toList();
      
      // Sort by date descending
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
      return _mapToEntity(model);
    } catch (e) {
      throw CacheException('Erro ao buscar registro por ID: ${e.toString()}');
    }
  }

  @override
  Future<MaintenanceEntity> addMaintenanceRecord(MaintenanceEntity maintenance) async {
    try {
      final model = _mapToModel(maintenance);
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
        throw CacheException('Registro não encontrado para atualização');
      }
      
      final updatedMaintenance = maintenance.copyWith(
        updatedAt: DateTime.now(),
      );
      
      final model = _mapToModel(updatedMaintenance).copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );
      
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
        throw CacheException('Registro não encontrado para exclusão');
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
      // Clear all maintenance records - we'll need to implement this in LocalDataService
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
    // For now, return a simple stream - in production you'd implement proper listening
    return Stream.periodic(const Duration(seconds: 1), (_) => null)
        .asyncMap((_) => getAllMaintenanceRecords());
  }

  @override
  Stream<List<MaintenanceEntity>> watchMaintenanceRecordsByVehicle(String vehicleId) {
    return watchMaintenanceRecords()
        .map((records) => records.where((record) => record.vehicleId == vehicleId).toList());
  }

  // Helper methods
  MaintenanceEntity _mapToEntity(MaintenanceModel model) {
    return MaintenanceEntity(
      id: model.id,
      userId: model.userId ?? '',
      vehicleId: model.veiculoId,
      type: _mapStringToMaintenanceType(model.tipo),
      status: model.concluida ? MaintenanceStatus.completed : MaintenanceStatus.pending,
      title: model.tipo, // Using type as title for now
      description: model.descricao,
      cost: model.valor,
      serviceDate: DateTime.fromMillisecondsSinceEpoch(model.data),
      odometer: model.odometro.toDouble(),
      workshopName: null, // Not available in current model
      workshopPhone: null,
      workshopAddress: null,
      nextServiceDate: model.proximaRevisao != null 
          ? DateTime.fromMillisecondsSinceEpoch(model.proximaRevisao!) 
          : null,
      nextServiceOdometer: null,
      photosPaths: const [],
      invoicesPaths: const [],
      parts: const {},
      notes: null,
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      metadata: {},
    );
  }

  MaintenanceModel _mapToModel(MaintenanceEntity entity) {
    return MaintenanceModel.create(
      id: entity.id,
      userId: entity.userId.isEmpty ? null : entity.userId,
      veiculoId: entity.vehicleId,
      tipo: _mapMaintenanceTypeToString(entity.type),
      descricao: entity.description,
      valor: entity.cost,
      data: entity.serviceDate.millisecondsSinceEpoch,
      odometro: entity.odometer.toInt(),
      proximaRevisao: entity.nextServiceDate?.millisecondsSinceEpoch,
      concluida: entity.status == MaintenanceStatus.completed,
    );
  }

  MaintenanceType _mapStringToMaintenanceType(String type) {
    switch (type.toLowerCase()) {
      case 'preventiva':
        return MaintenanceType.preventive;
      case 'corretiva':
        return MaintenanceType.corrective;
      case 'revisão':
      case 'revisao':
        return MaintenanceType.inspection;
      case 'emergencial':
        return MaintenanceType.emergency;
      default:
        return MaintenanceType.preventive;
    }
  }

  String _mapMaintenanceTypeToString(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return 'Preventiva';
      case MaintenanceType.corrective:
        return 'Corretiva';
      case MaintenanceType.inspection:
        return 'Revisão';
      case MaintenanceType.emergency:
        return 'Emergencial';
    }
  }
}