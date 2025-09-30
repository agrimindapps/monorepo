import 'package:core/core.dart' as core;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

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
    // PHASE 1 MIGRATION: Register both direct Firebase services AND core repositories
    // This allows gradual migration without breaking existing code

    // Direct Firebase services (existing code compatibility)
    getIt.registerLazySingleton<FirebaseAnalytics>(
      () => FirebaseAnalytics.instance,
    );

    getIt.registerLazySingleton<FirebaseCrashlytics>(
      () => FirebaseCrashlytics.instance,
    );

    // NOTE: FirebaseFirestore and FirebaseAuth are now registered by injectable
    // via RegisterModule to avoid duplicate registration errors
    // They are available via RegisterModule.firestore and RegisterModule.firebaseAuth

    // Core package repositories (new migration path)
    // These will be used by new code and gradual migration
    try {
      getIt.registerLazySingleton<core.IAuthRepository>(
        () => core.FirebaseAuthService(),
      );

      getIt.registerLazySingleton<core.IAnalyticsRepository>(
        () => kDebugMode
            ? core.MockAnalyticsService()
            : core.FirebaseAnalyticsService(),
      );

      getIt.registerLazySingleton<core.ICrashlyticsRepository>(
        () => core.FirebaseCrashlyticsService(),
      );

      // Register EnhancedAnalyticsService with app-specific configuration
      getIt.registerLazySingleton<core.EnhancedAnalyticsService>(
        () => core.EnhancedAnalyticsService(
          analytics: getIt<core.IAnalyticsRepository>(),
          crashlytics: getIt<core.ICrashlyticsRepository>(),
          config: core.AnalyticsConfig.forApp(
            appId: 'gasometer',
            version: '1.0.0', // TODO: Get from package_info_plus
          ),
        ),
      );

      debugPrint('✅ Core package repositories registered successfully');
    } catch (e) {
      debugPrint('⚠️ Warning: Could not register core repositories: $e');
    }

    // NOTE: Connectivity is now registered by injectable
    // via dependency injection to avoid duplicate registration errors

    // NOTE: SharedPreferences is now registered by injectable via RegisterModule
    // with @preResolve to ensure it's available during DI initialization
  }

  Future<void> _registerCoreServices(GetIt getIt) async {
    // For gasometer, we keep it minimal and leverage the packages/core services
    // Additional gasometer-specific services can be registered here as needed

    debugPrint('✅ GasOMeter core services initialized');
  }
}