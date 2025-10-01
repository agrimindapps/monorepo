import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';

import '../injection_container.dart';

/// Módulo de Dependency Injection para sincronização do AgrihUrbi
/// Integra AgrihUrbiSyncService com repositories existentes
abstract class AgrihUrbiSyncDIModule {
  static void init() {
    // Registrar AgrihUrbiSyncService do core package
    // Este service adiciona logging estruturado e monitoring aos repositories
    getIt.registerLazySingleton<AgrihUrbiSyncService>(
      () => AgrihUrbiSyncServiceFactory.create(
        livestockRepository: null, // Will be integrated with existing repositories
        marketRepository: null,
        weatherRepository: null,
        calculatorRepository: null,
      ),
    );

    // Inicialização é lazy, service só é criado quando solicitado
  }

  /// Inicializa o sync service após o app estar pronto
  /// E conecta com o connectivity monitoring existente
  static Future<void> initializeSyncService() async {
    try {
      final syncService = getIt<AgrihUrbiSyncService>();
      final result = await syncService.initialize();

      result.fold(
        (Failure failure) {
          // Log do erro mas não bloqueia o app
          if (kDebugMode) {
            print('⚠️ Failed to initialize AgrihUrbi sync service: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            print('✅ AgrihUrbi sync service initialized successfully');
          }

          // Integrar com connectivity monitoring existente
          _setupConnectivityMonitoring();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing AgrihUrbi sync service: $e');
      }
    }
  }

  /// Configura monitoramento de conectividade para auto-sync
  static void _setupConnectivityMonitoring() {
    try {
      final syncService = getIt<AgrihUrbiSyncService>();

      // ConnectivityService from core package
      final connectivityService = ConnectivityService.instance;

      // Conectar o sync service ao stream de conectividade
      syncService.startConnectivityMonitoring(
        connectivityService.connectivityStream,
      );

      if (kDebugMode) {
        print('✅ Connectivity monitoring integrated with AgrihUrbi sync service');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to setup connectivity monitoring: $e');
      }
    }
  }

  /// Executa sync inicial após o usuário fazer login
  static Future<void> performInitialSync() async {
    try {
      final syncService = getIt<AgrihUrbiSyncService>();

      final hasPending = await syncService.hasPendingSync;
      if (hasPending || !syncService.canSync) {
        if (kDebugMode) {
          print('ℹ️ Skipping initial sync - service not ready or sync pending');
        }
        return;
      }

      if (kDebugMode) {
        print('🔄 Starting initial sync for AgrihUrbi...');
        print('ℹ️ Agricultural mode with market data and weather tracking');
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
      final syncService = getIt<AgrihUrbiSyncService>();
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
      final syncService = getIt<AgrihUrbiSyncService>();
      final stats = await syncService.getStatistics();

      if (kDebugMode) {
        print('📊 AgrihUrbi Sync Statistics:');
        print('   Total syncs: ${stats.totalSyncs}');
        print('   Successful: ${stats.successfulSyncs}');
        print('   Failed: ${stats.failedSyncs}');
        print('   Last sync: ${stats.lastSyncTime}');
        print('   Items synced: ${stats.totalItemsSynced}');
        print('   Agricultural mode: ${stats.metadata['agricultural_mode']}');
        print('   Market data sync: ${stats.metadata['market_data_sync']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting sync statistics: $e');
      }
    }
  }

  /// Sync específico para gado/livestock
  static Future<void> syncLivestock() async {
    try {
      final syncService = getIt<AgrihUrbiSyncService>();
      final result = await syncService.syncLivestock();

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            print('⚠️ Livestock sync failed: ${failure.message}');
          }
        },
        (ServiceSyncResult syncResult) {
          if (kDebugMode) {
            print('✅ Livestock synced: ${syncResult.itemsSynced} items');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing livestock: $e');
      }
    }
  }

  /// Sync específico para dados de mercado
  static Future<void> syncMarketData() async {
    try {
      final syncService = getIt<AgrihUrbiSyncService>();
      final result = await syncService.syncMarketData();

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            print('⚠️ Market data sync failed: ${failure.message}');
          }
        },
        (ServiceSyncResult syncResult) {
          if (kDebugMode) {
            print('✅ Market data synced: ${syncResult.itemsSynced} items');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing market data: $e');
      }
    }
  }
}
