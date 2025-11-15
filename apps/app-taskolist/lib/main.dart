import 'package:core/core.dart' hide getIt, Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/di/modules/account_deletion_module.dart';
import 'core/di/modules/sync_module.dart';
import 'core/services/navigation_service.dart' as local_nav;
import 'core/services/notification_actions_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_test_helper.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/premium/presentation/promotional_page.dart';
import 'features/tasks/presentation/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'infrastructure/services/analytics_service.dart';
import 'infrastructure/services/crashlytics_service.dart';
import 'infrastructure/services/notification_service.dart';
import 'infrastructure/services/performance_service.dart';
late ICrashlyticsRepository _crashlyticsRepository;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  _crashlyticsRepository = getIt<ICrashlyticsRepository>();
  if (!kIsWeb) {
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
  try {
    debugPrint('🔐 MAIN: Initializing account deletion module...');
    AccountDeletionModule.init(getIt);
    debugPrint('✅ MAIN: Account deletion module initialized successfully');
  } catch (e) {
    debugPrint('❌ MAIN: Account deletion initialization failed: $e');
  }
  try {
    debugPrint('🔄 MAIN: Forcing Taskolist sync initialization...');
    await TaskolistSyncDIModule.init();
    await TaskolistSyncDIModule.initializeSyncService();
    debugPrint('✅ MAIN: Taskolist sync initialization completed successfully');
  } catch (e) {
    debugPrint('❌ MAIN: Sync initialization failed: $e');
  }
  await _initializeFirebaseServices();
  final providerContainer = ProviderContainer();
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
    final analyticsService = getIt<TaskManagerAnalyticsService>();
    final crashlyticsService = getIt<TaskManagerCrashlyticsService>();
    final performanceService = getIt<TaskManagerPerformanceService>();
    final notificationService = getIt<TaskManagerNotificationService>();
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
      await _crashlyticsRepository.recordError(
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
