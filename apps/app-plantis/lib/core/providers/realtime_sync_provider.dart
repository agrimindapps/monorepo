import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/plantis_realtime_service.dart';

part 'realtime_sync_provider.freezed.dart';
part 'realtime_sync_provider.g.dart';

/// Cores para indicador de status de sync
enum SyncIndicatorColor {
  success, // Verde - tudo sincronizado
  info, // Azul - sync por intervalos
  syncing, // Laranja - sincronizando
  warning, // Amarelo - offline mas funcionando
  error, // Vermelho - erro
}

/// State class for realtime sync with freezed immutability
@freezed
class RealtimeSyncState with _$RealtimeSyncState {
  const factory RealtimeSyncState({
    @Default(false) bool isRealtimeActive,
    @Default(true) bool isOnline,
    @Default('') String lastSyncEvent,
    @Default(SyncStatus.offline) SyncStatus currentSyncStatus,
    @Default([]) List<String> recentEvents,
    DateTime? lastSyncTime,
    @Default(0) int pendingChanges,
    @Default(true) bool showSyncNotifications,
    @Default(true) bool enableBackgroundSync,
  }) = _RealtimeSyncState;

  const RealtimeSyncState._();

  /// Status readable para UI
  String get statusMessage {
    if (!isOnline) {
      return 'Offline - Alterações salvas localmente';
    }

    switch (currentSyncStatus) {
      case SyncStatus.synced:
        return isRealtimeActive
            ? 'Sincronizado em tempo real'
            : 'Sincronizado por intervalos';
      case SyncStatus.syncing:
        return 'Sincronizando... ($pendingChanges pendentes)';
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
    if (!isOnline) return SyncIndicatorColor.warning;

    switch (currentSyncStatus) {
      case SyncStatus.synced:
        return isRealtimeActive
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
}

// =============================================================================
// DEPENDENCY PROVIDERS
// =============================================================================

/// Provider for PlantisRealtimeService
@riverpod
PlantisRealtimeService plantisRealtimeService(PlantisRealtimeServiceRef ref) {
  return PlantisRealtimeService.instance;
}

/// Provider for ConnectivityService
@riverpod
ConnectivityService connectivityService(ConnectivityServiceRef ref) {
  return ConnectivityService.instance;
}

// =============================================================================
// MAIN REALTIME SYNC NOTIFIER
// =============================================================================

/// Riverpod notifier for realtime sync state management
@riverpod
class RealtimeSync extends _$RealtimeSync {
  StreamSubscription<bool>? _realtimeStatusSubscription;
  StreamSubscription<String>? _syncEventSubscription;
  StreamSubscription<Map<String, SyncStatus>>? _globalSyncSubscription;
  StreamSubscription<AppSyncEvent>? _syncEventsSubscription;
  StreamSubscription<ConnectivityType>? _connectivitySubscription;

  @override
  RealtimeSyncState build() {
    _initializeProvider();

    // Cleanup on dispose
    ref.onDispose(() {
      _realtimeStatusSubscription?.cancel();
      _syncEventSubscription?.cancel();
      _globalSyncSubscription?.cancel();
      _syncEventsSubscription?.cancel();
      _connectivitySubscription?.cancel();
    });

    return const RealtimeSyncState();
  }

  /// Inicializa o provider e listeners
  Future<void> _initializeProvider() async {
    try {
      final realtimeService = ref.read(plantisRealtimeServiceProvider);
      final connectivitySvc = ref.read(connectivityServiceProvider);

      await realtimeService.initialize();
      await connectivitySvc.initialize();

      _setupRealtimeStatusListener();
      _setupSyncEventListener();
      _setupGlobalSyncListener();
      _setupSyncEventsListener();
      _setupConnectivityListener();

      await _updateInitialState();

      developer.log(
        'RealtimeSync provider initialized',
        name: 'RealtimeSync',
      );
    } catch (e) {
      developer.log(
        'Error initializing RealtimeSync: $e',
        name: 'RealtimeSync',
      );
    }
  }

  /// Configura listener do status do real-time
  void _setupRealtimeStatusListener() {
    final realtimeService = ref.read(plantisRealtimeServiceProvider);

    _realtimeStatusSubscription = realtimeService.realtimeStatusStream.listen(
      (isActive) {
        state = state.copyWith(isRealtimeActive: isActive);
        _addRecentEvent(
          isActive ? 'Real-time sync ativado' : 'Real-time sync desativado',
        );
      },
      onError: (Object error) {
        developer.log(
          'Error in realtime status listener: $error',
          name: 'RealtimeSync',
        );
      },
    );
  }

  /// Configura listener de eventos de sync
  void _setupSyncEventListener() {
    final realtimeService = ref.read(plantisRealtimeServiceProvider);

    _syncEventSubscription = realtimeService.syncEventStream.listen(
      (event) {
        state = state.copyWith(lastSyncEvent: event);
        _addRecentEvent(event);
      },
      onError: (Object error) {
        developer.log(
          'Error in sync events listener: $error',
          name: 'RealtimeSync',
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
            if (plantisStatus != null &&
                plantisStatus != state.currentSyncStatus) {
              state = state.copyWith(
                currentSyncStatus: plantisStatus,
                lastSyncTime: DateTime.now(),
              );

              _addRecentEvent('Status: ${_getStatusDescription(plantisStatus)}');
            }
          },
          onError: (Object error) {
            developer.log(
              'Error in global sync listener: $error',
              name: 'RealtimeSync',
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
            }
          },
          onError: (Object error) {
            developer.log(
              'Error in sync events listener: $error',
              name: 'RealtimeSync',
            );
          },
        );
  }

  /// Configura listener de conectividade
  void _setupConnectivityListener() {
    final connectivitySvc = ref.read(connectivityServiceProvider);

    _connectivitySubscription = connectivitySvc.networkStatusStream.listen(
      (status) {
        final wasOnline = state.isOnline;
        final isOnline = status != ConnectivityType.offline &&
            status != ConnectivityType.none;

        if (isOnline != wasOnline) {
          state = state.copyWith(isOnline: isOnline);
          _addRecentEvent(isOnline ? 'Conectado' : 'Desconectado');

          final realtimeService = ref.read(plantisRealtimeServiceProvider);
          realtimeService.handleConnectivityChange(isOnline);
        }
      },
      onError: (Object error) {
        developer.log(
          'Error in connectivity listener: $error',
          name: 'RealtimeSync',
        );
      },
    );
  }

  /// Atualiza estado inicial
  Future<void> _updateInitialState() async {
    final realtimeService = ref.read(plantisRealtimeServiceProvider);
    final connectivitySvc = ref.read(connectivityServiceProvider);

    final isRealtimeActive = realtimeService.isRealtimeActive;
    final currentSyncStatus = UnifiedSyncManager.instance.getAppSyncStatus(
      'plantis',
    );

    final connectivityResult = await connectivitySvc.getCurrentNetworkStatus();
    final isOnline = connectivityResult.fold(
      (failure) => false,
      (status) =>
          status != ConnectivityType.offline &&
          status != ConnectivityType.none,
    );

    state = state.copyWith(
      isRealtimeActive: isRealtimeActive,
      currentSyncStatus: currentSyncStatus,
      isOnline: isOnline,
    );

    _updatePendingChanges();
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

      state = state.copyWith(pendingChanges: totalPending);
    } catch (e) {
      developer.log(
        'Error updating pending changes: $e',
        name: 'RealtimeSync',
      );
    }
  }

  /// Adiciona evento à lista de eventos recentes
  void _addRecentEvent(String event) {
    final timestampedEvent = '${_formatTimestamp(DateTime.now())}: $event';
    final updatedEvents = [timestampedEvent, ...state.recentEvents];

    // Keep only last 10 events
    final trimmedEvents = updatedEvents.length > 10
        ? updatedEvents.sublist(0, 10)
        : updatedEvents;

    state = state.copyWith(recentEvents: trimmedEvents);
  }

  /// Força uma sincronização manual
  Future<void> forceSync() async {
    try {
      final realtimeService = ref.read(plantisRealtimeServiceProvider);
      await realtimeService.forceSync();
      _addRecentEvent('Sincronização manual solicitada');
    } catch (e) {
      developer.log('Error forcing sync: $e', name: 'RealtimeSync');
      _addRecentEvent('Erro na sincronização manual');
    }
  }

  /// Ativa/desativa real-time sync
  Future<void> toggleRealtimeSync() async {
    try {
      final realtimeService = ref.read(plantisRealtimeServiceProvider);

      if (state.isRealtimeActive) {
        await realtimeService.disableRealtime();
      } else {
        await realtimeService.enableRealtime();
      }
    } catch (e) {
      developer.log('Error toggling realtime sync: $e', name: 'RealtimeSync');
      _addRecentEvent('Erro ao alternar modo de sincronização');
    }
  }

  /// Configura notificações de sync
  void setSyncNotifications(bool enabled) {
    if (state.showSyncNotifications != enabled) {
      state = state.copyWith(showSyncNotifications: enabled);
      _addRecentEvent(
        enabled
            ? 'Notificações de sync ativadas'
            : 'Notificações de sync desativadas',
      );
    }
  }

  /// Configura sync em background
  void setBackgroundSync(bool enabled) {
    if (state.enableBackgroundSync != enabled) {
      state = state.copyWith(enableBackgroundSync: enabled);
      _addRecentEvent(
        enabled
            ? 'Sync em background ativado'
            : 'Sync em background desativado',
      );
    }
  }

  /// Limpa histórico de eventos
  void clearRecentEvents() {
    state = state.copyWith(recentEvents: []);
  }

  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo() {
    final realtimeService = ref.read(plantisRealtimeServiceProvider);

    return {
      'provider_state': {
        'is_realtime_active': state.isRealtimeActive,
        'is_online': state.isOnline,
        'current_sync_status': state.currentSyncStatus.name,
        'pending_changes': state.pendingChanges,
        'last_sync_time': state.lastSyncTime?.toIso8601String(),
        'show_sync_notifications': state.showSyncNotifications,
        'enable_background_sync': state.enableBackgroundSync,
      },
      'recent_events_count': state.recentEvents.length,
      'realtime_service_debug': realtimeService.getDebugInfo(),
    };
  }

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
}
