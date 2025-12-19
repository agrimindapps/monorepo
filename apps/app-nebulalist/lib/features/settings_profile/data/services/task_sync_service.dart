import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/sync_status.dart';
import '../datasources/firebase_sync_datasource.dart';
import '../models/task_model.dart';

class TaskSyncService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseSyncDataSource _syncDataSource;

  TaskSyncService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseSyncDataSource? syncDataSource,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _syncDataSource = syncDataSource ?? FirebaseSyncDataSource();

  /// Stream de sincronização de tarefas do usuário
  Stream<List<TaskModel>> watchUserTasks() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Sincroniza tarefa local para Firebase
  Future<SyncStatus> syncTaskToFirebase(TaskModel task) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return SyncStatus.error('Usuário não autenticado');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .set(task.toFirestore(), SetOptions(merge: true));

      return SyncStatus.synced();
    } catch (e) {
      return SyncStatus.error(e.toString());
    }
  }

  /// Deleta tarefa do Firebase
  Future<SyncStatus> deleteTaskFromFirebase(String taskId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return SyncStatus.error('Usuário não autenticado');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();

      return SyncStatus.synced();
    } catch (e) {
      return SyncStatus.error(e.toString());
    }
  }

  /// Sincroniza lista de tarefas em lote
  Future<SyncStatus> syncTasksBatch(List<TaskModel> tasks) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return SyncStatus.error('Usuário não autenticado');
      }

      final batch = _firestore.batch();
      final userTasksRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks');

      for (final task in tasks) {
        batch.set(
          userTasksRef.doc(task.id),
          task.toFirestore(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      return SyncStatus.synced();
    } catch (e) {
      return SyncStatus.error(e.toString());
    }
  }

  /// Baixa todas as tarefas do Firebase
  Future<List<TaskModel>> fetchAllTasksFromFirebase() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .get();

    return snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();
  }

  /// Verifica se há conflitos entre dados locais e remotos
  Future<bool> hasConflicts(List<TaskModel> localTasks) async {
    final remoteTasks = await fetchAllTasksFromFirebase();
    
    for (final local in localTasks) {
      final remote = remoteTasks.firstWhere(
        (r) => r.id == local.id,
        orElse: () => local,
      );
      
      if (remote.id == local.id && remote.updatedAt != local.updatedAt) {
        return true;
      }
    }
    
    return false;
  }

  /// Resolve conflitos usando estratégia "last write wins"
  Future<List<TaskModel>> resolveConflicts(List<TaskModel> localTasks) async {
    final remoteTasks = await fetchAllTasksFromFirebase();
    final Map<String, TaskModel> resolved = {};

    // Adiciona todas as tarefas remotas
    for (final remote in remoteTasks) {
      resolved[remote.id] = remote;
    }

    // Sobrescreve com tarefas locais mais recentes
    for (final local in localTasks) {
      final remote = resolved[local.id];
      if (remote == null || local.updatedAt.isAfter(remote.updatedAt)) {
        resolved[local.id] = local;
      }
    }

    return resolved.values.toList();
  }
}
