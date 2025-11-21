import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/base_sync_entity.dart';
import '../../domain/interfaces/i_disposable_service.dart';
import '../../domain/repositories/i_local_storage_repository.dart';
import '../../domain/repositories/i_sync_repository.dart';
import '../../shared/utils/failure.dart';
import 'connectivity_service.dart';

// TODO(refactoring): PRIORITY HIGH - This file is 1084 lines and violates SRP
// Plan: Extract to specialized services (see REFACTORING_PLAN.md)
// - FirestoreSyncClient (Firestore communication)
// - SyncConflictResolver (conflict resolution)
// - SyncQueueManager (queue management)
// - SyncThrottleService (throttling/rate limiting)
// - SyncRetryHandler (retry logic)
// Keep this class as Facade for backward compatibility
// Estimated effort: 8-10 hours | Risk: High | ROI: High

/// Serviço unificado de sincronização offline-first com Firebase
/// Implementa padrão Singleton Generic para reutilização por tipo
class SyncFirebaseService<T extends BaseSyncEntity>
    with SyncEntityMixin
    implements ISyncRepository<T>, IDisposableService {
  static final Map<String, SyncFirebaseService> _instances = {};

  /// Factory constructor para Singleton por coleção
  factory SyncFirebaseService.getInstance(
    String collectionName,
    T Function(Map<String, dynamic>) fromMap,
    Map<String, dynamic> Function(T) toMap, {
    SyncConfig? config,
    required ILocalStorageRepository localStorage,
  }) {
    final key = '${T.toString()}_$collectionName';

    if (!_instances.containsKey(key)) {
      _instances[key] = SyncFirebaseService<T>._(
        collectionName,
        fromMap,
        toMap,
        config ?? const SyncConfig(),
        localStorage,
      );
    }

    return _instances[key] as SyncFirebaseService<T>;
  }

  SyncFirebaseService._(
    this.collectionName,
    this.fromMap,
    this.toMap,
    this.config,
    this._localStorage,
  );

  final String collectionName;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;
  final SyncConfig config;
  final ILocalStorageRepository _localStorage;
  late final ConnectivityService _connectivity;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  bool _isInitialized = false;
  bool _isDisposed = false;
  Completer<void>? _initCompleter;
  SyncStatus _currentStatus = SyncStatus.offline;
  String? _currentUserId;
  Timer? _syncTimer;
  final StreamController<List<T>> _dataController =
      StreamController<List<T>>.broadcast();
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  List<T> _localData = [];
  DateTime? _lastSyncTime;

  @override
  Future<Either<Failure, void>> initialize() async {
    if (_isInitialized) return const Right(null);

    // Use completer for thread safety
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return const Right(null);
    }

    _initCompleter = Completer<void>();

    try {
      _connectivity = ConnectivityService.instance;
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      await _localStorage.initialize();
      await _connectivity.initialize();
      _setupConnectivityListener();
      _setupAuthListener();
      await _loadLocalData();
      await _updateSyncStatus();
      _setupAutoSync();

      _isInitialized = true;

      developer.log(
        'SyncFirebaseService<$T> inicializado para $collectionName${kIsWeb ? " (Web)" : ""}',
        name: 'SyncService',
      );

      _initCompleter!.complete();
      return const Right(null);
    } catch (e) {
      _initCompleter!.completeError(e);
      return Left(CacheFailure('Erro ao inicializar SyncFirebaseService: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> create(T item) async {
    try {
      await _ensureInitialized();

      final id = item.id.isEmpty ? _generateId() : item.id;
      final itemWithId = item.copyWith(id: id) as T;
      final dirtyItem = itemWithId.markAsDirty() as T;
      final localResult = await _saveLocal(dirtyItem);
      if (localResult.isLeft()) {
        return localResult.fold(
          (failure) => Left(failure),
          (_) => const Right(''),
        );
      }
      if (_canSync()) {
        _syncItemInBackground(dirtyItem);
      }

      await _refreshLocalData();
      return Right(id);
    } catch (e) {
      return Left(CacheFailure('Erro ao criar item: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> createBatch(List<T> items) async {
    try {
      await _ensureInitialized();

      final ids = <String>[];
      final itemsToSave = <T>[];

      for (var item in items) {
        final id = item.id.isEmpty ? _generateId() : item.id;
        final itemWithId = item.copyWith(id: id) as T;
        final dirtyItem = itemWithId.markAsDirty() as T;

        itemsToSave.add(dirtyItem);
        ids.add(id);
      }
      for (final item in itemsToSave) {
        final result = await _saveLocal(item);
        if (result.isLeft()) {
          return result.fold(
            (failure) => Left(failure),
            (_) => const Right([]),
          );
        }
      }
      if (_canSync()) {
        _syncBatchInBackground(itemsToSave);
      }

      await _refreshLocalData();
      return Right(ids);
    } catch (e) {
      return Left(CacheFailure('Erro ao criar lote: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> update(String id, T item) async {
    try {
      await _ensureInitialized();

      final updatedItem =
          item.copyWith(id: id, updatedAt: DateTime.now()).markAsDirty() as T;

      final result = await _saveLocal(updatedItem);
      if (result.isLeft()) return result;

      if (_canSync()) {
        _syncItemInBackground(updatedItem);
      }

      await _refreshLocalData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBatch(Map<String, T> items) async {
    try {
      await _ensureInitialized();

      final itemsToUpdate = <T>[];

      for (final entry in items.entries) {
        final updatedItem =
            entry.value
                    .copyWith(id: entry.key, updatedAt: DateTime.now())
                    .markAsDirty()
                as T;

        itemsToUpdate.add(updatedItem);

        final result = await _saveLocal(updatedItem);
        if (result.isLeft()) {
          return result.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        }
      }

      if (_canSync()) {
        _syncBatchInBackground(itemsToUpdate);
      }

      await _refreshLocalData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar lote: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _ensureInitialized();

      final existingResult = await _getLocal(id);
      if (existingResult.isLeft()) {
        return existingResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }

      final existing = existingResult.getOrElse(() => null);
      if (existing == null) {
        return Left(NotFoundFailure('Item não encontrado: $id'));
      }

      final deletedItem = existing.markAsDeleted().markAsDirty() as T;
      final result = await _saveLocal(deletedItem);
      if (result.isLeft()) return result;

      if (_canSync()) {
        _syncItemInBackground(deletedItem);
      }

      await _refreshLocalData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBatch(List<String> ids) async {
    try {
      await _ensureInitialized();

      for (final id in ids) {
        final deleteResult = await delete(id);
        if (deleteResult.isLeft()) {
          return deleteResult;
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar lote: $e'));
    }
  }

  @override
  Future<Either<Failure, T?>> findById(String id) async {
    try {
      await _ensureInitialized();
      return await _getLocal(id);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar item por ID: $e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> findAll() async {
    try {
      await _ensureInitialized();

      final activeItems = _localData.where((item) => !item.isDeleted).toList();
      return Right(activeItems);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar todos os itens: $e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> findWhere(
    Map<String, dynamic> filters,
  ) async {
    try {
      await _ensureInitialized();

      var results = _localData.where((item) => !item.isDeleted);
      for (final entry in filters.entries) {
        final key = entry.key;
        final value = entry.value;
        switch (key) {
          case 'userId':
            results = results.where((item) => item.userId == value);
            break;
          case 'moduleName':
            results = results.where((item) => item.moduleName == value);
            break;
          case 'isDirty':
            results = results.where((item) => item.isDirty == value);
            break;
        }
      }

      return Right(results.toList());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar com filtros: $e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> findRecent({
    Duration? since,
    int? limit,
  }) async {
    try {
      await _ensureInitialized();

      final cutoff = since != null
          ? DateTime.now().subtract(since)
          : DateTime.now().subtract(const Duration(days: 30));

      var results = _localData.where((item) => !item.isDeleted).where((item) {
        final updatedAt = item.updatedAt ?? item.createdAt;
        return updatedAt != null && updatedAt.isAfter(cutoff);
      }).toList();
      results.sort((a, b) {
        final aDate =
            a.updatedAt ??
            a.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.updatedAt ??
            b.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      if (limit != null && limit > 0) {
        results = results.take(limit).toList();
      }

      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar itens recentes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> fullTextSearch(
    String query, {
    List<String>? searchFields,
  }) async {
    try {
      await _ensureInitialized();

      if (query.trim().isEmpty) {
        return findAll();
      }

      final queryLower = query.toLowerCase();
      final results = <T>[];

      for (final item in _localData) {
        if (item.isDeleted) continue;
        final itemMap = toMap(item);
        bool matches = false;

        if (searchFields != null) {
          for (final field in searchFields) {
            final value = itemMap[field]?.toString().toLowerCase() ?? '';
            if (value.contains(queryLower)) {
              matches = true;
              break;
            }
          }
        } else {
          for (final value in itemMap.values) {
            if (value is String && value.toLowerCase().contains(queryLower)) {
              matches = true;
              break;
            }
          }
        }

        if (matches) {
          results.add(item);
        }
      }

      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Erro na busca de texto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> forceSync() async {
    try {
      await _ensureInitialized();

      if (!_canSync()) {
        return const Left(
          NetworkFailure(
            'Não é possível sincronizar: offline ou não autenticado',
          ),
        );
      }

      final unsyncedResult = await getUnsyncedItems();
      if (unsyncedResult.isLeft()) {
        return unsyncedResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }

      final unsyncedItems = unsyncedResult.getOrElse(() => []);

      if (unsyncedItems.isNotEmpty) {
        await _performBatchSync(unsyncedItems);
      }
      await _pullFromFirebase();

      _lastSyncTime = DateTime.now();
      await _updateSyncStatus();

      developer.log(
        'Sincronização forçada concluída para $collectionName',
        name: 'SyncService',
      );

      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro na sincronização forçada: $e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> getUnsyncedItems() async {
    try {
      await _ensureInitialized();

      final unsyncedItems = _localData.where((item) => item.needsSync).toList();
      return Right(unsyncedItems);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter itens não sincronizados: $e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> getConflictedItems() async {
    try {
      await _ensureInitialized();
      return const Right([]);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter itens em conflito: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resolveConflict(String id, T resolution) async {
    try {
      await _ensureInitialized();

      final resolvedItem = resolution.incrementVersion().markAsDirty() as T;
      final result = await _saveLocal(resolvedItem);

      if (result.isLeft()) return result;

      if (_canSync()) {
        _syncItemInBackground(resolvedItem);
      }

      await _refreshLocalData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao resolver conflito: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      await _ensureInitialized();

      await _localStorage.clear(box: collectionName);
      _localData.clear();
      _dataController.add([]);

      developer.log(
        'Dados locais limpos para $collectionName',
        name: 'SyncService',
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar dados locais: $e'));
    }
  }

  @override
  Map<String, dynamic> getDebugInfo() {
    return {
      'collection_name': collectionName,
      'is_initialized': _isInitialized,
      'current_status': _currentStatus.name,
      'current_user_id': _currentUserId,
      'local_items_count': _localData.length,
      'can_sync': _canSync(),
      'last_sync_time': _lastSyncTime?.toIso8601String(),
      'unsynced_items_count': _localData.where((item) => item.needsSync).length,
      'deleted_items_count': _localData.where((item) => item.isDeleted).length,
      'config': {
        'sync_interval_minutes': config.syncInterval.inMinutes,
        'batch_size': config.batchSize,
        'max_retries': config.maxRetries,
        'enable_realtime_sync': config.enableRealtimeSync,
        'enable_offline_mode': config.enableOfflineMode,
      },
    };
  }

  @override
  Stream<List<T>> get dataStream => _dataController.stream;

  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  @override
  Stream<bool> get connectivityStream => _connectivity.connectivityStream;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final result = await initialize();
      if (result.isLeft()) {
        throw Exception(
          result.fold((failure) => failure.message, (_) => 'Unknown error'),
        );
      }
    }
  }

  String _generateId() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      13,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  bool _canSync() {
    return _currentUserId != null && _currentStatus != SyncStatus.offline;
  }

  Future<Either<Failure, void>> _saveLocal(T item) async {
    try {
      final itemMap = toMap(item);
      return await _localStorage.save<Map<String, dynamic>>(
        key: item.id,
        data: itemMap,
        box: collectionName,
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar localmente: $e'));
    }
  }

  Future<Either<Failure, T?>> _getLocal(String id) async {
    try {
      final result = await _localStorage.get<Map<String, dynamic>>(
        key: id,
        box: collectionName,
      );

      return result.fold((failure) => Left(failure), (data) {
        if (data == null) return const Right(null);
        try {
          // ✅ FIXED: Safely handle LinkedMap, IdentityMap and other Hive internal types
          // Always convert to new Map to handle LinkedMap<dynamic, dynamic> from Hive
          final castedData = <String, dynamic>{};
          (data as Map).forEach((key, value) {
            castedData[key.toString()] = value;
          });

          final item = fromMap(castedData);
          return Right(item);
        } catch (e) {
          return Left(CacheFailure('Erro ao deserializar item: $e'));
        }
      });
    } catch (e) {
      return Left(CacheFailure('Erro ao obter localmente: $e'));
    }
  }

  Future<void> _loadLocalData() async {
    try {
      final result = await _localStorage.getValues<Map<String, dynamic>>(
        box: collectionName,
      );

      result.fold(
        (failure) => developer.log(
          'Erro ao carregar dados locais: ${failure.message}',
          name: 'SyncService',
        ),
        (dataMaps) {
          _localData = dataMaps
              .map((dataMap) {
                try {
                  // ✅ FIXED: Safely handle LinkedMap, IdentityMap and other Hive internal types
                  // Always convert to new Map to handle LinkedMap<dynamic, dynamic> from Hive
                  final castedData = <String, dynamic>{};
                  (dataMap as Map).forEach((key, value) {
                    castedData[key.toString()] = value;
                  });
                  return fromMap(castedData);
                } catch (e) {
                  developer.log(
                    'Erro ao deserializar item: $e',
                    name: 'SyncService',
                  );
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<T>()
              .toList();

          _dataController.add(
            _localData.where((item) => !item.isDeleted).toList(),
          );
        },
      );
    } catch (e) {
      developer.log('Erro ao carregar dados locais: $e', name: 'SyncService');
    }
  }

  Future<void> _refreshLocalData() async {
    await _loadLocalData();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.connectivityStream.listen(
      (isOnline) {
        _updateSyncStatus();

        if (isOnline && _currentUserId != null) {
          _syncUnsyncedItemsInBackground();
        }
      },
      onError: (Object? error) {
        developer.log(
          'Erro no listener de conectividade: $error',
          name: 'SyncService',
        );
      },
    );
  }

  void _setupAuthListener() {
    _authSubscription = _auth.authStateChanges().listen(
      (user) {
        final oldUserId = _currentUserId;
        _currentUserId = user?.uid;

        if (_currentUserId != oldUserId) {
          _updateSyncStatus();

          if (_currentUserId != null) {
            _setupFirestoreListener();
            _syncUnsyncedItemsInBackground();
          } else {
            _removeFirestoreListener();
          }
        }
      },
      onError: (Object? error) {
        developer.log('Erro no listener de auth: $error', name: 'SyncService');
      },
    );
  }

  void _setupFirestoreListener() {
    if (_currentUserId == null || !config.enableRealtimeSync) return;

    try {
      final collection = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection(collectionName);

      _firestoreSubscription = collection.snapshots().listen(
        (snapshot) {
          _handleFirestoreSnapshot(snapshot);
        },
        onError: (Object? error) {
          developer.log(
            'Erro no listener do Firestore: $error',
            name: 'SyncService',
          );
        },
      );
    } catch (e) {
      developer.log(
        'Erro ao configurar listener do Firestore: $e',
        name: 'SyncService',
      );
    }
  }

  void _removeFirestoreListener() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
  }

  void _handleFirestoreSnapshot(QuerySnapshot snapshot) async {
    try {
      bool hasChanges = false;

      for (final change in snapshot.docChanges) {
        final rawData = change.doc.data();
        if (rawData == null || rawData is! Map) continue;

        // Firebase returns LinkedMap<dynamic, dynamic>, ensure proper casting
        final data = Map<String, dynamic>.from(rawData);

        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            try {
              final remoteItem = fromMap(data);
              await _mergeRemoteItem(remoteItem);
              hasChanges = true;
            } catch (e) {
              developer.log(
                'Erro ao processar item remoto: $e',
                name: 'SyncService',
              );
            }
            break;
          case DocumentChangeType.removed:
            await _handleRemoteDelete(change.doc.id);
            hasChanges = true;
            break;
        }
      }

      if (hasChanges) {
        await _refreshLocalData();
      }
    } catch (e) {
      developer.log(
        'Erro ao processar snapshot do Firestore: $e',
        name: 'SyncService',
      );
    }
  }

  Future<void> _mergeRemoteItem(T remoteItem) async {
    try {
      final localResult = await _getLocal(remoteItem.id);

      localResult.fold(
        (failure) => developer.log(
          'Erro ao obter item local para merge: ${failure.message}',
          name: 'SyncService',
        ),
        (localItem) async {
          T itemToSave = remoteItem;

          if (localItem != null) {
            if (localItem.version > remoteItem.version ||
                (localItem.version == remoteItem.version &&
                    localItem.isDirty)) {
              if (!localItem.isDirty) {
                itemToSave = localItem.markAsSynced() as T;
              } else {
                return;
              }
            } else {
              itemToSave = remoteItem.markAsSynced() as T;
            }
          } else {
            itemToSave = remoteItem.markAsSynced() as T;
          }

          await _saveLocal(itemToSave);
        },
      );
    } catch (e) {
      developer.log(
        'Erro ao fazer merge do item remoto: $e',
        name: 'SyncService',
      );
    }
  }

  Future<void> _handleRemoteDelete(String id) async {
    try {
      final localResult = await _getLocal(id);

      localResult.fold(
        (failure) => developer.log(
          'Item remoto deletado não existe localmente: $id',
          name: 'SyncService',
        ),
        (localItem) async {
          if (localItem != null && !localItem.isDeleted) {
            final deletedItem = localItem.markAsDeleted().markAsSynced() as T;
            await _saveLocal(deletedItem);
          }
        },
      );
    } catch (e) {
      developer.log('Erro ao processar delete remoto: $e', name: 'SyncService');
    }
  }

  Future<void> _updateSyncStatus() async {
    try {
      final connectivityResult = await _connectivity.isOnline();
      final isOnline = connectivityResult.getOrElse(() => false);

      SyncStatus newStatus;

      if (!isOnline) {
        newStatus = SyncStatus.offline;
      } else if (_currentUserId == null) {
        newStatus = SyncStatus.localOnly;
      } else {
        final unsyncedCount = _localData.where((item) => item.needsSync).length;
        newStatus = unsyncedCount > 0 ? SyncStatus.syncing : SyncStatus.synced;
      }

      if (_currentStatus != newStatus) {
        _currentStatus = newStatus;
        _statusController.add(newStatus);

        developer.log(
          'Status de sincronização alterado para: ${newStatus.name}',
          name: 'SyncService',
        );
      }
    } catch (e) {
      developer.log(
        'Erro ao atualizar status de sincronização: $e',
        name: 'SyncService',
      );
    }
  }

  void _setupAutoSync() {
    if (config.syncInterval.inSeconds > 0) {
      _syncTimer?.cancel();
      _syncTimer = Timer.periodic(config.syncInterval, (timer) {
        if (_canSync()) {
          _syncUnsyncedItemsInBackground();
        }
      });
    }
  }

  void _syncItemInBackground(T item) {
    Future.microtask(() => _performItemSync(item));
  }

  void _syncBatchInBackground(List<T> items) {
    Future.microtask(() => _performBatchSync(items));
  }

  void _syncUnsyncedItemsInBackground() {
    Future.microtask(() async {
      final unsyncedResult = await getUnsyncedItems();
      unsyncedResult.fold(
        (failure) => developer.log(
          'Erro ao obter itens não sincronizados: ${failure.message}',
          name: 'SyncService',
        ),
        (unsyncedItems) {
          if (unsyncedItems.isNotEmpty) {
            _performBatchSync(unsyncedItems);
          }
        },
      );
    });
  }

  Future<void> _performItemSync(T item) async {
    try {
      if (!_canSync() || _currentUserId == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection(collectionName)
          .doc(item.id);

      if (item.isDeleted) {
        await docRef.delete();
        developer.log(
          'Item ${item.id} deletado do Firebase',
          name: 'SyncService',
        );
      } else {
        final firebaseData = item.toFirebaseMap();
        await docRef.set(firebaseData, SetOptions(merge: true));
        developer.log(
          'Item ${item.id} sincronizado com Firebase',
          name: 'SyncService',
        );
      }
      final syncedItem = item.markAsSynced(syncTime: DateTime.now()) as T;
      await _saveLocal(syncedItem);
    } catch (e) {
      developer.log(
        'Erro ao sincronizar item ${item.id}: $e',
        name: 'SyncService',
      );
    }
  }

  Future<void> _performBatchSync(List<T> items) async {
    try {
      if (!_canSync() || _currentUserId == null || items.isEmpty) return;

      final batch = _firestore.batch();
      final itemsToUpdate = <T>[];

      for (final item in items.take(config.batchSize)) {
        final docRef = _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection(collectionName)
            .doc(item.id);

        if (item.isDeleted) {
          batch.delete(docRef);
        } else {
          final firebaseData = item.toFirebaseMap();
          batch.set(docRef, firebaseData, SetOptions(merge: true));
        }

        itemsToUpdate.add(item);
      }

      await batch.commit();
      final syncTime = DateTime.now();
      for (final item in itemsToUpdate) {
        final syncedItem = item.markAsSynced(syncTime: syncTime) as T;
        await _saveLocal(syncedItem);
      }

      developer.log(
        'Lote de ${itemsToUpdate.length} itens sincronizado',
        name: 'SyncService',
      );
      if (items.length > config.batchSize) {
        final remainingItems = items.skip(config.batchSize).toList();
        await _performBatchSync(remainingItems);
      }

      await _refreshLocalData();
      await _updateSyncStatus();
    } catch (e) {
      developer.log('Erro ao sincronizar lote: $e', name: 'SyncService');
    }
  }

  Future<void> _pullFromFirebase() async {
    try {
      if (!_canSync() || _currentUserId == null) return;

      final collectionPath = 'users/$_currentUserId/$collectionName';
      developer.log(
        'Pulling data from Firebase path: $collectionPath',
        name: 'SyncService',
      );

      final collection = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection(collectionName);

      Query query = collection;
      if (_lastSyncTime != null) {
        query = query.where(
          'updated_at',
          isGreaterThan: Timestamp.fromDate(_lastSyncTime!),
        );
      }

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        try {
          // Firebase returns LinkedMap<dynamic, dynamic>, ensure proper casting
          final rawData = doc.data();
          if (rawData is Map) {
            final data = Map<String, dynamic>.from(rawData);
            // Ensure id is present in the data
            data['id'] ??= doc.id;
            final remoteItem = fromMap(data);
            await _mergeRemoteItem(remoteItem);
          } else {
            developer.log(
              'Documento ${doc.id} não contém dados válidos',
              name: 'SyncService',
            );
          }
        } catch (e) {
          developer.log(
            'Erro ao processar documento ${doc.id}: $e',
            name: 'SyncService',
          );
        }
      }

      if (snapshot.docs.isNotEmpty) {
        await _refreshLocalData();
      }
    } catch (e) {
      developer.log(
        'Erro ao puxar dados do Firebase para $collectionName (path: users/$_currentUserId/$collectionName): $e',
        name: 'SyncService',
      );
    }
  }

  /// Cleanup dos recursos
  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      _syncTimer?.cancel();
    } catch (e) {
      developer.log('Error canceling sync timer: $e', name: 'SyncService');
    }

    try {
      await _connectivitySubscription?.cancel();
    } catch (e) {
      developer.log(
        'Error canceling connectivity subscription: $e',
        name: 'SyncService',
      );
    }

    try {
      await _authSubscription?.cancel();
    } catch (e) {
      developer.log(
        'Error canceling auth subscription: $e',
        name: 'SyncService',
      );
    }

    try {
      await _firestoreSubscription?.cancel();
    } catch (e) {
      developer.log(
        'Error canceling firestore subscription: $e',
        name: 'SyncService',
      );
    }

    try {
      await _dataController.close();
    } catch (e) {
      developer.log('Error closing data controller: $e', name: 'SyncService');
    }

    try {
      await _statusController.close();
    } catch (e) {
      developer.log('Error closing status controller: $e', name: 'SyncService');
    }

    _isInitialized = false;
    _localData.clear();

    developer.log('SyncFirebaseService<$T> disposed', name: 'SyncService');
  }

  @override
  bool get isDisposed => _isDisposed;
}

/// Extensions para facilitar o uso
extension SyncFirebaseServiceExtensions<T extends BaseSyncEntity>
    on SyncFirebaseService<T> {
  /// Obtém métricas de performance
  SyncMetrics get metrics {
    final debug = getDebugInfo();
    return SyncMetrics(
      collectionName: debug['collection_name'] as String,
      localItemsCount: debug['local_items_count'] as int,
      lastSyncAt: debug['last_sync_time'] != null
          ? DateTime.parse(debug['last_sync_time'] as String)
          : null,
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == debug['current_status'],
      ),
      isOnline: debug['can_sync'] as bool,
      canSync: debug['can_sync'] as bool,
      pendingSyncCount: debug['unsynced_items_count'] as int,
    );
  }

  /// Verifica se está funcionando corretamente
  bool get isHealthy {
    return getDebugInfo()['is_initialized'] as bool;
  }
}
