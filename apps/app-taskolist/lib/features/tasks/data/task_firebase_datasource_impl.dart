import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../domain/task_entity.dart';
import 'task_firebase_datasource.dart';

/// Implementação Firebase do TaskFirebaseDataSource
/// Gerencia todas as operações de escrita/leitura no Firestore
class TaskFirebaseDataSourceImpl implements TaskFirebaseDataSource {
  final FirebaseFirestore _firestore;

  TaskFirebaseDataSourceImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Referência base para tasks de um usuário
  CollectionReference _tasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Future<void> createTask(String userId, TaskEntity task) async {
    try {
      final taskMap = task.toFirebaseMap();
      await _tasksCollection(userId).doc(task.id).set(taskMap);

      if (kDebugMode) {
        debugPrint('[FirebaseDS] Task created: ${task.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseDS] Error creating task: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateTask(String userId, TaskEntity task) async {
    try {
      final taskMap = task.toFirebaseMap();
      await _tasksCollection(userId).doc(task.id).update(taskMap);

      if (kDebugMode) {
        debugPrint('[FirebaseDS] Task updated: ${task.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseDS] Error updating task: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _tasksCollection(userId).doc(taskId).delete();

      if (kDebugMode) {
        debugPrint('[FirebaseDS] Task deleted: $taskId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseDS] Error deleting task: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> batchSync(String userId, List<TaskEntity> tasks) async {
    if (tasks.isEmpty) return;

    try {
      final batch = _firestore.batch();

      for (final task in tasks) {
        final docRef = _tasksCollection(userId).doc(task.id);
        final taskMap = task.toFirebaseMap();

        if (task.isDeleted) {
          // Soft delete: marca como deleted no Firebase ou deleta fisicamente
          batch.delete(docRef);
        } else {
          // Upsert (create or update)
          batch.set(docRef, taskMap, SetOptions(merge: true));
        }
      }

      await batch.commit();

      if (kDebugMode) {
        debugPrint('[FirebaseDS] Batch sync completed: ${tasks.length} tasks');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseDS] Error in batch sync: $e');
      }
      rethrow;
    }
  }

  @override
  Future<TaskEntity?> getTask(String userId, String taskId) async {
    try {
      final doc = await _tasksCollection(userId).doc(taskId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return TaskEntity.fromFirebaseMap({
        ...data,
        'id': doc.id,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseDS] Error getting task: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<TaskEntity>> getTasks(String userId) async {
    try {
      final snapshot = await _tasksCollection(userId).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TaskEntity.fromFirebaseMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseDS] Error getting tasks: $e');
      }
      rethrow;
    }
  }
}
