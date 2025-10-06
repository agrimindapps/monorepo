import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../entities/log_entry.dart';

abstract class LogRemoteDataSource {
  Future<void> syncLogs(List<LogEntry> logs);
  Future<void> saveLog(String userId, LogEntry log);
  Future<List<LogEntry>> getUserLogs(String userId, {int limit = 1000});
  Future<void> deleteUserLogs(String userId);
}

@LazySingleton(as: LogRemoteDataSource)
class LogRemoteDataSourceImpl implements LogRemoteDataSource {
  
  LogRemoteDataSourceImpl({
    required this.firestore,
  });
  final FirebaseFirestore firestore;
  
  static const String _logsCollection = 'user_logs';

  @override
  Future<void> syncLogs(List<LogEntry> logs) async {
    try {
      if (logs.isEmpty) return;
      final Map<String, List<LogEntry>> logsByUser = {};
      
      for (final log in logs) {
        if (log.userId != null) {
          if (!logsByUser.containsKey(log.userId)) {
            logsByUser[log.userId!] = [];
          }
          logsByUser[log.userId]!.add(log);
        }
      }
      for (final entry in logsByUser.entries) {
        final userId = entry.key;
        final userLogs = entry.value;
        
        await _batchWriteUserLogs(userId, userLogs);
      }
    } catch (e) {
      throw ServerException('Failed to sync logs: $e');
    }
  }

  @override
  Future<void> saveLog(String userId, LogEntry log) async {
    try {
      final docRef = firestore
          .collection(_logsCollection)
          .doc(userId)
          .collection('logs')
          .doc(log.id);
          
      await docRef.set(_logToFirestoreMap(log));
    } catch (e) {
      throw ServerException('Failed to save log: $e');
    }
  }

  @override
  Future<List<LogEntry>> getUserLogs(String userId, {int limit = 1000}) async {
    try {
      final querySnapshot = await firestore
          .collection(_logsCollection)
          .doc(userId)
          .collection('logs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => _logFromFirestoreMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user logs: $e');
    }
  }

  @override
  Future<void> deleteUserLogs(String userId) async {
    try {
      final collectionRef = firestore
          .collection(_logsCollection)
          .doc(userId)
          .collection('logs');

      final querySnapshot = await collectionRef.get();
      const batchSize = 500;
      final batches = <WriteBatch>[];
      
      for (int i = 0; i < querySnapshot.docs.length; i += batchSize) {
        final batch = firestore.batch();
        final batchDocs = querySnapshot.docs
            .skip(i)
            .take(batchSize);
            
        for (final doc in batchDocs) {
          batch.delete(doc.reference);
        }
        
        batches.add(batch);
      }
      for (final batch in batches) {
        await batch.commit();
      }
    } catch (e) {
      throw ServerException('Failed to delete user logs: $e');
    }
  }

  /// Batch write logs for a specific user
  Future<void> _batchWriteUserLogs(String userId, List<LogEntry> logs) async {
    try {
      const batchSize = 500; // Firestore batch limit
      
      for (int i = 0; i < logs.length; i += batchSize) {
        final batch = firestore.batch();
        final batchLogs = logs.skip(i).take(batchSize);
        
        for (final log in batchLogs) {
          final docRef = firestore
              .collection(_logsCollection)
              .doc(userId)
              .collection('logs')
              .doc(log.id);
              
          batch.set(docRef, _logToFirestoreMap(log));
        }
        
        await batch.commit();
      }
    } catch (e) {
      throw ServerException('Failed to batch write logs: $e');
    }
  }

  /// Convert LogEntry to Firestore-compatible Map
  Map<String, dynamic> _logToFirestoreMap(LogEntry log) {
    return {
      'id': log.id,
      'timestamp': Timestamp.fromDate(log.timestamp),
      'level': log.level,
      'category': log.category,
      'operation': log.operation,
      'message': log.message,
      'metadata': log.metadata,
      'userId': log.userId,
      'error': log.error,
      'stackTrace': log.stackTrace,
      'duration': log.duration,
      'synced': true, // Always true when saved to Firestore
    };
  }

  /// Convert Firestore Map to LogEntry
  LogEntry _logFromFirestoreMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      level: map['level'] as String,
      category: map['category'] as String,
      operation: map['operation'] as String,
      message: map['message'] as String,
      metadata: map['metadata'] as Map<String, dynamic>?,
      userId: map['userId'] as String?,
      error: map['error'] as String?,
      stackTrace: map['stackTrace'] as String?,
      duration: map['duration'] as int?,
      synced: map['synced'] as bool? ?? true,
    );
  }
}