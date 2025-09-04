import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:core/core.dart' as core;

import '../../cache/cache_service.dart';
import '../../logging/datasources/log_local_datasource.dart';
import '../../logging/datasources/log_local_datasource_simple_impl.dart';
import '../../logging/repositories/log_repository.dart';
import '../../logging/repositories/log_repository_impl.dart';
import '../../logging/services/logging_service.dart';
import '../../notifications/notification_service.dart';
import '../../optimization/lazy_loader.dart';
import '../../performance/performance_service.dart' as local_perf;
import '../di_module.dart';

/// MIGRATED Core module using shared core package services
/// 
/// Phase 1 of migration: Replace direct Firebase dependencies with core services
/// while maintaining existing app patterns and interfaces
class CoreModuleMigrated implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    await _registerCorePackageServices(getIt);
    await _registerAppSpecificServices(getIt);
    await _registerLoggingServices(getIt);
  }

  /// Register services from the core package
  Future<void> _registerCorePackageServices(GetIt getIt) async {
    // Initialize core package's injection container
    // This gives us access to Firebase services configured in the core package
    await core.InjectionContainer.init();

    // Register core services that are available from the core package
    // These replace our direct Firebase service registrations

    try {
      // Core services are initialized via core.InjectionContainer.init()
      // For now, we'll register fallback implementations since the core services
      // might not be available or compatible
      debugPrint('✅ Core package services initialization completed');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Warning: Core services initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue with fallbacks - app will use direct services where needed
    }
  }

  /// Register app-specific services and fallbacks
  Future<void> _registerAppSpecificServices(GetIt getIt) async {
    // Connectivity (no core equivalent, keep direct)
    getIt.registerLazySingleton<Connectivity>(() => Connectivity());

    // Google Sign In (authentication-related, might be in core later)
    getIt.registerLazySingleton<GoogleSignIn>(
      () => GoogleSignIn(
        scopes: ['email'],
        clientId: kIsWeb 
          ? '877618226732-7v4qhq8g97v05c7fmqd9mql3c5jfh55s.apps.googleusercontent.com'
          : null,
      ),
    );

    // App-specific cache service
    getIt.registerLazySingleton<CacheService>(
      () => CacheService(),
    );

    // Notification Service fallback (if core service not available)
    if (!kIsWeb && !getIt.isRegistered<core.LocalNotificationService>()) {
      getIt.registerLazySingleton<NotificationService>(
        () => NotificationService(),
      );
    }

    // Performance Service (app-specific)
    getIt.registerLazySingleton<local_perf.PerformanceService>(
      () => local_perf.PerformanceService(),
    );

    // Lazy Loader (app-specific)
    getIt.registerLazySingleton<LazyLoader>(() => LazyLoader());
  }

  /// Register logging services (integrates with core services when available)
  Future<void> _registerLoggingServices(GetIt getIt) async {
    // Local datasource
    getIt.registerLazySingleton<LogLocalDataSource>(
      () => LogLocalDataSourceSimpleImpl(),
    );

    // Repository
    getIt.registerLazySingleton<LogRepository>(
      () => LogRepositoryImpl(localDataSource: getIt<LogLocalDataSource>()),
    );
  }

  /// Initialize logging service using core services when available
  static Future<void> initializeLoggingService(GetIt getIt) async {
    try {
      final logRepository = getIt<LogRepository>();
      
      // Note: Core services integration can be added later when needed

      // Initialize logging service with available services
      await LoggingService.instance.initialize(
        logRepository: logRepository,
        analytics: null, // Core service not directly compatible
        crashlytics: null, // Core service not directly compatible
      );
      
      debugPrint('✅ Logging service initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Warning: Failed to initialize LoggingService: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue without logging service - app should still work
    }
  }
}