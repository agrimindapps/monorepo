import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../providers/core_providers.dart' as core_providers;
import '../services/prioritized_data_loader.dart';
import '../sync/receituagro_sync_config.dart';
import '../services/receituagro_realtime_service.dart';
import '../utils/diagnostico_logger.dart';

/// Helper class to initialize app services using Riverpod ProviderContainer
class AppInitialization {
  /// Initialize all core services
  static Future<void> initializeServices(ProviderContainer container) async {
    try {
      debugPrint('🌐 [MAIN] Initializing ConnectivityService...');
      await ConnectivityService.instance.initialize();
      debugPrint('✅ [MAIN] ConnectivityService initialized successfully');

      debugPrint(
        '🌾 [MAIN] Initializing EnhancedConnectivityService for rural environments...',
      );
      final enhancedConnectivity = container.read(core_providers.enhancedConnectivityServiceProvider);
      final enhancedResult = await enhancedConnectivity.initialize(
        customPingHost: '1.1.1.1',
        enableQualityMonitoring: true,
        qualityCheckInterval: const Duration(minutes: 2),
      );

      enhancedResult.fold(
        (error) => debugPrint(
          '❌ [MAIN] EnhancedConnectivityService initialization failed: ${error.message}',
        ),
        (_) => debugPrint(
          '✅ [MAIN] EnhancedConnectivityService initialized for agricultural operations',
        ),
      );
    } catch (e) {
      debugPrint('❌ [MAIN] Connectivity services initialization failed: $e');
      if (EnvironmentConfig.enableAnalytics) {
        final crashlytics = container.read(core.crashlyticsRepositoryProvider);
        await crashlytics.recordError(
          exception: e,
          stackTrace: StackTrace.current,
          reason: 'Failed to initialize connectivity services',
          fatal: false,
        );
      }
    }
  }

  /// Initialize sync coordinator
  static void initializeSyncCoordinator(ProviderContainer container) {
    try {
      debugPrint('🔄 [MAIN] Initializing SyncCoordinator...');
      final syncCoordinator = container.read(core_providers.syncCoordinatorProvider);
      syncCoordinator.initialize();
      debugPrint('✅ [MAIN] SyncCoordinator initialized');
    } catch (e) {
      debugPrint('❌ [MAIN] SyncCoordinator initialization failed: $e');
    }
  }

  /// Initialize push notifications
  static Future<void> initializePushNotifications(ProviderContainer container) async {
    try {
      final messagingService = container.read(core_providers.firebaseMessagingServiceProvider);
      await messagingService.initialize();

      final promotionalManager = container.read(core_providers.promotionalNotificationManagerProvider);
      await promotionalManager.initialize();

      debugPrint('✅ [MAIN] Push notifications inicializados com sucesso');
    } catch (e) {
      debugPrint('❌ [MAIN] Erro ao inicializar push notifications: $e');
    }
  }

  /// Initialize remote config
  static Future<void> initializeRemoteConfig(ProviderContainer container) async {
    final remoteConfigService = container.read(core_providers.remoteConfigServiceProvider);
    await remoteConfigService.initialize();
  }

  /// Initialize analytics
  static Future<void> initializeAnalytics(ProviderContainer container) async {
    try {
      final analyticsService = container.read(core_providers.analyticsServiceProvider);
      await analyticsService.initialize();
    } catch (e) {
      DiagnosticoLogger.debug('ReceitaAgroAnalyticsService not registered', e);
    }
  }

  /// Initialize premium service
  static Future<void> initializePremium(ProviderContainer container) async {
    final premiumService = container.read(core_providers.premiumServiceProvider);
    await premiumService.initialize();
  }

  /// Initialize notification service
  static Future<void> initializeNotifications(ProviderContainer container) async {
    final notificationService = container.read(core_providers.notificationServiceProvider);
    await notificationService.initialize();
  }

  /// Initialize app data manager
  static Future<void> initializeAppData(ProviderContainer container) async {
    final dataManager = container.read(core_providers.appDataManagerProvider);
    final dataResult = await dataManager.initialize();

    dataResult.fold(
      (error) {
        if (EnvironmentConfig.enableAnalytics) {
          final crashlytics = container.read(core.crashlyticsRepositoryProvider);
          crashlytics.recordError(
            exception: error,
            stackTrace: StackTrace.current,
            fatal: false,
          );
        }
      },
      (_) {
        DiagnosticoLogger.serviceInit('AppDataManager', 'Dados prontos');
      },
    );
  }

