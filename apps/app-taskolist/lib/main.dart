import 'package:core/core.dart' hide getIt, Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/providers/core_providers.dart';
import 'core/services/navigation_service.dart' as local_nav;
import 'core/services/notification_actions_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_test_helper.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/premium/presentation/promotional_page.dart';
import 'features/tasks/presentation/providers/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: kIsWeb ? const PromotionalPage() : const LoginPage(),
    );
  }
}
