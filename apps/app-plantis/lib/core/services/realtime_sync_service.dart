import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../database/repositories/comments_drift_repository.dart';
import '../../database/repositories/plant_tasks_drift_repository.dart';
import '../../database/repositories/plants_drift_repository.dart';
import '../../database/repositories/spaces_drift_repository.dart';
import '../../features/plants/data/models/plant_model.dart';
import '../../features/plants/data/models/plant_task_model.dart';
import '../../features/plants/data/models/space_model.dart';
import '../data/models/comentario_model.dart';
import '../data/models/espaco_model.dart';

/// Serviço de sincronização em tempo real usando Firebase Realtime Listeners
/// Escuta mudanças no Firestore e atualiza o banco local automaticamente
class RealtimeSyncService {
  final FirebaseFirestore _firestore;
  final PlantsDriftRepository _plantsRepository;
  final CommentsDriftRepository _commentsRepository;
  final PlantTasksDriftRepository _tasksRepository;
  final SpacesDriftRepository _spacesRepository;
  final IAuthRepository _authRepository;

  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _subscriptions = {};
  final _changesController = StreamController<RealtimeSyncEvent>.broadcast();

  String? _currentUserId;
  bool _isListening = false;

  RealtimeSyncService({
    required FirebaseFirestore firestore,
    required PlantsDriftRepository plantsRepository,
    required CommentsDriftRepository commentsRepository,
    required PlantTasksDriftRepository tasksRepository,
    required SpacesDriftRepository spacesRepository,
    required IAuthRepository authRepository,
  }) : _firestore = firestore,
       _plantsRepository = plantsRepository,
       _commentsRepository = commentsRepository,
       _tasksRepository = tasksRepository,
       _spacesRepository = spacesRepository,
       _authRepository = authRepository;

  /// Stream de eventos de sincronização para UI reagir
  Stream<RealtimeSyncEvent> get changesStream => _changesController.stream;

  /// Indica se está escutando mudanças
  bool get isListening => _isListening;

  /// Inicia os listeners de tempo real para todas as coleções
  Future<void> startListening() async {
    if (_isListening) {
      if (kDebugMode) {
        print('[RealtimeSync] Already listening, skipping...');
      }
      return;
    }

    try {
      // Obtém o userId atual
      final user = await _authRepository.currentUser.first;
      if (user == null) {
        if (kDebugMode) {
          print('[RealtimeSync] No user logged in, cannot start listeners');
        }
        return;
      }

      _currentUserId = user.id;
      _isListening = true;

      if (kDebugMode) {
        print(
          '[RealtimeSync] Starting realtime listeners for user: $_currentUserId',
        );
      }

      // Inicia listeners para cada coleção
      _startPlantsListener();
      _startCommentsListener();
      _startTasksListener();
      _startSpacesListener();

      if (kDebugMode) {
        print('[RealtimeSync] All listeners started successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RealtimeSync] Error starting listeners: $e');
      }
      _isListening = false;
    }
  }

  /// Para todos os listeners
  Future<void> stopListening() async {
    if (kDebugMode) {
      print('[RealtimeSync] Stopping all listeners...');
    }

    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _isListening = false;
    _currentUserId = null;

    if (kDebugMode) {
      print('[RealtimeSync] All listeners stopped');
    }
  }

  // ignore: cancel_subscriptions - subscriptions are stored in _subscriptions map and cancelled in stopListening()

  /// Listener para Plants
  void _startPlantsListener() {
    if (_currentUserId == null) return;

    // Subscription is stored in _subscriptions and cancelled in stopListening()
    // ignore: cancel_subscriptions
    final subscription = _firestore
        .collection('users/$_currentUserId/plants')
        .snapshots()
        .listen(
          (snapshot) async {
            for (final change in snapshot.docChanges) {
              await _handlePlantChange(change);
            }
          },
          onError: (Object e) {
            if (kDebugMode) {
              print('[RealtimeSync] Plants listener error: $e');
            }
          },
        );

    _subscriptions['plants'] = subscription;
    if (kDebugMode) {
      print('[RealtimeSync] Plants listener started');
    }
  }

  /// Listener para Comments
  void _startCommentsListener() {
    if (_currentUserId == null) return;

    // ignore: cancel_subscriptions
    final subscription = _firestore
        .collection('users/$_currentUserId/comments')
        .snapshots()
        .listen(
          (snapshot) async {
            for (final change in snapshot.docChanges) {
              await _handleCommentChange(change);
            }
          },
          onError: (Object e) {
            if (kDebugMode) {
              print('[RealtimeSync] Comments listener error: $e');
            }
          },
        );

    _subscriptions['comments'] = subscription;
    if (kDebugMode) {
      print('[RealtimeSync] Comments listener started');
    }
  }

