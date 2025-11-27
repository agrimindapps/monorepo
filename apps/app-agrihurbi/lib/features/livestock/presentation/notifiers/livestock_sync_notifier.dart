import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../../../../core/di/injection_container.dart';
import '../../domain/repositories/livestock_repository.dart';
import 'livestock_sync_state.dart';

part 'livestock_sync_notifier.g.dart';

/// Riverpod notifier for livestock synchronization
///
/// Single Responsibility: Manage synchronization of remote data
@riverpod
class LivestockSyncNotifier extends _$LivestockSyncNotifier {
  late final LivestockRepository _repository;

  @override
  LivestockSyncState build() {
    return const LivestockSyncState();
  }

  /// Computed properties
  bool get hasSync => state.lastSyncTime != null;
  bool get needsSync =>
      state.lastSyncTime == null ||
      DateTime.now().difference(state.lastSyncTime!).inHours > 1;

  String get lastSyncFormatted {
    if (state.lastSyncTime == null) return 'Nunca sincronizado';

    final now = DateTime.now();
    final difference = now.difference(state.lastSyncTime!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays} dias atrás';
    }
  }

  /// Forces manual synchronization
  Future<bool> forceSyncNow({
    void Function(double)? onProgress,
    bool showProgress = true,
  }) async {
    if (state.isSyncing) {
      debugPrint('LivestockSyncNotifier: Sincronização já em andamento');
      return false;
    }

    state = state.copyWith(
      isSyncing: true,
      errorMessage: null,
      syncStatus: SyncStatus.syncing,
      syncProgress: 0.0,
    );

    try {
      if (showProgress && onProgress != null) {
        _updateProgress(0.1, onProgress);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      final result = await _repository.syncLivestockData();

      return result.fold(
        (failure) {
          debugPrint(
            'LivestockSyncNotifier: Erro na sincronização - ${failure.message}',
          );
          state = state.copyWith(
            isSyncing: false,
            errorMessage: failure.message,
            syncStatus: SyncStatus.error,
          );
          return false;
        },
        (_) {
          debugPrint(
            'LivestockSyncNotifier: Sincronização realizada com sucesso',
          );
          state = state.copyWith(
            lastSyncTime: DateTime.now(),
            syncStatus: SyncStatus.success,
            syncProgress: 1.0,
            isSyncing: false,
          );

          if (showProgress && onProgress != null) {
            onProgress(1.0);
          }

          // Auto-reset status after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (state.syncStatus != SyncStatus.idle) {
              state = state.copyWith(syncStatus: SyncStatus.idle);
            }
          });

          return true;
        },
      );
    } catch (e, stackTrace) {
      debugPrint('LivestockSyncNotifier: Erro inesperado - $e');
      debugPrint('StackTrace: $stackTrace');
      state = state.copyWith(
        errorMessage: 'Erro inesperado na sincronização: $e',
        syncStatus: SyncStatus.error,
        isSyncing: false,
      );
      return false;
    }
  }

  /// Silent background synchronization
  Future<bool> backgroundSync() async {
    if (state.isSyncing || !needsSync) {
      return false;
    }

    debugPrint('LivestockSyncNotifier: Iniciando sincronização em background');
    return await forceSyncNow(showProgress: false);
  }

  /// Cancels synchronization if possible
  void cancelSync() {
    if (state.isSyncing) {
      state = state.copyWith(syncStatus: SyncStatus.cancelled);
      debugPrint('LivestockSyncNotifier: Sincronização cancelada pelo usuário');
    }
  }

  /// Clears error messages
  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      syncStatus: SyncStatus.idle,
    );
  }

  /// Complete reset of synchronization state
  void resetSyncState() {
    state = const LivestockSyncState();
  }

  void _updateProgress(double progress, void Function(double) onProgress) {
    state = state.copyWith(syncProgress: progress);
    onProgress(progress);
  }
}
