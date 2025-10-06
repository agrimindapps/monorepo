import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// State class for sync status
class SyncState {
  final bool isSyncing;
  final String? lastSyncMessage;
  final DateTime? lastSyncTime;
  final String? error;

  const SyncState({
    this.isSyncing = false,
    this.lastSyncMessage,
    this.lastSyncTime,
    this.error,
  });

  SyncState copyWith({
    bool? isSyncing,
    String? lastSyncMessage,
    DateTime? lastSyncTime,
    String? error,
    bool clearError = false,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncMessage: lastSyncMessage ?? this.lastSyncMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: clearError ? null : (error ?? this.error),
    );
  }

  String get statusMessage {
    if (isSyncing) {
      return lastSyncMessage ?? 'Sincronizando...';
    }
    if (error != null) {
      return 'Erro na sincronização';
    }
    if (lastSyncTime != null) {
      final duration = DateTime.now().difference(lastSyncTime!);
      if (duration.inMinutes < 1) {
        return 'Sincronizado agora';
      } else if (duration.inHours < 1) {
        return 'Sincronizado há ${duration.inMinutes} min';
      } else if (duration.inDays < 1) {
        return 'Sincronizado há ${duration.inHours}h';
      } else {
        return 'Sincronizado há ${duration.inDays} dias';
      }
    }
    return 'Dados sincronizados';
  }
}

/// Notifier for sync operations
class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(const SyncState());

  /// Triggers manual sync for the plantis app
  Future<void> triggerManualSync() async {
    if (state.isSyncing) return; // Prevent multiple concurrent syncs

    state = state.copyWith(
      isSyncing: true,
      lastSyncMessage: 'Iniciando sincronização...',
      clearError: true,
    );

    try {
      final result = await UnifiedSyncManager.instance.forceSyncApp('plantis');

      result.fold(
        (failure) {
          debugPrint('❌ Manual sync failed: ${failure.message}');
          state = state.copyWith(
            isSyncing: false,
            error: failure.message,
            lastSyncMessage: 'Erro na sincronização',
          );
        },
        (_) {
          debugPrint('✅ Manual sync completed successfully');
          state = state.copyWith(
            isSyncing: false,
            lastSyncTime: DateTime.now(),
            lastSyncMessage: 'Sincronização completa',
            clearError: true,
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Manual sync exception: $e');
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
        lastSyncMessage: 'Erro inesperado',
      );
    }
  }

  /// Updates sync status from external sources
  void updateSyncStatus({bool? isSyncing, String? message, String? error}) {
    state = state.copyWith(
      isSyncing: isSyncing ?? state.isSyncing,
      lastSyncMessage: message ?? state.lastSyncMessage,
      error: error,
      lastSyncTime:
          (isSyncing == false && error == null)
              ? DateTime.now()
              : state.lastSyncTime,
    );
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for sync state management
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier();
});
