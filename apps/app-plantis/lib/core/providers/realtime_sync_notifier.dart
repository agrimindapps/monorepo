import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/plantis_realtime_service.dart';

part 'realtime_sync_notifier.g.dart';

/// Provider do PlantisRealtimeService (singleton)
@riverpod
PlantisRealtimeService plantisRealtimeService(Ref ref) {
  return PlantisRealtimeService.instance;
}

/// Provider do ConnectivityService (singleton from core)
@riverpod
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService.instance;
}

/// Provider do UnifiedSyncManager (singleton from core)
@riverpod
UnifiedSyncManager unifiedSyncManager(Ref ref) {
  return UnifiedSyncManager.instance;
}

/// Estado imutável para sincronização em tempo real
@immutable
class RealtimeSyncState {
  final bool isRealtimeActive;
  final bool isOnline;
  final String lastSyncEvent;
  final SyncStatus currentSyncStatus;
  final List<String> recentEvents;
  final DateTime? lastSyncTime;
  final int pendingChanges;
  final bool showSyncNotifications;
  final bool enableBackgroundSync;

  const RealtimeSyncState({
    required this.isRealtimeActive,
    required this.isOnline,
    required this.lastSyncEvent,
    required this.currentSyncStatus,
    required this.recentEvents,
    this.lastSyncTime,
    required this.pendingChanges,
    required this.showSyncNotifications,
    required this.enableBackgroundSync,
  });

  /// Estado inicial padrão
  factory RealtimeSyncState.initial() {
    return const RealtimeSyncState(
      isRealtimeActive: false,
      isOnline: true,
      lastSyncEvent: '',
      currentSyncStatus: SyncStatus.offline,
      recentEvents: [],
      lastSyncTime: null,
      pendingChanges: 0,
      showSyncNotifications: true,
      enableBackgroundSync: true,
    );
  }

  /// Cria uma cópia com alterações
  RealtimeSyncState copyWith({
    bool? isRealtimeActive,
    bool? isOnline,
    String? lastSyncEvent,
    SyncStatus? currentSyncStatus,
    List<String>? recentEvents,
    DateTime? lastSyncTime,
    int? pendingChanges,
    bool? showSyncNotifications,
    bool? enableBackgroundSync,
  }) {
    return RealtimeSyncState(
      isRealtimeActive: isRealtimeActive ?? this.isRealtimeActive,
      isOnline: isOnline ?? this.isOnline,
      lastSyncEvent: lastSyncEvent ?? this.lastSyncEvent,
      currentSyncStatus: currentSyncStatus ?? this.currentSyncStatus,
      recentEvents: recentEvents ?? this.recentEvents,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      showSyncNotifications:
          showSyncNotifications ?? this.showSyncNotifications,
      enableBackgroundSync: enableBackgroundSync ?? this.enableBackgroundSync,
    );
  }

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RealtimeSyncState &&
        other.isRealtimeActive == isRealtimeActive &&
        other.isOnline == isOnline &&
        other.lastSyncEvent == lastSyncEvent &&
        other.currentSyncStatus == currentSyncStatus &&
        listEquals(other.recentEvents, recentEvents) &&
        other.lastSyncTime == lastSyncTime &&
        other.pendingChanges == pendingChanges &&
        other.showSyncNotifications == showSyncNotifications &&
        other.enableBackgroundSync == enableBackgroundSync;
  }

  @override
  int get hashCode {
    return isRealtimeActive.hashCode ^
        isOnline.hashCode ^
        lastSyncEvent.hashCode ^
        currentSyncStatus.hashCode ^
        Object.hashAll(recentEvents) ^
        lastSyncTime.hashCode ^
        pendingChanges.hashCode ^
        showSyncNotifications.hashCode ^
        enableBackgroundSync.hashCode;
  }
}

/// Notifier que integra o sistema de real-time sync com a UI
/// Fornece status e controles de sincronização para a interface
@riverpod
class RealtimeSyncNotifier extends _$RealtimeSyncNotifier {
  late PlantisRealtimeService _realtimeService;
  late ConnectivityService _connectivityService;
  late UnifiedSyncManager _syncManager;
  StreamSubscription<bool>? _realtimeStatusSubscription;
  StreamSubscription<String>? _syncEventSubscription;
  StreamSubscription<Map<String, SyncStatus>>? _globalSyncSubscription;
  StreamSubscription<AppSyncEvent>? _syncEventsSubscription;
  StreamSubscription<ConnectivityType>? _connectivitySubscription;

