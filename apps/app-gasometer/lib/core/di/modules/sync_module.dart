import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../../features/expenses/data/sync/expense_drift_sync_adapter.dart';
import '../../../features/fuel/data/sync/fuel_supply_drift_sync_adapter.dart';
import '../../../features/maintenance/data/sync/maintenance_drift_sync_adapter.dart';
import '../../../features/odometer/data/sync/odometer_drift_sync_adapter.dart';
import '../../../features/vehicles/data/sync/vehicle_drift_sync_adapter.dart';
import '../../../features/sync/domain/services/gasometer_sync_service.dart';
import '../../../features/sync/domain/services/gasometer_sync_orchestrator.dart';
import '../../../features/sync/domain/services/sync_push_service.dart';
import '../../../features/sync/domain/services/sync_pull_service.dart';
import '../../services/contracts/i_auth_provider.dart';
import '../../services/contracts/i_analytics_provider.dart';
import '../../services/providers/firebase_auth_provider.dart';
import '../../services/providers/firebase_analytics_provider.dart';
import '../../sync/adapters/sync_adapter_registry.dart';
import '../../sync/adapters/i_sync_adapter.dart';

/// Módulo de Dependency Injection para sincronização do Gasometer
/// Registra serviços de sync refatorados seguindo SRP:
/// - SyncPushService: Coordena push dos 5 adapters
/// - SyncPullService: Coordena pull dos 5 adapters
/// - GasometerSyncOrchestrator: Orquestra push + pull completa
/// - GasometerSyncService: Legado (mantido para compatibilidade)
abstract class SyncDIModule {
  static void init(GetIt sl) {
    if (kDebugMode) {
      print('📦 Registering Gasometer Sync Services...');
    }
    
    // Skip sync services on web (Drift not available)
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️  [SyncDIModule] Skipping sync services on web platform');
      }
      return;
    }

    try {
      // Adapters são registrados automaticamente via @lazySingleton (Injectable)
      // Validar que estão disponíveis
      sl<VehicleDriftSyncAdapter>();
      sl<FuelSupplyDriftSyncAdapter>();
      sl<MaintenanceDriftSyncAdapter>();
      sl<ExpenseDriftSyncAdapter>();
      sl<OdometerDriftSyncAdapter>();

      // Register SyncAdapterRegistry with all adapters
      sl.registerLazySingleton<SyncAdapterRegistry>(
        () => SyncAdapterRegistry(
          adapters: [
            sl<VehicleDriftSyncAdapter>() as ISyncAdapter,
            sl<FuelSupplyDriftSyncAdapter>() as ISyncAdapter,
            sl<MaintenanceDriftSyncAdapter>() as ISyncAdapter,
            sl<ExpenseDriftSyncAdapter>() as ISyncAdapter,
            sl<OdometerDriftSyncAdapter>() as ISyncAdapter,
          ],
        ),
      );

      // Register specialized push/pull services (SRP) with registry
      sl.registerLazySingleton<SyncPushService>(
        () => SyncPushService(
          adapterRegistry: sl<SyncAdapterRegistry>(),
        ),
      );

      sl.registerLazySingleton<SyncPullService>(
        () => SyncPullService(
          adapterRegistry: sl<SyncAdapterRegistry>(),
        ),
      );

      // Register orchestrator (coordinates push + pull)
      sl.registerLazySingleton<GasometerSyncOrchestrator>(
        () => GasometerSyncOrchestrator(
          pushService: sl<SyncPushService>(),
          pullService: sl<SyncPullService>(),
        ),
      );

      // Register main GasometerSyncService (delegates to push + pull)
      sl.registerLazySingleton<GasometerSyncService>(
        () => GasometerSyncService(
          pushService: sl<SyncPushService>(),
          pullService: sl<SyncPullService>(),
        ),
      );

      // Register Firebase Auth Provider
      sl.registerLazySingleton<IAuthProvider>(
        () => FirebaseAuthProvider(
          firebaseAuth: FirebaseAuth.instance,
        ) as IAuthProvider,
      );

      // Register Firebase Analytics Provider
      sl.registerLazySingleton<IAnalyticsProvider>(
        () => FirebaseAnalyticsProvider(
          firebaseAnalytics: FirebaseAnalytics.instance,
        ) as IAnalyticsProvider,
      );

      if (kDebugMode) {
        print('✅ Gasometer Sync Services registered successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to register Gasometer Sync Services: $e');
      }
    }
  }

  /// Inicializa o sync service após o app estar pronto
  /// E conecta com o connectivity monitoring existente
  static Future<void> initializeSyncService(GetIt sl) async {
    try {
      final syncService = sl<GasometerSyncService>();
      final result = await syncService.initialize();

      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              '⚠️ Failed to initialize Gasometer sync service: ${failure.message}',
            );
          }
        },
        (_) {
          if (kDebugMode) {
            print('✅ Gasometer sync service initialized successfully');
          }
          _setupConnectivityMonitoring(sl);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Gasometer sync service: $e');
      }
    }
  }

  /// Configura monitoramento de conectividade para auto-sync
  static void _setupConnectivityMonitoring(GetIt sl) {
    try {
      final syncService = sl<GasometerSyncService>();
      final connectivityService = sl<ConnectivityService>();
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
  /// Atualmente apenas valida o sistema (sync está desabilitado)
  static Future<void> performInitialSync(GetIt sl) async {
    try {
      final syncService = sl<GasometerSyncService>();

      final hasPending = await syncService.hasPendingSync;
      if (hasPending || !syncService.canSync) {
        if (kDebugMode) {
          print('ℹ️ Skipping initial sync - service not ready or sync pending');
        }
        return;
      }

      if (kDebugMode) {
        print('🔄 Starting initial sync for Gasometer...');
        print(
          'ℹ️ Note: Background sync is currently disabled due to Firestore indices',
        );
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
      final syncService = sl<GasometerSyncService>();
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
      final syncService = sl<GasometerSyncService>();
      final stats = await syncService.getStatistics();

      if (kDebugMode) {
        print('📊 Gasometer Sync Statistics:');
        print('   Total syncs: ${stats.totalSyncs}');
        print('   Successful: ${stats.successfulSyncs}');
        print('   Failed: ${stats.failedSyncs}');
        print('   Last sync: ${stats.lastSyncTime}');
        print('   Items synced: ${stats.totalItemsSynced}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting sync statistics: $e');
      }
    }
  }
}
