/// Exemplo de integração do Background Sync Manager com Sync Services
///
/// Este arquivo demonstra como integrar os componentes da Phase 8:
/// - BackgroundSyncManager
/// - SyncThrottler
/// - SyncQueue
///
/// Com os sync services existentes de cada app.
library;

import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../background/background_sync_manager.dart';
import '../interfaces/i_sync_service.dart';
import '../services/gasometer_sync_service.dart';
import '../services/plantis_sync_service.dart';
import '../throttling/sync_queue.dart';

/// ============================================
/// EXEMPLO 1: Setup Básico no main.dart de um App
/// ============================================

class BackgroundSyncSetupExample {
  static Future<void> setupInMainDart() async {
    final backgroundSync = BackgroundSyncManager.instance;

    final initResult = await backgroundSync.initialize(
      minSyncInterval: const Duration(minutes: 5), // Mínimo 5 min entre syncs
      maxQueueSize: 50, // Máx 50 items na fila
    );

    initResult.fold(
      (failure) {
        print('❌ Failed to initialize background sync: ${failure.message}');
      },
      (_) {
        print('✅ Background sync initialized successfully');
      },
    );
    final gasometerService = GasometerSyncService(
      vehicleRepository: null, // Injetar via DI
      fuelRepository: null,
      maintenanceRepository: null,
      expensesRepository: null,
    );

    backgroundSync.registerService(
      gasometerService,
      config: const BackgroundSyncConfig(
        syncInterval: Duration(minutes: 15), // Sync a cada 15min
        requiresWifi: false, // Pode usar dados móveis
        requiresCharging: false,
        minimumBatteryLevel: 20, // Só sync se bateria > 20%
        priority: SyncPriority.high,
        syncTimeout: Duration(minutes: 2),
        enabled: true,
      ),
    );
    final plantisService = PlantisSyncService(
      plantsRepository: null, // Injetar via DI
      spacesRepository: null,
      plantTasksRepository: null,
      plantCommentsRepository: null,
    );

    backgroundSync.registerService(
      plantisService,
      config: const BackgroundSyncConfig(
        syncInterval: Duration(hours: 1), // Sync a cada hora
        requiresWifi: true, // Apenas WiFi (economia de dados)
        requiresCharging: false,
        minimumBatteryLevel: 15,
        priority: SyncPriority.normal,
        enabled: true,
      ),
    );
    backgroundSync.events.listen((event) {
      switch (event.type) {
        case BackgroundSyncEventType.syncStarted:
          print('🔄 Sync started: ${event.serviceId}');
          break;

        case BackgroundSyncEventType.syncCompleted:
          print(
            '✅ Sync completed: ${event.serviceId} - ${event.result?.itemsSynced} items',
          );
          break;

        case BackgroundSyncEventType.syncFailed:
          print(
            '❌ Sync failed: ${event.serviceId} - ${event.failure?.message}',
          );
          break;

        case BackgroundSyncEventType.syncThrottled:
          print(
            '⏱️ Sync throttled: ${event.serviceId} - wait ${event.timeUntilNext?.inMinutes}min',
          );
          break;

        default:
          break;
      }
    });
  }
}

/// ============================================
/// EXEMPLO 2: Trigger Manual de Sync
/// ============================================

class ManualSyncTriggerExample {
  static Future<void> triggerSyncOnUserAction() async {
    final backgroundSync = BackgroundSyncManager.instance;
    await backgroundSync.triggerSync(
      'gasometer',
      priority: SyncPriority.critical, // Alta prioridade
      force: false, // Respeitar throttling
    );
    await backgroundSync.triggerSync(
      'gasometer',
      priority: SyncPriority.critical,
      force:
          true, // Ignorar throttling - usar apenas para ações críticas do usuário
    );
  }

  static Future<void> syncMultipleServicesWithPriority() async {
    final backgroundSync = BackgroundSyncManager.instance;
    await backgroundSync.triggerSync(
      'gasometer',
      priority: SyncPriority.critical,
    );
    await backgroundSync.triggerSync('plantis', priority: SyncPriority.high);
    await backgroundSync.triggerSync(
      'receituagro',
      priority: SyncPriority.normal,
    );
  }
}

/// ============================================
/// EXEMPLO 3: Controle de Background Sync
/// ============================================

class BackgroundSyncControlExample {
  static void pauseAndResumeSync() {
    final backgroundSync = BackgroundSyncManager.instance;
    backgroundSync.pause('gasometer');
    backgroundSync.pauseAll();
    backgroundSync.resume('gasometer');
    backgroundSync.resumeAll();
  }

