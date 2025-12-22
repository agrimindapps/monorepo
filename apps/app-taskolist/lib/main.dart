import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/providers/core_providers.dart';
import 'core/services/navigation_service.dart' as local_nav;
import 'core/services/notification_actions_service.dart';
import 'core/sync/taskolist_sync_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_test_helper.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/subscription/data/revenue_cat_service.dart';
import 'features/tasks/presentation/providers/recurrence_processor_provider.dart';
import 'features/tasks/presentation/providers/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🧪 AUTO-LOGIN para desenvolvimento (apenas em debug mode)
  if (kDebugMode) {
    await _performAutoLogin();
  }

  // Create ProviderContainer
  final providerContainer = ProviderContainer();

  // Get crashlytics repository from Riverpod
  final crashlyticsRepository = providerContainer.read(crashlyticsRepositoryProvider);
  if (!kIsWeb) {
    FlutterError.onError = (errorDetails) {
      crashlyticsRepository.recordError(
        exception: errorDetails.exception,
        stackTrace: errorDetails.stack ?? StackTrace.empty,
        reason: errorDetails.summary.toString(),
        fatal: true,
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlyticsRepository.recordError(
        exception: error,
        stackTrace: stack,
        fatal: true,
      );
      return true;
    };
  }

  // Initialize Firebase services
  await _initializeFirebaseServices(providerContainer);

  // Initialize RevenueCat
  if (kDebugMode) {
    await _initializeRevenueCat(providerContainer);
  }

  // Initialize UnifiedSyncManager with Taskolist configuration
  await TaskolistSyncConfig.configure();
  
  // Wait for auth state to propagate to sync services
  await Future<void>.delayed(const Duration(milliseconds: 500));
  debugPrint('✅ [MAIN] TaskolistSyncConfig initialized');

  // Process recurring tasks on app start
  try {
    await providerContainer.read(recurrenceProcessorProvider.future);
    debugPrint('✅ [MAIN] Recurring tasks processed');
  } catch (e) {
    debugPrint('⚠️ [MAIN] Error processing recurring tasks: $e');
  }

  // Initialize navigation and notification services
  local_nav.NavigationService.initialize(providerContainer);
  NotificationActionsService.initialize(providerContainer);

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: const TaskManagerApp(),
    ),
  );
}

Future<void> _initializeFirebaseServices(ProviderContainer container) async {
  try {
    final analyticsService = container.read(taskManagerAnalyticsServiceProvider);
    final crashlyticsService = container.read(taskManagerCrashlyticsServiceProvider);
    final performanceService = container.read(taskManagerPerformanceServiceProvider);
    final notificationService = container.read(taskManagerNotificationServiceProvider);
    await crashlyticsService.setTaskManagerContext(
      userId: 'anonymous', // Será atualizado quando usuário fizer login
      version: '1.0.0',
      environment: kDebugMode ? 'debug' : 'production',
    );
    await performanceService.markAppStarted();
    await performanceService.startPerformanceTracking();
    final notificationInitialized = await notificationService.initialize();
    if (notificationInitialized) {
      await notificationService.requestPermissions();
      notificationService.setupNotificationHandlers(
        onNotificationTap: _handleNotificationTap,
        onNotificationAction: _handleNotificationAction,
      );
    }
    await crashlyticsService.log('App initialized successfully');
    await analyticsService.logEvent(
      'app_initialized',
      parameters: {
        'platform': 'flutter',
        'environment': kDebugMode ? 'debug' : 'production',
        'notifications_enabled': notificationInitialized,
      },
    );

    debugPrint('🚀 Firebase services initialized successfully');
    if (kDebugMode && notificationInitialized) {
      Future<void>.delayed(const Duration(seconds: 5), () {
        debugPrint('🧪 Starting notification workflow tests...');
        NotificationTestHelper.runAllTests(notificationService);
      });
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error initializing Firebase services: $e');
    try {
      final crashlyticsRepository = container.read(crashlyticsRepositoryProvider);
      await crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Firebase services initialization failed',
      );
    } catch (_) {
    }
  }
}

Future<void> _initializeRevenueCat(ProviderContainer container) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      final revenueCatService = container.read(revenueCatServiceProvider);
      await revenueCatService.initialize(currentUser.uid);
      debugPrint('✅ [RevenueCat] Inicializado com userId: ${currentUser.uid}');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ [RevenueCat] Erro ao inicializar: $e');
    try {
      final crashlyticsRepository = container.read(crashlyticsRepositoryProvider);
      await crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'RevenueCat initialization failed',
      );
    } catch (_) {}
  }
}

/// Manipula quando uma notificação é tocada
void _handleNotificationTap(String? payload) {
  debugPrint('🔔 Notification tapped: $payload');

  if (payload != null) {
    local_nav.NavigationService.navigateFromNotification(payload);
  }
}

/// Manipula quando uma ação de notificação é executada
void _handleNotificationAction(String actionId, String? payload) {
  debugPrint('🔔 Notification action: $actionId, payload: $payload');
  NotificationActionsService.executeNotificationAction(actionId, payload);
}

class TaskManagerApp extends ConsumerWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(flutterThemeModeProvider);

    return MaterialApp(
      title: 'Task Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorKey: local_nav.NavigationService.navigatorKey,
      home: const AuthGate(),
    );
  }
}

/// Auto-login para desenvolvimento (apenas em kDebugMode)
/// Facilita testes sem precisar digitar credenciais manualmente
Future<void> _performAutoLogin() async {
  try {
    final auth = FirebaseAuth.instance;

    // Se já está logado, não faz nada
    if (auth.currentUser != null) {
      debugPrint(
        '🧪 [TASKOLIST-AUTO-LOGIN] Já autenticado como: ${auth.currentUser!.email}',
      );
      return;
    }

    // Credenciais de desenvolvimento
    const devEmail = 'lucineiy@hotmail.com';
    const devPassword = 'QWEqwe@123';

    debugPrint('🧪 [TASKOLIST-AUTO-LOGIN] Iniciando auto-login...');

    final userCredential = await auth.signInWithEmailAndPassword(
      email: devEmail,
      password: devPassword,
    );

    if (userCredential.user != null) {
      debugPrint(
        '✅ [TASKOLIST-AUTO-LOGIN] Login automático bem-sucedido! '
        'Usuário: ${userCredential.user!.email}',
      );
    }
  } catch (e, stackTrace) {
    debugPrint('❌ [TASKOLIST-AUTO-LOGIN] Falha no auto-login: $e');
    debugPrint('Stack: $stackTrace');
    
    // Em caso de erro, tenta login anônimo como fallback
    try {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('⚠️ [TASKOLIST-AUTO-LOGIN] Fallback para login anônimo');
    } catch (e2) {
      debugPrint('❌ [TASKOLIST-AUTO-LOGIN] Falha no fallback anônimo: $e2');
    }
  }
}
