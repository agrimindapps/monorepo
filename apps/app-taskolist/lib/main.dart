import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart' hide getIt;

import 'core/database/hive_config.dart';
import 'core/di/injection.dart';
import 'core/di/modules/account_deletion_module.dart';
import 'core/di/modules/sync_module.dart';
import 'core/services/navigation_service.dart' as local_nav;
import 'core/services/notification_actions_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_test_helper.dart';
import 'firebase_options.dart';
import 'infrastructure/services/analytics_service.dart';
import 'infrastructure/services/crashlytics_service.dart';
import 'infrastructure/services/notification_service.dart';
import 'infrastructure/services/performance_service.dart';
import 'features/premium/presentation/promotional_page.dart';
import 'features/tasks/presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configurar Crashlytics para capturar erros Flutter
  if (!kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Inicializar Hive
  await HiveConfig.initialize();

  // Inicializar Dependency Injection
  await configureDependencies();

  // ===== ACCOUNT DELETION INITIALIZATION =====
  // Initialize account deletion module after DI is ready
  try {
    print('🔐 MAIN: Initializing account deletion module...');
    AccountDeletionModule.init(getIt);
    print('✅ MAIN: Account deletion module initialized successfully');
  } catch (e) {
    print('❌ MAIN: Account deletion initialization failed: $e');
  }

  // ===== SYNC INITIALIZATION =====
  // Force sync initialization after DI is ready
  try {
    print('🔄 MAIN: Forcing Taskolist sync initialization...');
    TaskolistSyncDIModule.init();
    await TaskolistSyncDIModule.initializeSyncService();
    print('✅ MAIN: Taskolist sync initialization completed successfully');
  } catch (e) {
    print('❌ MAIN: Sync initialization failed: $e');
  }

  // Inicializar serviços Firebase
  await _initializeFirebaseServices();

  // Criar ProviderScope e inicializar serviços de navegação
  final providerContainer = ProviderContainer();

  // Inicializar serviços com container
  local_nav.NavigationService.initialize(providerContainer);
  NotificationActionsService.initialize(providerContainer);

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: const TaskManagerApp(),
    ),
  );
}

Future<void> _initializeFirebaseServices() async {
  try {
    // Obter serviços do DI container
    final analyticsService = getIt<TaskManagerAnalyticsService>();
    final crashlyticsService = getIt<TaskManagerCrashlyticsService>();
    final performanceService = getIt<TaskManagerPerformanceService>();
    final notificationService = getIt<TaskManagerNotificationService>();

    // Configurar contexto inicial do Crashlytics
    await crashlyticsService.setTaskManagerContext(
      userId: 'anonymous', // Será atualizado quando usuário fizer login
      version: '1.0.0',
      environment: kDebugMode ? 'debug' : 'production',
    );

    // Marcar início da aplicação para Performance
    await performanceService.markAppStarted();

    // Iniciar monitoramento de performance
    await performanceService.startPerformanceTracking();

    // Inicializar serviço de notificações
    final notificationInitialized = await notificationService.initialize();
    if (notificationInitialized) {
      // Solicitar permissões de notificação
      await notificationService.requestPermissions();

      // Configurar handlers de notificação
      notificationService.setupNotificationHandlers(
        onNotificationTap: _handleNotificationTap,
        onNotificationAction: _handleNotificationAction,
      );
    }

    // Log de inicialização bem-sucedida
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

    // Em modo debug, executar testes de notificação após 5 segundos
    if (kDebugMode && notificationInitialized) {
      Future<void>.delayed(const Duration(seconds: 5), () {
        debugPrint('🧪 Starting notification workflow tests...');
        NotificationTestHelper.runAllTests(notificationService);
      });
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error initializing Firebase services: $e');

    // Registrar erro mesmo se os serviços não estiverem totalmente configurados
    try {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Firebase services initialization failed',
      );
    } catch (_) {
      // Ignorar se Crashlytics também falhou
    }
  }
}

/// Manipula quando uma notificação é tocada
void _handleNotificationTap(String? payload) {
  debugPrint('🔔 Notification tapped: $payload');

  if (payload != null) {
    // Usar NavigationService para gerenciar navegação
    local_nav.NavigationService.navigateFromNotification(payload);
  }
}

/// Manipula quando uma ação de notificação é executada
void _handleNotificationAction(String actionId, String? payload) {
  debugPrint('🔔 Notification action: $actionId, payload: $payload');

  // Usar NotificationActionsService para executar ações
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
      home: const PromotionalPage(),
    );
  }
}
