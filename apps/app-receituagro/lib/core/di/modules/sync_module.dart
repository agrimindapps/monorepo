import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../services/receita_agro_sync_service.dart';

/// Módulo de Dependency Injection para sincronização do ReceitaAgro
/// Integra ReceitaAgroSyncService com UnifiedSyncManager existente
abstract class SyncDIModule {
  static void init(GetIt sl) {
    sl.registerLazySingleton<ReceitaAgroSyncService>(
      () => ReceitaAgroSyncServiceFactory.create(
        unifiedSyncManager: UnifiedSyncManager.instance,
      ),
    );
  }

  /// Inicializa o sync service após o app estar pronto
  /// E conecta com o connectivity monitoring existente
  static Future<void> initializeSyncService(GetIt sl) async {
    try {
      final syncService = sl<ReceitaAgroSyncService>();
      final result = await syncService.initialize();

      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              '⚠️ Failed to initialize ReceitaAgro sync service: ${failure.message}',
            );
          }
        },
        (_) {
          if (kDebugMode) {
            print('✅ ReceitaAgro sync service initialized successfully');
          }
          _setupConnectivityMonitoring(sl);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing ReceitaAgro sync service: $e');
      }
    }
  }

  /// Configura monitoramento de conectividade para auto-sync
  static void _setupConnectivityMonitoring(GetIt sl) {
    try {
      final syncService = sl<ReceitaAgroSyncService>();
      final connectivityService = ConnectivityService.instance;
      syncService.startConnectivityMonitoring(
        connectivityService.connectivityStream,
      );

      if (kDebugMode) {
        print('✅ Connectivity monitoring integrated with sync service');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to setup connectivity monitoring: $e');
      }
    }
  }

  /// Executa sync inicial após o usuário fazer login
  /// Usando o UnifiedSyncManager que já está configurado
  static Future<void> performInitialSync(GetIt sl) async {
    try {
      final syncService = sl<ReceitaAgroSyncService>();

      final hasPending = await syncService.hasPendingSync;
      if (hasPending || !syncService.canSync) {
        if (kDebugMode) {
          print('ℹ️ Skipping initial sync - service not ready or sync pending');
        }
        return;
      }

      if (kDebugMode) {
        print('🔄 Starting initial sync for ReceitaAgro...');
        print('ℹ️ Using UnifiedSyncManager with advanced features');
      }

      final result = await syncService.sync();

      result.fold(
        (failure) {
          if (kDebugMode) {
            print('⚠️ Initial sync failed: ${failure.message}');
          }
        },
        (syncResult) {
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
  static Future<void> clearSyncData(GetIt sl) async {
    try {
      final syncService = sl<ReceitaAgroSyncService>();
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
  static Future<void> printSyncStatistics(GetIt sl) async {
    try {
      final syncService = sl<ReceitaAgroSyncService>();
      final stats = await syncService.getStatistics();

      if (kDebugMode) {
        print('📊 ReceitaAgro Sync Statistics:');
        print('   Total syncs: ${stats.totalSyncs}');
        print('   Successful: ${stats.successfulSyncs}');
        print('   Failed: ${stats.failedSyncs}');
        print('   Last sync: ${stats.lastSyncTime}');
        print('   Items synced: ${stats.totalItemsSynced}');
        print(
          '   UnifiedSyncManager: ${stats.metadata['unified_sync_manager']}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting sync statistics: $e');
      }
    }
  }

  /// Sync específico para dados do usuário (favoritos, comentários, settings)
  static Future<void> syncUserData(GetIt sl) async {
    try {
      final syncService = sl<ReceitaAgroSyncService>();
      final result = await syncService.syncUserData();

      result.fold(
        (failure) {
          if (kDebugMode) {
            print('⚠️ User data sync failed: ${failure.message}');
          }
        },
        (syncResult) {
          if (kDebugMode) {
            print('✅ User data synced: ${syncResult.itemsSynced} items');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing user data: $e');
      }
    }
  }
}
