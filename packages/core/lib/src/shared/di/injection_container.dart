import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../../repositories/license_local_storage.dart';
import '../../../repositories/license_repository.dart';
import '../../../services/license_service.dart';
import '../../domain/interfaces/i_disposable_service.dart';
import '../../domain/repositories/i_analytics_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_crashlytics_repository.dart';
import '../../domain/repositories/i_local_storage_repository.dart';
import '../../domain/repositories/i_storage_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../domain/services/i_box_registry_service.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../infrastructure/services/box_registry_service.dart';
import '../../infrastructure/services/firebase_analytics_service.dart';
import '../../infrastructure/services/firebase_auth_service.dart';
import '../../infrastructure/services/firebase_crashlytics_service.dart';
import '../../infrastructure/services/firebase_storage_service.dart';
import '../../infrastructure/services/hive_storage_service.dart';
import '../../infrastructure/services/revenue_cat_service.dart';
import '../../sync/config/sync_feature_flags.dart';
import '../../sync/factories/sync_service_factory.dart';
import '../../sync/implementations/cache_manager_impl.dart';
import '../../sync/implementations/network_monitor_impl.dart';
import '../../sync/implementations/sync_orchestrator_impl.dart';
import '../../sync/interfaces/i_cache_manager.dart';
import '../../sync/interfaces/i_network_monitor.dart';
import '../../sync/interfaces/i_sync_orchestrator.dart';
import '../../sync/unified_sync_manager.dart';
import '../services/dio_service.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Dependency Injection Container for Core Package
///
/// Manages service registration and dependency resolution for all core services.
/// Services are registered in dependency order to ensure proper initialization.
class InjectionContainer {
  /// Initializes all core services and their dependencies
  ///
  /// Must be called before using any services from the core package.
  /// Throws exception if initialization fails.
  ///
  /// Performance: Services are initialized in parallel groups:
  /// - Group 1: Local services (no Firebase dependency)
  /// - Group 2: Firebase + Firebase-dependent services
  /// - Group 3: Composite services (need both local + Firebase)
  static Future<void> init() async {
    try {
      // Group 1: Register local services (parallel with Firebase init)
      await Future.wait([
        Firebase.initializeApp(),
        _registerLocalServices(),
      ]);

      // Group 2: Register Firebase-dependent services (parallel)
      await _registerFirebaseServices();

      // Group 3: Register composite services (depend on previous groups)
      await _registerCompositeServices();

      // Group 4: Register sync services (feature-flag controlled)
      _registerSyncServices();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Registers services that don't depend on Firebase
  ///
  /// These can initialize in parallel with Firebase initialization
  static Future<void> _registerLocalServices() async {
    getIt.registerLazySingleton<IBoxRegistryService>(
      () => BoxRegistryService(),
    );

    getIt.registerLazySingleton<DioService>(() => DioService());

    getIt.registerLazySingleton<LicenseRepository>(
      () => LicenseLocalStorage(),
    );

    getIt.registerLazySingleton<LicenseService>(
      () => LicenseService(getIt<LicenseRepository>()),
    );

    // Platform-specific: Hive storage (local only)
    if (!kIsWeb) {
      getIt.registerLazySingleton<ILocalStorageRepository>(
        () => HiveStorageService(getIt<IBoxRegistryService>()),
      );
    } else if (kDebugMode) {
      debugPrint(
        '⚠️ [Core Package] ILocalStorageRepository skipped on Web platform (Hive limitations)',
      );
    }

    if (kDebugMode) {
      debugPrint('[InjectionContainer] Local services registered');
    }
  }

  /// Registers Firebase-dependent services
  ///
  /// Called after Firebase.initializeApp() completes
  static Future<void> _registerFirebaseServices() async {
    // Register all Firebase services in parallel (they're independent)
    await Future.wait([
      Future(() {
        getIt.registerLazySingleton<IAuthRepository>(
          () => FirebaseAuthService(),
        );
      }),
      Future(() {
        getIt.registerLazySingleton<ICrashlyticsRepository>(
          () => FirebaseCrashlyticsService(),
        );
      }),
      Future(() {
        getIt.registerLazySingleton<IStorageRepository>(
          () => FirebaseStorageService(),
        );
      }),
      Future(() {
        getIt.registerLazySingleton<IAnalyticsRepository>(
          () => FirebaseAnalyticsService(),
        );
      }),
      Future(() {
        getIt.registerLazySingleton<ISubscriptionRepository>(
          () => RevenueCatService(),
        );
      }),
    ]);

    if (kDebugMode) {
      debugPrint('[InjectionContainer] Firebase services registered');
    }
  }

  /// Registers services that depend on both local and Firebase services
  ///
  /// Called after both local and Firebase services are registered
  static Future<void> _registerCompositeServices() async {
    getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(
        getIt<IAuthRepository>(),
        getIt<IAnalyticsRepository>(),
      ),
    );

    getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(
        getIt<IAuthRepository>(),
        getIt<IAnalyticsRepository>(),
      ),
    );

    if (kDebugMode) {
      debugPrint('[InjectionContainer] Composite services registered');
    }
  }

