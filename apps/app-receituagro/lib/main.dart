import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/modules/sync_module.dart';
import 'core/navigation/app_router.dart' as app_router;
import 'core/providers/theme_notifier.dart';
import 'core/services/app_data_manager.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/premium_service.dart';
import 'core/services/prioritized_data_loader.dart';
import 'core/services/promotional_notification_manager.dart';
import 'core/services/receituagro_notification_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/sync/receituagro_sync_config.dart';
import 'core/theme/receituagro_theme.dart';
import 'core/utils/diagnostico_logger.dart';
import 'core/utils/receita_agro_data_inspector_initializer.dart';
import 'core/utils/theme_preference_migration.dart';
import 'features/analytics/analytics_service.dart';
import 'firebase_options.dart';

late ICrashlyticsRepository _crashlyticsRepository;
late IPerformanceRepository _performanceRepository;

/// Handler para mensagens em background (deve ser top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemePreferenceMigration.migratePreferences();
  await di.init();
  await _initializeFirebaseServices();
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously();
    } catch (e) {
      if (EnvironmentConfig.enableAnalytics) {
        await _crashlyticsRepository.recordError(
          exception: e,
          stackTrace: StackTrace.current,
          reason: 'Failed to sign in anonymously',
          fatal: false,
        );
      }
    }
  }
  try {
    debugPrint('🌐 [MAIN] Initializing ConnectivityService...');
    await ConnectivityService.instance.initialize();
    debugPrint('✅ [MAIN] ConnectivityService initialized successfully');
    debugPrint(
      '🌾 [MAIN] Initializing EnhancedConnectivityService for rural environments...',
    );
    final enhancedConnectivity = di.sl<EnhancedConnectivityService>();
    final enhancedResult = await enhancedConnectivity.initialize(
      customPingHost: '1.1.1.1', // Cloudflare DNS for better rural access
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
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: StackTrace.current,
        reason: 'Failed to initialize connectivity services',
        fatal: false,
      );
    }
  }
  if (kDebugMode) {
    ReceitaAgroDataInspectorInitializer.initialize();
    DiagnosticoLogger.debug('Data Inspector initialization completed');
  }
  try {
    DiagnosticoLogger.debug('Forcing sync initialization...');
    await ReceitaAgroSyncConfig.configure();
    DiagnosticoLogger.debug('Sync initialization completed successfully');
    SyncDIModule.init(di.sl);
    await SyncDIModule.initializeSyncService(di.sl);
  } catch (e) {
    DiagnosticoLogger.debug('Sync initialization failed', e);
  }
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  try {
    final messagingService = di.sl<ReceitaAgroFirebaseMessagingService>();
    await messagingService.initialize();
    final promotionalManager = di.sl<PromotionalNotificationManager>();
    await promotionalManager.initialize();

    debugPrint('✅ [MAIN] Push notifications inicializados com sucesso');
  } catch (e) {
    debugPrint('❌ [MAIN] Erro ao inicializar push notifications: $e');
  }
  final remoteConfigService = di.sl<ReceitaAgroRemoteConfigService>();
  await remoteConfigService.initialize();
  try {
    final analyticsService = di.sl<ReceitaAgroAnalyticsService>();
    await analyticsService.initialize();
  } catch (e) {
    DiagnosticoLogger.debug('ReceitaAgroAnalyticsService not registered', e);
  }
  final premiumService = di.sl<ReceitaAgroPremiumService>();
  await premiumService.initialize();
  final notificationService = di.sl<IReceitaAgroNotificationService>();
  await notificationService.initialize();
  try {} catch (e) {
    if (EnvironmentConfig.enableAnalytics) {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: StackTrace.current,
        reason: 'Failed to initialize RevenueCat',
        fatal: false,
      );
    }
  }
  final dataManager = di.sl<IAppDataManager>();
  final dataResult = await dataManager.initialize();

  dataResult.fold(
    (error) {
      if (EnvironmentConfig.enableAnalytics) {
        _crashlyticsRepository.recordError(
          exception: error,
          stackTrace: StackTrace.current,
          fatal: false,
        );
      }
    },
    (_) {
      DiagnosticoLogger.serviceInit('AppDataManager', 'Hive pronto');
    },
  );
  // 🚀 CARREGAMENTO PRIORIZADO DE DADOS
  // Fase 1: Dados prioritários (bloqueante) - Culturas, Pragas, Fitossanitários
  try {
    DiagnosticoLogger.debug(
      '🚀 [PHASE 1] Carregando dados prioritários (culturas, pragas, fitossanitários)...',
    );
    await PrioritizedDataLoader.loadPriorityData();

    final isPriorityReady = await PrioritizedDataLoader.isPriorityDataReady();
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
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: StackTrace.current,
        reason: 'Priority data loading failed',
        fatal: false,
      );
    }
  }
  if (!kIsWeb) {
    await _performanceRepository.markFirstFrame();
  }

  // 🔄 FASE 2: Dados secundários (não-bloqueante) - Diagnósticos em background
  // Inicia carregamento mas NÃO aguarda - app já pode iniciar
  DiagnosticoLogger.debug(
    '⏳ [PHASE 2] Iniciando carregamento em background (diagnósticos)...',
  );
  PrioritizedDataLoader.loadBackgroundData();

  runApp(const ProviderScope(child: ReceitaAgroApp()));
}

