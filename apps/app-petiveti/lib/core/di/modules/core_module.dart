import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart' as core;
import 'package:core/core.dart' show GetIt;
import 'package:flutter/foundation.dart';

import '../../cache/cache_service.dart';
import '../../logging/datasources/log_local_datasource.dart';
import '../../logging/datasources/log_local_datasource_simple_impl.dart';
import '../../logging/repositories/log_repository.dart';
import '../../logging/repositories/log_repository_impl.dart';
import '../../logging/services/logging_service.dart';
import '../../notifications/notification_service.dart';
import '../../performance/lazy_loader.dart';
import '../../performance/performance_service.dart' as local_perf;
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
    await _registerLoggingServices(getIt);
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

      // Subscription repository from core package
      getIt.registerLazySingleton<core.ISubscriptionRepository>(
        () => core.RevenueCatService(),
      );

      debugPrint('✅ Core package repositories registered successfully');
    } catch (e) {
      debugPrint('⚠️ Warning: Could not register core repositories: $e');
    }

    // NOTE: GoogleSignIn is now registered by injectable via RegisterModule
    // to avoid duplicate registration errors

    // Connectivity (always available)
    getIt.registerLazySingleton<Connectivity>(() => Connectivity());

    // NOTE: SharedPreferences is now registered by injectable via RegisterModule
    // with @preResolve to ensure it's available during DI initialization
  }

  Future<void> _registerCoreServices(GetIt getIt) async {
    // Cache Service
    getIt.registerLazySingleton<CacheService>(() => CacheService());

    // Notification Service - register always except for web
    if (!kIsWeb) {
      getIt.registerLazySingleton<NotificationService>(
        () => NotificationService(),
      );
    }

    // Performance Service
    getIt.registerLazySingleton<local_perf.PerformanceService>(
      () => local_perf.PerformanceService(),
    );

    // Lazy Loader
    getIt.registerLazySingleton<LazyLoader>(() => LazyLoader());
  }

  Future<void> _registerLoggingServices(GetIt getIt) async {
    // Local datasource
    getIt.registerLazySingleton<LogLocalDataSource>(
      () => LogLocalDataSourceSimpleImpl(),
    );

    // Repository
    getIt.registerLazySingleton<LogRepository>(
      () => LogRepositoryImpl(localDataSource: getIt<LogLocalDataSource>()),
    );

    // Logging service initialization will be handled separately
  }

  /// Initialize logging service after all dependencies are registered
  static Future<void> initializeLoggingService(GetIt getIt) async {
    try {
      // Initialize with core repository interfaces
      await LoggingService.instance.initialize(
        logRepository: getIt<LogRepository>(),
        analyticsRepository: getIt<core.IAnalyticsRepository>(),
        crashlyticsRepository: getIt<core.ICrashlyticsRepository>(),
      );
    } catch (e) {
      // If logging service fails to initialize, continue without it
      debugPrint('Warning: Failed to initialize LoggingService: $e');
    }
  }
}