  /// Listener para Tasks
  void _startTasksListener() {
    if (_currentUserId == null) return;

    // ignore: cancel_subscriptions
    final subscription = _firestore
        .collection('users/$_currentUserId/tasks')
        .snapshots()
        .listen(
          (snapshot) async {
            for (final change in snapshot.docChanges) {
              await _handleTaskChange(change);
            }
          },
          onError: (Object e) {
            if (kDebugMode) {
              print('[RealtimeSync] Tasks listener error: $e');
            }
          },
        );

    _subscriptions['tasks'] = subscription;
    if (kDebugMode) {
      print('[RealtimeSync] Tasks listener started');
    }
  }

  /// Listener para Spaces
  void _startSpacesListener() {
    if (_currentUserId == null) return;

    // ignore: cancel_subscriptions
    final subscription = _firestore
        .collection('users/$_currentUserId/spaces')
        .snapshots()
        .listen(
          (snapshot) async {
            for (final change in snapshot.docChanges) {
              await _handleSpaceChange(change);
            }
          },
          onError: (Object e) {
            if (kDebugMode) {
              print('[RealtimeSync] Spaces listener error: $e');
            }
          },
        );

    _subscriptions['spaces'] = subscription;
    if (kDebugMode) {
      print('[RealtimeSync] Spaces listener started');
    }
  }