/// Initialize Firebase services (Analytics, Crashlytics, Performance)
Future<void> _initializeFirebaseServices() async {
  try {
    debugPrint('🚀 Initializing Firebase services...');
    final analyticsRepository = di.sl<IAnalyticsRepository>();
    _crashlyticsRepository = di.sl<ICrashlyticsRepository>();
    _performanceRepository = di.sl<IPerformanceRepository>();
    if (EnvironmentConfig.enableAnalytics && !kIsWeb) {
      FlutterError.onError = (errorDetails) {
        _crashlyticsRepository.recordError(
          exception: errorDetails.exception,
          stackTrace: errorDetails.stack ?? StackTrace.empty,
          reason: errorDetails.summary.toString(),
          fatal: true,
        );
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlyticsRepository.recordError(
          exception: error,
          stackTrace: stack,
          fatal: true,
        );
        return true;
      };
    }
    await _crashlyticsRepository.setCustomKey(
      key: 'app_name',
      value: 'ReceitaAgro',
    );
    await _crashlyticsRepository.setCustomKey(
      key: 'environment',
      value: EnvironmentConfig.enableAnalytics ? 'production' : 'development',
    );
    if (!kIsWeb) {
      await _performanceRepository.startPerformanceTracking(
        config: const PerformanceConfig(
          enableFpsMonitoring: true,
          enableMemoryMonitoring: true,
          enableCpuMonitoring: false,
          enableFirebaseIntegration: true,
        ),
      );
      await _performanceRepository.markAppStarted();
    }
    await analyticsRepository.logEvent(
      'app_initialized',
      parameters: {
        'platform': kIsWeb ? 'web' : 'mobile',
        'environment':
            EnvironmentConfig.enableAnalytics ? 'production' : 'development',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    await _crashlyticsRepository.log(
      'ReceitaAgro app initialized successfully',
    );

    debugPrint('✅ Firebase services initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Error initializing Firebase services: $e');
    try {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Firebase services initialization failed',
      );
    } catch (_) {}
  }
}

class ReceitaAgroApp extends ConsumerWidget {
  const ReceitaAgroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Pragas Soja',
      theme: ReceitaAgroTheme.lightTheme,
      darkTheme: ReceitaAgroTheme.darkTheme,
      themeMode: themeMode,
      // ❌ REMOVIDO: builder com NavigationShell
      // NavigationShell precisa estar DENTRO do context do MaterialApp (após Overlay ser criado)
      // Solução: mover NavigationShell para dentro das páginas ou usar home
      initialRoute: '/home-defensivos',
      onGenerateRoute: app_router.AppRouter.generateRoute,
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
