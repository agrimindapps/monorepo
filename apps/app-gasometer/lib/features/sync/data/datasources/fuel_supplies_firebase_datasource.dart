

/// Firebase Remote Data Source for Fuel Records (Supplies)
///
/// Responsibilities:
/// - CREATE: Upload new fuel records to Firestore
/// - READ: Fetch single fuel record by Firebase ID
/// - UPDATE: Update existing fuel records (merge=true to avoid overwrites)
/// - DELETE: Soft delete (add deletedAt) or hard delete
/// - FETCH: Get all fuel records modified since timestamp (incremental sync)
///
/// Collection structure: users/{userId}/fuel_supplies/{recordId}
/// Ownership-based: All operations require userId for security
library;
import 'package:core/core.dart';

import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../mappers/fuel_record_firebase_mapper.dart';
abstract class FuelSuppliesFirebaseDataSource {
  Future<String> createFuelRecord(FuelRecordEntity record, String userId);
  Future<FuelRecordEntity> getFuelRecordByFirebaseId(String firebaseId, String userId);
  Future<void> updateFuelRecord(FuelRecordEntity record, String userId);
  Future<void> deleteFuelRecord(String firebaseId, String userId, {bool hardDelete = false});
  Future<List<FuelRecordEntity>> fetchFuelRecordsSince(DateTime? timestamp, String userId);
  Future<List<FuelRecordEntity>> getAllUserFuelRecords(String userId);
  Future<List<FuelRecordEntity>> getFuelRecordsByVehicle(String vehicleId, String userId);
}

class FuelSuppliesFirebaseDataSourceImpl implements FuelSuppliesFirebaseDataSource {

  FuelSuppliesFirebaseDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Private helper: Get fuel_supplies collection reference for user
  CollectionReference _getFuelSuppliesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('fuel_supplies');
  }

  /// CREATE: Upload new fuel record to Firestore
  ///
  /// Returns Firebase document ID (auto-generated UUID)
  /// Throws: AuthFailure, NetworkFailure, ServerFailure
  @override
  Future<String> createFuelRecord(FuelRecordEntity record, String userId) async {
    try {
      // Validate user authentication
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }

      // Convert FuelRecordEntity to Firestore JSON
      final recordData = FuelRecordFirebaseMapper.toJson(record);

      // Create document in Firestore (auto-generated ID)
      final docRef = await _getFuelSuppliesCollection(userId).add(recordData);

      return docRef.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkFailure('Firebase network error - service unavailable');
      } else {
        throw ServerFailure('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Unexpected error creating fuel record: $e');
    }
  }

  /// READ: Get single fuel record by Firebase ID
  ///
  /// Throws: NotFoundFailure, AuthFailure, NetworkFailure
  @override
  Future<FuelRecordEntity> getFuelRecordByFirebaseId(
    String firebaseId,
    String userId,
  ) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }
      if (firebaseId.isEmpty) {
        throw const ValidationFailure('Fuel record Firebase ID cannot be empty');
      }

      // Fetch document from Firestore
      final doc = await _getFuelSuppliesCollection(userId).doc(firebaseId).get();

      // Check if document exists
      if (!doc.exists || doc.data() == null) {
        throw NotFoundFailure('Fuel record not found with ID: $firebaseId');
      }

      // Convert Firestore JSON to FuelRecordEntity
      final recordData = doc.data() as Map<String, dynamic>;
      final record = FuelRecordFirebaseMapper.fromJson(recordData, doc.id);

      // Check if record is soft-deleted
      if (record.isDeleted) {
        throw NotFoundFailure('Fuel record was deleted: $firebaseId');
      }

      return record;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkFailure('Firebase network error - service unavailable');
      } else {
        throw ServerFailure('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Unexpected error fetching fuel record: $e');
    }
  }

  /// UPDATE: Update existing fuel record (merge=true to avoid overwrites)
  ///
  /// record.id must contain the Firebase document ID
  /// Uses SetOptions(merge: true) to prevent overwriting fields we didn't send
  ///
  /// Throws: NotFoundFailure, AuthFailure, NetworkFailure, ServerFailure
  @override
  Future<void> updateFuelRecord(FuelRecordEntity record, String userId) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }
      if (record.id.isEmpty) {
        throw const ValidationFailure('Fuel record ID cannot be empty');
      }

      // Convert FuelRecordEntity to Firestore JSON
      final recordData = FuelRecordFirebaseMapper.toJson(record);

      // Update document in Firestore (merge=true for safety)
      await _getFuelSuppliesCollection(userId)
          .doc(record.id)
          .set(recordData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure('User not authenticated or permission denied');
      } else if (e.code == 'not-found') {
        throw NotFoundFailure('Fuel record not found with ID: ${record.id}');
      } else if (e.code == 'unavailable') {
        throw const NetworkFailure('Firebase network error - service unavailable');
      } else {
        throw ServerFailure('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Unexpected error updating fuel record: $e');
    }
  }

  /// DELETE: Soft delete (add deletedAt timestamp) or hard delete
  ///
  /// Soft delete (default): Sets isDeleted=true, keeps document
  /// Hard delete: Removes document completely from Firestore
  ///
  /// Throws: AuthFailure, NetworkFailure, ServerFailure
  @override
  Future<void> deleteFuelRecord(
    String firebaseId,
    String userId, {
    bool hardDelete = false,
  }) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }
      if (firebaseId.isEmpty) {
        throw const ValidationFailure('Fuel record Firebase ID cannot be empty');
      }

      final docRef = _getFuelSuppliesCollection(userId).doc(firebaseId);

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
        throw const AuthFailure('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkFailure('Firebase network error - service unavailable');
      } else {
        throw ServerFailure('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Unexpected error deleting fuel record: $e');
    }
  }

  /// FETCH: Get all fuel records modified since timestamp
  ///
  /// If timestamp is null, fetches all non-deleted fuel records (initial sync)
  /// Uses .where('updated_at', isGreaterThan: timestamp) for incremental sync
  ///
  /// Throws: AuthFailure, NetworkFailure
  @override
  Future<List<FuelRecordEntity>> fetchFuelRecordsSince(
    DateTime? timestamp,
    String userId,
  ) async {
    try {
      // Validate user
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }

      Query query = _getFuelSuppliesCollection(userId)
          .where('is_deleted', isEqualTo: false);

      // Incremental sync: Only fetch records modified after timestamp
      if (timestamp != null) {
        query = query.where(
          'updated_at',
          isGreaterThan: Timestamp.fromDate(timestamp.toUtc()),
        );
      }

      // Execute query
      final snapshot = await query.get();

      // Convert documents to FuelRecordEntities
      return FuelRecordFirebaseMapper.fromQuerySnapshot(snapshot);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkFailure('Firebase network error - service unavailable');
      } else {
        throw ServerFailure('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Unexpected error fetching fuel records: $e');
    }
  }

  /// FETCH: Get all user's fuel records (for initial sync)
  ///
  /// Returns all non-deleted fuel records for the user
  /// Sorted by date descending (newest first)
  ///
  /// Throws: AuthFailure, NetworkFailure
  @override
  Future<List<FuelRecordEntity>> getAllUserFuelRecords(String userId) async {
    try {
      // Validate user
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }

      // Fetch all non-deleted fuel records
      final snapshot = await _getFuelSuppliesCollection(userId)
          .where('is_deleted', isEqualTo: false)
          .orderBy('date', descending: true)
          .get();

      // Convert documents to FuelRecordEntities
      return FuelRecordFirebaseMapper.fromQuerySnapshot(snapshot);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkFailure('Firebase network error - service unavailable');
      } else {
        throw ServerFailure('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Unexpected error fetching all fuel records: $e');
    }
  }

  /// FETCH: Get fuel records for a specific vehicle
  ///
  /// Returns all non-deleted fuel records for a vehicle
  /// Sorted by date descending (newest first)
  ///
  /// Throws: AuthFailure, NetworkFailure
  @override
  Future<List<FuelRecordEntity>> getFuelRecordsByVehicle(
    String vehicleId,
    String userId,
  ) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }
      if (vehicleId.isEmpty) {
        throw const ValidationFailure('Vehicle ID cannot be empty');
      }

      // Fetch fuel records for vehicle
      final snapshot = await _getFuelSuppliesCollection(userId)
          .where('vehicle_id', isEqualTo: vehicleId)
          .where('is_deleted', isEqualTo: false)
          .orderBy('date', descending: true)
          .get();

      // Convert documents to FuelRecordEntities
      return FuelRecordFirebaseMapper.fromQuerySnapshot(snapshot);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure('User not authenticated or permission denied');
      } else if (e.code == 'unavailable') {
        throw const NetworkFailure('Firebase network error - service unavailable');
      } else {
        throw ServerFailure('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Unexpected error fetching fuel records by vehicle: $e');
    }
  }
}
