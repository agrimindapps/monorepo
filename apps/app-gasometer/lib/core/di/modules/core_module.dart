import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

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
    // MIGRATION COMPLETED: Using only core package repositories
    // Removed direct Firebase services to avoid duplication

    // NOTE: FirebaseFirestore and FirebaseAuth are now registered by injectable
    // via RegisterModule to avoid duplicate registration errors
    // They are available via RegisterModule.firestore and RegisterModule.firebaseAuth

    // Core package repositories (standard migration path)
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

      getIt.registerLazySingleton<core.IPerformanceRepository>(
        () => core.PerformanceService(),
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

    // Register core package services needed by Injectable dependencies
    try {
      // Services from core package needed by DeviceManagementModule
      getIt.registerLazySingleton<core.FirebaseDeviceService>(
        () => core.FirebaseDeviceService(),
      );

      // TODO: IDeviceRepository implementation not found in core package
      // DeviceManagementModule expects this but no implementation exists
      // For now, we skip registration and let it fail gracefully if needed

      // FirebaseAuthService - reuse the IAuthRepository instance
      // (IAuthRepository is implemented by FirebaseAuthService)
      getIt.registerLazySingleton<core.FirebaseAuthService>(
        () => getIt<core.IAuthRepository>() as core.FirebaseAuthService,
      );

      // FirebaseAnalyticsService - reuse the IAnalyticsRepository instance
      getIt.registerLazySingleton<core.FirebaseAnalyticsService>(
        () => getIt<core.IAnalyticsRepository>() as core.FirebaseAnalyticsService,
      );

      // Subscription Repository from core package
      getIt.registerLazySingleton<core.ISubscriptionRepository>(
        () => core.RevenueCatService(),
      );

      // DataCleanerService (app-specific singleton)
      getIt.registerLazySingleton<DataCleanerService>(
        () => DataCleanerService.instance,
      );

      debugPrint('✅ Core package services registered for Injectable dependencies');
    } catch (e) {
      debugPrint('⚠️ Warning: Could not register additional core services: $e');
    }

    debugPrint('✅ GasOMeter core services initialized');
  }
}