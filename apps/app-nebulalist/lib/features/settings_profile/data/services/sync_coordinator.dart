import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/sync_status.dart';
import '../models/task_model.dart';
import 'task_sync_service.dart';

/// Coordena a sincronização automática entre local e Firebase
class SyncCoordinator {
  final TaskSyncService _taskSyncService;
  final FirebaseAuth _auth;
  final Connectivity _connectivity;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<User?>? _authSubscription;
  Timer? _periodicSyncTimer;
  
  bool _isSyncing = false;
  SyncStatus _currentStatus = SyncStatus.pending();

  SyncCoordinator({
    TaskSyncService? taskSyncService,
    FirebaseAuth? auth,
    Connectivity? connectivity,
  })  : _taskSyncService = taskSyncService ?? TaskSyncService(),
        _auth = auth ?? FirebaseAuth.instance,
        _connectivity = connectivity ?? Connectivity();

  SyncStatus get currentStatus => _currentStatus;
  bool get isSyncing => _isSyncing;

  /// Inicia sincronização automática
  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    // Monitora conectividade
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final hasConnection = results.any((result) => 
          result == ConnectivityResult.mobile || 
          result == ConnectivityResult.wifi
        );
        
        if (hasConnection && !_isSyncing) {
          syncNow();
        }
      },
    );

    // Monitora autenticação
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null && !_isSyncing) {
        syncNow();
      }
    });

    // Sincronização periódica
    _periodicSyncTimer = Timer.periodic(interval, (_) {
      syncNow();
    });
  }

  /// Para sincronização automática
  void stopAutoSync() {
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    _periodicSyncTimer?.cancel();
  }

  /// Executa sincronização imediata
  Future<SyncStatus> syncNow() async {
    if (_isSyncing) {
      return _currentStatus;
    }

    _isSyncing = true;
    _currentStatus = SyncStatus.syncing();

    try {
      // Verifica conexão
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasConnection = connectivityResult.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi
      );

      if (!hasConnection) {
        _currentStatus = SyncStatus.pending();
        return _currentStatus;
      }

      // Verifica autenticação
      if (_auth.currentUser == null) {
        _currentStatus = SyncStatus.error('Usuário não autenticado');
        return _currentStatus;
      }

      // Aqui você integraria com o repository local para pegar as tarefas
      // Por enquanto, vamos simular
      // final localTasks = await _localRepository.getAllTasks();
      
      // Sincroniza com Firebase
      // await _taskSyncService.syncTasksBatch(localTasks);

      _currentStatus = SyncStatus.synced();
      return _currentStatus;
    } catch (e) {
      _currentStatus = SyncStatus.error(e.toString());
      return _currentStatus;
    } finally {
      _isSyncing = false;
    }
  }

  /// Sincroniza tarefa específica
  Future<SyncStatus> syncTask(TaskModel task) async {
    try {
      return await _taskSyncService.syncTaskToFirebase(task);
    } catch (e) {
      return SyncStatus.error(e.toString());
    }
  }

  /// Deleta tarefa do Firebase
  Future<SyncStatus> deleteTask(String taskId) async {
    try {
      return await _taskSyncService.deleteTaskFromFirebase(taskId);
    } catch (e) {
      return SyncStatus.error(e.toString());
    }
  }

  /// Força sincronização completa (upload e download)
  Future<SyncStatus> forceFullSync(List<TaskModel> localTasks) async {
    if (_isSyncing) {
      return _currentStatus;
    }

    _isSyncing = true;
    _currentStatus = SyncStatus.syncing();

    try {
      // Resolve conflitos
      final resolvedTasks = await _taskSyncService.resolveConflicts(localTasks);
      
      // Sincroniza todos
      await _taskSyncService.syncTasksBatch(resolvedTasks);

      _currentStatus = SyncStatus.synced();
      return _currentStatus;
    } catch (e) {
      _currentStatus = SyncStatus.error(e.toString());
      return _currentStatus;
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    stopAutoSync();
  }
}
