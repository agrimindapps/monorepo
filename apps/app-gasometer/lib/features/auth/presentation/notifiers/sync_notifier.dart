import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container_modular.dart';
import '../../../../core/services/gasometer_analytics_service.dart';
import '../state/sync_state.dart';
import 'auth_notifier.dart';

part 'sync_notifier.g.dart';

/// SyncNotifier - Gerenciamento de sincronização de dados
///
/// Responsabilidades:
/// - Background sync após login
/// - Data synchronization com UnifiedSync
/// - Sync state management
///
/// Separado do AuthNotifier para aplicar SRP (Single Responsibility Principle)
@Riverpod(keepAlive: true)
class Sync extends _$Sync {
  late final GasometerAnalyticsService _analytics;

  @override
  GasometerSyncState build() {
    _analytics = sl<GasometerAnalyticsService>();

    return const GasometerSyncState.initial();
  }

  /// LOGIN WITH SYNC - Executa login e depois sincronização
  Future<void> loginAndSync(String email, String password) async {
    try {
      state = state.copyWith(
        isSyncing: false,
        syncMessage: null,
        clearMessage: true,
      );

      // Delega login para AuthNotifier
      await ref.read(authProvider.notifier).login(email, password);

      final authState = ref.read(authProvider);

      // Não sincroniza se houve erro no login
      if (!authState.isAuthenticated || authState.errorMessage != null) {
        return;
      }

      // Não sincroniza para usuários anônimos
      if (!authState.isAnonymous) {
        _performBackgroundSync();
      }
    } catch (e) {
      state = state.copyWith(
        syncMessage: 'Erro na sincronização após login',
        hasError: true,
      );

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'loginAndSync_error',
      );
    }
  }

  /// Executa sincronização em background sem bloquear navegação
  void _performBackgroundSync() {
    Future.delayed(const Duration(milliseconds: 500), () {
      final authState = ref.read(authProvider);

      if (authState.isAuthenticated && !authState.isAnonymous) {
        _startBackgroundDataSync();
      }
    });
  }

  /// Sincronização de dados em background (padrão app-plantis)
  Future<void> _startBackgroundDataSync() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      hasError: false,
      syncMessage: 'Sincronizando dados...',
    );

    try {
      if (kDebugMode) {
        debugPrint('🔄 [Sync] Iniciando sincronização em background...');
      }

      await _syncGasometerData();

      state = state.copyWith(
        syncMessage: 'Sincronização concluída',
      );

      await _analytics.log('gasometer_background_sync_completed');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Sync] Erro na sincronização em background: $e');
      }

      state = state.copyWith(
        syncMessage: 'Erro na sincronização',
        hasError: true,
      );

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'gasometer_background_sync_error',
      );
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  /// Sincronizar dados do Gasometer usando UnifiedSync
  Future<void> _syncGasometerData() async {
    try {
      final syncResult = await UnifiedSyncManager.instance.forceSyncApp(
        'gasometer',
      );

      syncResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ [Sync] Erro na sincronização UnifiedSync: ${failure.message}',
            );
          }
          throw Exception(failure.message);
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ [Sync] Sincronização UnifiedSync concluída com sucesso');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Sync] Erro na sincronização Gasometer: $e');
      }
      rethrow;
    }
  }

  /// Force sync - Para uso manual (pull-to-refresh, etc)
  Future<void> forceSync() async {
    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated || authState.isAnonymous) {
      state = state.copyWith(
        syncMessage: 'Sincronização disponível apenas para usuários autenticados',
        hasError: true,
      );
      return;
    }

    await _startBackgroundDataSync();
  }

  /// Para sincronização em andamento
  void stopSync() {
    state = state.copyWith(
      isSyncing: false,
      syncMessage: 'Sincronização cancelada',
    );
  }

  /// Clear sync message
  void clearMessage() {
    state = state.copyWith(clearMessage: true);
  }
}
