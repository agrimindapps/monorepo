import 'dart:async';
import 'package:core/core.dart' hide SyncQueue, SyncQueueItem;
import 'package:flutter/foundation.dart';
import '../../features/comentarios/data/comentario_model.dart';
import '../data/models/diagnostico_hive.dart';
import '../data/models/sync_queue_item.dart';
import '../data/repositories/comentarios_hive_repository.dart';
import '../data/repositories/diagnostico_hive_repository.dart';
import 'sync_queue.dart';

/// Handles sync operations with queue management
/// Note: Not using @singleton because dependencies aren't injectable-annotated
/// Must be registered manually in injection_container.dart
class SyncOperations {
  final SyncQueue _syncQueue;
  final ConnectivityService _connectivityService;

  // Repositories for data persistence
  late final ComentariosHiveRepository _comentariosRepo;
  late final DiagnosticoHiveRepository _diagnosticoRepo;

  late StreamSubscription<ConnectivityType> _networkSubscription;
  bool _isProcessingSync = false;
  bool _isInitialized = false;

  SyncOperations(this._syncQueue, this._connectivityService) {
    // Initialize repositories from GetIt
    try {
      _comentariosRepo = GetIt.instance<ComentariosHiveRepository>();
    } catch (e) {
      _comentariosRepo = ComentariosHiveRepository();
      if (kDebugMode) {
        print('⚠️ ComentariosHiveRepository not registered in GetIt, creating new instance');
      }
    }

    try {
      _diagnosticoRepo = GetIt.instance<DiagnosticoHiveRepository>();
    } catch (e) {
      _diagnosticoRepo = DiagnosticoHiveRepository();
      if (kDebugMode) {
        print('⚠️ DiagnosticoHiveRepository not registered in GetIt, creating new instance');
      }
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _syncQueue.initialize();
    _initializeNetworkListener();
    _isInitialized = true;
  }

  void _initializeNetworkListener() {
    _networkSubscription = _connectivityService.networkStatusStream.listen(
      (status) {
        if (status != ConnectivityType.offline &&
            status != ConnectivityType.none) {
          processOfflineQueue();
        }
      },
    );
  }

  /// Process all pending items in the sync queue
  Future<void> processOfflineQueue() async {
    if (_isProcessingSync) return;
    _isProcessingSync = true;

    try {
      final pendingItems = _syncQueue.getPendingItems();
      final prioritizedItems = _prioritizeItems(pendingItems);

      if (kDebugMode) {
        print('Processing ${prioritizedItems.length} pending sync items');
      }

      for (var item in prioritizedItems) {
        try {
          await _processSyncItem(item);
        } catch (e) {
          if (kDebugMode) {
            print('Error syncing item ${item.sync_id}: $e');
          }

          if (!item.hasExceededMaxRetries) {
            await _syncQueue.incrementRetryCount(
              item.sync_id,
              errorMessage: e.toString(),
            );
          }
        }
      }

      // Clean up synced items periodically
      await _syncQueue.clearSyncedItems();

      if (kDebugMode) {
        print('Sync queue processing completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing offline queue: $e');
      }
    } finally {
      _isProcessingSync = false;
    }
  }

  /// Prioritize sync items: create > update > delete
  List<SyncQueueItem> _prioritizeItems(List<SyncQueueItem> items) {
    items.sort((a, b) {
      int getPriority(SyncQueueItem item) {
        switch (item.operationType) {
          case SyncOperationType.create:
            return 3; // Highest priority
          case SyncOperationType.update:
            return 2; // Medium priority
          case SyncOperationType.delete:
            return 1; // Lowest priority
        }
      }

      final priorityComparison = getPriority(b).compareTo(getPriority(a));
      return priorityComparison != 0
          ? priorityComparison
          : a.sync_timestamp.compareTo(b.sync_timestamp); // FIFO within same priority
    });

    return items;
  }

  /// Process individual sync item
  Future<void> _processSyncItem(SyncQueueItem item) async {
    if (kDebugMode) {
      print('Processing sync item: ${item.modelType} - ${item.sync_operation}');
    }

    switch (item.operationType) {
      case SyncOperationType.create:
        await _performCreate(item);
        break;
      case SyncOperationType.update:
        await _performUpdate(item);
        break;
      case SyncOperationType.delete:
        await _performDelete(item);
        break;
    }

    await _syncQueue.markItemAsSynced(item.sync_id);

    if (kDebugMode) {
      print('Successfully synced item: ${item.sync_id}');
    }
  }

  /// Perform create operation - saves new records to local storage
  Future<void> _performCreate(SyncQueueItem item) async {
    try {
      switch (item.modelType) {
        case 'ComentarioHive':
          // Deserialize data to ComentarioModel
          final comentario = ComentarioModel.fromJson(item.data);
          await _comentariosRepo.addComentario(comentario);

          if (kDebugMode) {
            print('✅ Created ComentarioHive: ${comentario.idReg}');
          }
          break;

        case 'DiagnosticoHive':
          // Deserialize data to DiagnosticoHive
          final diagnostico = DiagnosticoHive.fromJson(item.data);
          final result = await _diagnosticoRepo.saveWithIdReg(diagnostico);

          result.fold(
            (failure) => throw Exception('Failed to save DiagnosticoHive: ${failure.message}'),
            (_) {
              if (kDebugMode) {
                print('✅ Created DiagnosticoHive: ${diagnostico.idReg}');
              }
            },
          );
          break;

        default:
          if (kDebugMode) {
            print('⚠️ Unknown model type for create: ${item.modelType}');
          }
          throw UnsupportedError('Unsupported model type: ${item.modelType}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error performing create for ${item.modelType}: $e');
      }
      rethrow;
    }
  }

  /// Perform update operation - updates existing records in local storage
  Future<void> _performUpdate(SyncQueueItem item) async {
    try {
      switch (item.modelType) {
        case 'ComentarioHive':
          // Deserialize data to ComentarioModel
          final comentario = ComentarioModel.fromJson(item.data);
          await _comentariosRepo.updateComentario(comentario);

          if (kDebugMode) {
            print('✅ Updated ComentarioHive: ${comentario.idReg}');
          }
          break;

        case 'DiagnosticoHive':
          // Deserialize data to DiagnosticoHive
          final diagnostico = DiagnosticoHive.fromJson(item.data);
          final result = await _diagnosticoRepo.saveWithIdReg(diagnostico);

          result.fold(
            (failure) => throw Exception('Failed to update DiagnosticoHive: ${failure.message}'),
            (_) {
              if (kDebugMode) {
                print('✅ Updated DiagnosticoHive: ${diagnostico.idReg}');
              }
            },
          );
          break;

        default:
          if (kDebugMode) {
            print('⚠️ Unknown model type for update: ${item.modelType}');
          }
          throw UnsupportedError('Unsupported model type: ${item.modelType}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error performing update for ${item.modelType}: $e');
      }
      rethrow;
    }
  }

  /// Perform delete operation - soft deletes records in local storage
  Future<void> _performDelete(SyncQueueItem item) async {
    try {
      switch (item.modelType) {
        case 'ComentarioHive':
          // Extract ID from data
          final id = item.data['idReg']?.toString() ?? item.data['id']?.toString();
          if (id == null || id.isEmpty) {
            throw ArgumentError('ComentarioHive delete requires idReg or id in data');
          }

          await _comentariosRepo.deleteComentario(id);

          if (kDebugMode) {
            print('✅ Deleted ComentarioHive: $id');
          }
          break;

        case 'DiagnosticoHive':
          // Extract ID from data
          final idReg = item.data['idReg']?.toString();
          if (idReg == null || idReg.isEmpty) {
            throw ArgumentError('DiagnosticoHive delete requires idReg in data');
          }

          // Find the diagnostico by idReg
          final diagnostico = await _diagnosticoRepo.getByIdOrObjectId(idReg);
          if (diagnostico == null) {
            if (kDebugMode) {
              print('⚠️ DiagnosticoHive not found for delete: $idReg');
            }
            return; // Item doesn't exist, consider delete successful
          }

          // Delete from Hive
          await diagnostico.delete();

          if (kDebugMode) {
            print('✅ Deleted DiagnosticoHive: $idReg');
          }
          break;

        default:
          if (kDebugMode) {
            print('⚠️ Unknown model type for delete: ${item.modelType}');
          }
          throw UnsupportedError('Unsupported model type: ${item.modelType}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error performing delete for ${item.modelType}: $e');
      }
      rethrow;
    }
  }

  /// Manual trigger for sync queue processing
  Future<void> syncNow() async {
    if (!_isInitialized) {
      throw StateError('SyncOperations not initialized');
    }

    await processOfflineQueue();
  }

  /// Get current sync status
  bool get isSyncing => _isProcessingSync;

  /// Get pending items count
  int get pendingItemsCount => _syncQueue.pendingCount;

  void dispose() {
    _networkSubscription.cancel();
  }
}
