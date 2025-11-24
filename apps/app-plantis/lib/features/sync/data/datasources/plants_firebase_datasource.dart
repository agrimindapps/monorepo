import 'package:core/core.dart';

import '../../../plants/data/models/plant_model.dart';
import '../mappers/plant_firebase_mapper.dart';

/// Firebase Remote Data Source for Plants
///
/// Responsibilities:
/// - CREATE: Upload new plants to Firestore
/// - READ: Fetch single plant by Firebase ID
/// - UPDATE: Update existing plants (merge=true to avoid overwrites)
/// - DELETE: Soft delete (add deletedAt) or hard delete
/// - FETCH: Get all plants modified since timestamp (incremental sync)
///
/// Collection structure: users/{userId}/plants/{plantId}
/// Ownership-based: All operations require userId for security
abstract class PlantsFirebaseDataSource {
  Future<String> createPlant(PlantModel plant, String userId);
  Future<PlantModel> getPlantByFirebaseId(String firebaseId, String userId);
  Future<void> updatePlant(PlantModel plant, String userId);
  Future<void> deletePlant(String firebaseId, String userId, {bool hardDelete = false});
  Future<List<PlantModel>> fetchPlantsSince(DateTime? timestamp, String userId);
  Future<List<PlantModel>> getAllUserPlants(String userId);
}

class PlantsFirebaseDataSourceImpl implements PlantsFirebaseDataSource {
  final FirebaseFirestore _firestore;

  PlantsFirebaseDataSourceImpl(this._firestore, FirebaseAuth _);

  /// Private helper: Get plants collection reference for user
  CollectionReference _getPlantsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('plants');
  }

  /// CREATE: Upload new plant to Firestore
  ///
  /// Returns Firebase document ID (NOT local id)
  /// Throws: AuthFailure, NetworkFailure, ServerFailure
  @override
  Future<String> createPlant(PlantModel plant, String userId) async {
    try {
      // Validate user authentication
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }

      // Convert PlantModel to Firestore JSON
      final plantData = PlantFirebaseMapper.toJson(plant);

      // Create document in Firestore (auto-generated ID)
      final docRef = await _getPlantsCollection(userId).add(plantData);

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
      throw ServerFailure('Unexpected error creating plant: $e');
    }
  }

  /// READ: Get single plant by Firebase ID
  ///
  /// Throws: NotFoundFailure, AuthFailure, NetworkFailure
  @override
  Future<PlantModel> getPlantByFirebaseId(
    String firebaseId,
    String userId,
  ) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }
      if (firebaseId.isEmpty) {
        throw const ValidationFailure('Plant Firebase ID cannot be empty');
      }

      // Fetch document from Firestore
      final doc = await _getPlantsCollection(userId).doc(firebaseId).get();

      // Check if document exists
      if (!doc.exists || doc.data() == null) {
        throw NotFoundFailure('Plant not found with ID: $firebaseId');
      }

      // Convert Firestore JSON to PlantModel
      final plantData = doc.data() as Map<String, dynamic>;
      final plant = PlantFirebaseMapper.fromJson(plantData, doc.id);

      // Check if plant is soft-deleted
      if (plant.isDeleted) {
        throw NotFoundFailure('Plant was deleted: $firebaseId');
      }

      return plant;
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
      throw ServerFailure('Unexpected error fetching plant: $e');
    }
  }

  /// UPDATE: Update existing plant (merge=true to avoid overwrites)
  ///
  /// plant.id must contain the Firebase document ID
  /// Uses SetOptions(merge: true) to prevent overwriting fields we didn't send
  ///
  /// Throws: NotFoundFailure, AuthFailure, NetworkFailure, ServerFailure
  @override
  Future<void> updatePlant(PlantModel plant, String userId) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }
      if (plant.id.isEmpty) {
        throw const ValidationFailure('Plant ID cannot be empty');
      }

      // Convert PlantModel to Firestore JSON
      final plantData = PlantFirebaseMapper.toJson(plant);

      // Update document in Firestore (merge=true for safety)
      await _getPlantsCollection(userId)
          .doc(plant.id)
          .set(plantData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthFailure('User not authenticated or permission denied');
      } else if (e.code == 'not-found') {
        throw NotFoundFailure('Plant not found with ID: ${plant.id}');
      } else if (e.code == 'unavailable') {
        throw const NetworkFailure('Firebase network error - service unavailable');
      } else {
        throw ServerFailure('Firebase error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Unexpected error updating plant: $e');
    }
  }

  /// DELETE: Soft delete (add deletedAt timestamp) or hard delete
  ///
  /// Soft delete (default): Sets isDeleted=true, keeps document
  /// Hard delete: Removes document completely from Firestore
  ///
  /// Throws: AuthFailure, NetworkFailure, ServerFailure
  @override
  Future<void> deletePlant(
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
        throw const ValidationFailure('Plant Firebase ID cannot be empty');
      }

      final docRef = _getPlantsCollection(userId).doc(firebaseId);

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
      throw ServerFailure('Unexpected error deleting plant: $e');
    }
  }

  /// FETCH: Get all plants modified since timestamp
  ///
  /// If timestamp is null, fetches all non-deleted plants (initial sync)
  /// Uses .where('updated_at', isGreaterThan: timestamp) for incremental sync
  ///
  /// Throws: AuthFailure, NetworkFailure
  @override
  Future<List<PlantModel>> fetchPlantsSince(
    DateTime? timestamp,
    String userId,
  ) async {
    try {
      // Validate user
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }

      Query query = _getPlantsCollection(userId)
          .where('is_deleted', isEqualTo: false);

      // Incremental sync: Only fetch plants modified after timestamp
      if (timestamp != null) {
        query = query.where(
          'updated_at',
          isGreaterThan: Timestamp.fromDate(timestamp.toUtc()),
        );
      }

      // Execute query
      final snapshot = await query.get();

      // Convert documents to PlantModels
      return PlantFirebaseMapper.fromQuerySnapshot(snapshot);
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
      throw ServerFailure('Unexpected error fetching plants: $e');
    }
  }

  /// FETCH: Get all user's plants (for initial sync)
  ///
  /// Returns all non-deleted plants for the user
  /// Sorted by created_at descending (newest first)
  ///
  /// Throws: AuthFailure, NetworkFailure
  @override
  Future<List<PlantModel>> getAllUserPlants(String userId) async {
    try {
      // Validate user
      if (userId.isEmpty) {
        throw const AuthFailure('User ID cannot be empty');
      }

      // Fetch all non-deleted plants
      final snapshot = await _getPlantsCollection(userId)
          .where('is_deleted', isEqualTo: false)
          .orderBy('created_at', descending: true)
          .get();

      // Convert documents to PlantModels
      return PlantFirebaseMapper.fromQuerySnapshot(snapshot);
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
      throw ServerFailure('Unexpected error fetching all plants: $e');
    }
  }
}
