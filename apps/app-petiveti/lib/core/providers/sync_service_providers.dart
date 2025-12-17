import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../sync/petiveti_sync_manager.dart';
import '../sync/petiveti_sync_service.dart';

part 'sync_service_providers.g.dart';

/// Estado do serviço de sincronização
class SyncServiceState {
  const SyncServiceState({
    this.isInitialized = false,
    this.isInitializing = false,
    this.status = SyncStatus.offline,
    this.error,
    this.lastSyncTime,
  });

  final bool isInitialized;
  final bool isInitializing;
  final SyncStatus status;
  final String? error;
  final DateTime? lastSyncTime;

  SyncServiceState copyWith({
    bool? isInitialized,
    bool? isInitializing,
    SyncStatus? status,
    String? error,
    DateTime? lastSyncTime,
  }) {
    return SyncServiceState(
      isInitialized: isInitialized ?? this.isInitialized,
      isInitializing: isInitializing ?? this.isInitializing,
      status: status ?? this.status,
      error: error,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  bool get canSync => isInitialized && !isInitializing;
}

/// Notifier para gerenciar o PetivetiSyncService
@Riverpod(keepAlive: true)
class SyncServiceNotifier extends _$SyncServiceNotifier {
  @override
  SyncServiceState build() {
    ref.onDispose(_dispose);
    return const SyncServiceState();
  }

  /// Inicializa o serviço de sincronização
  Future<void> initialize({bool developmentMode = false}) async {
    if (state.isInitialized || state.isInitializing) {
      debugPrint('[SyncService] Already initialized or initializing');
      return;
    }

    state = state.copyWith(isInitializing: true, error: null);

    try {
      debugPrint('[SyncService] Initializing PetivetiSyncService...');

      final result = await PetivetiSyncService.instance.initialize(
        enableDevelopmentMode: developmentMode || kDebugMode,
      );

      result.fold(
        (failure) {
          debugPrint('[SyncService] Initialization failed: ${failure.message}');
          state = state.copyWith(
            isInitializing: false,
            isInitialized: false,
            error: failure.message,
          );
        },
        (_) {
          debugPrint('[SyncService] Initialization successful');
          state = state.copyWith(
            isInitializing: false,
            isInitialized: true,
            status: PetivetiSyncService.instance.currentStatus,
          );
        },
      );
    } catch (e) {
      debugPrint('[SyncService] Initialization error: $e');
      state = state.copyWith(
        isInitializing: false,
        isInitialized: false,
        error: e.toString(),
      );
    }
  }

  /// Força sincronização de emergência (dados médicos prioritários)
  Future<void> forceEmergencySync() async {
    if (!state.canSync) {
      debugPrint('[SyncService] Cannot sync - not initialized');
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing);

    final result = await PetivetiSyncService.instance.forceEmergencySync();

    result.fold(
      (failure) {
        debugPrint('[SyncService] Emergency sync failed: ${failure.message}');
        state = state.copyWith(
          status: SyncStatus.error,
          error: failure.message,
        );
      },
      (_) {
        debugPrint('[SyncService] Emergency sync successful');
        state = state.copyWith(
          status: SyncStatus.synced,
          lastSyncTime: DateTime.now(),
          error: null,
        );
      },
    );
  }

  /// Atualiza status de sync
  void updateStatus(SyncStatus status) {
    state = state.copyWith(status: status);
  }

  void _dispose() {
    PetivetiSyncService.instance.dispose();
  }
}

/// Provider para o PetivetiSyncManager (singleton)
@Riverpod(keepAlive: true)
PetivetiSyncManager petivetiSyncManager(Ref ref) {
  return PetivetiSyncManager.instance;
}

/// Provider para o PetivetiSyncService (singleton)
@Riverpod(keepAlive: true)
PetivetiSyncService petivetiSyncService(Ref ref) {
  return PetivetiSyncService.instance;
}

/// Provider para stream de eventos de pet care
@riverpod
Stream<PetCareSyncEvent> petCareSyncEvents(Ref ref) {
  return PetivetiSyncService.instance.petCareEventStream;
}

/// Provider para stream de status de emergência
@riverpod
Stream<EmergencySyncStatus> emergencySyncStatus(Ref ref) {
  return PetivetiSyncService.instance.emergencyStatusStream;
}

/// Provider para informações de debug do sync
@riverpod
Map<String, dynamic> syncDebugInfo(Ref ref) {
  final syncNotifier = ref.watch(syncServiceProvider);

  if (!syncNotifier.isInitialized) {
    return {'status': 'not_initialized'};
  }

  return PetivetiSyncService.instance.getDebugInfo();
}
