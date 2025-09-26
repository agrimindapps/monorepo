import 'package:core/core.dart';
import 'package:core/core.dart' as core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart' as di;
import 'core/services/receituagro_navigation_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/sync/receituagro_sync_config.dart';
import 'core/providers/feature_flags_provider.dart';
import 'core/providers/preferences_provider.dart';
import 'core/providers/remote_config_provider.dart';
import 'core/utils/theme_preference_migration.dart';
import 'features/analytics/analytics_service.dart';
import 'features/settings/presentation/providers/profile_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/services/app_data_manager.dart';
import 'core/services/culturas_data_loader.dart';
import 'core/services/diagnosticos_data_loader.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/premium_service.dart';
import 'core/services/promotional_notification_manager.dart';
import 'core/services/receituagro_notification_service.dart';
import 'core/services/remote_config_service.dart';
// navigation_service.dart moved to core package - available via 'package:core/core.dart'
// Emergency stub removed
// revenuecat_service.dart removed - consolidated into premium_service.dart
// startup_optimization_service.dart removed - unused
import 'core/setup/receituagro_data_setup.dart';
import 'core/theme/receituagro_theme.dart';
import 'core/inspector/receita_agro_data_inspector_initializer.dart';
import 'features/navigation/main_navigation_page.dart';
import 'firebase_options.dart';

/// Handler para mensagens em background (deve ser top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  // Processar mensagem em background se necessário
}

