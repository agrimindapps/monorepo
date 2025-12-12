

/// Firebase Remote Data Source for Vehicles
///
/// Responsibilities:
/// - CREATE: Upload new vehicles to Firestore
/// - READ: Fetch single vehicle by Firebase ID
/// - UPDATE: Update existing vehicles (merge=true to avoid overwrites)
/// - DELETE: Soft delete (add deletedAt) or hard delete
/// - FETCH: Get all vehicles modified since timestamp (incremental sync)
///
/// Collection structure: users/{userId}/vehicles/{vehicleId}
/// Ownership-based: All operations require userId for security
library;
import 'package:core/core.dart'
    hide
        ValidationException,
        NetworkException;

import '../../../../core/error/exceptions.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../mappers/vehicle_firebase_mapper.dart';
abstract class VehiclesFirebaseDataSource {
  Future<String> createVehicle(VehicleEntity vehicle, String userId);
  Future<VehicleEntity> getVehicleByFirebaseId(String firebaseId, String userId);
  Future<void> updateVehicle(VehicleEntity vehicle, String userId);
  Future<void> deleteVehicle(String firebaseId, String userId, {bool hardDelete = false});
  Future<List<VehicleEntity>> fetchVehiclesSince(DateTime? timestamp, String userId);
  Future<List<VehicleEntity>> getAllUserVehicles(String userId);
}

class VehiclesFirebaseDataSourceImpl implements VehiclesFirebaseDataSource {

  VehiclesFirebaseDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Private helper: Get vehicles collection reference for user
  CollectionReference _getVehiclesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('vehicles');
  }

  /// CREATE: Upload new vehicle to Firestore
  ///
  /// Returns Firebase document ID (auto-generated UUID)
  /// Throws: AuthFailure, NetworkFailure, ServerFailure
  @override
  Future<String> createVehicle(VehicleEntity vehicle, String userId) async {
    try {
      // Validate user authentication
      if (userId.isEmpty) {
        throw const AuthenticationException('User ID cannot be empty');
      }

      // Convert VehicleEntity to Firestore JSON
      final vehicleData = VehicleFirebaseMapper.toJson(vehicle);

      // Create document in Firestore (auto-generated ID)
      final docRef = await _getVehiclesCollection(userId).add(vehicleData);

      return docRef.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthenticationException('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkException('Firebase network error - service unavailable');
      } else {
        throw ServerException('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is GasometerException) rethrow;
      throw ServerException('Unexpected error creating vehicle: $e');
    }
  }

  /// READ: Get single vehicle by Firebase ID
  ///
  /// Throws: NotFoundFailure, AuthFailure, NetworkFailure
  @override
  Future<VehicleEntity> getVehicleByFirebaseId(
    String firebaseId,
    String userId,
  ) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw const AuthenticationException('User ID cannot be empty');
      }
      if (firebaseId.isEmpty) {
        throw const ValidationException('Vehicle Firebase ID cannot be empty');
      }

      // Fetch document from Firestore
      final doc = await _getVehiclesCollection(userId).doc(firebaseId).get();

      // Check if document exists
      if (!doc.exists || doc.data() == null) {
        throw VehicleNotFoundException('Vehicle not found with ID: $firebaseId');
      }

      // Convert Firestore JSON to VehicleEntity
      final vehicleData = doc.data() as Map<String, dynamic>;
      final vehicle = VehicleFirebaseMapper.fromJson(vehicleData, doc.id);

      // Check if vehicle is soft-deleted
      if (vehicle.isDeleted) {
        throw VehicleNotFoundException('Vehicle was deleted: $firebaseId');
      }

      return vehicle;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthenticationException('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkException('Firebase network error - service unavailable');
      } else {
        throw ServerException('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is GasometerException) rethrow;
      throw ServerException('Unexpected error fetching vehicle: $e');
    }
  }

  /// UPDATE: Update existing vehicle (merge=true to avoid overwrites)
  ///
  /// vehicle.firebaseId must contain the Firebase document ID
  /// Uses SetOptions(merge: true) to prevent overwriting fields we didn't send
  ///
  /// Throws: NotFoundFailure, AuthFailure, NetworkFailure, ServerFailure
  @override
  Future<void> updateVehicle(VehicleEntity vehicle, String userId) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw const AuthenticationException('User ID cannot be empty');
      }
      final firebaseId = vehicle.firebaseId ?? vehicle.id;
      if (firebaseId.isEmpty) {
        throw const ValidationException('Vehicle Firebase ID cannot be empty');
      }

      // Convert VehicleEntity to Firestore JSON
      final vehicleData = VehicleFirebaseMapper.toJson(vehicle);

      // Update document in Firestore (merge=true for safety)
      await _getVehiclesCollection(userId)
          .doc(firebaseId)
          .set(vehicleData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthenticationException('User not authenticated or permission denied');
      } else if (e.code == 'not-found') {
        throw VehicleNotFoundException('Vehicle not found with ID: ${vehicle.firebaseId}');
      } else if (e.code == 'unavailable') {
        throw const NetworkException('Firebase network error - service unavailable');
      } else {
        throw ServerException('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is GasometerException) rethrow;
      throw ServerException('Unexpected error updating vehicle: $e');
    }
  }

  /// DELETE: Soft delete (add deletedAt timestamp) or hard delete
  ///
  /// Soft delete (default): Sets isDeleted=true, keeps document
  /// Hard delete: Removes document completely from Firestore
  ///
  /// Throws: AuthFailure, NetworkFailure, ServerFailure
  @override
  Future<void> deleteVehicle(
    String firebaseId,
    String userId, {
    bool hardDelete = false,
  }) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw const AuthenticationException('User ID cannot be empty');
      }
      if (firebaseId.isEmpty) {
        throw const ValidationException('Vehicle Firebase ID cannot be empty');
      }

      final docRef = _getVehiclesCollection(userId).doc(firebaseId);

      if (hardDelete) {
        // Hard delete: Remove document completely
        await docRef.delete();
      } else {
        // Soft delete: Mark as deleted
        await docRef.update({
          'is_deleted': true,
          'updated_at': Timestamp.now(),
        });
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthenticationException('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkException('Firebase network error - service unavailable');
      } else {
        throw ServerException('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is GasometerException) rethrow;
      throw ServerException('Unexpected error deleting vehicle: $e');
    }
  }

  /// FETCH: Get all vehicles modified since timestamp
  ///
  /// If timestamp is null, fetches all non-deleted vehicles (initial sync)
  /// Uses .where('updated_at', isGreaterThan: timestamp) for incremental sync
  ///
  /// Throws: AuthFailure, NetworkFailure
  @override
  Future<List<VehicleEntity>> fetchVehiclesSince(
    DateTime? timestamp,
    String userId,
  ) async {
    try {
      // Validate user
      if (userId.isEmpty) {
        throw const AuthenticationException('User ID cannot be empty');
      }

      Query query = _getVehiclesCollection(userId)
          .where('is_deleted', isEqualTo: false);

      // Incremental sync: Only fetch vehicles modified after timestamp
      if (timestamp != null) {
        query = query.where(
          'updated_at',
          isGreaterThan: Timestamp.fromDate(timestamp.toUtc()),
        );
      }

      // Execute query
      final snapshot = await query.get();

      // Convert documents to VehicleEntities
      return VehicleFirebaseMapper.fromQuerySnapshot(snapshot);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthenticationException('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkException('Firebase network error - service unavailable');
      } else {
        throw ServerException('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is GasometerException) rethrow;
      throw ServerException('Unexpected error fetching vehicles: $e');
    }
  }

  /// FETCH: Get all user's vehicles (for initial sync)
  ///
  /// Returns all non-deleted vehicles for the user
  /// Sorted by created_at descending (newest first)
  ///
  /// Throws: AuthFailure, NetworkFailure
  @override
  Future<List<VehicleEntity>> getAllUserVehicles(String userId) async {
    try {
      // Validate user
      if (userId.isEmpty) {
        throw const AuthenticationException('User ID cannot be empty');
      }

      // Fetch all non-deleted vehicles
      final snapshot = await _getVehiclesCollection(userId)
          .where('is_deleted', isEqualTo: false)
          .orderBy('created_at', descending: true)
          .get();

      // Convert documents to VehicleEntities
      return VehicleFirebaseMapper.fromQuerySnapshot(snapshot);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthenticationException('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkException('Firebase network error - service unavailable');
      } else {
        throw ServerException('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is GasometerException) rethrow;
      throw ServerException('Unexpected error fetching all vehicles: $e');
    }
  }
}
