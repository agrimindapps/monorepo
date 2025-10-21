import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/water_achievement_model.dart';
import '../models/water_record_model.dart';

/// Remote data source for water intake data using Firebase Firestore
abstract class WaterRemoteDataSource {
  /// Add a new water record to Firestore
  Future<WaterRecordModel> addRecord(WaterRecordModel record, String userId);

  /// Update an existing water record in Firestore
  Future<WaterRecordModel> updateRecord(WaterRecordModel record, String userId);

  /// Delete a water record from Firestore
  Future<void> deleteRecord(String id, String userId);

  /// Get all water records for a user from Firestore
  Future<List<WaterRecordModel>> getRecords(String userId);

  /// Get water records for a specific date from Firestore
  Future<List<WaterRecordModel>> getRecordsByDate(String userId, DateTime date);

  /// Get water records within a date range from Firestore
  Future<List<WaterRecordModel>> getRecordsInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Sync local records to Firestore
  Future<void> syncRecords(String userId, List<WaterRecordModel> localRecords);

  /// Get all achievements for a user from Firestore
  Future<List<WaterAchievementModel>> getAchievements(String userId);

  /// Add a new achievement to Firestore
  Future<WaterAchievementModel> addAchievement(
      WaterAchievementModel achievement, String userId);

  /// Get daily goal from Firestore
  Future<int> getDailyGoal(String userId);

  /// Update daily goal in Firestore
  Future<void> updateDailyGoal(String userId, int goal);

  /// Get current streak from Firestore
  Future<int> getCurrentStreak(String userId);

  /// Update current streak in Firestore
  Future<void> updateStreak(String userId, int streak);
}

@Injectable(as: WaterRemoteDataSource)
class WaterRemoteDataSourceImpl implements WaterRemoteDataSource {
  static const String _usersCollection = 'users';
  static const String _waterRecordsCollection = 'waterRecords';
  static const String _waterAchievementsCollection = 'waterAchievements';
  static const String _waterSettingsCollection = 'waterSettings';

  final FirebaseFirestore _firestore;

  WaterRemoteDataSourceImpl(this._firestore);

  /// Get reference to user's water records collection
  CollectionReference<Map<String, dynamic>> _getRecordsCollection(
      String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_waterRecordsCollection);
  }

  /// Get reference to user's water achievements collection
  CollectionReference<Map<String, dynamic>> _getAchievementsCollection(
      String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_waterAchievementsCollection);
  }

  /// Get reference to user's water settings document
  DocumentReference<Map<String, dynamic>> _getSettingsDocument(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_waterSettingsCollection)
        .doc('settings');
  }

  @override
  Future<WaterRecordModel> addRecord(
      WaterRecordModel record, String userId) async {
    try {
      final collection = _getRecordsCollection(userId);
      await collection.doc(record.id).set(record.toFirebaseMap());
      return record;
    } catch (e) {
      throw ServerException('Failed to add water record to Firestore: $e');
    }
  }

  @override
  Future<WaterRecordModel> updateRecord(
      WaterRecordModel record, String userId) async {
    try {
      final collection = _getRecordsCollection(userId);
      final docRef = collection.doc(record.id);

      // Check if document exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw ServerException('Water record not found: ${record.id}');
      }

      await docRef.update(record.toFirebaseMap());
      return record;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update water record in Firestore: $e');
    }
  }

  @override
  Future<void> deleteRecord(String id, String userId) async {
    try {
      final collection = _getRecordsCollection(userId);
      await collection.doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete water record from Firestore: $e');
    }
  }

  @override
  Future<List<WaterRecordModel>> getRecords(String userId) async {
    try {
      final collection = _getRecordsCollection(userId);
      final snapshot = await collection.get();

      return snapshot.docs
          .map((doc) => WaterRecordModel.fromFirebaseMap(doc.data()))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      throw ServerException('Failed to get water records from Firestore: $e');
    }
  }

  @override
  Future<List<WaterRecordModel>> getRecordsByDate(
      String userId, DateTime date) async {
    try {
      final collection = _getRecordsCollection(userId);
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await collection
          .where('timestamp',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .get();

      return snapshot.docs
          .map((doc) => WaterRecordModel.fromFirebaseMap(doc.data()))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      throw ServerException(
          'Failed to get water records by date from Firestore: $e');
    }
  }

  @override
  Future<List<WaterRecordModel>> getRecordsInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final collection = _getRecordsCollection(userId);
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      final snapshot = await collection
          .where('timestamp', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: end.toIso8601String())
          .get();

      return snapshot.docs
          .map((doc) => WaterRecordModel.fromFirebaseMap(doc.data()))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      throw ServerException(
          'Failed to get water records in range from Firestore: $e');
    }
  }

  @override
  Future<void> syncRecords(
      String userId, List<WaterRecordModel> localRecords) async {
    try {
      final collection = _getRecordsCollection(userId);
      final batch = _firestore.batch();

      for (final record in localRecords) {
        final docRef = collection.doc(record.id);
        batch.set(docRef, record.toFirebaseMap(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to sync water records to Firestore: $e');
    }
  }

  @override
  Future<List<WaterAchievementModel>> getAchievements(String userId) async {
    try {
      final collection = _getAchievementsCollection(userId);
      final snapshot = await collection.get();

      return snapshot.docs
          .map((doc) => WaterAchievementModel.fromFirebaseMap(doc.data()))
          .toList()
        ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    } catch (e) {
      throw ServerException('Failed to get achievements from Firestore: $e');
    }
  }

  @override
  Future<WaterAchievementModel> addAchievement(
      WaterAchievementModel achievement, String userId) async {
    try {
      final collection = _getAchievementsCollection(userId);
      await collection.doc(achievement.id).set(achievement.toFirebaseMap());
      return achievement;
    } catch (e) {
      throw ServerException('Failed to add achievement to Firestore: $e');
    }
  }

  @override
  Future<int> getDailyGoal(String userId) async {
    try {
      final doc = await _getSettingsDocument(userId).get();

      if (!doc.exists) {
        return 2000; // Default goal
      }

      final data = doc.data();
      return (data?['dailyGoal'] as num?)?.toInt() ?? 2000;
    } catch (e) {
      throw ServerException('Failed to get daily goal from Firestore: $e');
    }
  }

  @override
  Future<void> updateDailyGoal(String userId, int goal) async {
    try {
      await _getSettingsDocument(userId).set({
        'dailyGoal': goal,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to update daily goal in Firestore: $e');
    }
  }

  @override
  Future<int> getCurrentStreak(String userId) async {
    try {
      final doc = await _getSettingsDocument(userId).get();

      if (!doc.exists) {
        return 0; // Default streak
      }

      final data = doc.data();
      return (data?['currentStreak'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw ServerException('Failed to get current streak from Firestore: $e');
    }
  }

  @override
  Future<void> updateStreak(String userId, int streak) async {
    try {
      await _getSettingsDocument(userId).set({
        'currentStreak': streak,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to update streak in Firestore: $e');
    }
  }
}
