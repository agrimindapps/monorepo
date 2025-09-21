import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../models/maintenance_model.dart';

abstract class MaintenanceRemoteDataSource {
  Future<List<MaintenanceEntity>> getAllMaintenanceRecords();
  Future<List<MaintenanceEntity>> getMaintenanceRecordsByVehicle(String vehicleId);
  Future<MaintenanceEntity?> getMaintenanceRecordById(String id);
  Future<MaintenanceEntity> addMaintenanceRecord(MaintenanceEntity maintenance);
  Future<MaintenanceEntity> updateMaintenanceRecord(MaintenanceEntity maintenance);
  Future<void> deleteMaintenanceRecord(String id);
  Future<List<MaintenanceEntity>> searchMaintenanceRecords(String query);
  Stream<List<MaintenanceEntity>> watchMaintenanceRecords();
  Stream<List<MaintenanceEntity>> watchMaintenanceRecordsByVehicle(String vehicleId);
}

@LazySingleton(as: MaintenanceRemoteDataSource)
class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  MaintenanceRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  String get _userId {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const AuthenticationException('Usuário não autenticado');
    return user.uid;
  }

  CollectionReference get _collection => 
      _firestore.collection('users').doc(_userId).collection('maintenance');

  @override
  Future<List<MaintenanceEntity>> getAllMaintenanceRecords() async {
    try {
      final querySnapshot = await _collection
          .where('is_deleted', isEqualTo: false)
          .orderBy('data', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return _mapToEntity(MaintenanceModel.fromFirebaseMap(data));
          })
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar manutenções: ${e.toString()}');
    }
  }

  @override
  Future<List<MaintenanceEntity>> getMaintenanceRecordsByVehicle(String vehicleId) async {
    try {
      final querySnapshot = await _collection
          .where('veiculo_id', isEqualTo: vehicleId)
          .where('is_deleted', isEqualTo: false)
          .orderBy('data', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return _mapToEntity(MaintenanceModel.fromFirebaseMap(data));
          })
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar manutenções por veículo: ${e.toString()}');
    }
  }

  @override
  Future<MaintenanceEntity?> getMaintenanceRecordById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      
      final model = MaintenanceModel.fromFirebaseMap(data);
      return _mapToEntity(model);
    } catch (e) {
      throw ServerException('Erro ao buscar manutenção por ID: ${e.toString()}');
    }
  }

  @override
  Future<MaintenanceEntity> addMaintenanceRecord(MaintenanceEntity maintenance) async {
    try {
      final model = _mapToModel(maintenance);
      final firebaseData = model.toFirebaseMap();
      
      await _collection.doc(maintenance.id).set(firebaseData);
      
      return maintenance;
    } catch (e) {
      throw ServerException('Erro ao adicionar manutenção: ${e.toString()}');
    }
  }

  @override
  Future<MaintenanceEntity> updateMaintenanceRecord(MaintenanceEntity maintenance) async {
    try {
      final updatedMaintenance = maintenance.copyWith(
        updatedAt: DateTime.now(),
      );

      final model = _mapToModel(updatedMaintenance).copyWith(
        isDirty: false,
        lastSyncAt: DateTime.now(),
      );

      final firebaseData = model.toFirebaseMap();
      await _collection.doc(maintenance.id).update(firebaseData);
      
      return updatedMaintenance;
    } catch (e) {
      throw ServerException('Erro ao atualizar manutenção: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMaintenanceRecord(String id) async {
    try {
      await _collection.doc(id).update({
        'is_deleted': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Erro ao deletar manutenção: ${e.toString()}');
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
      throw ServerException('Erro ao buscar manutenções: ${e.toString()}');
    }
  }

  @override
  Stream<List<MaintenanceEntity>> watchMaintenanceRecords() {
    try {
      return _collection
          .where('is_deleted', isEqualTo: false)
          .orderBy('data', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return _mapToEntity(MaintenanceModel.fromFirebaseMap(data));
              })
              .toList());
    } catch (e) {
      throw ServerException('Erro ao observar manutenções: ${e.toString()}');
    }
  }

  @override
  Stream<List<MaintenanceEntity>> watchMaintenanceRecordsByVehicle(String vehicleId) {
    try {
      return _collection
          .where('veiculo_id', isEqualTo: vehicleId)
          .where('is_deleted', isEqualTo: false)
          .orderBy('data', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return _mapToEntity(MaintenanceModel.fromFirebaseMap(data));
              })
              .toList());
    } catch (e) {
      throw ServerException('Erro ao observar manutenções por veículo: ${e.toString()}');
    }
  }

  // Helper methods for entity-model mapping
  MaintenanceEntity _mapToEntity(MaintenanceModel model) {
    return MaintenanceEntity(
      id: model.id,
      userId: model.userId ?? '',
      vehicleId: model.veiculoId,
      type: _mapStringToMaintenanceType(model.tipo),
      status: model.concluida ? MaintenanceStatus.completed : MaintenanceStatus.pending,
      title: model.tipo,
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
      metadata: const {},
    );
  }

  MaintenanceModel _mapToModel(MaintenanceEntity entity) {
    return MaintenanceModel.create(
      id: entity.id,
      userId: entity.userId?.isEmpty == true ? null : entity.userId,
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

