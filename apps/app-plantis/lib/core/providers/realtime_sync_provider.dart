import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../services/plantis_realtime_service.dart';

/// Provider que integra o sistema de real-time sync com a UI
/// Fornece status e controles de sincronização para a interface
class RealtimeSyncProvider with ChangeNotifier {
  final PlantisRealtimeService _realtimeService;
  final ConnectivityService _connectivityService;

  // Stream subscriptions
  StreamSubscription<bool>? _realtimeStatusSubscription;
  StreamSubscription<String>? _syncEventSubscription;
  StreamSubscription<Map<String, SyncStatus>>? _globalSyncSubscription;
  StreamSubscription<AppSyncEvent>? _syncEventsSubscription;
  StreamSubscription<ConnectivityType>? _connectivitySubscription;

  // Estado do provider
  bool _isRealtimeActive = false;
  bool _isOnline = true;
  String _lastSyncEvent = '';
  SyncStatus _currentSyncStatus = SyncStatus.offline;
  final List<String> _recentEvents = [];
  DateTime? _lastSyncTime;
  int _pendingChanges = 0;

  // Configurações
  bool _showSyncNotifications = true;
  bool _enableBackgroundSync = true;

  RealtimeSyncProvider({
    PlantisRealtimeService? realtimeService,
    ConnectivityService? connectivityService,
  }) : _realtimeService = realtimeService ?? PlantisRealtimeService.instance,
       _connectivityService =
           connectivityService ?? ConnectivityService.instance {
    _initializeProvider();
  }

  // Getters
  bool get isRealtimeActive => _isRealtimeActive;
  bool get isOnline => _isOnline;
  String get lastSyncEvent => _lastSyncEvent;
  SyncStatus get currentSyncStatus => _currentSyncStatus;
  List<String> get recentEvents => List.unmodifiable(_recentEvents);
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingChanges => _pendingChanges;
  bool get showSyncNotifications => _showSyncNotifications;
  bool get enableBackgroundSync => _enableBackgroundSync;

  /// Status readable para UI
  String get statusMessage {
    if (!_isOnline) {
      return 'Offline - Alterações salvas localmente';
    }

    switch (_currentSyncStatus) {
      case SyncStatus.synced:
        return _isRealtimeActive
            ? 'Sincronizado em tempo real'
            : 'Sincronizado por intervalos';
      case SyncStatus.syncing:
        return 'Sincronizando... ($_pendingChanges pendentes)';
      case SyncStatus.offline:
        return 'Aguardando conectividade';
      case SyncStatus.localOnly:
        return 'Somente local - Verifique autenticação';
      case SyncStatus.error:
        return 'Erro na sincronização';
      case SyncStatus.conflict:
        return 'Conflito detectado - ação necessária';
    }
  }

  /// Cor do indicador de status
  SyncIndicatorColor get statusColor {
    if (!_isOnline) return SyncIndicatorColor.warning;

    switch (_currentSyncStatus) {
      case SyncStatus.synced:
        return _isRealtimeActive
            ? SyncIndicatorColor.success
            : SyncIndicatorColor.info;
      case SyncStatus.syncing:
        return SyncIndicatorColor.syncing;
      case SyncStatus.offline:
        return SyncIndicatorColor.error;
      case SyncStatus.localOnly:
        return SyncIndicatorColor.warning;
      case SyncStatus.error:
        return SyncIndicatorColor.error;
      case SyncStatus.conflict:
        return SyncIndicatorColor.warning;
    }
  }

  /// Inicializa o provider e listeners
  Future<void> _initializeProvider() async {
    try {
      // Inicializar serviços
      await _realtimeService.initialize();
      await _connectivityService.initialize();

      // Configurar listeners
      _setupRealtimeStatusListener();
      _setupSyncEventListener();
      _setupGlobalSyncListener();
      _setupSyncEventsListener();
      _setupConnectivityListener();

      // Estado inicial
      await _updateInitialState();

      developer.log(
        'RealtimeSyncProvider inicializado',
        name: 'RealtimeSyncProvider',
      );
    } catch (e) {
      developer.log(
        'Erro ao inicializar RealtimeSyncProvider: $e',
        name: 'RealtimeSyncProvider',
      );
    }
  }