  /// Initialize sync services
  static Future<void> initializeSync(ProviderContainer container) async {
    try {
      DiagnosticoLogger.debug('Forcing sync initialization...');
      await ReceitaAgroSyncConfig.configure(container);
      DiagnosticoLogger.debug('Sync initialization completed successfully');

      // SyncDIModule.init(getIt);
      // await SyncDIModule.initializeSyncService(getIt);
      await ReceitaAgroRealtimeService.instance.initialize();

      DiagnosticoLogger.debug('Realtime sync service initialized successfully');
    } catch (e) {
      DiagnosticoLogger.debug('Sync initialization failed', e);
    }
  }

  /// Load priority data
  static Future<void> loadPriorityData(ProviderContainer container) async {
    try {
      DiagnosticoLogger.debug(
        '🚀 [PHASE 1] Carregando dados prioritários (culturas, pragas, fitossanitários)...',
      );
      await PrioritizedDataLoader.loadPriorityData(container);

      final isPriorityReady = await PrioritizedDataLoader.isPriorityDataReady(container);
      if (isPriorityReady) {
        DiagnosticoLogger.debug(
          '✅ [PHASE 1] Dados prioritários carregados - app pronto para iniciar',
        );
      } else {
        DiagnosticoLogger.warning(
          '⚠️ [PHASE 1] Dados prioritários não carregados completamente',
          null,
        );
      }
    } catch (e) {
      DiagnosticoLogger.warning(
        '❌ [PHASE 1] Erro ao carregar dados prioritários',
        e,
      );
      DiagnosticoLogger.debug('Stack trace do erro: ${StackTrace.current}');
      if (EnvironmentConfig.enableAnalytics) {
        final crashlytics = container.read(core.crashlyticsRepositoryProvider);
        await crashlytics.recordError(
          exception: e,
          stackTrace: StackTrace.current,
          reason: 'Priority data loading failed',
          fatal: false,
        );
      }
    }
  }

  /// Load background data (non-blocking)
  static void loadBackgroundData(ProviderContainer container) {
    DiagnosticoLogger.debug(
      '⏳ [PHASE 2] Iniciando carregamento em background (diagnósticos)...',
    );
    PrioritizedDataLoader.loadBackgroundData(container);
  }

  /// Initialize Firebase services
  static Future<void> initializeFirebaseServices(
    ProviderContainer container,
  ) async {
    try {
      debugPrint('🚀 Initializing Firebase services...');
      final analyticsRepository = container.read(core.analyticsRepositoryProvider);
      final crashlyticsRepository = container.read(core.crashlyticsRepositoryProvider);
      final performanceRepository = container.read(core.performanceRepositoryProvider);

      if (EnvironmentConfig.enableAnalytics && !kIsWeb) {
        // Error handlers will be set in main.dart after this initialization
      }

      await crashlyticsRepository.setCustomKey(
        key: 'app_name',
        value: 'ReceitaAgro',
      );
      await crashlyticsRepository.setCustomKey(
        key: 'environment',
        value: EnvironmentConfig.enableAnalytics ? 'production' : 'development',
      );

      if (!kIsWeb) {
        await performanceRepository.startPerformanceTracking(
          config: const PerformanceConfig(
            enableFpsMonitoring: true,
            enableMemoryMonitoring: true,
            enableCpuMonitoring: false,
            enableFirebaseIntegration: true,
          ),
        );
        await performanceRepository.markAppStarted();
      }

      await analyticsRepository.logEvent(
        'app_initialized',
        parameters: {
          'platform': kIsWeb ? 'web' : 'mobile',
          'environment': EnvironmentConfig.enableAnalytics
              ? 'production'
              : 'development',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      await crashlyticsRepository.log(
        'ReceitaAgro app initialized successfully',
      );

      debugPrint('✅ Firebase services initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Firebase services: $e');
      try {
        final crashlyticsRepository = container.read(core.crashlyticsRepositoryProvider);
        await crashlyticsRepository.recordError(
          exception: e,
          stackTrace: stackTrace,
          reason: 'Firebase services initialization failed',
        );
      } catch (_) {}
    }
  }
}
