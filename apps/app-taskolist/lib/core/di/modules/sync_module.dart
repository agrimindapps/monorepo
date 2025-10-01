import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';

import '../injection.dart' as local_di;

/// Módulo de Dependency Injection para sincronização do Taskolist
/// Integra TaskolistSyncService com TaskManagerSyncService existente
abstract class TaskolistSyncDIModule {
  static void init() {
    // Registrar TaskolistSyncService do core package
    // Este service adiciona logging estruturado e monitoring ao TaskManagerSyncService
    local_di.getIt.registerLazySingleton<TaskolistSyncService>(
      () => TaskolistSyncServiceFactory.create(
        taskManagerSyncService: null, // Will be integrated later with existing sync
      ),
    );

    // Inicialização é lazy, service só é criado quando solicitado
  }

  /// Inicializa o sync service após o app estar pronto
  /// E conecta com o connectivity monitoring existente
  static Future<void> initializeSyncService() async {
    try {
      final syncService = local_di.getIt<TaskolistSyncService>();
      final result = await syncService.initialize();

      result.fold(
        (Failure failure) {
          // Log do erro mas não bloqueia o app
          if (kDebugMode) {
            print('⚠️ Failed to initialize Taskolist sync service: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            print('✅ Taskolist sync service initialized successfully');
          }

          // Integrar com connectivity monitoring existente
          _setupConnectivityMonitoring();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Taskolist sync service: $e');
      }
    }
  }

  /// Configura monitoramento de conectividade para auto-sync
  static void _setupConnectivityMonitoring() {
    try {
      final syncService = local_di.getIt<TaskolistSyncService>();

      // ConnectivityService from core package
      final connectivityService = ConnectivityService.instance;

      // Conectar o sync service ao stream de conectividade
      syncService.startConnectivityMonitoring(
        connectivityService.connectivityStream,
      );

      if (kDebugMode) {
        print('✅ Connectivity monitoring integrated with Taskolist sync service');
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
      final syncService = local_di.getIt<TaskolistSyncService>();

      final hasPending = await syncService.hasPendingSync;
      if (hasPending || !syncService.canSync) {
        if (kDebugMode) {
          print('ℹ️ Skipping initial sync - service not ready or sync pending');
        }
        return;
      }

      if (kDebugMode) {
        print('🔄 Starting initial sync for Taskolist...');
        print('ℹ️ Premium-only sync with 5min auto-sync interval');
      }

      final result = await syncService.sync();

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            print('⚠️ Initial sync failed: ${failure.message}');
          }
        },
        (ServiceSyncResult syncResult) {
          if (kDebugMode) {
            print(
              '✅ Initial sync completed: ${syncResult.itemsSynced} items in ${syncResult.duration.inSeconds}s',
            );
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
      final syncService = local_di.getIt<TaskolistSyncService>();
      await syncService.clearLocalData();

      if (kDebugMode) {
        print('✅ Sync data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing sync data: $e');
      }
    }
  }

  /// Obtém estatísticas de sincronização
  static Future<void> printSyncStatistics() async {
    try {
      final syncService = local_di.getIt<TaskolistSyncService>();
      final stats = await syncService.getStatistics();

      if (kDebugMode) {
        print('📊 Taskolist Sync Statistics:');
        print('   Total syncs: ${stats.totalSyncs}');
        print('   Successful: ${stats.successfulSyncs}');
        print('   Failed: ${stats.failedSyncs}');
        print('   Last sync: ${stats.lastSyncTime}');
        print('   Items synced: ${stats.totalItemsSynced}');
        print('   Premium-only: ${stats.metadata['premium_only']}');
        print('   Auto-sync interval: ${stats.metadata['auto_sync_interval']}');
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
      final syncService = local_di.getIt<TaskolistSyncService>();
      final result = await syncService.syncTasks();

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            print('⚠️ Tasks sync failed: ${failure.message}');
          }
        },
        (ServiceSyncResult syncResult) {
          if (kDebugMode) {
            print('✅ Tasks synced: ${syncResult.itemsSynced} items');
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
      final syncService = local_di.getIt<TaskolistSyncService>();
      final result = await syncService.syncProjects();

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            print('⚠️ Projects sync failed: ${failure.message}');
          }
        },
        (ServiceSyncResult syncResult) {
          if (kDebugMode) {
            print('✅ Projects synced: ${syncResult.itemsSynced} items');
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
