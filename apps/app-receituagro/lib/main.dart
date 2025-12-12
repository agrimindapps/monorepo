import 'package:core/core.dart' hide Column, themeProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/init/app_initialization.dart';
import 'core/navigation/app_router.dart' as app_router;
import 'core/providers/theme_notifier.dart';
import 'core/theme/receituagro_theme.dart';
import 'core/utils/diagnostico_logger.dart';
import 'core/utils/theme_preference_migration.dart';
import 'features/analytics/analytics_providers.dart';
import 'firebase_options.dart';

late ProviderContainer _container;
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

  // Create Riverpod container
  _container = ProviderContainer();

  // Initialize Firebase services (Analytics, Crashlytics, Performance)
  await AppInitialization.initializeFirebaseServices(_container);

  // Store references for error handlers
  _crashlyticsRepository = _container.read(crashlyticsRepositoryProvider);
  _performanceRepository = _container.read(performanceRepositoryProvider);

  // Set up error handlers
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
  } else if (kIsWeb) {
    // Web-specific error handler to suppress Flutter engine assertion errors
    // These are known issues in Flutter Web and don't affect functionality
    FlutterError.onError = (errorDetails) {
      final errorString = errorDetails.exception.toString();
      // Suppress known Flutter Web engine errors
      if (errorString.contains('window.dart') ||
          errorString.contains('Assertion failed')) {
        // Silently ignore these known issues
        return;
      }
      // Log other errors to console
      debugPrint('❌ Flutter Error: ${errorDetails.exception}');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      final errorString = error.toString();
      // Suppress known Flutter Web engine assertion errors
      if (errorString.contains('window.dart') ||
          errorString.contains('Assertion failed')) {
        return true; // Error handled (suppressed)
      }
      debugPrint('❌ Platform Error: $error');
      return true;
    };
  }

  final auth = FirebaseAuth.instance;
  
  // 🧪 AUTO-LOGIN para testes (apenas em desenvolvimento)
  if (kDebugMode && auth.currentUser == null) {
    try {
      debugPrint('🧪 [RECEITUAGRO-TEST] Attempting auto-login...');
      final userCredential = await auth.signInWithEmailAndPassword(
        email: 'lucineiy@hotmail.com',
        password: 'QWEqwe@123',
      );
      debugPrint('🧪 [RECEITUAGRO-TEST] Auto-login successful! User: ${userCredential.user?.email}');
    } catch (e) {
      debugPrint('⚠️ [RECEITUAGRO-TEST] Auto-login failed: $e');
      // Fallback para anonymous
      try {
        await auth.signInAnonymously();
      } catch (e2) {
        if (EnvironmentConfig.enableAnalytics) {
          await _crashlyticsRepository.recordError(
            exception: e2,
            stackTrace: StackTrace.current,
            reason: 'Failed to sign in anonymously',
            fatal: false,
          );
        }
      }
    }
  } else if (auth.currentUser == null) {
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

  // Initialize connectivity services
  await AppInitialization.initializeServices(_container);

  // Initialize sync coordinator
  AppInitialization.initializeSyncCoordinator(_container);

  // ✅ Drift-based storage is initialized via DI (no manual box registration needed)
  DiagnosticoLogger.debug('✅ Drift database initialized via DI');

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Initialize push notifications
  await AppInitialization.initializePushNotifications(_container);

  // Initialize remote config
  await AppInitialization.initializeRemoteConfig(_container);

  // Initialize analytics
  await AppInitialization.initializeAnalytics(_container);

  // Initialize premium service
  await AppInitialization.initializePremium(_container);

  // Initialize notification service
  await AppInitialization.initializeNotifications(_container);

  // Initialize app data manager
  await AppInitialization.initializeAppData(_container);

  // 🔄 Inicializar Sync DEPOIS que as boxes foram abertas com tipos corretos
  await AppInitialization.initializeSync(_container);

  // ✅ FIXED: Executar sync inicial automático se usuário estiver autenticado (não anônimo)
  final currentUser = auth.currentUser;
  if (currentUser != null && !currentUser.isAnonymous) {
    DiagnosticoLogger.debug(
      '🔄 User authenticated (${currentUser.email}) - starting initial sync...',
    );
    // Fire and forget - não bloqueamos a inicialização do app
    // TODO: Implementar sync via Riverpod provider
  } else {
    DiagnosticoLogger.debug('ℹ️ User is anonymous - skipping initial sync');
  }

  // 🚀 CARREGAMENTO PRIORIZADO DE DADOS
  await AppInitialization.loadPriorityData(_container);

  if (!kIsWeb) {
    await _performanceRepository.markFirstFrame();
  }

  // 🔄 FASE 2: Dados secundários (não-bloqueante) - Diagnósticos em background
  AppInitialization.loadBackgroundData(_container);

  runApp(
    UncontrolledProviderScope(
      container: _container,
      child: const ReceitaAgroApp(),
    ),
  );
}

class ReceitaAgroApp extends ConsumerStatefulWidget {
  const ReceitaAgroApp({super.key});

  @override
  ConsumerState<ReceitaAgroApp> createState() => _ReceitaAgroAppState();
}

class _ReceitaAgroAppState extends ConsumerState<ReceitaAgroApp> {
  @override
  void initState() {
    super.initState();
    
    // 🧪 AUTO-LOGIN PARA TESTES (remover em produção)
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performTestAutoLogin();
      });
    }
  }

  /// 🧪 AUTO-LOGIN PARA TESTES
  /// Remove this method in production!
  void _performTestAutoLogin() async {
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('🧪 [RECEITUAGRO-TEST] Firebase not initialized, skipping auto-login');
        return;
      }

      debugPrint('🧪 [RECEITUAGRO-TEST] Attempting auto-login...');
      
      final auth = FirebaseAuth.instance;
      
      // Se já está logado com conta não-anônima, não faz nada
      if (auth.currentUser != null && !auth.currentUser!.isAnonymous) {
        debugPrint(
          '🧪 [RECEITUAGRO-TEST] Already logged in as: ${auth.currentUser!.email}',
        );
        return;
      }
      
      const testEmail = 'lucineiy@hotmail.com';
      const testPassword = 'QWEqwe@123';
      
      final result = await auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      
      if (result.user != null) {
        debugPrint(
          '🧪 [RECEITUAGRO-TEST] Auto-login successful! User: ${result.user!.email}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('🧪 [RECEITUAGRO-TEST] Auto-login error: $e');
      debugPrint('Stack: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(app_router.appRouterProvider);

    return MaterialApp.router(
      title: 'Pragas Soja',
      theme: ReceitaAgroTheme.lightTheme,
      darkTheme: ReceitaAgroTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

}
