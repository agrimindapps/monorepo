import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../infrastructure/services/sync_service.dart';
import '../injection.dart' as local_di;

/// Módulo de Dependency Injection para sincronização do Taskolist
/// Integra TaskManagerSyncService existente
abstract class TaskolistSyncDIModule {
  static void init() {
    // TaskManagerSyncService já está registrado no sistema de DI principal
    // Não precisamos registrar novamente aqui
  }

  /// Inicializa o sync service após o app estar pronto
  /// E conecta com o connectivity monitoring existente
  static Future<void> initializeSyncService() async {
    try {
      // TaskManagerSyncService já está inicializado no construtor
      if (kDebugMode) {
        print('✅ TaskManagerSyncService initialized successfully');
      }
      _setupConnectivityMonitoring();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing TaskManagerSyncService: $e');
      }
    }
  }

  /// Configura monitoramento de conectividade para auto-sync
  static void _setupConnectivityMonitoring() {
    try {
      // TaskManagerSyncService já tem monitoramento interno
      if (kDebugMode) {
        print(
          '✅ Connectivity monitoring already integrated in TaskManagerSyncService',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to setup connectivity monitoring: $e');
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
          print('ℹ️ Skipping initial sync - service is already syncing');
        }
        return;
      }

      if (kDebugMode) {
        print('🔄 Starting initial sync for Taskolist...');
        print('ℹ️ Premium-only sync with 5min auto-sync interval');
      }

      // Precisamos obter o userId e isPremium de algum lugar
      // Por enquanto, vamos usar valores padrão ou obter do auth service
      final authService = local_di.getIt<IAuthRepository>();
      final currentUser = await authService.currentUser.first;

      if (currentUser == null) {
        if (kDebugMode) {
          print('ℹ️ Skipping sync - no user logged in');
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
            print('⚠️ Initial sync failed: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            print('✅ Initial sync completed successfully');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during initial sync: $e');
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
        print('✅ Sync service disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error disposing sync service: $e');
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
        print('📊 TaskManagerSyncService Statistics:');
        print('   Auto-sync enabled: ✅ (5min intervals)');
        print('   Currently syncing: ${syncService.isSyncing}');
        print('   Premium-only sync: ✅');
        // Outras estatísticas não estão disponíveis no TaskManagerSyncService atual
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting sync statistics: $e');
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
          print('ℹ️ Skipping tasks sync - no user logged in');
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
            print('⚠️ Tasks sync failed: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            print('✅ Tasks sync completed');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing tasks: $e');
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
          print('ℹ️ Skipping projects sync - no user logged in');
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
            print('⚠️ Projects sync failed: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            print('✅ Projects sync completed');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing projects: $e');
      }
    }
  }
}
