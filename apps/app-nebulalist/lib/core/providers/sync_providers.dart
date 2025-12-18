import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_providers.freezed.dart';
part 'sync_providers.g.dart';

/// State class for sync status with freezed immutability
///
/// **Padrão:** Baseado em app-plantis/SyncState
///
/// Gerencia estado de sincronização para UI.
@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState({
    @Default(false) bool isSyncing,
    String? lastSyncMessage,
    DateTime? lastSyncTime,
    String? error,
    @Default(0) int pendingItems,
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

  /// Returns true if there are items waiting to sync
  bool get hasPendingSync => pendingItems > 0;
}

/// Riverpod notifier for sync operations
///
/// **Responsabilidades:**
/// - Triggar sync manual
/// - Monitorar status de sync
/// - Reportar progresso
/// - Gerenciar estado de erro
///
/// **Exemplo de uso:**
/// ```dart
/// // No widget
/// final syncState = ref.watch(syncProvider);
///
/// if (syncState.isSyncing) {
///   return CircularProgressIndicator();
/// }
///
/// // Trigger manual sync
/// ElevatedButton(
///   onPressed: () => ref.read(syncProvider.notifier).triggerManualSync(),
///   child: Text('Sync Now'),
/// )
/// ```
@riverpod
class Sync extends _$Sync {
  @override
  SyncState build() {
    return const SyncState();
  }

  /// Triggers manual sync for the nebulalist app
  ///
  /// TODO: Integrar com UnifiedSyncManager quando registrado
  /// Por enquanto, apenas simula sync
  Future<void> triggerManualSync() async {
    if (state.isSyncing) return; // Prevent multiple concurrent syncs

    state = state.copyWith(
      isSyncing: true,
      lastSyncMessage: 'Iniciando sincronização...',
      error: null,
    );

    try {
      // TODO: Usar UnifiedSyncManager quando integrado
      // final result = await UnifiedSyncManager.instance.forceSyncApp('nebulalist');
      //
      // result.fold(
      //   (failure) {
      //     debugPrint('❌ Manual sync failed: ${failure.message}');
      //     state = state.copyWith(
      //       isSyncing: false,
      //       error: failure.message,
      //       lastSyncMessage: 'Erro na sincronização',
      //     );
      //   },
      //   (_) {
      //     debugPrint('✅ Manual sync completed successfully');
      //     state = state.copyWith(
      //       isSyncing: false,
      //       lastSyncTime: DateTime.now(),
      //       lastSyncMessage: 'Sincronização completa',
      //       error: null,
      //     );
      //   },
      // );

      // Placeholder: Simula sync (remover quando integrar UnifiedSyncManager)
      await Future.delayed(const Duration(seconds: 2));

      if (kDebugMode) {
        debugPrint('✅ Manual sync completed (placeholder mode)');
      }

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        lastSyncMessage: 'Sincronização completa',
        error: null,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Manual sync exception: $e');
      }

      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
        lastSyncMessage: 'Erro inesperado',
      );
    }
  }

  /// Updates sync status from external sources
  ///
  /// [isSyncing] - Se está sincronizando
  /// [message] - Mensagem de status
  /// [error] - Mensagem de erro (se houver)
  void updateSyncStatus({
    bool? isSyncing,
    String? message,
    String? error,
  }) {
    state = state.copyWith(
      isSyncing: isSyncing ?? state.isSyncing,
      lastSyncMessage: message ?? state.lastSyncMessage,
      error: error,
      lastSyncTime: (isSyncing == false && error == null)
          ? DateTime.now()
          : state.lastSyncTime,
    );
  }

  /// Updates pending items count
  ///
  /// [count] - Número de items pendentes na fila
  void updatePendingCount(int count) {
    state = state.copyWith(pendingItems: count);
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
