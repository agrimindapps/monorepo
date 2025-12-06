import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/livestock_repository.dart';
import 'livestock_di_providers.dart';

part 'livestock_sync_provider.g.dart';

/// Status da sincronização
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  cancelled,
}

/// State class for LivestockSync
class LivestockSyncState {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final SyncStatus syncStatus;
  final double syncProgress;

  const LivestockSyncState({
    this.isSyncing = false,
    this.lastSyncTime,
    this.errorMessage,
    this.syncStatus = SyncStatus.idle,
    this.syncProgress = 0.0,
  });

  LivestockSyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    String? errorMessage,
    SyncStatus? syncStatus,
    double? syncProgress,
    bool clearError = false,
    bool resetState = false,
  }) {
    return LivestockSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: resetState ? null : (lastSyncTime ?? this.lastSyncTime),
      errorMessage: (clearError || resetState) ? null : (errorMessage ?? this.errorMessage),
      syncStatus: resetState ? SyncStatus.idle : (syncStatus ?? this.syncStatus),
      syncProgress: resetState ? 0.0 : (syncProgress ?? this.syncProgress),
    );
  }

  bool get hasSync => lastSyncTime != null;
  bool get needsSync =>
      lastSyncTime == null ||
      DateTime.now().difference(lastSyncTime!).inHours > 1;

  String get lastSyncFormatted {
    if (lastSyncTime == null) return 'Nunca sincronizado';

    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays} dias atrás';
    }
  }
}

/// Provider especializado para sincronização de dados de livestock
///
/// Responsabilidade única: Gerenciar sincronização de dados remotos
/// Seguindo Single Responsibility Principle
@riverpod
class LivestockSyncNotifier extends _$LivestockSyncNotifier {
  LivestockRepository get _repository => ref.read(livestockRepositoryProvider);

  @override
  LivestockSyncState build() {
    return const LivestockSyncState();
  }

  // Convenience getters for backward compatibility
  bool get isSyncing => state.isSyncing;
  DateTime? get lastSyncTime => state.lastSyncTime;
  String? get errorMessage => state.errorMessage;
  SyncStatus get syncStatus => state.syncStatus;
  double get syncProgress => state.syncProgress;
  bool get hasSync => state.hasSync;
  bool get needsSync => state.needsSync;
  String get lastSyncFormatted => state.lastSyncFormatted;

  /// Força sincronização manual
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
      syncStatus: SyncStatus.syncing,
      syncProgress: 0.0,
      clearError: true,
    );

    try {
      if (showProgress && onProgress != null) {
        _updateProgress(0.1, onProgress);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      final result = await _repository.syncLivestockData();

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
            syncStatus: SyncStatus.error,
            isSyncing: false,
          );
          debugPrint(
              'LivestockSyncNotifier: Erro na sincronização - ${failure.message}');
          _resetStatusAfterDelay();
          return false;
        },
        (_) {
          state = state.copyWith(
            lastSyncTime: DateTime.now(),
            syncStatus: SyncStatus.success,
            syncProgress: 1.0,
            isSyncing: false,
          );
          debugPrint(
              'LivestockSyncNotifier: Sincronização realizada com sucesso');

          if (showProgress && onProgress != null) {
            onProgress(1.0);
          }
          _resetStatusAfterDelay();
          return true;
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado na sincronização: $e',
        syncStatus: SyncStatus.error,
        isSyncing: false,
      );
      debugPrint('LivestockSyncNotifier: Erro inesperado - $e');
      debugPrint('StackTrace: $stackTrace');
      _resetStatusAfterDelay();
      return false;
    }
  }

  void _resetStatusAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (state.syncStatus != SyncStatus.idle) {
        state = state.copyWith(syncStatus: SyncStatus.idle);
      }
    });
  }

  void _updateProgress(double progress, void Function(double) onProgress) {
    state = state.copyWith(syncProgress: progress);
    onProgress(progress);
  }

  /// Sincronização silenciosa em background
  Future<bool> backgroundSync() async {
    if (state.isSyncing || !state.needsSync) {
      return false;
    }

    debugPrint('LivestockSyncNotifier: Iniciando sincronização em background');
    return await forceSyncNow(showProgress: false);
  }

  /// Cancela sincronização se possível
  void cancelSync() {
    if (state.isSyncing) {
      state = state.copyWith(syncStatus: SyncStatus.cancelled);
      debugPrint('LivestockSyncNotifier: Sincronização cancelada pelo usuário');
    }
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true, syncStatus: SyncStatus.idle);
  }

  /// Reset completo do estado de sincronização
  void resetSyncState() {
    state = state.copyWith(resetState: true);
  }
}
