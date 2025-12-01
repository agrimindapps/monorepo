import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_providers.freezed.dart';
part 'sync_providers.g.dart';

/// State class for sync status with freezed immutability
@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState({
    @Default(false) bool isSyncing,
    String? lastSyncMessage,
    DateTime? lastSyncTime,
    String? error,
  }) = _SyncState;
}

/// Extension providing computed properties for SyncState
extension SyncStateX on SyncState {
  /// Returns a user-friendly status message
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

/// Riverpod notifier for sync operations
@riverpod
class Sync extends _$Sync {
  @override
  SyncState build() {
    return const SyncState();
  }

  /// Triggers manual sync for the plantis app
  Future<void> triggerManualSync() async {
    if (state.isSyncing) return; // Prevent multiple concurrent syncs

    state = state.copyWith(
      isSyncing: true,
      lastSyncMessage: 'Iniciando sincronização...',
      error: null,
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
            error: null,
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
      lastSyncTime: (isSyncing == false && error == null)
          ? DateTime.now()
          : state.lastSyncTime,
    );
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
