import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// Módulo de Dependency Injection para sincronização do Petiveti
/// Integra PetivetiSyncService com repositories existentes
abstract class PetivetiSyncDIModule {
  static void init() {
    // Registrar PetivetiSyncService do core package
    // Este service adiciona logging estruturado e monitoring aos repositories
    GetIt.instance.registerLazySingleton<PetivetiSyncService>(
      () => PetivetiSyncServiceFactory.create(
        animalRepository: null, // Will be integrated with existing repositories
        appointmentRepository: null,
        medicationRepository: null,
        vaccineRepository: null,
        weightRepository: null,
        expenseRepository: null,
        reminderRepository: null,
      ),
    );

    // Inicialização é lazy, service só é criado quando solicitado
  }

  /// Inicializa o sync service após o app estar pronto
  /// E conecta com o connectivity monitoring existente
  static Future<void> initializeSyncService() async {
    try {
      final syncService = GetIt.instance<PetivetiSyncService>();
      final result = await syncService.initialize();

      result.fold(
        (Failure failure) {
          // Log do erro mas não bloqueia o app
          if (kDebugMode) {
            print('⚠️ Failed to initialize Petiveti sync service: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            print('✅ Petiveti sync service initialized successfully');
          }

          // Integrar com connectivity monitoring existente
          _setupConnectivityMonitoring();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Petiveti sync service: $e');
      }
    }
  }

  /// Configura monitoramento de conectividade para auto-sync
  static void _setupConnectivityMonitoring() {
    try {
      final syncService = GetIt.instance<PetivetiSyncService>();

      // ConnectivityService from core package
      final connectivityService = ConnectivityService.instance;

      // Conectar o sync service ao stream de conectividade
      syncService.startConnectivityMonitoring(
        connectivityService.connectivityStream,
      );

      if (kDebugMode) {
        print('✅ Connectivity monitoring integrated with Petiveti sync service');
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
      final syncService = GetIt.instance<PetivetiSyncService>();

      final hasPending = await syncService.hasPendingSync;
      if (hasPending || !syncService.canSync) {
        if (kDebugMode) {
          print('ℹ️ Skipping initial sync - service not ready or sync pending');
        }
        return;
      }

      if (kDebugMode) {
        print('🔄 Starting initial sync for Petiveti...');
        print('ℹ️ Multi-pet support with veterinary data tracking');
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
      final syncService = GetIt.instance<PetivetiSyncService>();
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
      final syncService = GetIt.instance<PetivetiSyncService>();
      final stats = await syncService.getStatistics();

      if (kDebugMode) {
        print('📊 Petiveti Sync Statistics:');
        print('   Total syncs: ${stats.totalSyncs}');
        print('   Successful: ${stats.successfulSyncs}');
        print('   Failed: ${stats.failedSyncs}');
        print('   Last sync: ${stats.lastSyncTime}');
        print('   Items synced: ${stats.totalItemsSynced}');
        print('   Multi-pet support: ${stats.metadata['multi_pet_support']}');
        print('   Offline-first: ${stats.metadata['offline_first']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting sync statistics: $e');
      }
    }
  }

  /// Sync específico para animais
  static Future<void> syncAnimals() async {
    try {
      final syncService = GetIt.instance<PetivetiSyncService>();
      final result = await syncService.syncAnimals();

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            print('⚠️ Animals sync failed: ${failure.message}');
          }
        },
        (ServiceSyncResult syncResult) {
          if (kDebugMode) {
            print('✅ Animals synced: ${syncResult.itemsSynced} items');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing animals: $e');
      }
    }
  }

  /// Sync específico para dados veterinários
  static Future<void> syncVeterinaryData() async {
    try {
      final syncService = GetIt.instance<PetivetiSyncService>();
      final result = await syncService.syncVeterinaryData();

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            print('⚠️ Veterinary data sync failed: ${failure.message}');
          }
        },
        (ServiceSyncResult syncResult) {
          if (kDebugMode) {
            print('✅ Veterinary data synced: ${syncResult.itemsSynced} items');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing veterinary data: $e');
      }
    }
  }
}
