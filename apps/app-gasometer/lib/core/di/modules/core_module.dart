import 'package:core/core.dart' as core;
import 'package:core/core.dart' show GetIt;
import 'package:flutter/foundation.dart';

import '../di_module.dart';

/// Core module responsible for external services and core infrastructure
///
/// Follows SRP: Single responsibility of core services registration
/// Follows OCP: Open for extension via DI module interface
class CoreModule implements DIModule {
  final bool firebaseEnabled;

  CoreModule({this.firebaseEnabled = false});

  @override
  Future<void> register(GetIt getIt) async {
    await _registerExternalServices(getIt);
    await _registerCoreServices(getIt);
  }

  Future<void> _registerExternalServices(GetIt getIt) async {
    // Register Firebase services only if Firebase is initialized
    if (firebaseEnabled) {
      try {
        // NOTE: These may already be registered via @injectable in injection.config.dart
        // Only register if not already present to avoid duplicate registration errors
        if (!getIt.isRegistered<core.IAuthRepository>()) {
          getIt.registerLazySingleton<core.IAuthRepository>(
            () => core.FirebaseAuthService(),
          );
        }

        if (!getIt.isRegistered<core.IAnalyticsRepository>()) {
          getIt.registerLazySingleton<core.IAnalyticsRepository>(
            () => core.FirebaseAnalyticsService(),
          );
        }

        if (!getIt.isRegistered<core.ICrashlyticsRepository>()) {
          getIt.registerLazySingleton<core.ICrashlyticsRepository>(
            () => core.FirebaseCrashlyticsService(),
          );
        }

        if (!getIt.isRegistered<core.IPerformanceRepository>()) {
          getIt.registerLazySingleton<core.IPerformanceRepository>(
            () => core.PerformanceService(),
          );
        }

        if (!getIt.isRegistered<core.EnhancedAnalyticsService>()) {
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
        }

        debugPrint('✅ Core package repositories registered successfully');
      } catch (e) {
        debugPrint('⚠️ Warning: Could not register core repositories: $e');
      }
    } else {
      debugPrint(
        '⚠️ Firebase services not registered (running in local-only mode)',
      );
    }
  }

  Future<void> _registerCoreServices(GetIt getIt) async {
    try {
      // Firebase-dependent services
      if (firebaseEnabled) {
        // Only register if not already present (avoid duplicates)
        if (!getIt.isRegistered<core.FirebaseDeviceService>()) {
          getIt.registerLazySingleton<core.FirebaseDeviceService>(
            () => core.FirebaseDeviceService(),
          );
        }

        if (!getIt.isRegistered<core.FirebaseAuthService>()) {
          getIt.registerLazySingleton<core.FirebaseAuthService>(
            () => getIt<core.IAuthRepository>() as core.FirebaseAuthService,
          );
        }

        if (!getIt.isRegistered<core.FirebaseAnalyticsService>()) {
          getIt.registerLazySingleton<core.FirebaseAnalyticsService>(
            () =>
                getIt<core.IAnalyticsRepository>()
                    as core.FirebaseAnalyticsService,
          );
        }
        // Note: FirebaseDeviceService já implementa IDeviceRepository
        // mas não podemos fazer cast direto, então criamos nova instância
      }

      // RevenueCat and local services (don't require Firebase)
      if (!getIt.isRegistered<core.ISubscriptionRepository>()) {
        getIt.registerLazySingleton<core.ISubscriptionRepository>(
          () => core.RevenueCatService(),
        );
      }
      // DataCleanerService is registered via Injectable (@lazySingleton)

      debugPrint(
        '✅ Core package services registered for Injectable dependencies',
      );
    } catch (e) {
      debugPrint('⚠️ Warning: Could not register additional core services: $e');
    }

    debugPrint('✅ GasOMeter core services initialized');
  }
}