  /// Configura listener do status do real-time
  void _setupRealtimeStatusListener() {
    _realtimeStatusSubscription = _realtimeService.realtimeStatusStream.listen(
      (isActive) {
        _isRealtimeActive = isActive;
        _addRecentEvent(
          isActive ? 'Real-time sync ativado' : 'Real-time sync desativado',
        );
        notifyListeners();
      },
      onError: (Object error) {
        developer.log(
          'Erro no listener de real-time status: $error',
          name: 'RealtimeSyncProvider',
        );
      },
    );
  }

  /// Configura listener de eventos de sync
  void _setupSyncEventListener() {
    _syncEventSubscription = _realtimeService.syncEventStream.listen(
      (event) {
        _lastSyncEvent = event;
        _addRecentEvent(event);
        notifyListeners();
      },
      onError: (Object error) {
        developer.log(
          'Erro no listener de sync events: $error',
          name: 'RealtimeSyncProvider',
        );
      },
    );
  }

  /// Configura listener do status global de sync
  void _setupGlobalSyncListener() {
    _globalSyncSubscription = UnifiedSyncManager.instance.globalSyncStatusStream
        .listen(
          (statusMap) {
            final plantisStatus = statusMap['plantis'];
            if (plantisStatus != null && plantisStatus != _currentSyncStatus) {
              _currentSyncStatus = plantisStatus;
              _lastSyncTime = DateTime.now();

              _addRecentEvent(
                'Status: ${_getStatusDescription(plantisStatus)}',
              );
              notifyListeners();
            }
          },
          onError: (error) {
            developer.log(
              'Erro no listener de global sync: $error',
              name: 'RealtimeSyncProvider',
            );
          },
        );
  }

  /// Configura listener de eventos individuais de sync
  void _setupSyncEventsListener() {
    _syncEventsSubscription = UnifiedSyncManager.instance.syncEventStream
        .listen(
          (event) {
            if (event.appName == 'plantis') {
              _updatePendingChanges();
              _addRecentEvent(
                '${_getActionDescription(event.action)}: ${event.entityType}',
              );
              notifyListeners();
            }
          },
          onError: (Object error) {
            developer.log(
              'Erro no listener de sync events: $error',
              name: 'RealtimeSyncProvider',
            );
          },
        );
  }

