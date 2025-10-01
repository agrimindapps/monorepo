import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../features/plants/domain/repositories/plant_comments_repository.dart';
import '../../../features/plants/domain/repositories/plant_tasks_repository.dart';
import '../../../features/plants/domain/repositories/plants_repository.dart';
import '../../../features/plants/domain/repositories/spaces_repository.dart';

/// Módulo de Dependency Injection para sincronização do Plantis
/// Registra o PlantisSyncService do core package
abstract class SyncDIModule {
  static void init(GetIt sl) {
    // Registrar PlantisSyncService do core package
    sl.registerLazySingleton<PlantisSyncService>(
      () => PlantisSyncServiceFactory.create(
        plantsRepository: sl<PlantsRepository>(),
        spacesRepository: sl<SpacesRepository>(),
        plantTasksRepository: sl<PlantTasksRepository>(),
        plantCommentsRepository: sl<PlantCommentsRepository>(),
      ),
    );

    // Inicializar o service no startup (será chamado pelo app)
    // A inicialização é lazy, então o service só é criado quando solicitado
  }

  /// Inicializa o sync service após o app estar pronto
  /// E conecta com o connectivity monitoring existente
  static Future<void> initializeSyncService(GetIt sl) async {
    try {
      final syncService = sl<PlantisSyncService>();
      final result = await syncService.initialize();

      result.fold(
        (failure) {
          // Log do erro mas não bloqueia o app
          if (kDebugMode) {
            print('⚠️ Failed to initialize Plantis sync service: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            print('✅ Plantis sync service initialized successfully');
          }

          // Integrar com connectivity monitoring existente
          _setupConnectivityMonitoring(sl);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Plantis sync service: $e');
      }
    }
  }

  /// Configura monitoramento de conectividade para auto-sync
  static void _setupConnectivityMonitoring(GetIt sl) {
    try {
      final syncService = sl<PlantisSyncService>();
      final connectivityService = sl<ConnectivityService>();

      // Conectar o sync service ao stream de conectividade
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
  static Future<void> performInitialSync(GetIt sl) async {
    try {
      final syncService = sl<PlantisSyncService>();

      final hasPending = await syncService.hasPendingSync;
      if (hasPending || !syncService.canSync) {
        if (kDebugMode) {
          print('ℹ️ Skipping initial sync - service not ready or sync pending');
        }
        return;
      }

      if (kDebugMode) {
        print('🔄 Starting initial sync for Plantis...');
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
      final syncService = sl<PlantisSyncService>();
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
}
