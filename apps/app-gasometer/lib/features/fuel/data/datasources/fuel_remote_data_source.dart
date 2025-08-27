import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../models/fuel_supply_model.dart';

abstract class FuelRemoteDataSource {
  Future<List<FuelRecordEntity>> getAllFuelRecords(String userId);
  Future<List<FuelRecordEntity>> getFuelRecordsByVehicle(String userId, String vehicleId);
  Future<FuelRecordEntity?> getFuelRecordById(String userId, String id);
  Future<FuelRecordEntity> addFuelRecord(String userId, FuelRecordEntity fuelRecord);
  Future<FuelRecordEntity> updateFuelRecord(String userId, FuelRecordEntity fuelRecord);
  Future<void> deleteFuelRecord(String userId, String id);
  Future<List<FuelRecordEntity>> searchFuelRecords(String userId, String query);
  Stream<List<FuelRecordEntity>> watchFuelRecords(String userId);
  Stream<List<FuelRecordEntity>> watchFuelRecordsByVehicle(String userId, String vehicleId);
}

@LazySingleton(as: FuelRemoteDataSource)
class FuelRemoteDataSourceImpl implements FuelRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'fuel_records';

  FuelRemoteDataSourceImpl(this._firestore);

  CollectionReference _getUserFuelCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collection);
  }

  @override
  Future<List<FuelRecordEntity>> getAllFuelRecords(String userId) async {
    try {
      final querySnapshot = await _getUserFuelCollection(userId)
          .orderBy('data', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return _mapToEntity(FuelSupplyModel.fromFirebaseMap(data));
      }).toList();
    } catch (e) {
      throw ServerException('Erro ao buscar registros de combustível: ${e.toString()}');
    }
  }

  @override
  Future<List<FuelRecordEntity>> getFuelRecordsByVehicle(String userId, String vehicleId) async {
    try {
      final querySnapshot = await _getUserFuelCollection(userId)
          .where('veiculo_id', isEqualTo: vehicleId)
          .orderBy('data', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return _mapToEntity(FuelSupplyModel.fromFirebaseMap(data));
      }).toList();
    } catch (e) {
      throw ServerException('Erro ao buscar registros por veículo: ${e.toString()}');
    }
  }

  @override
  Future<FuelRecordEntity?> getFuelRecordById(String userId, String id) async {
    try {
      final docSnapshot = await _getUserFuelCollection(userId).doc(id).get();

      if (!docSnapshot.exists) return null;

      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = docSnapshot.id;
      return _mapToEntity(FuelSupplyModel.fromFirebaseMap(data));
    } catch (e) {
      throw ServerException('Erro ao buscar registro por ID: ${e.toString()}');
    }
  }

  @override
  Future<FuelRecordEntity> addFuelRecord(String userId, FuelRecordEntity fuelRecord) async {
    try {
      final model = _mapToModel(fuelRecord, userId);
      final docRef = _getUserFuelCollection(userId).doc(fuelRecord.id);
      
      await docRef.set(model.toFirebaseMap());
      return fuelRecord;
    } catch (e) {
      throw ServerException('Erro ao adicionar registro: ${e.toString()}');
    }
  }

  @override
  Future<FuelRecordEntity> updateFuelRecord(String userId, FuelRecordEntity fuelRecord) async {
    try {
      final updatedRecord = fuelRecord.copyWith(
        atualizadoEm: DateTime.now(),
      );

      final model = _mapToModel(updatedRecord, userId);
      final docRef = _getUserFuelCollection(userId).doc(fuelRecord.id);
      
      await docRef.update(model.toFirebaseMap());
      return updatedRecord;
    } catch (e) {
      throw ServerException('Erro ao atualizar registro: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteFuelRecord(String userId, String id) async {
    try {
      await _getUserFuelCollection(userId).doc(id).delete();
    } catch (e) {
      throw ServerException('Erro ao deletar registro: ${e.toString()}');
    }
  }

  @override
  Future<List<FuelRecordEntity>> searchFuelRecords(String userId, String query) async {
    try {
      // Firebase doesn't have full-text search, so we'll implement basic search
      final querySnapshot = await _getUserFuelCollection(userId)
          .orderBy('data', descending: true)
          .get();

      final allRecords = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return _mapToEntity(FuelSupplyModel.fromFirebaseMap(data));
      }).toList();

      final lowerQuery = query.toLowerCase();
      return allRecords.where((record) {
        return record.gasStationName?.toLowerCase().contains(lowerQuery) == true ||
               record.gasStationBrand?.toLowerCase().contains(lowerQuery) == true ||
               record.notes?.toLowerCase().contains(lowerQuery) == true ||
               record.address?.toLowerCase().contains(lowerQuery) == true;
      }).toList();
    } catch (e) {
      throw ServerException('Erro ao buscar registros: ${e.toString()}');
    }
  }

  @override
  Stream<List<FuelRecordEntity>> watchFuelRecords(String userId) {
    try {
      return _getUserFuelCollection(userId)
          .orderBy('data', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return _mapToEntity(FuelSupplyModel.fromFirebaseMap(data));
        }).toList();
      });
    } catch (e) {
      throw ServerException('Erro ao observar registros: ${e.toString()}');
    }
  }

  @override
  Stream<List<FuelRecordEntity>> watchFuelRecordsByVehicle(String userId, String vehicleId) {
    try {
      return _getUserFuelCollection(userId)
          .where('veiculo_id', isEqualTo: vehicleId)
          .orderBy('data', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return _mapToEntity(FuelSupplyModel.fromFirebaseMap(data));
        }).toList();
      });
    } catch (e) {
      throw ServerException('Erro ao observar registros por veículo: ${e.toString()}');
    }
  }

  // Helper methods
  FuelRecordEntity _mapToEntity(FuelSupplyModel model) {
    return FuelRecordEntity(
      id: model.id,
      idUsuario: model.userId ?? '',
      veiculoId: model.veiculoId,
      tipoCombustivel: _mapIntToFuelType(model.tipoCombustivel),
      litros: model.litros,
      precoPorLitro: model.precoPorLitro,
      valorTotal: model.valorTotal,
      odometro: model.odometro,
      data: DateTime.fromMillisecondsSinceEpoch(model.data),
      nomePosto: model.posto,
      marcaPosto: null, // Not available in current model
      tanqueCheio: model.tanqueCheio ?? true,
      observacoes: model.observacao,
      criadoEm: model.createdAt ?? DateTime.now(),
      atualizadoEm: model.updatedAt ?? DateTime.now(),
      latitude: null,
      longitude: null,
      odometroAnterior: null,
      distanciaPercorrida: null,
      consumo: null,
    );
  }

  FuelSupplyModel _mapToModel(FuelRecordEntity entity, String userId) {
    return FuelSupplyModel.create(
      id: entity.id,
      userId: userId,
      veiculoId: entity.vehicleId,
      data: entity.date.millisecondsSinceEpoch,
      odometro: entity.odometer,
      litros: entity.liters,
      valorTotal: entity.totalPrice,
      tanqueCheio: entity.fullTank,
      precoPorLitro: entity.pricePerLiter,
      posto: entity.gasStationName,
      observacao: entity.notes,
      tipoCombustivel: _mapFuelTypeToInt(entity.fuelType),
    );
  }

  FuelType _mapIntToFuelType(int type) {
    switch (type) {
      case 1: return FuelType.gasoline;
      case 2: return FuelType.ethanol;
      case 3: return FuelType.diesel;
      case 4: return FuelType.gas;
      case 5: return FuelType.hybrid;
      case 6: return FuelType.electric;
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