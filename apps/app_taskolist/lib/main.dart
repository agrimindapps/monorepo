import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/hive_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/navigation_service.dart';
import 'core/services/notification_actions_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_test_helper.dart';
import 'firebase_options.dart';
import 'infrastructure/services/analytics_service.dart';
import 'infrastructure/services/crashlytics_service.dart';
import 'infrastructure/services/notification_service.dart';
import 'infrastructure/services/performance_service.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/widgets/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  await di.init();

  // Inicializar serviços Firebase
  await _initializeFirebaseServices();

  // Criar ProviderScope e inicializar serviços de navegação
  final providerContainer = ProviderContainer();

  // Inicializar serviços com container
  NavigationService.initialize(providerContainer);
  NotificationActionsService.initialize(providerContainer);

  runApp(UncontrolledProviderScope(
    container: providerContainer,
    child: const TaskManagerApp(),
  ));
}

Future<void> _initializeFirebaseServices() async {
  try {
    // Obter serviços do DI container
    final analyticsService = di.sl<TaskManagerAnalyticsService>();
    final crashlyticsService = di.sl<TaskManagerCrashlyticsService>();
    final performanceService = di.sl<TaskManagerPerformanceService>();
    final notificationService = di.sl<TaskManagerNotificationService>();

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
    await analyticsService.logEvent('app_initialized', parameters: {
      'platform': 'flutter',
      'environment': kDebugMode ? 'debug' : 'production',
      'notifications_enabled': notificationInitialized,
    });

    debugPrint('🚀 Firebase services initialized successfully');

    // Em modo debug, executar testes de notificação após 5 segundos
    if (kDebugMode && notificationInitialized) {
      Future.delayed(const Duration(seconds: 5), () {
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
    NavigationService.navigateFromNotification(payload);
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
      navigatorKey: NavigationService.navigatorKey,
      home: const AuthGuard(
        child: HomePage(),
      ),
    );
  }
}