  /// Processa mudança em Plant
  Future<void> _handlePlantChange(DocumentChange change) async {
    try {
      final data = change.doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final docId = change.doc.id;
      data['id'] = docId;

      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          final plant = PlantModel.fromJson(data);

          // Verifica se é deletado
          if (plant.isDeleted) {
            await _plantsRepository.deletePlant(docId);
            _emitEvent(
              RealtimeSyncEvent(
                collection: 'plants',
                type: SyncEventType.deleted,
                entityId: docId,
              ),
            );
          } else {
            // Verifica se já existe localmente
            final existing = await _plantsRepository.getPlantById(docId);
            if (existing != null) {
              // Atualiza se remoto é mais recente
              final remoteUpdated =
                  plant.updatedAt ?? plant.createdAt ?? DateTime.now();
              final localUpdated =
                  existing.updatedAt ?? existing.createdAt ?? DateTime.now();

              if (remoteUpdated.isAfter(localUpdated)) {
                await _plantsRepository.updatePlant(plant);
                _emitEvent(
                  RealtimeSyncEvent(
                    collection: 'plants',
                    type: SyncEventType.updated,
                    entityId: docId,
                  ),
                );
              }
            } else {
              await _plantsRepository.insertPlant(plant);
              _emitEvent(
                RealtimeSyncEvent(
                  collection: 'plants',
                  type: SyncEventType.added,
                  entityId: docId,
                ),
              );
            }
          }
          break;

        case DocumentChangeType.removed:
          await _plantsRepository.deletePlant(docId);
          _emitEvent(
            RealtimeSyncEvent(
              collection: 'plants',
              type: SyncEventType.deleted,
              entityId: docId,
            ),
          );
          break;
      }

      if (kDebugMode) {
        print('[RealtimeSync] Plant ${change.type.name}: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RealtimeSync] Error handling plant change: $e');
      }
    }
  }

  /// Processa mudança em Comment
  Future<void> _handleCommentChange(DocumentChange change) async {
    try {
      final data = change.doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final docId = change.doc.id;
      data['id'] = docId;

      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          final comment = ComentarioModel.fromFirebaseMap(data);

          if (comment.isDeleted) {
            await _commentsRepository.softDeleteComment(docId);
            _emitEvent(
              RealtimeSyncEvent(
                collection: 'comments',
                type: SyncEventType.deleted,
                entityId: docId,
                relatedId: comment.plantId,
              ),
            );
          } else {
            final existing = await _commentsRepository.getCommentById(docId);
            if (existing != null) {
              final remoteUpdated =
                  comment.updatedAt ?? comment.createdAt ?? DateTime.now();
              final localUpdated =
                  existing.updatedAt ?? existing.createdAt ?? DateTime.now();

              if (remoteUpdated.isAfter(localUpdated)) {
                await _commentsRepository.updateComment(comment);
                _emitEvent(
                  RealtimeSyncEvent(
                    collection: 'comments',
                    type: SyncEventType.updated,
                    entityId: docId,
                    relatedId: comment.plantId,
                  ),
                );
              }
            } else {
              await _commentsRepository.insertComment(comment);
              _emitEvent(
                RealtimeSyncEvent(
                  collection: 'comments',
                  type: SyncEventType.added,
                  entityId: docId,
                  relatedId: comment.plantId,
                ),
              );
            }
          }
          break;

        case DocumentChangeType.removed:
          final comment = ComentarioModel.fromFirebaseMap(data);
          await _commentsRepository.softDeleteComment(docId);
          _emitEvent(
            RealtimeSyncEvent(
              collection: 'comments',
              type: SyncEventType.deleted,
              entityId: docId,
              relatedId: comment.plantId,
            ),
          );
          break;
      }

      if (kDebugMode) {
        print('[RealtimeSync] Comment ${change.type.name}: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RealtimeSync] Error handling comment change: $e');
      }
    }
  }

  /// Processa mudança em Task
  Future<void> _handleTaskChange(DocumentChange change) async {
    try {
      final data = change.doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final docId = change.doc.id;
      data['id'] = docId;

      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          final task = PlantTaskModel.fromJson(data);

          if (task.isDeleted) {
            await _tasksRepository.deletePlantTask(docId);
            _emitEvent(
              RealtimeSyncEvent(
                collection: 'tasks',
                type: SyncEventType.deleted,
                entityId: docId,
                relatedId: task.plantId,
              ),
            );
          } else {
            final existing = await _tasksRepository.getPlantTaskById(docId);
            if (existing != null) {
              final remoteUpdated =
                  task.updatedAt ?? task.createdAt ?? DateTime.now();
              final localUpdated =
                  existing.updatedAt ?? existing.createdAt ?? DateTime.now();

              if (remoteUpdated.isAfter(localUpdated)) {
                await _tasksRepository.updatePlantTask(task);
                _emitEvent(
                  RealtimeSyncEvent(
                    collection: 'tasks',
                    type: SyncEventType.updated,
                    entityId: docId,
                    relatedId: task.plantId,
                  ),
                );
              }
            } else {
              await _tasksRepository.insertPlantTask(task);
              _emitEvent(
                RealtimeSyncEvent(
                  collection: 'tasks',
                  type: SyncEventType.added,
                  entityId: docId,
                  relatedId: task.plantId,
                ),
              );
            }
          }
          break;

        case DocumentChangeType.removed:
          final task = PlantTaskModel.fromJson(data);
          await _tasksRepository.deletePlantTask(docId);
          _emitEvent(
            RealtimeSyncEvent(
              collection: 'tasks',
              type: SyncEventType.deleted,
              entityId: docId,
              relatedId: task.plantId,
            ),
          );
          break;
      }

      if (kDebugMode) {
        print('[RealtimeSync] Task ${change.type.name}: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RealtimeSync] Error handling task change: $e');
      }
    }
  }

  /// Processa mudança em Space
  Future<void> _handleSpaceChange(DocumentChange change) async {
    try {
      final data = change.doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final docId = change.doc.id;
      data['id'] = docId;

      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          final space = SpaceModel.fromJson(data);
          final espacoModel = EspacoModel(
            id: space.id,
            nome: space.name,
            descricao: space.description,
            createdAtMs: space.createdAt?.millisecondsSinceEpoch,
            updatedAtMs: space.updatedAt?.millisecondsSinceEpoch,
            isDeleted: space.isDeleted,
            isDirty: space.isDirty,
          );

          if (space.isDeleted) {
            await _spacesRepository.deleteSpace(docId);
            _emitEvent(
              RealtimeSyncEvent(
                collection: 'spaces',
                type: SyncEventType.deleted,
                entityId: docId,
              ),
            );
          } else {
            final existing = await _spacesRepository.getSpaceById(docId);
            if (existing != null) {
              final remoteUpdated =
                  space.updatedAt ?? space.createdAt ?? DateTime.now();
              final localUpdated =
                  existing.updatedAt ?? existing.createdAt ?? DateTime.now();

              if (remoteUpdated.isAfter(localUpdated)) {
                await _spacesRepository.updateSpace(espacoModel);
                _emitEvent(
                  RealtimeSyncEvent(
                    collection: 'spaces',
                    type: SyncEventType.updated,
                    entityId: docId,
                  ),
                );
              }
            } else {
              await _spacesRepository.insertSpace(espacoModel);
              _emitEvent(
                RealtimeSyncEvent(
                  collection: 'spaces',
                  type: SyncEventType.added,
                  entityId: docId,
                ),
              );
            }
          }
          break;

        case DocumentChangeType.removed:
          await _spacesRepository.deleteSpace(docId);
          _emitEvent(
            RealtimeSyncEvent(
              collection: 'spaces',
              type: SyncEventType.deleted,
              entityId: docId,
            ),
          );
          break;
      }

      if (kDebugMode) {
        print('[RealtimeSync] Space ${change.type.name}: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RealtimeSync] Error handling space change: $e');
      }
    }
  }

  void _emitEvent(RealtimeSyncEvent event) {
    _changesController.add(event);
  }

  /// Libera recursos
  Future<void> dispose() async {
    await stopListening();
    await _changesController.close();
  }
}

/// Tipos de evento de sincronização
enum SyncEventType { added, updated, deleted }

/// Evento de sincronização em tempo real
class RealtimeSyncEvent {
  final String collection;
  final SyncEventType type;
  final String entityId;
  final String? relatedId; // Ex: plantId para comments/tasks

  const RealtimeSyncEvent({
    required this.collection,
    required this.type,
    required this.entityId,
    this.relatedId,
  });

  @override
  String toString() =>
      'RealtimeSyncEvent(collection: $collection, type: $type, entityId: $entityId, relatedId: $relatedId)';
}