  @override
  Future<RealtimeSyncState> build() async {
    _realtimeService = ref.read(plantisRealtimeServiceProvider);
    _connectivityService = ref.read(connectivityServiceProvider);
    _syncManager = ref.read(unifiedSyncManagerProvider);
    ref.onDispose(() {
      _realtimeStatusSubscription?.cancel();
      _syncEventSubscription?.cancel();
      _globalSyncSubscription?.cancel();
      _syncEventsSubscription?.cancel();
      _connectivitySubscription?.cancel();

      developer.log(
        'RealtimeSyncNotifier disposed - all subscriptions cancelled',
        name: 'RealtimeSyncNotifier',
      );
    });

    try {
      await _realtimeService.initialize();
      await _connectivityService.initialize();
      _setupRealtimeStatusListener();
      _setupSyncEventListener();
      _setupGlobalSyncListener();
      _setupSyncEventsListener();
      _setupConnectivityListener();
      final initialState = await _getInitialState();

      developer.log(
        'RealtimeSyncNotifier initialized',
        name: 'RealtimeSyncNotifier',
      );

      return initialState;
    } catch (e) {
      developer.log(
        'Error initializing RealtimeSyncNotifier: $e',
        name: 'RealtimeSyncNotifier',
      );
      return RealtimeSyncState.initial();
    }
  }

  /// Obtém estado inicial do sistema
  Future<RealtimeSyncState> _getInitialState() async {
    final isRealtimeActive = _realtimeService.isRealtimeActive;
    final currentSyncStatus = _syncManager.getAppSyncStatus('plantis');

    final connectivityResult = await _connectivityService
        .getCurrentNetworkStatus();
    final isOnline = connectivityResult.fold(
      (failure) => false,
      (status) =>
          status != ConnectivityType.offline && status != ConnectivityType.none,
    );

    final pendingChanges = _getPendingChangesCount();

    return RealtimeSyncState(
      isRealtimeActive: isRealtimeActive,
      isOnline: isOnline,
      lastSyncEvent: '',
      currentSyncStatus: currentSyncStatus,
      recentEvents: const [],
      lastSyncTime: null,
      pendingChanges: pendingChanges,
      showSyncNotifications: true,
      enableBackgroundSync: true,
    );
  }

  /// Configura listener do status do real-time
  void _setupRealtimeStatusListener() {
    _realtimeStatusSubscription = _realtimeService.realtimeStatusStream.listen(
      (isActive) {
        final currentState = state.value;
        if (currentState == null) return;

        final newState = currentState.copyWith(isRealtimeActive: isActive);
        final updatedState = _addRecentEvent(
          newState,
          isActive ? 'Real-time sync ativado' : 'Real-time sync desativado',
        );

        state = AsyncValue.data(updatedState);
      },
      onError: (Object error) {
        developer.log(
          'Error in realtime status listener: $error',
          name: 'RealtimeSyncNotifier',
        );
      },
    );
  }

  /// Configura listener de eventos de sync
  void _setupSyncEventListener() {
    _syncEventSubscription = _realtimeService.syncEventStream.listen(
      (event) {
        final currentState = state.value;
        if (currentState == null) return;

        final newState = currentState.copyWith(lastSyncEvent: event);
        final updatedState = _addRecentEvent(newState, event);

        state = AsyncValue.data(updatedState);
      },
      onError: (Object error) {
        developer.log(
          'Error in sync event listener: $error',
          name: 'RealtimeSyncNotifier',
        );
      },
    );
  }

  /// Configura listener do status global de sync
  void _setupGlobalSyncListener() {
    _globalSyncSubscription = _syncManager.globalSyncStatusStream.listen(
      (statusMap) {
        final currentState = state.value;
        if (currentState == null) return;

        final plantisStatus = statusMap['plantis'];
        if (plantisStatus != null &&
            plantisStatus != currentState.currentSyncStatus) {
          final newState = currentState.copyWith(
            currentSyncStatus: plantisStatus,
            lastSyncTime: DateTime.now(),
          );

          final updatedState = _addRecentEvent(
            newState,
            'Status: ${_getStatusDescription(plantisStatus)}',
          );

          state = AsyncValue.data(updatedState);
        }
      },
      onError: (Object error) {
        developer.log(
          'Error in global sync listener: $error',
          name: 'RealtimeSyncNotifier',
        );
      },
    );
  }

