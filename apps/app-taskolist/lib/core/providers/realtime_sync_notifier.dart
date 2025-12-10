import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/tasks/data/task_model.dart';
import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/presentation/providers/task_notifier.dart';
import '../../features/tasks/providers/task_providers.dart';

part 'realtime_sync_notifier.g.dart';

/// Notifier para sincronização em tempo real com Firebase
/// Escuta mudanças nas coleções e atualiza o banco local + invalida providers
@riverpod
class RealtimeSyncNotifier extends _$RealtimeSyncNotifier {
  final Map<String, StreamSubscription<QuerySnapshot>> _subscriptions = {};
  String? _currentUserId;

  @override
  void build() {
    ref.onDispose(_disposeAll);
  }

  /// Inicia listeners para todas as coleções do usuário
  Future<void> startListening(String userId) async {
    if (_currentUserId == userId && _subscriptions.isNotEmpty) {
      debugPrint('[RealtimeSync] Already listening for user: $userId');
      return;
    }

    // Ensure we stop any existing listeners before starting new ones
    await stopListening();
    _currentUserId = userId;

    debugPrint('[RealtimeSync] Starting realtime listeners for user: $userId');

    // Escuta coleção de tasks
    _listenToCollection(
      userId: userId,
      collection: 'tasks',
      onData: _handleTasksUpdate,
    );

    debugPrint('[RealtimeSync] Realtime sync started for taskolist');
  }

  /// Para todos os listeners
  Future<void> stopListening() async {
    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _currentUserId = null;
    debugPrint('[RealtimeSync] Realtime sync stopped');
  }

  void _disposeAll() {
    // Cancel all subscriptions synchronously
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _currentUserId = null;
    debugPrint('[RealtimeSync] All subscriptions disposed');
  }

  /// Escuta uma coleção específica do Firebase
  void _listenToCollection({
    required String userId,
    required String collection,
    required Future<void> Function(QuerySnapshot snapshot) onData,
  }) {
    try {
      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore
          .collection('users')
          .doc(userId)
          .collection(collection);

      late final StreamSubscription<QuerySnapshot> subscription;
      subscription = collectionRef.snapshots().listen(
        (snapshot) async {
          if (snapshot.docChanges.isNotEmpty) {
            debugPrint(
              '[RealtimeSync] $collection: ${snapshot.docChanges.length} changes detected',
            );
            await onData(snapshot);
          }
        },
        onError: (Object error) {
          debugPrint('[RealtimeSync] Error listening to $collection: $error');
          // Cancel the subscription on error
          subscription.cancel();
          _subscriptions.remove(collection);
        },
      );

      _subscriptions[collection] = subscription;
      debugPrint('[RealtimeSync] Listening to $collection');
    } catch (e) {
      debugPrint('[RealtimeSync] Failed to setup listener for $collection: $e');
    }
  }

  /// Processa atualizações de tasks
  Future<void> _handleTasksUpdate(QuerySnapshot snapshot) async {
    try {
      final taskLocalDataSource = ref.read(taskLocalDataSourceProvider);

      for (final change in snapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final firebaseId = change.doc.id;

        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            // Converte e salva no banco local
            try {
              final taskEntity = TaskEntity.fromFirebaseMap({
                ...data,
                'id': firebaseId,
              });
              final taskModel = TaskModel.fromEntity(taskEntity);

              // Verifica se já existe
              final existing = await taskLocalDataSource.getTask(firebaseId);
              if (existing != null) {
                // Atualiza
                await taskLocalDataSource.updateTask(taskModel);
                debugPrint('[RealtimeSync] Task updated: $firebaseId');
              } else {
                // Insere
                await taskLocalDataSource.cacheTask(taskModel);
                debugPrint('[RealtimeSync] Task created: $firebaseId');
              }
            } catch (e) {
              debugPrint(
                '[RealtimeSync] Error processing task $firebaseId: $e',
              );
            }
            break;

          case DocumentChangeType.removed:
            // Remove do banco local
            await taskLocalDataSource.deleteTask(firebaseId);
            debugPrint('[RealtimeSync] Task deleted: $firebaseId');
            break;
        }
      }

      // Invalida o provider de tasks para atualizar a UI
      ref.invalidate(taskProvider);
      debugPrint('[RealtimeSync] Tasks provider invalidated');
    } catch (e) {
      debugPrint('[RealtimeSync] Error handling tasks update: $e');
    }
  }
}