  static void updateSyncConfiguration() {
    final backgroundSync = BackgroundSyncManager.instance;
    backgroundSync.updateConfig(
      'gasometer',
      const BackgroundSyncConfig(
        syncInterval: Duration(hours: 2), // Mudou de 15min para 2h
        requiresWifi: true, // Agora requer WiFi
        enabled: true,
      ),
    );
  }

  static void monitorSyncStats() {
    final backgroundSync = BackgroundSyncManager.instance;
    final stats = backgroundSync.getStats();

    print('📊 Background Sync Stats:');
    print('  Registered services: ${stats.registeredServices}');
    print('  Active timers: ${stats.activeTimers}');
    print('  Queue size: ${stats.queueStats.queueSize}');
    print('  Is processing: ${stats.queueStats.isProcessing}');
    stats.serviceStats.forEach((serviceId, serviceStats) {
      print('  $serviceId:');
      print('    Enabled: ${serviceStats['enabled']}');
      print('    Last sync: ${serviceStats['last_sync']}');
      print('    Failure count: ${serviceStats['failure_count']}');
      print('    Can sync now: ${serviceStats['can_sync_now']}');
    });
  }
}

/// ============================================
/// EXEMPLO 4: Integração com Lifecycle do App
/// ============================================

class AppLifecycleIntegrationExample {
  static void handleAppLifecycle() {}
}

/// ============================================
/// EXEMPLO 5: Custom Sync Service com Background Sync
/// ============================================

class CustomSyncServiceExample implements ISyncService {
  @override
  String get serviceId => 'my_custom_app';

  @override
  String get displayName => 'My Custom App Sync';

  @override
  String get version => '1.0.0';

  @override
  List<String> get dependencies => [];

  @override
  Future<Either<Failure, void>> initialize() async => const Right(null);

  @override
  bool get canSync => true;

  @override
  Future<bool> get hasPendingSync async => false;

  @override
  Stream<SyncServiceStatus> get statusStream =>
      Stream.value(SyncServiceStatus.idle);

  @override
  Stream<ServiceProgress> get progressStream => const Stream.empty();

  @override
  Future<Either<Failure, ServiceSyncResult>> sync() async {
    return Right(
      ServiceSyncResult(
        success: true,
        itemsSynced: 10,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> syncSpecific(
    List<String> ids,
  ) async => sync();

  @override
  Future<void> stopSync() async {}

  @override
  Future<bool> checkConnectivity() async => true;

  @override
  Future<Either<Failure, void>> clearLocalData() async => const Right(null);

  @override
  Future<SyncStatistics> getStatistics() async => SyncStatistics(
    serviceId: serviceId,
    totalSyncs: 0,
    successfulSyncs: 0,
    failedSyncs: 0,
  );

  @override
  Future<void> dispose() async {}

  /// Como integrar com Background Sync Manager
  void registerWithBackgroundSync() {
    final backgroundSync = BackgroundSyncManager.instance;

    backgroundSync.registerService(
      this,
      config: const BackgroundSyncConfig(
        syncInterval: Duration(minutes: 30),
        priority: SyncPriority.normal,
        enabled: true,
      ),
    );
  }
}

/// ============================================
/// EXEMPLO 6: Error Handling e Backoff
/// ============================================

class ErrorHandlingExample {
  static void demonstrateThrottlingAndBackoff() {
    final backgroundSync = BackgroundSyncManager.instance;
    final stats = backgroundSync.getStats();
    final gasometerStats = stats.serviceStats['gasometer'];

    print('Gasometer throttling:');
    print('  Failure count: ${gasometerStats?['failure_count']}');
    print('  Time until next sync: ${gasometerStats?['time_until_next']} min');
  }
}

/// ============================================
/// DICAS DE INTEGRAÇÃO
/// ============================================

/// 1. **Inicialização no main.dart**:
///    - Chamar `BackgroundSyncManager.instance.initialize()` após DI setup
///    - Registrar todos os sync services com suas configs
///
/// 2. **Configurações Recomendadas**:
///    - Apps com dados críticos: syncInterval = 15-30min, priority = high
///    - Apps com dados menos críticos: syncInterval = 1-2h, priority = normal
///    - Apps com dados grandes: requiresWifi = true
///    - Apps offline-first: minimumBatteryLevel = 15-20%
///
/// 3. **Performance**:
///    - Use SyncPriority.critical apenas para ações explícitas do usuário
///    - Pause background sync quando app está em background (opcional)
///    - Monitor stats regularmente para detectar problemas
///
/// 4. **Testing**:
///    - Mock ISyncService para testar background sync logic
///    - Simular failures para testar exponential backoff
///    - Testar comportamento com diferentes battery levels e network types
///
/// 5. **Production Monitoring**:
///    - Log eventos de sync via SyncLogger
///    - Enviar métricas para Firebase Analytics
///    - Alertar se failure_count > threshold
