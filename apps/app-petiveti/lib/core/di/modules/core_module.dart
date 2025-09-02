import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    // Firebase services (skip in web debug)
    if (!kIsWeb || !kDebugMode) {
      // Firebase Core services
      getIt.registerLazySingleton<FirebaseAnalytics>(
        () => FirebaseAnalytics.instance,
      );

      getIt.registerLazySingleton<FirebaseCrashlytics>(
        () => FirebaseCrashlytics.instance,
      );

      getIt.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
      );

      getIt.registerLazySingleton<firebase_auth.FirebaseAuth>(
        () => firebase_auth.FirebaseAuth.instance,
      );

      // Google Sign In
      getIt.registerLazySingleton<GoogleSignIn>(
        () => GoogleSignIn(
          scopes: ['email'],
          clientId: kIsWeb 
            ? '877618226732-7v4qhq8g97v05c7fmqd9mql3c5jfh55s.apps.googleusercontent.com'
            : null,
        ),
      );
    }

    // Connectivity (always available)
    getIt.registerLazySingleton<Connectivity>(() => Connectivity());

    // SharedPreferences (already registered in main init)
    // This is handled in the main initialization
  }

  Future<void> _registerCoreServices(GetIt getIt) async {
    // Cache Service
    getIt.registerLazySingleton<CacheService>(
      () => CacheService(),
    );

    // Notification Service (skip in web debug)
    if (!kIsWeb || !kDebugMode) {
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
      // Skip Firebase services in web debug mode
      if (kIsWeb && kDebugMode) {
        await LoggingService.instance.initialize(
          logRepository: getIt<LogRepository>(),
          analytics: null,
          crashlytics: null,
        );
      } else {
        await LoggingService.instance.initialize(
          logRepository: getIt<LogRepository>(),
          analytics: getIt<FirebaseAnalytics>(),
          crashlytics: getIt<FirebaseCrashlytics>(),
        );
      }
    } catch (e) {
      // If logging service fails to initialize, continue without it
      debugPrint('Warning: Failed to initialize LoggingService: $e');
    }
  }
}