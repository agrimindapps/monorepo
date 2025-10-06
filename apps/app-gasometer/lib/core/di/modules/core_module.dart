import 'package:core/core.dart' as core;
import 'package:core/core.dart' show GetIt;
import 'package:flutter/foundation.dart';

import '../../services/data_cleaner_service.dart';
import '../di_module.dart';

/// Core module responsible for external services and core infrastructure
///
/// Follows SRP: Single responsibility of core services registration
/// Follows OCP: Open for extension via DI module interface
class CoreModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    await _registerExternalServices(getIt);
    await _registerCoreServices(getIt);
  }

  Future<void> _registerExternalServices(GetIt getIt) async {
    try {
      getIt.registerLazySingleton<core.IAuthRepository>(
        () => core.FirebaseAuthService(),
      );

      getIt.registerLazySingleton<core.IAnalyticsRepository>(
        () =>
            kDebugMode
                ? core.MockAnalyticsService()
                : core.FirebaseAnalyticsService(),
      );

      getIt.registerLazySingleton<core.ICrashlyticsRepository>(
        () => core.FirebaseCrashlyticsService(),
      );

      getIt.registerLazySingleton<core.IPerformanceRepository>(
        () => core.PerformanceService(),
      );
      getIt.registerLazySingleton<core.EnhancedAnalyticsService>(
        () => core.EnhancedAnalyticsService(
          analytics: getIt<core.IAnalyticsRepository>(),
          crashlytics: getIt<core.ICrashlyticsRepository>(),
          config: core.AnalyticsConfig.forApp(
            appId: 'gasometer',
            version: '1.0.0',
          ),
        ),
      );

      debugPrint('✅ Core package repositories registered successfully');
    } catch (e) {
      debugPrint('⚠️ Warning: Could not register core repositories: $e');
    }
  }

  Future<void> _registerCoreServices(GetIt getIt) async {
    try {
      getIt.registerLazySingleton<core.FirebaseDeviceService>(
        () => core.FirebaseDeviceService(),
      );
      getIt.registerLazySingleton<core.FirebaseAuthService>(
        () => getIt<core.IAuthRepository>() as core.FirebaseAuthService,
      );
      getIt.registerLazySingleton<core.FirebaseAnalyticsService>(
        () =>
            getIt<core.IAnalyticsRepository>() as core.FirebaseAnalyticsService,
      );
      getIt.registerLazySingleton<core.ISubscriptionRepository>(
        () => core.RevenueCatService(),
      );
      getIt.registerLazySingleton<DataCleanerService>(
        () => DataCleanerService.instance,
      );

      debugPrint(
        '✅ Core package services registered for Injectable dependencies',
      );
    } catch (e) {
      debugPrint('⚠️ Warning: Could not register additional core services: $e');
    }

    debugPrint('✅ GasOMeter core services initialized');
  }
}
