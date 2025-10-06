import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> getAllVehicles(String userId);
  Future<VehicleModel?> getVehicleById(String userId, String vehicleId);
  Future<void> saveVehicle(String userId, VehicleModel vehicle);
  Future<void> updateVehicle(String userId, VehicleModel vehicle);
  Future<void> deleteVehicle(String userId, String vehicleId);
  Future<void> syncVehicles(String userId, List<VehicleModel> vehicles);
  Stream<List<VehicleModel>> watchVehicles(String userId);
}

@LazySingleton(as: VehicleRemoteDataSource)
class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {

  VehicleRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;
  static const String _collection = 'vehicles';

  CollectionReference _getVehiclesCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection);
  }

  @override
  Future<List<VehicleModel>> getAllVehicles(String userId) async {
    try {
      final querySnapshot = await _getVehiclesCollection(userId).get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return VehicleModel.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw RemoteDataSourceException('Failed to get all vehicles: $e');
    }
  }

  @override
  Future<VehicleModel?> getVehicleById(String userId, String vehicleId) async {
    try {
      final docSnapshot = await _getVehiclesCollection(userId).doc(vehicleId).get();
      
      if (!docSnapshot.exists) return null;
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = docSnapshot.id;
      return VehicleModel.fromJson(data);
    } catch (e) {
      throw RemoteDataSourceException('Failed to get vehicle by id: $e');
    }
  }

  @override
  Future<void> saveVehicle(String userId, VehicleModel vehicle) async {
    try {
      final vehicleData = vehicle.toFirebaseMap();
      vehicleData.addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'user_id': userId,
      });

      await _getVehiclesCollection(userId).doc(vehicle.id).set(vehicleData);
    } catch (e) {
      throw RemoteDataSourceException('Failed to save vehicle: $e');
    }
  }

  @override
  Future<void> updateVehicle(String userId, VehicleModel vehicle) async {
    try {
      final vehicleData = vehicle.toFirebaseMap();
      vehicleData.addAll({
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _getVehiclesCollection(userId).doc(vehicle.id).update(vehicleData);
    } catch (e) {
      throw RemoteDataSourceException('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(String userId, String vehicleId) async {
    try {
      await _getVehiclesCollection(userId).doc(vehicleId).delete();
    } catch (e) {
      throw RemoteDataSourceException('Failed to delete vehicle: $e');
    }
  }

  @override
  Future<void> syncVehicles(String userId, List<VehicleModel> vehicles) async {
    try {
      final batch = _firestore.batch();
      final collection = _getVehiclesCollection(userId);

      for (final vehicle in vehicles) {
        final vehicleData = vehicle.toFirebaseMap();
        vehicleData.addAll({
          'updatedAt': FieldValue.serverTimestamp(),
          'synced': true,
          'user_id': userId,
        });

        batch.set(collection.doc(vehicle.id), vehicleData);
      }

      await batch.commit();
    } catch (e) {
      throw RemoteDataSourceException('Failed to sync vehicles: $e');
    }
  }

  @override
  Stream<List<VehicleModel>> watchVehicles(String userId) {
    try {
      return _getVehiclesCollection(userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return VehicleModel.fromJson(data);
            })
            .toList();
      });
    } catch (e) {
      throw RemoteDataSourceException('Failed to watch vehicles: $e');
    }
  }
}

class RemoteDataSourceException implements Exception {
  RemoteDataSourceException(this.message);
  final String message;

  @override
  String toString() => 'RemoteDataSourceException: $message';
}
