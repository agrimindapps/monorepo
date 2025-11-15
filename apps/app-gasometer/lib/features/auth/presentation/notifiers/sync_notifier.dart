import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container_modular.dart';
import '../../../../core/services/analytics/gasometer_analytics_service.dart';
import '../state/auth_state.dart' as gasometer_auth;
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
/// REFATORADO: Agora usa listener reativo (stream-based) similar ao ReceitaAgro
/// Separado do AuthNotifier para aplicar SRP (Single Responsibility Principle)
@Riverpod(keepAlive: true)
class Sync extends _$Sync {
  late final GasometerAnalyticsService _analytics;

  @override
  GasometerSyncState build() {
    _analytics = sl<GasometerAnalyticsService>();

    // Setup reactive listener para auth state changes
    _setupAuthListener();

    return const GasometerSyncState.initial();
  }

  /// Configura listener reativo para mudanças de autenticação
  /// Substitui o delay de 500ms por uma abordagem stream-based
  void _setupAuthListener() {
    ref.listen(authProvider, (previous, next) {
      // Detecta quando usuário faz login (transição de não-autenticado para autenticado)
      final wasUnauthenticated = previous?.isAuthenticated != true;
      final isNowAuthenticated = next.isAuthenticated && !next.isAnonymous;

      if (wasUnauthenticated &&
          isNowAuthenticated &&
          next.currentUser != null) {
        if (kDebugMode) {
          debugPrint(
            '🔄 [Sync] Auth state changed: user logged in, triggering sync',
          );
        }

        // Trigger sync automático após login
        _triggerPostAuthSync(next);
      }

      // Detecta quando usuário faz logout
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        if (kDebugMode) {
          debugPrint('🔄 [Sync] Auth state changed: user logged out');
        }

        // Clear sync state
        state = const GasometerSyncState.initial();
      }
    });
  }

  /// Trigger sync após autenticação (similar ao ReceitaAgro)
  Future<void> _triggerPostAuthSync(gasometer_auth.AuthState authState) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 [Sync] Triggering post-auth sync for user: ${authState.currentUser?.id}',
        );
      }

      // Pequeno delay para não bloquear navegação
      await Future<void>.delayed(const Duration(milliseconds: 300));

      await _startBackgroundDataSync();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Sync] Error in post-auth sync: $e');
      }
    }
  }

  /// LOGIN WITH SYNC - Mantido para compatibilidade, mas agora usa listener reativo
  Future<void> loginAndSync(String email, String password) async {
    try {
      state = state.copyWith(
        isSyncing: false,
        syncMessage: null,
        clearMessage: true,
      );

      // Delega login para AuthNotifier
      // O listener reativo irá disparar o sync automaticamente
      await ref.read(authProvider.notifier).login(email, password);

      final authState = ref.read(authProvider);

      // Verificação de erro
      if (authState.errorMessage != null) {
        state = state.copyWith(syncMessage: 'Erro no login', hasError: true);
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '🔄 [Sync] Login completed, sync will be triggered by listener',
        );
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

      state = state.copyWith(syncMessage: 'Sincronização concluída');

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
            debugPrint(
              '✅ [Sync] Sincronização UnifiedSync concluída com sucesso',
            );
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
        syncMessage:
            'Sincronização disponível apenas para usuários autenticados',
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
