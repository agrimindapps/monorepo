import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../../repositories/license_local_storage.dart';
import '../../../repositories/license_repository.dart';
import '../../../services/license_service.dart';
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
import '../../shared/config/environment_config.dart';
import '../../sync/config/sync_feature_flags.dart';
import '../../sync/factories/sync_service_factory.dart';
import '../../sync/implementations/cache_manager_impl.dart';
import '../../sync/implementations/network_monitor_impl.dart';
import '../../sync/implementations/sync_orchestrator_impl.dart';
import '../../sync/interfaces/i_cache_manager.dart';
import '../../sync/interfaces/i_network_monitor.dart';
import '../../sync/interfaces/i_sync_orchestrator.dart';
import '../services/dio_service.dart';
import '../services/uuid_service.dart';

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
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      getIt.registerLazySingleton<IBoxRegistryService>(
        () => BoxRegistryService(),
      );
      getIt.registerLazySingleton<IAuthRepository>(() => FirebaseAuthService());

      getIt.registerLazySingleton<ICrashlyticsRepository>(
        () => FirebaseCrashlyticsService(),
      );

      getIt.registerLazySingleton<IStorageRepository>(
        () => FirebaseStorageService(),
      );
      getIt.registerLazySingleton<IAnalyticsRepository>(
        () => FirebaseAnalyticsService(),
      );
      if (!kIsWeb) {
        getIt.registerLazySingleton<ILocalStorageRepository>(
          () => HiveStorageService(getIt<IBoxRegistryService>()),
        );
      } else if (kDebugMode) {
        print(
          '⚠️ [Core Package] ILocalStorageRepository skipped on Web platform (Hive limitations)',
        );
      }
      getIt.registerLazySingleton<ISubscriptionRepository>(
        () => RevenueCatService(),
      );
      getIt.registerLazySingleton<UuidService>(() => UuidService());
      getIt.registerLazySingleton<DioService>(() => DioService());
      getIt.registerLazySingleton<LicenseRepository>(
        () => LicenseLocalStorage(),
      );

      getIt.registerLazySingleton<LicenseService>(
        () => LicenseService(getIt<LicenseRepository>()),
      );
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
      _registerSyncServices();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Initialization failed: $e');
      }
      rethrow;
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

  /// Resets all registered services
  ///
  /// Used for testing or when reinitializing the container
  static void reset() {
    getIt.reset();
  }
}
