import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/interfaces/i_disposable_service.dart';
import '../../domain/repositories/i_sync_repository.dart';
import '../../infrastructure/services/connectivity_service.dart';
import 'sync_coordinator.dart';

/// State machine para gerenciamento de status de sincronização
///
/// Responsabilidades:
/// - Gerenciar SyncStatus por app
/// - Emitir streams de mudanças de status
/// - Calcular status baseado em conectividade e auth
/// - Emitir eventos de sincronização
class SyncStateMachine implements IDisposableService {
  final SyncCoordinator _coordinator;
  final ConnectivityService _connectivity;
  final FirebaseAuth _auth;

  final Map<String, SyncStatus> _appSyncStatus = {};
  final StreamController<Map<String, SyncStatus>> _globalStatusController =
      StreamController<Map<String, SyncStatus>>.broadcast();
  final StreamController<AppSyncEvent> _eventController =
      StreamController<AppSyncEvent>.broadcast();

  StreamSubscription<User?>? _authSubscription;
  String? _currentUserId;
  bool _isDisposed = false;

  SyncStateMachine({
    required SyncCoordinator coordinator,
    ConnectivityService? connectivity,
    FirebaseAuth? auth,
  })  : _coordinator = coordinator,
        _connectivity = connectivity ?? ConnectivityService.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Inicializa a state machine
  Future<void> initialize() async {
    _setupAuthListener();
    developer.log('SyncStateMachine initialized', name: 'SyncStateMachine');
  }

  /// Configura listener de autenticação
  void _setupAuthListener() {
    _authSubscription = _auth.authStateChanges().listen(
      (user) async {
        final oldUserId = _currentUserId;
        _currentUserId = user?.uid;

        if (_currentUserId != oldUserId) {
          developer.log(
            'Auth state changed: ${_currentUserId ?? 'null'}',
            name: 'SyncStateMachine',
          );

          // Atualiza status de todos os apps
          for (final appName in _coordinator.registeredApps) {
            await updateAppStatus(appName);
          }
        }
      },
      onError: (Object error) {
        developer.log('Auth listener error: $error', name: 'SyncStateMachine');
      },
    );
  }

  /// Atualiza o status de sincronização de um app
  Future<void> updateAppStatus(String appName) async {
    try {
      final repositories = _coordinator.getAppRepositories(appName);
      if (repositories == null) return;

      SyncStatus newStatus;

      if (_currentUserId == null) {
        newStatus = SyncStatus.localOnly;
      } else {
        // Verifica conectividade
        final connectivityResult = await _connectivity.isOnline();
        final isOnline = connectivityResult.getOrElse(() => false);

        if (!isOnline) {
          newStatus = SyncStatus.offline;
        } else {
          // Verifica se há items não sincronizados
          final unsyncedCount = await _countUnsyncedItems(repositories);
          newStatus = unsyncedCount > 0 ? SyncStatus.syncing : SyncStatus.synced;
        }
      }

      if (_appSyncStatus[appName] != newStatus) {
        _appSyncStatus[appName] = newStatus;
        _globalStatusController.add(Map.from(_appSyncStatus));

        developer.log(
          'Status updated for $appName: ${newStatus.name}',
          name: 'SyncStateMachine',
        );

        // Emite evento de mudança de status
        _emitEvent(AppSyncEvent(
          appName: appName,
          entityType: Object,
          action: SyncAction.sync,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      developer.log(
        'Error updating status for $appName: $e',
        name: 'SyncStateMachine',
      );
    }
  }

  /// Conta items não sincronizados em todos os repositórios de um app
  Future<int> _countUnsyncedItems(
    Map<String, ISyncRepository<dynamic>> repositories,
  ) async {
    int totalUnsynced = 0;

    for (final repo in repositories.values) {
      try {
        final debugInfo = repo.getDebugInfo();
        final unsyncedCount = debugInfo['unsynced_items_count'] as int? ?? 0;
        totalUnsynced += unsyncedCount;
      } catch (e) {
        developer.log('Error counting unsynced items: $e', name: 'SyncStateMachine');
      }
    }

    return totalUnsynced;
  }

  /// Emite um evento de sincronização
  void emitEvent(AppSyncEvent event) {
    _emitEvent(event);
  }

  void _emitEvent(AppSyncEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// Obtém status de um app
  SyncStatus getAppStatus(String appName) {
    return _appSyncStatus[appName] ?? SyncStatus.offline;
  }

  /// Stream de status global
  Stream<Map<String, SyncStatus>> get globalStatusStream =>
      _globalStatusController.stream;

  /// Stream de eventos
  Stream<AppSyncEvent> get eventStream => _eventController.stream;

  /// User ID atual
  String? get currentUserId => _currentUserId;

  /// Verifica se pode sincronizar
  bool canSync() {
    return _currentUserId != null;
  }

  /// Verifica se um app pode sincronizar
  bool canAppSync(String appName) {
    if (_currentUserId == null) return false;
    final status = _appSyncStatus[appName];
    return status != null && status != SyncStatus.offline;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      await _authSubscription?.cancel();
    } catch (e) {
      developer.log(
        'Error canceling auth subscription: $e',
        name: 'SyncStateMachine',
      );
    }

    try {
      await _globalStatusController.close();
    } catch (e) {
      developer.log(
        'Error closing global status controller: $e',
        name: 'SyncStateMachine',
      );
    }

    try {
      await _eventController.close();
    } catch (e) {
      developer.log(
        'Error closing event controller: $e',
        name: 'SyncStateMachine',
      );
    }

    _appSyncStatus.clear();
    developer.log('SyncStateMachine disposed', name: 'SyncStateMachine');
  }

  @override
  bool get isDisposed => _isDisposed;
}

/// Evento de sincronização
class AppSyncEvent {
  const AppSyncEvent({
    required this.appName,
    required this.entityType,
    required this.action,
    this.entityId,
    this.error,
    this.timestamp,
  });

  final String appName;
  final Type entityType;
  final SyncAction action;
  final String? entityId;
  final String? error;
  final DateTime? timestamp;

  @override
  String toString() {
    return 'AppSyncEvent(app: $appName, type: $entityType, action: $action, id: $entityId)';
  }
}

/// Ações de sincronização
enum SyncAction { create, update, delete, sync, conflict, error }