  /// Configura listener de conectividade
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.networkStatusStream.listen(
      (status) {
        final wasOnline = _isOnline;
        _isOnline =
            status != ConnectivityType.offline &&
            status != ConnectivityType.none;

        if (_isOnline != wasOnline) {
          _addRecentEvent(_isOnline ? 'Conectado' : 'Desconectado');

          // Notificar o real-time service sobre mudança de conectividade
          _realtimeService.handleConnectivityChange(_isOnline);
          notifyListeners();
        }
      },
      onError: (error) {
        developer.log(
          'Erro no listener de conectividade: $error',
          name: 'RealtimeSyncProvider',
        );
      },
    );
  }

  /// Atualiza estado inicial
  Future<void> _updateInitialState() async {
    _isRealtimeActive = _realtimeService.isRealtimeActive;
    _currentSyncStatus = UnifiedSyncManager.instance.getAppSyncStatus(
      'plantis',
    );

    final connectivityResult =
        await _connectivityService.getCurrentNetworkStatus();
    connectivityResult.fold(
      (failure) => _isOnline = false,
      (status) =>
          _isOnline =
              status != ConnectivityType.offline &&
              status != ConnectivityType.none,
    );

    _updatePendingChanges();
    notifyListeners();
  }

  /// Atualiza contagem de mudanças pendentes
  void _updatePendingChanges() {
    try {
      final debugInfo = UnifiedSyncManager.instance.getAppDebugInfo('plantis');
      final entities = debugInfo['entities'] as Map<String, dynamic>? ?? {};

      int totalPending = 0;
      for (final entityInfo in entities.values) {
        if (entityInfo is Map<String, dynamic>) {
          final unsyncedCount = entityInfo['unsynced_items_count'] as int? ?? 0;
          totalPending += unsyncedCount;
        }
      }

      _pendingChanges = totalPending;
    } catch (e) {
      developer.log(
        'Erro ao atualizar mudanças pendentes: $e',
        name: 'RealtimeSyncProvider',
      );
    }
  }

  /// Adiciona evento à lista de eventos recentes
  void _addRecentEvent(String event) {
    final timestampedEvent = '${_formatTimestamp(DateTime.now())}: $event';
    _recentEvents.insert(0, timestampedEvent);

    // Manter apenas os últimos 10 eventos
    if (_recentEvents.length > 10) {
      _recentEvents.removeRange(10, _recentEvents.length);
    }
  }

  /// Força uma sincronização manual
  Future<void> forceSync() async {
    try {
      await _realtimeService.forceSync();
      _addRecentEvent('Sincronização manual solicitada');
      notifyListeners();
    } catch (e) {
      developer.log(
        'Erro ao forçar sincronização: $e',
        name: 'RealtimeSyncProvider',
      );
      _addRecentEvent('Erro na sincronização manual');
      notifyListeners();
    }
  }

  /// Ativa/desativa real-time sync
  Future<void> toggleRealtimeSync() async {
    try {
      if (_isRealtimeActive) {
        await _realtimeService.disableRealtime();
      } else {
        await _realtimeService.enableRealtime();
      }
    } catch (e) {
      developer.log(
        'Erro ao alternar real-time sync: $e',
        name: 'RealtimeSyncProvider',
      );
      _addRecentEvent('Erro ao alternar modo de sincronização');
      notifyListeners();
    }
  }

  /// Configura notificações de sync
  void setSyncNotifications(bool enabled) {
    if (_showSyncNotifications != enabled) {
      _showSyncNotifications = enabled;
      _addRecentEvent(
        enabled
            ? 'Notificações de sync ativadas'
            : 'Notificações de sync desativadas',
      );
      notifyListeners();
    }
  }

  /// Configura sync em background
  void setBackgroundSync(bool enabled) {
    if (_enableBackgroundSync != enabled) {
      _enableBackgroundSync = enabled;
      _addRecentEvent(
        enabled
            ? 'Sync em background ativado'
            : 'Sync em background desativado',
      );
      notifyListeners();
    }
  }

  /// Limpa histórico de eventos
  void clearRecentEvents() {
    _recentEvents.clear();
    notifyListeners();
  }

  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'provider_state': {
        'is_realtime_active': _isRealtimeActive,
        'is_online': _isOnline,
        'current_sync_status': _currentSyncStatus.name,
        'pending_changes': _pendingChanges,
        'last_sync_time': _lastSyncTime?.toIso8601String(),
        'show_sync_notifications': _showSyncNotifications,
        'enable_background_sync': _enableBackgroundSync,
      },
      'recent_events_count': _recentEvents.length,
      'realtime_service_debug': _realtimeService.getDebugInfo(),
    };
  }

  // Métodos auxiliares
  String _getStatusDescription(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Sincronizado';
      case SyncStatus.syncing:
        return 'Sincronizando';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.localOnly:
        return 'Somente local';
      case SyncStatus.error:
        return 'Erro';
      case SyncStatus.conflict:
        return 'Conflito';
    }
  }

  String _getActionDescription(SyncAction action) {
    switch (action) {
      case SyncAction.create:
        return 'Criado';
      case SyncAction.update:
        return 'Atualizado';
      case SyncAction.delete:
        return 'Deletado';
      case SyncAction.sync:
        return 'Sincronizado';
      case SyncAction.conflict:
        return 'Conflito';
      case SyncAction.error:
        return 'Erro';
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _realtimeStatusSubscription?.cancel();
    _syncEventSubscription?.cancel();
    _globalSyncSubscription?.cancel();
    _syncEventsSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Cores para indicador de status de sync
enum SyncIndicatorColor {
  success, // Verde - tudo sincronizado
  info, // Azul - sync por intervalos
  syncing, // Laranja - sincronizando
  warning, // Amarelo - offline mas funcionando
  error, // Vermelho - erro
}