  /// Registers the new SOLID sync services with feature flag support
  ///
  /// Only registers services if their corresponding feature flags are enabled
  static void _registerSyncServices() {
    final flags = SyncFeatureFlags.instance;

    if (kDebugMode) {
      debugPrint(
        '[InjectionContainer] Sync feature flags: ${flags.getDebugInfo()}',
      );
    }
    if (flags.useNewCacheManager) {
      getIt.registerLazySingleton<ICacheManager>(() => CacheManagerImpl());

      if (kDebugMode) {
        debugPrint('[InjectionContainer] Registered new CacheManager');
      }
    }
    if (flags.useNewNetworkMonitor) {
      getIt.registerLazySingleton<INetworkMonitor>(() => NetworkMonitorImpl());

      if (kDebugMode) {
        debugPrint('[InjectionContainer] Registered new NetworkMonitor');
      }
    }
    if (flags.useNewSyncServiceFactory) {
      getIt.registerLazySingleton<SyncServiceFactory>(
        () => SyncServiceFactory.instance,
      );

      if (kDebugMode) {
        debugPrint('[InjectionContainer] Registered SyncServiceFactory');
      }
    }
    if (flags.useNewSyncOrchestrator &&
        flags.useNewCacheManager &&
        flags.useNewNetworkMonitor) {
      getIt.registerLazySingleton<ISyncOrchestrator>(
        () => SyncOrchestratorImpl(
          cacheManager: getIt<ICacheManager>(),
          networkMonitor: getIt<INetworkMonitor>(),
        ),
      );

      if (kDebugMode) {
        debugPrint('[InjectionContainer] Registered new SyncOrchestrator');
      }
    }
  }

  /// Disposes all disposable services and resets the container
  ///
  /// Should be called on app lifecycle events (e.g., app termination)
  /// to prevent memory leaks from StreamControllers, Timers, etc.
  ///
  /// Usage:
  /// ```dart
  /// // In main.dart
  /// WidgetsBinding.instance.addObserver(
  ///   LifecycleEventHandler(
  ///     detachedCallBack: () async {
  ///       await InjectionContainer.dispose();
  ///     },
  ///   ),
  /// );
  /// ```
  static Future<void> dispose() async {
    try {
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Disposing all services...');
      }

      // Dispose known services that implement IDisposableService
      int disposedCount = 0;

      // Helper to safely dispose a service
      Future<void> tryDispose<T extends Object>() async {
        if (getIt.isRegistered<T>()) {
          try {
            final instance = getIt<T>();
            if (instance is IDisposableService && !instance.isDisposed) {
              if (kDebugMode) {
                debugPrint('[InjectionContainer] Disposing $T');
              }
              await instance.dispose();
              disposedCount++;
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[InjectionContainer] Error disposing $T: $e');
            }
          }
        }
      }

      // Dispose services in parallel
      await Future.wait([
        // Repositories
        tryDispose<ISubscriptionRepository>(),

        // Sync services
        tryDispose<ICacheManager>(),
        tryDispose<INetworkMonitor>(),
        tryDispose<ISyncOrchestrator>(),

        // Add more disposable services here as they're identified
      ]);

      // Dispose singleton services (not registered in GetIt)
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Disposing singleton services...');
      }

      try {
        final syncManager =
            UnifiedSyncManager.instance; // Singleton pattern access
        if (!syncManager.isDisposed) {
          await syncManager.dispose();
          disposedCount++;
          if (kDebugMode) {
            debugPrint('[InjectionContainer] Disposed UnifiedSyncManager');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[InjectionContainer] Error disposing UnifiedSyncManager: $e');
        }
      }

      if (kDebugMode) {
        debugPrint('[InjectionContainer] Disposed $disposedCount services');
      }

      // Reset GetIt container
      await getIt.reset();

      if (kDebugMode) {
        debugPrint('[InjectionContainer] Container reset complete');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Error during disposal: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      // Don't rethrow - disposal should be best-effort
    }
  }

  /// Resets all registered services
  ///
  /// Used for testing or when reinitializing the container
  ///
  /// **Note**: Prefer [dispose] for production cleanup as it properly
  /// disposes resources before resetting.
  static Future<void> reset() async {
    await dispose();
  }
}