  /// Configura listener de eventos individuais de sync
  void _setupSyncEventsListener() {
    _syncEventsSubscription = _syncManager.syncEventStream.listen(
      (event) {
        final currentState = state.value;
        if (currentState == null || event.appName != 'plantis') return;

        final pendingChanges = _getPendingChangesCount();
        final newState = currentState.copyWith(pendingChanges: pendingChanges);

        final updatedState = _addRecentEvent(
          newState,
          '${_getActionDescription(event.action)}: ${event.entityType}',
        );

        state = AsyncValue.data(updatedState);
      },
      onError: (Object error) {
        developer.log(
          'Error in sync events listener: $error',
          name: 'RealtimeSyncNotifier',
        );
      },
    );
  }

  /// Configura listener de conectividade
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.networkStatusStream.listen(
      (status) {
        final currentState = state.value;
        if (currentState == null) return;

        final isOnline =
            status != ConnectivityType.offline &&
            status != ConnectivityType.none;

        if (isOnline != currentState.isOnline) {
          final newState = currentState.copyWith(isOnline: isOnline);
          final updatedState = _addRecentEvent(
            newState,
            isOnline ? 'Conectado' : 'Desconectado',
          );

          state = AsyncValue.data(updatedState);
          _realtimeService.handleConnectivityChange(isOnline);
        }
      },
      onError: (Object error) {
        developer.log(
          'Error in connectivity listener: $error',
          name: 'RealtimeSyncNotifier',
        );
      },
    );
  }

  /// Força uma sincronização manual
  Future<void> forceSync() async {
    try {
      await _realtimeService.forceSync();

      final currentState = state.value;
      if (currentState != null) {
        final updatedState = _addRecentEvent(
          currentState,
          'Sincronização manual solicitada',
        );
        state = AsyncValue.data(updatedState);
      }
    } catch (e) {
      developer.log('Error forcing sync: $e', name: 'RealtimeSyncNotifier');

      final currentState = state.value;
      if (currentState != null) {
        final updatedState = _addRecentEvent(
          currentState,
          'Erro na sincronização manual',
        );
        state = AsyncValue.data(updatedState);
      }
    }
  }

  /// Ativa/desativa real-time sync
  Future<void> toggleRealtimeSync() async {
    try {
      final currentState = state.value;
      if (currentState == null) return;

      if (currentState.isRealtimeActive) {
        await _realtimeService.disableRealtime();
      } else {
        await _realtimeService.enableRealtime();
      }
    } catch (e) {
      developer.log(
        'Error toggling realtime sync: $e',
        name: 'RealtimeSyncNotifier',
      );

      final currentState = state.value;
      if (currentState != null) {
        final updatedState = _addRecentEvent(
          currentState,
          'Erro ao alternar modo de sincronização',
        );
        state = AsyncValue.data(updatedState);
      }
    }
  }

  /// Configura notificações de sync
  void setSyncNotifications(bool enabled) {
    final currentState = state.value;
    if (currentState == null || currentState.showSyncNotifications == enabled) {
      return;
    }

    final newState = currentState.copyWith(showSyncNotifications: enabled);
    final updatedState = _addRecentEvent(
      newState,
      enabled
          ? 'Notificações de sync ativadas'
          : 'Notificações de sync desativadas',
    );

    state = AsyncValue.data(updatedState);
  }

  /// Configura sync em background
  void setBackgroundSync(bool enabled) {
    final currentState = state.value;
    if (currentState == null || currentState.enableBackgroundSync == enabled) {
      return;
    }

    final newState = currentState.copyWith(enableBackgroundSync: enabled);
    final updatedState = _addRecentEvent(
      newState,
      enabled ? 'Sync em background ativado' : 'Sync em background desativado',
    );

    state = AsyncValue.data(updatedState);
  }

  /// Limpa histórico de eventos
  void clearRecentEvents() {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(recentEvents: const []);
    state = AsyncValue.data(newState);
  }

  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo() {
    final currentState = state.value;
    if (currentState == null) {
      return {'error': 'State not initialized'};
    }

    return {
      'provider_state': {
        'is_realtime_active': currentState.isRealtimeActive,
        'is_online': currentState.isOnline,
        'current_sync_status': currentState.currentSyncStatus.name,
        'pending_changes': currentState.pendingChanges,
        'last_sync_time': currentState.lastSyncTime?.toIso8601String(),
        'show_sync_notifications': currentState.showSyncNotifications,
        'enable_background_sync': currentState.enableBackgroundSync,
      },
      'recent_events_count': currentState.recentEvents.length,
      'realtime_service_debug': _realtimeService.getDebugInfo(),
    };
  }

  /// Atualiza contagem de mudanças pendentes
  int _getPendingChangesCount() {
    try {
      final debugInfo = _syncManager.getAppDebugInfo('plantis');
      final entities = debugInfo['entities'] as Map<String, dynamic>? ?? {};

      int totalPending = 0;
      for (final entityInfo in entities.values) {
        if (entityInfo is Map<String, dynamic>) {
          final unsyncedCount = entityInfo['unsynced_items_count'] as int? ?? 0;
          totalPending += unsyncedCount;
        }
      }

      return totalPending;
    } catch (e) {
      developer.log(
        'Error getting pending changes count: $e',
        name: 'RealtimeSyncNotifier',
      );
      return 0;
    }
  }

  /// Adiciona evento à lista de eventos recentes (retorna novo state)
  RealtimeSyncState _addRecentEvent(
    RealtimeSyncState currentState,
    String event,
  ) {
    final timestampedEvent = '${_formatTimestamp(DateTime.now())}: $event';
    final updatedEvents = [timestampedEvent, ...currentState.recentEvents];
    final trimmedEvents = updatedEvents.length > 10
        ? updatedEvents.sublist(0, 10)
        : updatedEvents;

    return currentState.copyWith(recentEvents: trimmedEvents);
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

/// Provider para verificar se realtime está ativo
@riverpod
bool isRealtimeActive(Ref ref) {
  final stateAsync = ref.watch(realtimeSyncNotifierProvider);
  return stateAsync.when(
    data: (state) => state.isRealtimeActive,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Provider para verificar se está online
@riverpod
bool isSyncOnline(Ref ref) {
  final stateAsync = ref.watch(realtimeSyncNotifierProvider);
  return stateAsync.when(
    data: (state) => state.isOnline,
    loading: () => true,
    error: (_, __) => false,
  );
}

/// Provider para status atual de sync
@riverpod
SyncStatus currentSyncStatus(Ref ref) {
  final stateAsync = ref.watch(realtimeSyncNotifierProvider);
  return stateAsync.when(
    data: (state) => state.currentSyncStatus,
    loading: () => SyncStatus.offline,
    error: (_, __) => SyncStatus.error,
  );
}

/// Provider para mensagem de status
@riverpod
String syncStatusMessage(Ref ref) {
  final stateAsync = ref.watch(realtimeSyncNotifierProvider);
  return stateAsync.when(
    data: (state) => state.statusMessage,
    loading: () => 'Carregando...',
    error: (_, __) => 'Erro ao carregar status',
  );
}

/// Provider para cor do indicador
@riverpod
SyncIndicatorColor syncStatusColor(Ref ref) {
  final stateAsync = ref.watch(realtimeSyncNotifierProvider);
  return stateAsync.when(
    data: (state) => state.statusColor,
    loading: () => SyncIndicatorColor.info,
    error: (_, __) => SyncIndicatorColor.error,
  );
}

/// Provider para mudanças pendentes
@riverpod
int pendingChangesCount(Ref ref) {
  final stateAsync = ref.watch(realtimeSyncNotifierProvider);
  return stateAsync.when(
    data: (state) => state.pendingChanges,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider para eventos recentes
@riverpod
List<String> recentSyncEvents(Ref ref) {
  final stateAsync = ref.watch(realtimeSyncNotifierProvider);
  return stateAsync.when(
    data: (state) => state.recentEvents,
    loading: () => const [],
    error: (_, __) => const [],
  );
}

/// Cores para indicador de status de sync
enum SyncIndicatorColor {
  success, // Verde - tudo sincronizado
  info, // Azul - sync por intervalos
  syncing, // Laranja - sincronizando
  warning, // Amarelo - offline mas funcionando
  error, // Vermelho - erro
}

/// Alias for backwards compatibility with legacy code
/// Use realtimeSyncProvider instead in new code
const realtimeSyncNotifierProvider = realtimeSyncProvider;
