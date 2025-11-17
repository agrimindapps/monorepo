import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart' as core;
import 'package:core/core.dart' show GetIt, FirebaseAuth, FirebaseFirestore;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../cache/cache_service.dart';
import '../../logging/datasources/log_local_datasource.dart';
import '../../logging/datasources/log_local_datasource_simple_impl.dart';
import '../../logging/repositories/log_repository.dart';
import '../../logging/repositories/log_repository_impl.dart';
import '../../logging/services/logging_service.dart';
import '../../interfaces/logging_service.dart';
import '../../services/logging_service_impl.dart';
import '../../notifications/notification_service.dart';
import '../../performance/lazy_loader.dart';
import '../../performance/performance_service.dart' as local_perf;
import '../../services/auto_sync_service.dart';
import '../../services/mock_analytics_service.dart';
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
    try {
      // Register SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      getIt.registerSingleton<SharedPreferences>(prefs);

      // Register Firebase instances
      getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
      getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
      getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

      getIt.registerLazySingleton<core.IAuthRepository>(
        () => core.FirebaseAuthService(),
      );

      getIt.registerLazySingleton<core.IAnalyticsRepository>(
        () =>
            kDebugMode
                ? MockAnalyticsService()
                : core.FirebaseAnalyticsService(),
      );

      getIt.registerLazySingleton<core.ICrashlyticsRepository>(
        () => core.FirebaseCrashlyticsService(),
      );

      getIt.registerLazySingleton<core.IPerformanceRepository>(
        () => core.PerformanceService(),
      );
      getIt.registerLazySingleton<core.ISubscriptionRepository>(
        () => core.RevenueCatService(),
      );

      debugPrint('✅ Core package repositories registered successfully');
    } catch (e) {
      debugPrint('⚠️ Warning: Could not register core repositories: $e');
    }
    getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  }

  Future<void> _registerCoreServices(GetIt getIt) async {
    getIt.registerLazySingleton<CacheService>(() => CacheService());
    if (!kIsWeb) {
      getIt.registerLazySingleton<NotificationService>(
        () => NotificationService(),
      );
    }
    getIt.registerLazySingleton<local_perf.PerformanceService>(
      () => local_perf.PerformanceService(),
    );
    getIt.registerLazySingleton<LazyLoader>(() => LazyLoader());

    // FASE 2: AutoSyncService singleton
    getIt.registerLazySingleton<AutoSyncService>(
      () => AutoSyncService.instance,
    );
  }

  Future<void> _registerLoggingServices(GetIt getIt) async {
    getIt.registerLazySingleton<LogLocalDataSource>(
      () => LogLocalDataSourceSimpleImpl(),
    );
    getIt.registerLazySingleton<LogRepository>(
      () => LogRepositoryImpl(localDataSource: getIt<LogLocalDataSource>()),
    );
    // FASE 2: Register ILoggingService implementation (DIP)
    getIt.registerLazySingleton<ILoggingService>(
      () => LoggingServiceImpl(
        logRepository: getIt<LogRepository>(),
        analyticsRepository: getIt<core.IAnalyticsRepository>(),
        crashlyticsRepository: getIt<core.ICrashlyticsRepository>(),
      ),
    );
  }

  /// Initialize logging service after all dependencies are registered
  static Future<void> initializeLoggingService(GetIt getIt) async {
    try {
      await LoggingService.instance.initialize(
        logRepository: getIt<LogRepository>(),
        analyticsRepository: getIt<core.IAnalyticsRepository>(),
        crashlyticsRepository: getIt<core.ICrashlyticsRepository>(),
      );
    } catch (e) {
      debugPrint('Warning: Failed to initialize LoggingService: $e');
    }
  }
}
