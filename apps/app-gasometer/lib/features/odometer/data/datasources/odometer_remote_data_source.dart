import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/odometer_entity.dart';
import '../models/odometer_model.dart';

abstract class OdometerRemoteDataSource {
  Future<List<OdometerEntity>> getAllOdometerReadings(String userId);
  Future<List<OdometerEntity>> getOdometerReadingsByVehicle(String userId, String vehicleId);
  Future<OdometerEntity?> getOdometerReadingById(String userId, String id);
  Future<OdometerEntity> addOdometerReading(String userId, OdometerEntity reading);
  Future<OdometerEntity> updateOdometerReading(String userId, OdometerEntity reading);
  Future<void> deleteOdometerReading(String userId, String id);
  Future<List<OdometerEntity>> searchOdometerReadings(String userId, String query);
  Stream<List<OdometerEntity>> watchOdometerReadings(String userId);
  Stream<List<OdometerEntity>> watchOdometerReadingsByVehicle(String userId, String vehicleId);
}

@LazySingleton(as: OdometerRemoteDataSource)
class OdometerRemoteDataSourceImpl implements OdometerRemoteDataSource {

  OdometerRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;
  static const String _collection = 'odometer_readings';

  CollectionReference _getUserOdometerCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collection);
  }

  @override
  Future<List<OdometerEntity>> getAllOdometerReadings(String userId) async {
    try {
      final QuerySnapshot snapshot = await _getUserOdometerCollection(userId)
          .orderBy('registrationDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _documentToEntity(doc))
          .where((reading) => reading != null)
          .cast<OdometerEntity>()
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch odometer readings from remote: $e');
    }
  }

  @override
  Future<List<OdometerEntity>> getOdometerReadingsByVehicle(String userId, String vehicleId) async {
    try {
      final QuerySnapshot snapshot = await _getUserOdometerCollection(userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('registrationDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _documentToEntity(doc))
          .where((reading) => reading != null)
          .cast<OdometerEntity>()
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch odometer readings by vehicle from remote: $e');
    }
  }

  @override
  Future<OdometerEntity?> getOdometerReadingById(String userId, String id) async {
    try {
      final DocumentSnapshot doc = await _getUserOdometerCollection(userId).doc(id).get();
      return _documentToEntity(doc);
    } catch (e) {
      throw ServerException('Failed to fetch odometer reading by id from remote: $e');
    }
  }

  @override
  Future<OdometerEntity> addOdometerReading(String userId, OdometerEntity reading) async {
    try {
      final model = OdometerModel.create(
        id: reading.id,
        userId: userId,
        vehicleId: reading.vehicleId,
        registrationDate: reading.registrationDate.millisecondsSinceEpoch,
        value: reading.value,
        description: reading.description,
        type: reading.type.name,
      );
      
      final docRef = _getUserOdometerCollection(userId).doc(reading.id);
      await docRef.set(model.toFirebaseMap());
      
      return reading;
    } catch (e) {
      throw ServerException('Failed to add odometer reading to remote: $e');
    }
  }

  @override
  Future<OdometerEntity> updateOdometerReading(String userId, OdometerEntity reading) async {
    try {
      final model = OdometerModel.create(
        id: reading.id,
        userId: userId,
        vehicleId: reading.vehicleId,
        registrationDate: reading.registrationDate.millisecondsSinceEpoch,
        value: reading.value,
        description: reading.description,
        type: reading.type.name,
      );
      
      await _getUserOdometerCollection(userId)
          .doc(reading.id)
          .update(model.toFirebaseMap());
      
      return reading;
    } catch (e) {
      throw ServerException('Failed to update odometer reading in remote: $e');
    }
  }

  @override
  Future<void> deleteOdometerReading(String userId, String id) async {
    try {
      await _getUserOdometerCollection(userId).doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete odometer reading from remote: $e');
    }
  }

  @override
  Future<List<OdometerEntity>> searchOdometerReadings(String userId, String query) async {
    try {
      // Firebase text search is limited, so we'll fetch all and filter locally
      final allReadings = await getAllOdometerReadings(userId);
      final lowercaseQuery = query.toLowerCase();
      
      return allReadings.where((reading) {
        return reading.description.toLowerCase().contains(lowercaseQuery) ||
               reading.type.name.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to search odometer readings in remote: $e');
    }
  }

  @override
  Stream<List<OdometerEntity>> watchOdometerReadings(String userId) {
    try {
      return _getUserOdometerCollection(userId)
          .orderBy('registrationDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => _documentToEntity(doc))
            .where((reading) => reading != null)
            .cast<OdometerEntity>()
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to watch odometer readings from remote: $e');
    }
  }

  @override
  Stream<List<OdometerEntity>> watchOdometerReadingsByVehicle(String userId, String vehicleId) {
    try {
      return _getUserOdometerCollection(userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('registrationDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => _documentToEntity(doc))
            .where((reading) => reading != null)
            .cast<OdometerEntity>()
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to watch odometer readings by vehicle from remote: $e');
    }
  }

  OdometerEntity? _documentToEntity(DocumentSnapshot doc) {
    try {
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;
      
      data['id'] = doc.id;
      final model = OdometerModel.fromFirebaseMap(data);
      
      return OdometerEntity(
        id: model.id,
        vehicleId: model.vehicleId,
        userId: model.userId ?? '',
        value: model.value,
        registrationDate: DateTime.fromMillisecondsSinceEpoch(model.registrationDate),
        description: model.description,
        type: OdometerType.fromString(model.type ?? 'other'),
        createdAt: model.createdAt ?? DateTime.now(),
        updatedAt: model.updatedAt ?? DateTime.now(),
        metadata: {
          'version': model.version,
          'isDirty': model.isDirty,
          'lastSync': model.lastSyncAt?.toIso8601String(),
        },
      );
    } catch (e) {
      // Log the error but don't throw to avoid breaking the entire list
      print('Error converting document to odometer entity: $e');
      return null;
    }
  }
}