void main() async {
  // Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Migrate theme preferences from app-specific to core package
  await ThemePreferenceMigration.migratePreferences();

  // Sign in anonymously if no user is logged in
  // This ensures the app works even without user authentication
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously();
    } catch (e) {
      // Log error but don't block app startup
      if (EnvironmentConfig.enableAnalytics) {
        await FirebaseCrashlytics.instance.recordError(
          e,
          StackTrace.current,
          reason: 'Failed to sign in anonymously',
          fatal: false,
        );
      }
    }
  }

  // Initialize Performance Service
  final performanceService = PerformanceService();

  // Start performance tracking (only for mobile platforms)
  if (!kIsWeb) {
    await performanceService.startPerformanceTracking(
      config: const PerformanceConfig(
        enableFpsMonitoring: true,
        enableMemoryMonitoring: true,
        enableCpuMonitoring: false,
        enableFirebaseIntegration: true,
      ),
    );
    await performanceService.markAppStarted();
  }

  // Configure Crashlytics (only in production/staging and not on web)
  if (EnvironmentConfig.enableAnalytics && !kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Initialize dependency injection
  await di.init();

  // ===== CONNECTIVITY INITIALIZATION =====
  // Initialize ConnectivityService for agricultural operations with poor network
  try {
    debugPrint('🌐 [MAIN] Initializing ConnectivityService...');
    await ConnectivityService.instance.initialize();
    debugPrint('✅ [MAIN] ConnectivityService initialized successfully');

    // Initialize EnhancedConnectivityService for rural optimization
    debugPrint('🌾 [MAIN] Initializing EnhancedConnectivityService for rural environments...');
    final enhancedConnectivity = di.sl<core.EnhancedConnectivityService>();
    final enhancedResult = await enhancedConnectivity.initialize(
      customPingHost: '1.1.1.1', // Cloudflare DNS for better rural access
      enableQualityMonitoring: true,
      qualityCheckInterval: const Duration(minutes: 2),
    );

    enhancedResult.fold(
      (error) => debugPrint('❌ [MAIN] EnhancedConnectivityService initialization failed: ${error.message}'),
      (_) => debugPrint('✅ [MAIN] EnhancedConnectivityService initialized for agricultural operations'),
    );

  } catch (e) {
    debugPrint('❌ [MAIN] Connectivity services initialization failed: $e');
    // Don't block app startup - connectivity will be handled gracefully
    if (EnvironmentConfig.enableAnalytics) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to initialize connectivity services',
        fatal: false,
      );
    }
  }

  // Initialize Data Inspector (debug mode only)
  if (kDebugMode) {
    ReceitaAgroDataInspectorInitializer.initialize();
    debugPrint('🔍 Data Inspector initialized for ReceitaAgro');
  }

  // ===== SYNC INITIALIZATION =====
  // Force sync initialization after DI is ready
  try {
    print('🔄 MAIN: Forcing sync initialization...');
    await ReceitaAgroSyncConfig.configure();
    print('✅ MAIN: Sync initialization completed successfully');
  } catch (e) {
    print('❌ MAIN: Sync initialization failed: $e');
  }

  // ===== PUSH NOTIFICATIONS INITIALIZATION =====
  // Configurar handler para mensagens em background
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inicializar Firebase Messaging Service
  try {
    final messagingService = di.sl<ReceitaAgroFirebaseMessagingService>();
    final navigationService = di.sl<ReceitaAgroNavigationService>();
    await messagingService.initialize();

    // Inicializar Promotional Notification Manager
    final promotionalManager = di.sl<PromotionalNotificationManager>();
    await promotionalManager.initialize();

    debugPrint('✅ [MAIN] Push notifications inicializados com sucesso');
  } catch (e) {
    debugPrint('❌ [MAIN] Erro ao inicializar push notifications: $e');
    // Não bloquear o app por falha nas notificações
  }

  // ===== SPRINT 1 SERVICES INITIALIZATION =====

  // Initialize Remote Config Service
  final remoteConfigService = di.sl<ReceitaAgroRemoteConfigService>();
  await remoteConfigService.initialize();

  // Initialize Analytics Service
  try {
    final analyticsService = di.sl<ReceitaAgroAnalyticsService>();
    await analyticsService.initialize();
  } catch (e) {
    if (kDebugMode) print('❌ [MAIN] ReceitaAgroAnalyticsService not registered: $e');
    // Analytics service will be initialized later when properly registered
  }

  // Initialize Premium Service (handles web platform internally)
  final premiumService = di.sl<ReceitaAgroPremiumService>();
  await premiumService.initialize();

  // 🚀 PERFORMANCE OPTIMIZATION: Startup optimization service removed
  // Image optimization now handled by OptimizedImageService in core package
  // Lazy loading implemented at widget level

  // Initialize storage service - Using consolidated storage service
  // Emergency stub removed - using main storage service
  // final storageService = di.sl<ReceitaAgroStorageService>();
  // await storageService.initialize();

  // Initialize notifications
  final notificationService = di.sl<IReceitaAgroNotificationService>();
  await notificationService.initialize();

  // Initialize RevenueCat (now handled by premium_service.dart)
  try {
    // RevenueCat initialization moved to premium_service.dart
    // await local_rc.RevenueCatService.initialize(); // Removed - consolidated
  } catch (e) {
    // Log error but don't block app startup
    if (EnvironmentConfig.enableAnalytics) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to initialize RevenueCat',
        fatal: false,
      );
    }
  }

  // Initialize data system
  final dataManager = di.sl<IAppDataManager>();
  final dataResult = await dataManager.initialize();

  dataResult.fold(
    (error) {
      // Log error but don't block app startup
      if (EnvironmentConfig.enableAnalytics) {
        FirebaseCrashlytics.instance.recordError(
          error,
          StackTrace.current,
          fatal: false,
        );
      }
    },
    (_) {
      // Data initialization successful - Now safe to initialize ReceitaAgroDataSetup
      print('✅ [MAIN] AppDataManager inicializado com sucesso - Hive pronto');
    },
  );

  // FIXED: ReceitaAgro data initialization moved AFTER AppDataManager initialization
  try {
    print('🔧 [FIXED] Iniciando ReceitaAgroDataSetup após AppDataManager...');
    await ReceitaAgroDataSetup.initialize();
    print('✅ [MAIN] ReceitaAgroDataSetup concluído com sucesso');

    // DEBUG: Verificar se diagnósticos foram carregados
    print('🔍 [DEBUG] Verificando status dos diagnósticos após setup...');
    final diagnosticosStats = await DiagnosticosDataLoader.getStats();
    print('📊 [DEBUG] Diagnósticos Stats: $diagnosticosStats');

    // Se não há diagnósticos, tentar forçar carregamento
    if (diagnosticosStats['total_diagnosticos'] == 0) {
      print(
        '⚠️ [DEBUG] Nenhum diagnóstico encontrado, forçando carregamento...',
      );
      try {
        await DiagnosticosDataLoader.forceReload();
        final newStats = await DiagnosticosDataLoader.getStats();
        print('🔄 [DEBUG] Diagnósticos após reload forçado: $newStats');
      } catch (reloadError) {
        print('❌ [DEBUG] Erro no reload forçado: $reloadError');
      }
    }
  } catch (e) {
    print(
      '⚠️ [MAIN] ReceitaAgroDataSetup falhou, mas AppDataManager já carregou os dados: $e',
    );
    print('🔧 [DEBUG] Stack trace do erro: ${StackTrace.current}');
    // Log error but don't block app startup - AppDataManager already loaded the data
    if (EnvironmentConfig.enableAnalytics) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'ReceitaAgroDataSetup failed but AppDataManager succeeded',
        fatal: false,
      );
    }
  }

  // 🌱 CULTURAS: Loading culturas data from repository
  print('🌱 [MAIN] Carregando dados de culturas...');
  await CulturasDataLoader.loadCulturasData();
  print('🌱 [MAIN] Dados de culturas carregados com sucesso.');

  // Mark first frame before running app
  if (!kIsWeb) {
    await performanceService.markFirstFrame();
  }

  // Run app (zone guarding handled by Flutter error handlers)
  runApp(const ReceitaAgroApp());
}

class ReceitaAgroApp extends StatelessWidget {
  const ReceitaAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(
          create: (_) => PreferencesProvider()..initialize(),
        ),
        // Auth Provider from Core Package Integration
        ChangeNotifierProvider(create: (_) => di.sl<ReceitaAgroAuthProvider>()),
        // Sprint 1 Providers
        ChangeNotifierProvider(
          create: (_) => di.sl<RemoteConfigProvider>()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<FeatureFlagsProvider>()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<ReceitaAgroPremiumService>(),
        ),
        // Profile Provider for user profile management
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
        // Settings Provider for device management and settings
        ChangeNotifierProvider(create: (_) => di.sl<SettingsProvider>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Pragas Soja',
            theme: ReceitaAgroTheme.lightTheme,
            darkTheme: ReceitaAgroTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationPage(),
            navigatorKey: NavigationService.navigatorKey,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
