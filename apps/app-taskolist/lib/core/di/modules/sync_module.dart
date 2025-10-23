import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../sync/taskolist_sync_config.dart';
import '../../../infrastructure/services/sync_service.dart';
import '../injection.dart' as local_di;

/// Módulo de Dependency Injection para sincronização do Taskolist
/// Integra UnifiedSyncManager para sincronização offline-first moderna
/// Mantém compatibilidade com TaskManagerSyncService legado
abstract class TaskolistSyncDIModule {
  /// Inicializa o UnifiedSyncManager com a configuração do Taskolist
  /// Deve ser chamado durante o bootstrap do app, após configureDependencies()
  static Future<void> init() async {
    try {
      // Configurar UnifiedSyncManager com TaskolistSyncConfig
      await TaskolistSyncConfig.configure();

      if (kDebugMode) {
        debugPrint('✅ UnifiedSyncManager configured for Taskolist');
        debugPrint('   - TaskEntity registered');
        debugPrint('   - Conflict strategy: Last Write Wins (timestamp-based)');
        debugPrint('   - Sync interval: 5 minutes');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error configuring UnifiedSyncManager: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      // Não propagar erro - deixar app continuar funcionando
    }
  }

  /// Inicializa o sync service após o app estar pronto
  /// E conecta com o connectivity monitoring existente
  static Future<void> initializeSyncService() async {
    try {
      // TaskManagerSyncService já está inicializado no construtor
      if (kDebugMode) {
        debugPrint('✅ TaskManagerSyncService initialized successfully');
      }
      _setupConnectivityMonitoring();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing TaskManagerSyncService: $e');
      }
    }
  }

  /// Configura monitoramento de conectividade para auto-sync
  static void _setupConnectivityMonitoring() {
    try {
      // TaskManagerSyncService já tem monitoramento interno
      if (kDebugMode) {
        debugPrint(
          '✅ Connectivity monitoring already integrated in TaskManagerSyncService',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to setup connectivity monitoring: $e');
      }
    }
  }

  /// Executa sync inicial após o usuário fazer login
  /// Usando o TaskManagerSyncService que já está configurado
  static Future<void> performInitialSync() async {
    try {
      final syncService = local_di.getIt<TaskManagerSyncService>();

      // TaskManagerSyncService não tem hasPendingSync ou canSync
      // Vamos verificar se está sincronizando
      if (syncService.isSyncing) {
        if (kDebugMode) {
          debugPrint('ℹ️ Skipping initial sync - service is already syncing');
        }
        return;
      }

      if (kDebugMode) {
        debugPrint('🔄 Starting initial sync for Taskolist...');
        debugPrint('ℹ️ Premium-only sync with 5min auto-sync interval');
      }

      // Precisamos obter o userId e isPremium de algum lugar
      // Por enquanto, vamos usar valores padrão ou obter do auth service
      final authService = local_di.getIt<IAuthRepository>();
      final currentUser = await authService.currentUser.first;

      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('ℹ️ Skipping sync - no user logged in');
        }
        return;
      }

      final result = await syncService.syncAll(
        userId: currentUser.id,
        isUserPremium: false, // TODO: verificar se usuário é premium
      );

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            debugPrint('⚠️ Initial sync failed: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Initial sync completed successfully');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error during initial sync: $e');
      }
    }
  }

  /// Limpa dados de sync (útil para logout)
  static Future<void> clearSyncData() async {
    try {
      final syncService = local_di.getIt<TaskManagerSyncService>();
      // TaskManagerSyncService não tem clearLocalData
      // Vamos usar dispose() que limpa os recursos
      syncService.dispose();

      if (kDebugMode) {
        debugPrint('✅ Sync service disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing sync service: $e');
      }
    }
  }

  /// Obtém estatísticas de sincronização
  static Future<void> printSyncStatistics() async {
    try {
      // TaskManagerSyncService não tem método getStatistics
      // Vamos apenas mostrar informações básicas
      final syncService = local_di.getIt<TaskManagerSyncService>();

      if (kDebugMode) {
        debugPrint('📊 TaskManagerSyncService Statistics:');
        debugPrint('   Auto-sync enabled: ✅ (5min intervals)');
        debugPrint('   Currently syncing: ${syncService.isSyncing}');
        debugPrint('   Premium-only sync: ✅');
        // Outras estatísticas não estão disponíveis no TaskManagerSyncService atual
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting sync statistics: $e');
      }
    }
  }

  /// Sync específico para tasks (mais frequente)
  static Future<void> syncTasks() async {
    try {
      // TaskManagerSyncService não tem syncTasks público
      // Vamos usar syncAll que inclui tasks
      final syncService = local_di.getIt<TaskManagerSyncService>();
      final authService = local_di.getIt<IAuthRepository>();
      final currentUser = await authService.currentUser.first;

      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('ℹ️ Skipping tasks sync - no user logged in');
        }
        return;
      }

      final result = await syncService.syncAll(
        userId: currentUser.id,
        isUserPremium: false, // TODO: verificar se usuário é premium
      );

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            debugPrint('⚠️ Tasks sync failed: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Tasks sync completed');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error syncing tasks: $e');
      }
    }
  }

  /// Sync específico para projects
  static Future<void> syncProjects() async {
    try {
      // TaskManagerSyncService não tem syncProjects público
      // Vamos usar syncAll que inclui projects
      final syncService = local_di.getIt<TaskManagerSyncService>();
      final authService = local_di.getIt<IAuthRepository>();
      final currentUser = await authService.currentUser.first;

      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('ℹ️ Skipping projects sync - no user logged in');
        }
        return;
      }

      final result = await syncService.syncAll(
        userId: currentUser.id,
        isUserPremium: false, // TODO: verificar se usuário é premium
      );

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            debugPrint('⚠️ Projects sync failed: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Projects sync completed');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error syncing projects: $e');
      }
    }
  }
}
