import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'core/database/hive_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/widgets/auth_guard.dart';
import 'presentation/providers/theme_provider.dart';
import 'infrastructure/services/analytics_service.dart';
import 'infrastructure/services/crashlytics_service.dart';
import 'infrastructure/services/performance_service.dart';
import 'infrastructure/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

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

  runApp(const ProviderScope(child: TaskManagerApp()));
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
    // Navegar baseado no payload
    if (payload.startsWith('task_reminder:')) {
      final taskId = payload.split(':')[1];
      // TODO: Navegar para a tarefa específica
      debugPrint('Navigate to task: $taskId');
    } else if (payload.startsWith('task_deadline:')) {
      final taskId = payload.split(':')[1];
      // TODO: Navegar para a tarefa com foco no deadline
      debugPrint('Navigate to task deadline: $taskId');
    } else if (payload == 'weekly_review') {
      // TODO: Navegar para página de revisão semanal
      debugPrint('Navigate to weekly review');
    } else if (payload == 'daily_productivity') {
      // TODO: Navegar para página principal com foco em produtividade
      debugPrint('Navigate to productivity view');
    }
  }
}

/// Manipula quando uma ação de notificação é executada
void _handleNotificationAction(String actionId, String? payload) {
  debugPrint('🔔 Notification action: $actionId, payload: $payload');
  
  if (payload != null && (payload.startsWith('task_reminder:') || payload.startsWith('task_deadline:'))) {
    final taskId = payload.split(':')[1];
    
    switch (actionId) {
      case 'mark_done':
        // TODO: Marcar tarefa como concluída
        debugPrint('Mark task as done: $taskId');
        break;
      case 'snooze_1h':
        // TODO: Reagendar lembrete para 1 hora
        debugPrint('Snooze task for 1 hour: $taskId');
        break;
      case 'extend_deadline':
        // TODO: Abrir dialog para estender deadline
        debugPrint('Extend deadline for task: $taskId');
        break;
    }
  }
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
      home: const AuthGuard(
        child: HomePage(),
      ),
    );
  }
}
